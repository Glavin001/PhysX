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
    imp_6.rotation_err_1 = impactors_0[ii_0].rotation_err_1;
    imp_6.ledger_0 = impactors_0[ii_0].ledger_0;
    imp_6.cand_0 = impactors_0[ii_0].cand_0;
    imp_6.momentum_1 = impactors_0[ii_0].momentum_1;
    imp_6.momentum_err_1 = impactors_0[ii_0].momentum_err_1;
    var _S147 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S147;
    var unused_0 : vec4<f32> = _S147;
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
    impactors_0[ii_0].rotation_err_1 = imp_6.rotation_err_1;
    impactors_0[ii_0].ledger_0 = imp_6.ledger_0;
    impactors_0[ii_0].cand_0 = imp_6.cand_0;
    impactors_0[ii_0].momentum_1 = imp_6.momentum_1;
    impactors_0[ii_0].momentum_err_1 = imp_6.momentum_err_1;
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

fn turn_minus_one_0( axis_4 : vec3<f32>,  angle_1 : f32) -> vec4<f32>
{
    var s_3 : f32 = sin(0.25f * angle_1);
    return vec4<f32>(axis_4 * vec3<f32>(sin(0.5f * angle_1)), -2.0f * s_3 * s_3);
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

fn quat_vec_0( q_12 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_12.x_1, q_12.y_1, q_12.z_0, q_12.w_0);
}

fn comp_add4_0( sum_4 : ptr<function, vec4<f32>>,  err_4 : ptr<function, vec4<f32>>,  x_7 : vec4<f32>)
{
    var t_5 : vec4<f32> = (*sum_4) + x_7;
    var _S155 : vec4<f32> = abs(x_7);
    (*err_4) = (*err_4) + (select(x_7, (*sum_4), (abs((*sum_4))) >= _S155) - t_5 + select((*sum_4), x_7, (abs((*sum_4))) >= _S155));
    (*sum_4) = t_5;
    return;
}

fn quat_accumulate_0( hi_1 : ptr<function, Quat_0>,  lo_1 : ptr<function, vec4<f32>>,  x_8 : vec4<f32>)
{
    var sum_5 : vec4<f32> = quat_vec_0((*hi_1));
    comp_add4_0(&(sum_5), &((*lo_1)), x_8);
    var t_6 : vec4<f32> = sum_5 + (*lo_1);
    (*lo_1) = (*lo_1) - (t_6 - sum_5);
    (*hi_1) = quat_of_0(t_6);
    return;
}

fn turn_left_0( hi_2 : ptr<function, Quat_0>,  lo_2 : ptr<function, vec4<f32>>,  omega_0 : vec3<f32>,  dt_3 : f32)
{
    var _S156 : f32 = length(omega_0);
    var angle_2 : f32 = _S156 * dt_3;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_15 : vec4<f32> = turn_minus_one_0(omega_0 / vec3<f32>(_S156), angle_2);
    var dq_0 : Quat_0;
    dq_0.x_1 = d_15.x;
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
    var _S157 : bool;
    if((imp_7.cand_0.z) != u32(0))
    {
        _S157 = true;
    }
    else
    {
        _S157 = (((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0);
    }
    if(_S157)
    {
        _S157 = true;
    }
    else
    {
        var _S158 : u32 = islands_0[params_0.halt_index_0].info_0.y;
        if(_S158 != u32(0))
        {
            _S157 = (imp_7.cand_0.w) >= _S158;
        }
        else
        {
            _S157 = false;
        }
    }
    if(_S157)
    {
        return;
    }
    var _S159 : vec4<f32> = vec4<f32>(0.0f);
    var rf_0 : vec4<f32> = _S159;
    var rt_0 : vec4<f32> = _S159;
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
        var _S160 : u32 = u32(3) * k_10;
        rf_0 = rf_0 + scratch_0[params_0.cand_base_0 + _S160 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S160 + u32(2)];
        k_10 = k_10 + u32(256);
    }
    group_sum2_0(tid_4, &(rf_0), &(rt_0));
    if(tid_4 != u32(0))
    {
        return;
    }
    var dt_4 : f32 = params_0.dt_0;
    var _S161 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_7, _S161, imp_7.half_1.xyz);
        var _S162 : vec3<f32> = imp_7.velocity_1.xyz + imp_7.velocity_err_1.xyz;
        const _S163 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_7.mat_0.x, ib_0, _S163);
        var _S164 : f32 = imp_7.position_1.z - params_0.ground_hi_0 + (imp_7.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_7.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S165 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
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
            if((_S164 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + u32(1);
            }
            s_4 = s_4 + u32(1);
        }
        s_4 = u32(0);
        load_f_0 = _S161;
        load_t_0 = _S161;
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
            var depth_5 : f32 = - (_S164 + p_10.z);
            if(depth_5 <= 0.0f)
            {
                s_4 = s_4 + u32(1);
                continue;
            }
            var stored_4 : f32;
            var diss_2 : f32;
            var f_3 : vec3<f32> = penalty_force_1(_S165, imp_7.mat_0.z, params_0.ground_friction_0, depth_5, _S163, _S162 + cross(imp_7.angular_velocity_1.xyz, p_10), dt_4, below_0, &(stored_4), &(diss_2));
            var load_f_1 : vec3<f32> = load_f_0 + f_3;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_10, f_3);
            var _S166 : f32 = imp_7.ledger_0[i32(0)];
            var _S167 : f32 = imp_7.ledger_0[i32(1)];
            comp_add1_2(&(_S166), &(_S167), diss_2);
            imp_7.ledger_0[i32(0)] = _S166;
            imp_7.ledger_0[i32(1)] = _S167;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_4 = s_4 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S161;
        load_t_0 = _S161;
    }
    var load_f_2 : vec3<f32> = rf_0.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_2 : f32 = imp_7.mat_0.z;
    var vel_0 : vec3<f32> = imp_7.velocity_1.xyz;
    var vel_err_0 : vec3<f32> = imp_7.velocity_err_1.xyz;
    var _S168 : vec3<f32> = vec3<f32>(dt_4);
    comp_add_0(&(vel_0), &(vel_err_0), (load_f_2 / vec3<f32>(m_2) + params_0.gravity_0.xyz) * _S168);
    var _S169 : Quat_0 = quat_of_0(imp_7.rotation_1);
    var q_13 : Quat_0 = _S169;
    var q_err_0 : vec4<f32> = imp_7.rotation_err_1;
    var l_hi_0 : vec3<f32> = imp_7.momentum_1.xyz;
    var l_err_0 : vec3<f32> = imp_7.momentum_err_1.xyz;
    comp_add_0(&(l_hi_0), &(l_err_0), load_t_2 * _S168);
    var l_1 : vec3<f32> = l_hi_0 + l_err_0;
    var w_mid_0 : vec3<f32> = world_mul_0(_S169, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_1);
    var pos_0 : vec3<f32> = imp_7.position_1.xyz;
    var pos_err_0 : vec3<f32> = imp_7.position_err_1.xyz;
    comp_add_0(&(pos_0), &(pos_err_0), (vel_0 + vel_err_0) * _S168);
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
    const _S170 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S171 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_26, chunks_0[c_9].cmat_0.x, b_26, _S170);
    var _S172 : u32 = sample_count_0(b_26);
    var s_5 : u32 = u32(0);
    var n_8 : u32 = u32(0);
    loop
    {
        if(s_5 < _S172)
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
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    chunk_velocity_1(c_9, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9];
    s_5 = u32(0);
    loop
    {
        if(s_5 < _S172)
        {
        }
        else
        {
            break;
        }
        var p_11 : vec3<f32> = sample_point_0(b_26, s_5);
        var _S173 : f32 = above_0 + p_11.z;
        if(!(_S173 < 0.0f))
        {
            s_5 = s_5 + u32(1);
            continue;
        }
        var stored_5 : f32;
        var diss_3 : f32;
        var g_0 : vec3<f32> = penalty_force_1(_S171 / f32(max(n_8, u32(5))), chunks_0[c_9].center_0.w, params_0.ground_friction_0, - _S173, _S170, vc_1 + cross(wc_1, p_11), params_0.dt_0, n_8, &(stored_5), &(diss_3));
        (*f_4) = (*f_4) + g_0;
        (*t_7) = (*t_7) + cross(p_11, g_0);
        var _S174 : f32 = ledger_2[i32(1)];
        var _S175 : f32 = ledger_2[i32(2)];
        comp_add1_2(&(_S174), &(_S175), diss_3);
        ledger_2[i32(1)] = _S174;
        ledger_2[i32(2)] = _S175;
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
    var t_8 : vec3<f32> = _S180;
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
            ground_contact_0(_S178, true, &(f_5), &(t_8));
            e_2 = e_2 + u32(1);
            continue;
        }
        var _S181 : u32 = u32(2) * entry_1;
        f_5 = f_5 + scratch_0[params_0.slot_base_0 + _S181].xyz;
        t_8 = t_8 + scratch_0[params_0.slot_base_0 + _S181 + u32(1)].xyz;
        e_2 = e_2 + u32(1);
    }
    var _S182 : u32 = u32(2) * g_1;
    scratch_0[params_0.seg_base_0 + _S182] = vec4<f32>(f_5, 0.0f);
    scratch_0[params_0.seg_base_0 + _S182 + u32(1)] = vec4<f32>(t_8, 0.0f);
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
     rotation_err_0 : vec4<f32>,
     momentum_0 : vec4<f32>,
     momentum_err_0 : vec4<f32>,
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
    var _S189 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.torque_0 = _S189;
    rg_0.a_8 = _S189;
    rg_0.alpha_0 = _S189;
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
    var _S190 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.torque_0 = _S190;
    rg_1.a_8 = _S190;
    rg_1.alpha_0 = _S190;
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
                var _S191 : u32 = u32(4) * i_4;
                value_1 = dot(rg_2.vel_1 + rg_2.vel_err_1 + cross(rg_2.w_4, rotate_0(rg_2.rot_0, chunks_0[i_4].center_0.xyz + state_0[_S191].xyz - isl_4.com_0.xyz)) + rotate_0(rg_2.rot_0, state_0[_S191 + u32(2)].xyz), a_9.xyz);
            }
            else
            {
                if(kind_0 == u32(2))
                {
                    var _S192 : u32 = u32(3) * i_4;
                    var f_6 : vec3<f32> = scratch_0[_S192].xyz;
                    var _S193 : bool = (info_2.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S193)
                    {
                        mc_0 = scratch_0[_S192 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S192 + u32(2)].xyz;
                    }
                    var fc_0 : vec3<f32>;
                    if(_S193)
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
                    var _S194 : u32 = u32(4) * i_4;
                    value_1 = dot(rotate_0(rg_2.rot_0, vec3<f32>(state_0[_S194 + u32(1)].w, state_0[_S194 + u32(2)].w, state_0[_S194 + u32(3)].w)), a_9.xyz);
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
        var _S195 : u32 = offset_0 + i_5;
        var b_28 : vec4<f32> = loads_0[_S195];
        var _S196 : f32 = b_28.x;
        if(tau_0 <= _S196)
        {
            var a_10 : vec4<f32> = loads_0[_S195 - u32(1)];
            var _S197 : f32 = a_10.x;
            var _S198 : f32 = a_10.y;
            return _S198 + (tau_0 - _S197) / max(_S196 - _S197, 1.00000000317107685e-30f) * (b_28.y - _S198);
        }
        i_5 = i_5 + u32(1);
    }
    return loads_0[offset_0 + count_2 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_15 : u32,  dt_6 : f32,  shift_0 : f32) -> f32
{
    var _S199 : u32 = u32(5) * term_0;
    var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S199])));
    var origin_1 : vec4<f32> = loads_0[_S199 + u32(3)];
    var p_12 : vec4<f32> = loads_0[_S199 + u32(4)];
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
            var _S200 : f32 = p_12.x;
            if(tau_1 >= _S200)
            {
                shape_1 = p_12.y;
            }
            else
            {
                shape_1 = p_12.y * tau_1 / _S200;
            }
        }
        return shape_1;
    }
    var _S201 : bool;
    if(kind_1 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S201 = true;
        }
        else
        {
            _S201 = tau_1 > (p_12.x);
        }
        if(_S201)
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
            _S201 = true;
        }
        else
        {
            _S201 = sn_0 > 1.0f;
        }
        if(_S201)
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
            _S201 = true;
        }
        else
        {
            _S201 = sn_1 > 1.0f;
        }
        if(_S201)
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
        var _S202 : f32 = p_12.w;
        return (_S202 + (p_12.z - _S202) * relax_0) * shape_1;
    }
    if(kind_1 == u32(7))
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var _S203 : f32 = p_12.y;
        if(tau_1 < _S203)
        {
            return p_12.x;
        }
        var s_6 : f32 = tau_1 - _S203;
        var _S204 : f32 = p_12.w;
        if(s_6 > _S204)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.z * sin(3.14159274101257324f * s_6 / _S204);
        }
        return shape_1;
    }
    var _S205 : f32 = p_12.x;
    if(_S205 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S205, 0.0f, 1.0f);
}

fn record_chunk_load_0( c_10 : u32,  f_7 : vec3<f32>,  t_9 : vec3<f32>)
{
    if((params_0.solve_mode_0) == u32(0))
    {
        return;
    }
    var _S206 : u32 = u32(2) * c_10;
    scratch_0[params_0.cload_base_0 + _S206] = vec4<f32>(f_7, 0.0f);
    scratch_0[params_0.cload_base_0 + _S206 + u32(1)] = vec4<f32>(t_9, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S206] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S206].xyz + f_7, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S206 + u32(1)] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S206 + u32(1)].xyz + t_9, 0.0f);
    return;
}

fn chunk_external_0( _S207 : u32,  _S208 : u32,  _S209 : Quat_0,  _S210 : u32,  _S211 : f32,  _S212 : bool,  _S213 : ptr<function, vec3<f32>>,  _S214 : ptr<function, vec3<f32>>)
{
    var _S215 : bool;
    var _S216 : vec3<f32> = vec3<f32>(0.0f);
    (*_S213) = _S216;
    (*_S214) = _S216;
    var _S217 : vec4<u32> = chunks_0[_S208].load_range_0;
    var term_1 : u32 = chunks_0[_S208].load_range_0.x;
    loop
    {
        if(term_1 < (_S217.y))
        {
        }
        else
        {
            break;
        }
        var _S218 : u32 = u32(5) * term_1;
        var _S219 : u32 = (bitcast<vec4<u32>>((loads_0[_S218]))).y;
        if(_S219 == u32(2))
        {
            term_1 = term_1 + u32(1);
            continue;
        }
        var dir_1 : vec4<f32> = loads_0[_S218 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S218 + u32(2)];
        var value_2 : f32 = eval_function_0(term_1, _S210, _S211, 0.0f);
        if(_S219 == u32(0))
        {
            _S215 = true;
        }
        else
        {
            _S215 = _S219 == u32(3);
        }
        var fw_0 : vec3<f32>;
        if(_S215)
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_2);
        }
        else
        {
            fw_0 = rotate_0(_S209, dir_1.xyz) * vec3<f32>((- value_2 * dir_1.w));
        }
        var lever_0 : vec3<f32>;
        if(_S219 == u32(3))
        {
            lever_0 = arm_0.xyz - state_0[u32(4) * _S207].xyz;
        }
        else
        {
            lever_0 = arm_0.xyz;
        }
        (*_S213) = (*_S213) + fw_0;
        (*_S214) = (*_S214) + cross(rotate_0(_S209, lever_0), fw_0);
        term_1 = term_1 + u32(1);
    }
    if(_S212)
    {
        _S215 = (chunks_0[_S208].cinfo_0.z) != u32(0);
    }
    else
    {
        _S215 = false;
    }
    if(_S215)
    {
        var _S220 : vec4<u32> = chunks_0[_S208].cinfo_0;
        var g_2 : u32 = chunks_0[_S208].cinfo_0.x;
        loop
        {
            if(g_2 < (_S220.y))
            {
            }
            else
            {
                break;
            }
            var _S221 : u32 = u32(2) * g_2;
            (*_S213) = (*_S213) + scratch_0[params_0.seg_base_0 + _S221].xyz;
            (*_S214) = (*_S214) + scratch_0[params_0.seg_base_0 + _S221 + u32(1)].xyz;
            g_2 = g_2 + u32(1);
        }
    }
    return;
}

fn settled_chunk_load_0( c_11 : u32,  rot_1 : Quat_0,  k_16 : u32,  dt_7 : f32,  contact_0 : bool) -> f32
{
    var f_8 : vec3<f32>;
    var t_10 : vec3<f32>;
    chunk_external_0(c_11, c_11, rot_1, k_16, dt_7, contact_0, &(f_8), &(t_10));
    record_chunk_load_0(c_11, f_8, t_10);
    return length(f_8);
}

fn chunk_external_1( _S222 : u32,  _S223 : u32,  _S224 : Quat_0,  _S225 : u32,  _S226 : f32,  _S227 : bool,  _S228 : ptr<function, vec3<f32>>,  _S229 : ptr<function, vec3<f32>>)
{
    var _S230 : bool;
    var _S231 : vec3<f32> = vec3<f32>(0.0f);
    (*_S228) = _S231;
    (*_S229) = _S231;
    var _S232 : vec4<u32> = chunks_0[_S223].load_range_0;
    var term_2 : u32 = chunks_0[_S223].load_range_0.x;
    loop
    {
        if(term_2 < (_S232.y))
        {
        }
        else
        {
            break;
        }
        var _S233 : u32 = u32(5) * term_2;
        var _S234 : u32 = (bitcast<vec4<u32>>((loads_0[_S233]))).y;
        if(_S234 == u32(2))
        {
            term_2 = term_2 + u32(1);
            continue;
        }
        var dir_2 : vec4<f32> = loads_0[_S233 + u32(1)];
        var arm_1 : vec4<f32> = loads_0[_S233 + u32(2)];
        var value_3 : f32 = eval_function_0(term_2, _S225, _S226, 0.0f);
        if(_S234 == u32(0))
        {
            _S230 = true;
        }
        else
        {
            _S230 = _S234 == u32(3);
        }
        var fw_1 : vec3<f32>;
        if(_S230)
        {
            fw_1 = dir_2.xyz * vec3<f32>(value_3);
        }
        else
        {
            fw_1 = rotate_0(_S224, dir_2.xyz) * vec3<f32>((- value_3 * dir_2.w));
        }
        var lever_1 : vec3<f32>;
        if(_S234 == u32(3))
        {
            lever_1 = arm_1.xyz - state_0[u32(4) * _S222].xyz;
        }
        else
        {
            lever_1 = arm_1.xyz;
        }
        (*_S228) = (*_S228) + fw_1;
        (*_S229) = (*_S229) + cross(rotate_0(_S224, lever_1), fw_1);
        term_2 = term_2 + u32(1);
    }
    if(_S227)
    {
        _S230 = (chunks_0[_S223].cinfo_0.z) != u32(0);
    }
    else
    {
        _S230 = false;
    }
    if(_S230)
    {
        var _S235 : vec4<u32> = chunks_0[_S223].cinfo_0;
        var g_3 : u32 = chunks_0[_S223].cinfo_0.x;
        loop
        {
            if(g_3 < (_S235.y))
            {
            }
            else
            {
                break;
            }
            var _S236 : u32 = u32(2) * g_3;
            (*_S228) = (*_S228) + scratch_0[params_0.seg_base_0 + _S236].xyz;
            (*_S229) = (*_S229) + scratch_0[params_0.seg_base_0 + _S236 + u32(1)].xyz;
            g_3 = g_3 + u32(1);
        }
    }
    return;
}

fn net_load_0( c_12 : u32,  isl_5 : ptr<function, Island_std430_0>,  rg_3 : Rigid_0,  k_17 : u32,  dt_8 : f32,  contact_1 : bool,  f_9 : ptr<function, vec3<f32>>,  t_11 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    chunk_external_1(c_12, c_12, rg_3.rot_0, k_17, dt_8, contact_1, &(fl_0), &(tl_0));
    var fc_1 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_12].center_0.w);
    var _S237 : vec3<f32> = chunks_0[c_12].center_0.xyz;
    var _S238 : vec3<f32> = (*isl_5).com_0.xyz;
    var r_6 : vec3<f32> = rotate_0(rg_3.rot_0, _S237 + state_0[u32(4) * c_12].xyz - _S238);
    (*f_9) = (*f_9) + fc_1;
    (*t_11) = (*t_11) + (cross(r_6, fc_1) + tl_0);
    var _S239 : vec4<u32> = chunks_0[c_12].load_range_0;
    var term_3 : u32 = chunks_0[c_12].load_range_0.x;
    loop
    {
        if(term_3 < (_S239.y))
        {
        }
        else
        {
            break;
        }
        var _S240 : u32 = u32(5) * term_3;
        if(((bitcast<vec4<u32>>((loads_0[_S240]))).y) != u32(2))
        {
            term_3 = term_3 + u32(1);
            continue;
        }
        var _S241 : vec3<f32> = vec3<f32>(eval_function_0(term_3, k_17, dt_8, 0.0f));
        var fw_2 : vec3<f32> = rotate_0(rg_3.rot_0, loads_0[_S240 + u32(1)].xyz * _S241);
        (*f_9) = (*f_9) + fw_2;
        (*t_11) = (*t_11) + (cross(rotate_0(rg_3.rot_0, _S237 - _S238), fw_2) + rotate_0(rg_3.rot_0, loads_0[_S240 + u32(2)].xyz * _S241));
        term_3 = term_3 + u32(1);
    }
    return;
}

fn net_load_1( c_13 : u32,  isl_6 : Island_0,  rg_4 : Rigid_0,  k_18 : u32,  dt_9 : f32,  contact_2 : bool,  f_10 : ptr<function, vec3<f32>>,  t_12 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    chunk_external_1(c_13, c_13, rg_4.rot_0, k_18, dt_9, contact_2, &(fl_1), &(tl_1));
    var fc_2 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_13].center_0.w);
    var _S242 : vec3<f32> = chunks_0[c_13].center_0.xyz;
    var _S243 : vec3<f32> = isl_6.com_0.xyz;
    var r_7 : vec3<f32> = rotate_0(rg_4.rot_0, _S242 + state_0[u32(4) * c_13].xyz - _S243);
    (*f_10) = (*f_10) + fc_2;
    (*t_12) = (*t_12) + (cross(r_7, fc_2) + tl_1);
    var _S244 : vec4<u32> = chunks_0[c_13].load_range_0;
    var term_4 : u32 = chunks_0[c_13].load_range_0.x;
    loop
    {
        if(term_4 < (_S244.y))
        {
        }
        else
        {
            break;
        }
        var _S245 : u32 = u32(5) * term_4;
        if(((bitcast<vec4<u32>>((loads_0[_S245]))).y) != u32(2))
        {
            term_4 = term_4 + u32(1);
            continue;
        }
        var _S246 : vec3<f32> = vec3<f32>(eval_function_0(term_4, k_18, dt_9, 0.0f));
        var fw_3 : vec3<f32> = rotate_0(rg_4.rot_0, loads_0[_S245 + u32(1)].xyz * _S246);
        (*f_10) = (*f_10) + fw_3;
        (*t_12) = (*t_12) + (cross(rotate_0(rg_4.rot_0, _S242 - _S243), fw_3) + rotate_0(rg_4.rot_0, loads_0[_S245 + u32(2)].xyz * _S246));
        term_4 = term_4 + u32(1);
    }
    return;
}

fn rigid_acceleration_0( isl_7 : ptr<function, Island_std430_0>,  rg_5 : ptr<function, Rigid_0>,  f_11 : vec3<f32>,  t_13 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_5).rot_0, (*isl_7).inertia0_0, (*isl_7).inertia1_0, (*isl_7).inertia2_0, (*rg_5).w_4);
    (*rg_5).a_8 = f_11 / vec3<f32>((*isl_7).com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_0, (*isl_7).inv0_0, (*isl_7).inv1_0, (*isl_7).inv2_0, t_13 - cross((*rg_5).w_4, iw_w_0));
    (*rg_5).torque_0 = t_13;
    return;
}

fn rigid_acceleration_1( isl_8 : Island_0,  rg_6 : ptr<function, Rigid_0>,  f_12 : vec3<f32>,  t_14 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_6).rot_0, isl_8.inertia0_0, isl_8.inertia1_0, isl_8.inertia2_0, (*rg_6).w_4);
    (*rg_6).a_8 = f_12 / vec3<f32>(isl_8.com_0.w);
    (*rg_6).alpha_0 = world_mul_0((*rg_6).rot_0, isl_8.inv0_0, isl_8.inv1_0, isl_8.inv2_0, t_14 - cross((*rg_6).w_4, iw_w_1));
    (*rg_6).torque_0 = t_14;
    return;
}

fn turn_difference_0( omega_1 : vec3<f32>,  dt_10 : f32,  v_9 : vec3<f32>) -> vec3<f32>
{
    var _S247 : f32 = length(omega_1);
    var angle_3 : f32 = _S247 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return vec3<f32>(0.0f);
    }
    var a_11 : vec3<f32> = omega_1 / vec3<f32>(_S247);
    var s_7 : f32 = sin(0.5f * angle_3);
    var av_0 : vec3<f32> = cross(a_11, v_9);
    return av_0 * vec3<f32>(sin(angle_3)) + cross(a_11, av_0) * vec3<f32>((2.0f * s_7 * s_7));
}

fn integrate_rigid_0( isl_9 : ptr<function, Island_std430_0>,  rg_7 : ptr<function, Rigid_0>,  dt_11 : f32)
{
    var _S248 : vec3<f32> = vec3<f32>(dt_11);
    var _S249 : vec3<f32> = (*rg_7).torque_0 * _S248;
    var _S250 : vec3<f32> = (*rg_7).l_2;
    var _S251 : vec3<f32> = (*rg_7).l_err_1;
    comp_add_0(&(_S250), &(_S251), _S249);
    (*rg_7).l_2 = _S250;
    (*rg_7).l_err_1 = _S251;
    var l_3 : vec3<f32> = _S250 + _S251;
    var _S252 : vec3<f32> = (*rg_7).a_8 * _S248;
    var _S253 : vec3<f32> = (*rg_7).vel_1;
    var _S254 : vec3<f32> = (*rg_7).vel_err_1;
    comp_add_0(&(_S253), &(_S254), _S252);
    (*rg_7).vel_1 = _S253;
    (*rg_7).vel_err_1 = _S254;
    var _S255 : vec4<f32> = (*isl_9).inv0_0;
    var _S256 : vec4<f32> = (*isl_9).inv1_0;
    var _S257 : vec4<f32> = (*isl_9).inv2_0;
    var w_mid_1 : vec3<f32> = world_mul_0((*rg_7).rot_0, (*isl_9).inv0_0, (*isl_9).inv1_0, (*isl_9).inv2_0, l_3);
    var delta_0 : vec3<f32> = (_S253 + _S254) * _S248 - turn_difference_0(w_mid_1, dt_11, rotate_0((*rg_7).rot_0, (*isl_9).com_0.xyz));
    var _S258 : vec3<f32> = (*rg_7).pos_1;
    var _S259 : vec3<f32> = (*rg_7).pos_err_1;
    comp_add_0(&(_S258), &(_S259), delta_0);
    (*rg_7).pos_1 = _S258;
    (*rg_7).pos_err_1 = _S259;
    var _S260 : Quat_0 = (*rg_7).rot_0;
    var _S261 : vec4<f32> = (*rg_7).rot_err_0;
    turn_left_0(&(_S260), &(_S261), w_mid_1, dt_11);
    (*rg_7).rot_0 = _S260;
    (*rg_7).rot_err_0 = _S261;
    (*rg_7).w_4 = world_mul_0(_S260, _S255, _S256, _S257, l_3);
    return;
}

fn integrate_rigid_1( isl_10 : Island_0,  rg_8 : ptr<function, Rigid_0>,  dt_12 : f32)
{
    var _S262 : vec3<f32> = vec3<f32>(dt_12);
    var _S263 : vec3<f32> = (*rg_8).torque_0 * _S262;
    var _S264 : vec3<f32> = (*rg_8).l_2;
    var _S265 : vec3<f32> = (*rg_8).l_err_1;
    comp_add_0(&(_S264), &(_S265), _S263);
    (*rg_8).l_2 = _S264;
    (*rg_8).l_err_1 = _S265;
    var l_4 : vec3<f32> = _S264 + _S265;
    var _S266 : vec3<f32> = (*rg_8).a_8 * _S262;
    var _S267 : vec3<f32> = (*rg_8).vel_1;
    var _S268 : vec3<f32> = (*rg_8).vel_err_1;
    comp_add_0(&(_S267), &(_S268), _S266);
    (*rg_8).vel_1 = _S267;
    (*rg_8).vel_err_1 = _S268;
    var w_mid_2 : vec3<f32> = world_mul_0((*rg_8).rot_0, isl_10.inv0_0, isl_10.inv1_0, isl_10.inv2_0, l_4);
    var delta_1 : vec3<f32> = (_S267 + _S268) * _S262 - turn_difference_0(w_mid_2, dt_12, rotate_0((*rg_8).rot_0, isl_10.com_0.xyz));
    var _S269 : vec3<f32> = (*rg_8).pos_1;
    var _S270 : vec3<f32> = (*rg_8).pos_err_1;
    comp_add_0(&(_S269), &(_S270), delta_1);
    (*rg_8).pos_1 = _S269;
    (*rg_8).pos_err_1 = _S270;
    var _S271 : Quat_0 = (*rg_8).rot_0;
    var _S272 : vec4<f32> = (*rg_8).rot_err_0;
    turn_left_0(&(_S271), &(_S272), w_mid_2, dt_12);
    (*rg_8).rot_0 = _S271;
    (*rg_8).rot_err_0 = _S272;
    (*rg_8).w_4 = world_mul_0(_S271, isl_10.inv0_0, isl_10.inv1_0, isl_10.inv2_0, l_4);
    return;
}

fn connected_0( st_0 : ptr<function, JointState_std430_0>,  has_rebar_0 : bool) -> bool
{
    var _S273 : bool;
    if(((*st_0).damage_0) < 1.0f)
    {
        _S273 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S273 = ((*st_0).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S273 = false;
        }
    }
    return _S273;
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

fn connected_1( st_1 : JointState_0,  has_rebar_1 : bool) -> bool
{
    var _S274 : bool;
    if((st_1.damage_0) < 1.0f)
    {
        _S274 = true;
    }
    else
    {
        if(has_rebar_1)
        {
            _S274 = (st_1.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S274 = false;
        }
    }
    return _S274;
}

fn fdiv_0( a_12 : f32,  b_29 : f32) -> f32
{
    return a_12 / b_29;
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

fn stress_measures_0( b_30 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_2 : f32 = (*b_30).geom0_0.x;
    var _S275 : f32 = q_lin_0.z;
    var axial_0 : f32 = fdiv_0(_S275, area_2);
    var bending_0 : f32 = fdiv_0(abs(q_ang_0.x), (*b_30).geom1_0.x) + fdiv_0(abs(q_ang_0.y), (*b_30).geom1_0.y);
    var _S276 : f32 = q_lin_0.x;
    var _S277 : f32 = q_lin_0.y;
    var shear_1 : f32 = fdiv_0(fsqrt_0(_S276 * _S276 + _S277 * _S277), area_2) + fdiv_0(abs(q_ang_0.z), (*b_30).geom0_0.w);
    var m_3 : Measures_0;
    m_3.tension_0 = axial_0 + bending_0;
    m_3.shear_0 = shear_1;
    var _S278 : f32 = - axial_0;
    m_3.normal_compression_0 = max(_S278, 0.0f);
    m_3.compression_0 = _S278 + bending_0;
    m_3.compressive_force_0 = max(- _S275, 0.0f);
    return m_3;
}

fn expm1_accurate_0( x_9 : f32) -> f32
{
    if((abs(x_9)) < 0.00100000004749745f)
    {
        return x_9 * (1.0f + x_9 * (0.5f + x_9 * 0.1666666716337204f));
    }
    return exp(x_9) - 1.0f;
}

fn fpow_0( a_14 : f32,  b_31 : f32) -> f32
{
    return pow(a_14, b_31);
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_8 : f32 = abs(strain_rate_1);
    var _S279 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_8 <= ref_0)
    {
        return 1.0f;
    }
    var _S280 : f32 = _S279.z;
    var f_13 : f32;
    if(r_8 <= _S280)
    {
        f_13 = fpow_0(fdiv_0(r_8, ref_0), _S279.y);
    }
    else
    {
        f_13 = fpow_0(fdiv_0(_S280, ref_0), _S279.y) * fpow_0(fdiv_0(r_8, _S280), _S279.w);
    }
    return clamp(f_13, 1.0f, (*mat_1).misc_0.x);
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

fn failure_indices_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_32 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_3 : f32 = (*mat_4).strength_0.y * multiplier_0;
    var _S281 : f32 = min((*mat_4).strength_0.z * multiplier_0 + (*mat_4).strength_0.w * m_4.normal_compression_0, (*mat_4).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(fdiv_0(m_4.tension_0, (*mat_4).strength_0.x * multiplier_0), 0.0f);
    var _S282 : f32;
    if(_S281 > 0.0f)
    {
        _S282 = fdiv_0(m_4.shear_0, _S281);
    }
    else
    {
        _S282 = infinity_0();
    }
    idx_0[i32(1)] = _S282;
    idx_0[i32(2)] = max(fdiv_0(m_4.compression_0, fc_3), 0.0f);
    var _S283 : f32 = (*b_32).stiff1_0.y;
    if(_S283 > 0.0f)
    {
        _S282 = fdiv_0(m_4.compressive_force_0, _S283);
    }
    else
    {
        _S282 = 0.0f;
    }
    idx_0[i32(3)] = _S282;
    return idx_0;
}

fn sq_0( x_10 : f32) -> f32
{
    return x_10 * x_10;
}

fn damage_law_0( kind_2 : u32,  kappa_1 : f32,  r_9 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == u32(0))
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

fn damage_increment_0( kind_3 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_10 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S284 : f32 = max(damage_law_0(kind_3, lambda_0, r_10), d_old_0);
    var _S285 : bool;
    if(_S284 <= d_old_0)
    {
        _S285 = true;
    }
    else
    {
        _S285 = d_old_0 >= 1.0f;
    }
    if(_S285)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = fdiv_0(psi_0, lambda_0 * lambda_0);
    var _S286 : f32 = max(kappa_old_0, 1.0f);
    if(kind_3 == u32(0))
    {
        if(r_10 > 1.0f)
        {
            return vec2<f32>(_S284, fdiv_0(u0_0 * r_10, r_10 - 1.0f) * max(min(lambda_0, r_10) - min(_S286, r_10), 0.0f));
        }
        return vec2<f32>(_S284, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_10 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S286, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S284 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S284, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_3 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S287 : f32 = - h0_0;
    var _S288 : f32 = - h1_0;
    var _S289 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S287, _S288), vec2<f32>(h0_0, _S288), vec2<f32>(h0_0, h1_0), vec2<f32>(_S287, h1_0) );
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
        var _S290 : u32 = i_6;
        var _S291 : u32 = i_6 + u32(1);
        var _S292 : u32 = _S291 % u32(4);
        var _S293 : f32 = _S289[i_6].y;
        var _S294 : f32 = _S289[i_6].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S293 - ay_0 * _S294;
        var _S295 : f32 = _S289[_S292].y;
        var _S296 : f32 = _S289[_S292].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S295 - ay_0 * _S296;
        var _S297 : bool = fp_0 < 0.0f;
        if(_S297)
        {
            var _S298 : u32 = count_4 + u32(1);
            poly_0[count_4] = _S289[_S290];
            count_3 = _S298;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S297 != (fq_0 < 0.0f))
        {
            var t_15 : f32 = fp_0 / (fp_0 - fq_0);
            var _S299 : u32 = count_3 + u32(1);
            poly_0[count_3] = vec2<f32>(_S294 + t_15 * (_S296 - _S294), _S293 + t_15 * (_S295 - _S293));
            count_4 = _S299;
        }
        else
        {
            count_4 = count_3;
        }
        i_6 = _S291;
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
    var a_15 : f32 = 0.0f;
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
        var _S300 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_6].x - _S300;
        var _S301 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_6].y - _S301;
        var _S302 : u32 = i_6 + u32(1);
        var _S303 : u32 = _S302 % count_4;
        var x1_0 : f32 = poly_0[_S303].x - _S300;
        var y1_0 : f32 = poly_0[_S303].y - _S301;
        var _S304 : f32 = x0_0 * y1_0;
        var _S305 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S304 - _S305;
        var a_16 : f32 = a_15 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S304 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S305) * cr_0 / 24.0f;
        i_6 = _S302;
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
    var _S306 : f32 = a_15 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S306 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_15 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S306 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_11 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_11));
    var a_17 : f32 = r_11[i32(0)];
    if((r_11[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_19 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_4 : f32 = dz_1 + ax_1 * r_11[i32(2)] - ay_1 * r_11[i32(1)];
    var _S307 : f32 = a_17 * fc_4;
    var _S308 : f32 = - ay_1;
    return vec4<f32>(k_19 * a_17 * fc_4, k_19 * (_S307 * r_11[i32(2)] + (_S308 * r_11[i32(5)] + ax_1 * r_11[i32(4)])), - k_19 * (_S307 * r_11[i32(1)] + (_S308 * r_11[i32(3)] + ax_1 * r_11[i32(5)])), 0.5f * k_19 * (_S307 * fc_4 + ay_1 * ay_1 * r_11[i32(3)] + ax_1 * ax_1 * r_11[i32(4)] - 2.0f * ax_1 * ay_1 * r_11[i32(5)]));
}

fn signum_0( x_11 : f32) -> f32
{
    var _S309 : f32;
    if((((bitcast<u32>((x_11))) & (u32(2147483648)))) != u32(0))
    {
        _S309 = -1.0f;
    }
    else
    {
        _S309 = 1.0f;
    }
    return _S309;
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
    var _S310 : vec3<f32> = vec3<f32>(0.0f);
    c_14.q_lin_1 = _S310;
    c_14.q_ang_1 = _S310;
    c_14.energy_2 = 0.0f;
    c_14.diss_4 = 0.0f;
    c_14.plastic_1 = plastic_2;
    var _S311 : u32 = (*mat_5).kind_flags_0.y;
    if(((_S311 & (u32(2)))) == u32(0))
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
    if(((_S311 & (u32(4)))) != u32(0))
    {
        var p_13 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S312 : f32 = p_13.y;
        var _S313 : f32 = p_13.z;
        var _S314 : f32 = p_13.w;
        nc_sum_0 = p_13.x;
        m1_0 = _S312;
        m2_0 = _S313;
        energy_3 = _S314;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S315 : f32 = d_ang_0.x;
        var _S316 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S315) * 0.4166666567325592f * w1_2 + abs(_S316) * 0.4166666567325592f * w0_2;
        var _S317 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S317) + spread_0);
        if((_S317 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S317 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S318 : f32 = ki_0 * _S315 * i2_0;
                var _S319 : f32 = ki_0 * _S316 * i1_0;
                var _S320 : f32 = 0.5f * ki_0 * (36.0f * _S317 * _S317 + _S315 * _S315 * i2_0 + _S316 * _S316 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S317;
                m1_0 = _S318;
                m2_0 = _S319;
                energy_3 = _S320;
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
                    var _S321 : f32 = SPRING_AT_0[i_7] * w0_2;
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
                        var di_0 : f32 = _S317 + _S315 * s2_0 - _S316 * _S321;
                        if(di_0 < 0.0f)
                        {
                            var f_15 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_15 * s2_0;
                            var m2_2 : f32 = m2_0 - f_15 * _S321;
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
    var _S322 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S323 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var tn_0 : f32 = fsqrt_0(_S322 * _S322 + _S323 * _S323);
    var _S324 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S324 = tn_0 > 0.0f;
    }
    else
    {
        _S324 = false;
    }
    if(_S324)
    {
        var _S325 : f32 = fdiv_0(_S322, tn_0);
        var _S326 : f32 = fdiv_0(_S323, tn_0);
        var dslip_0 : f32 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        p_14[i32(0)] = p_14[i32(0)] + _S325 * dslip_0;
        p_14[i32(1)] = p_14[i32(1)] + _S326 * dslip_0;
        c_14.q_lin_1[i32(0)] = _S325 * slide_cap_0;
        c_14.q_lin_1[i32(1)] = _S326 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_14.q_lin_1[i32(0)] = _S322;
        c_14.q_lin_1[i32(1)] = _S323;
        diss_5 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_14.z, slide_cap_0 * (*b_33).geom1_0.z);
    var _S327 : f32 = tq_0.x;
    var _S328 : f32 = tq_0.y;
    var diss_6 : f32 = diss_5 + abs(_S327) * abs(_S328);
    p_14[i32(2)] = p_14[i32(2)] + _S328;
    c_14.q_ang_1[i32(2)] = _S327;
    c_14.energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0(c_14.q_lin_1.x), ks_0) + fdiv_0(sq_0(c_14.q_lin_1.y), ks_0) + fdiv_0(sq_0(_S327), kt_0));
    c_14.diss_4 = diss_6;
    c_14.plastic_1 = p_14;
    return c_14;
}

fn contact_offsets_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_34 : ptr<function, JointBond_std430_0>,  crush_3 : f32,  plastic_3 : vec3<f32>,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>) -> vec3<f32>
{
    var _S329 : u32 = (*mat_6).kind_flags_0.y;
    if(((_S329 & (u32(2)))) == u32(0))
    {
        return plastic_3;
    }
    var kn_2 : f32 = (*b_34).stiff0_0.x;
    var ks_1 : f32 = (*b_34).stiff0_0.y;
    var kt_1 : f32 = (*b_34).stiff1_0.x;
    var w0_3 : f32 = (*b_34).geom0_0.y;
    var w1_3 : f32 = (*b_34).geom0_0.z;
    var nc_sum_1 : f32;
    if(((_S329 & (u32(4)))) != u32(0))
    {
        var _S330 : vec4<f32> = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S330.x;
    }
    else
    {
        var ki_1 : f32 = kn_2 * (1.0f - crush_3) / 36.0f;
        var _S331 : f32 = d_ang_1.x;
        var _S332 : f32 = d_ang_1.y;
        var spread_1 : f32 = abs(_S331) * 0.4166666567325592f * w1_3 + abs(_S332) * 0.4166666567325592f * w0_3;
        var _S333 : f32 = d_lin_1.z;
        var slack_1 : f32 = 9.99999997475242708e-07f * (abs(_S333) + spread_1);
        if((_S333 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S333 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S333;
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
                    var _S334 : f32 = SPRING_AT_0[i_8] * w0_3;
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
                        var di_1 : f32 = _S333 + _S331 * (SPRING_AT_0[j_6] * w1_3) - _S332 * _S334;
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
    var _S335 : f32 = ks_1 * (d_lin_1.x - plastic_3.x);
    var _S336 : f32 = ks_1 * (d_lin_1.y - plastic_3.y);
    var tn_1 : f32 = fsqrt_0(_S335 * _S335 + _S336 * _S336);
    var _S337 : bool;
    if(tn_1 > slide_cap_1)
    {
        _S337 = tn_1 > 0.0f;
    }
    else
    {
        _S337 = false;
    }
    if(_S337)
    {
        var _S338 : f32 = fdiv_0(_S336, tn_1);
        var dslip_1 : f32 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        p_15[i32(0)] = p_15[i32(0)] + fdiv_0(_S335, tn_1) * dslip_1;
        p_15[i32(1)] = p_15[i32(1)] + _S338 * dslip_1;
    }
    p_15[i32(2)] = p_15[i32(2)] + return_map_0(kt_1, d_ang_1.z, p_15.z, slide_cap_1 * (*b_34).geom1_0.z).y;
    return p_15;
}

fn life_rate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  s_8 : f32) -> f32
{
    if(s_8 <= 0.0f)
    {
        return 0.0f;
    }
    var _S339 : f32 = (*mat_7).misc_0.y;
    return fdiv_0((_S339 + 1.0f) * fpow_0(s_8, _S339), (*mat_7).misc_0.z);
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

fn joint_evaluate_0( mat_8 : ptr<function, JointMaterial_std140_0>,  b_35 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_2 : vec3<f32>,  d_ang_2 : vec3<f32>,  dt_13 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_3 : f32 = (*b_35).stiff0_0.x;
    var ks_2 : f32 = (*b_35).stiff0_0.y;
    var kb1_0 : f32 = (*b_35).stiff0_0.z;
    var kb2_0 : f32 = (*b_35).stiff0_0.w;
    var _S340 : vec4<f32> = (*b_35).stiff1_0;
    var kt_2 : f32 = (*b_35).stiff1_0.x;
    var has_rebar_2 : bool = ((*b_35).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_8).kind_flags_0.x;
    var flags_1 : u32 = (*mat_8).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_2 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_1(state_2, has_rebar_2);
    var qe_lin_0 : vec3<f32> = d_lin_2 * vec3<f32>(ks_2, ks_2, kn_3);
    var qe_ang_0 : vec3<f32> = d_ang_2 * vec3<f32>(kb1_0, kb2_0, kt_2);
    var _S341 : Measures_0 = stress_measures_0(&((*b_35)), qe_lin_0, qe_ang_0);
    var _S342 : f32 = max(max(_S341.tension_0, _S341.shear_0), _S341.compression_0);
    var _S343 : bool = dt_13 > 0.0f;
    var dif_1 : f32;
    if(_S343)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S342 - st_2.governing_stress_0, dt_13), 0.0f), (*mat_8).misc_0.w);
        var tau_2 : f32 = _S340.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_13, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_13, tau_2), 1.0f);
        }
        st_2.strain_rate_0 = st_2.strain_rate_0 + (raw_0 - st_2.strain_rate_0) * dif_1;
        st_2.governing_stress_0 = _S342;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S344 : f32 = dif_factor_0(&((*mat_8)), st_2.strain_rate_0);
        dif_1 = _S344;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_35).geom1_0.w;
    var _S345 : f32 = weibull_0 * dif_1;
    var _S346 : f32 = fatigue_factor_1(&((*mat_8)), st_2.life_0);
    var multiplier_1 : f32 = _S345 * _S346;
    var _S347 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S341, multiplier_1);
    var _S348 : f32 = _S347.x;
    var _S349 : f32 = _S347.y;
    st_2.utilization_0 = max(max(_S348, _S349), max(_S347.z, _S347.w));
    var _S350 : f32 = d_lin_2.x;
    var _S351 : f32 = d_lin_2.y;
    var _S352 : f32 = ks_2 * (sq_0(_S350) + sq_0(_S351)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    var _S353 : f32 = d_lin_2.z;
    var _S354 : bool = _S353 > 0.0f;
    if(_S354)
    {
        dif_1 = kn_3 * sq_0(_S353);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S352 + dif_1);
    var psi_c_0 : f32;
    if(_S353 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S353);
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
    var _S355 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S356 : bool = _S348 >= _S349;
        if(_S356)
        {
            diss_contact_0 = _S348;
        }
        else
        {
            diss_contact_0 = _S349;
        }
        var mode_ts_0 : u32;
        if(_S356)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_2.kappa_0))
        {
            _S355 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S355 = false;
        }
        if(_S355)
        {
            _S355 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S355 = false;
        }
        var mode_c_0 : u32;
        if(_S355)
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
            var _S357 : f32 = inc_0.x;
            if(_S357 > (st_2.damage_0))
            {
                var _S358 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), st_2.crush_1, plastic_4, d_lin_2, d_ang_2);
                var _S359 : f32 = max(_S358.energy_2 - (1.0f - st_2.crush_1) * psi_c_0, 0.0f);
                var _S360 : f32 = max(inc_0.y - _S359 * (_S357 - st_2.damage_0), 0.0f);
                var _S361 : f32 = max((psi_ts_0 - _S359) * (_S357 - st_2.damage_0) - _S360, 0.0f);
                st_2.damage_0 = _S357;
                st_2.mode_0 = mode_ts_0;
                dissipated_4 = _S360;
                overshoot_1 = _S361;
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
            var _S362 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), state_2.crush_1, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S362.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S363 : Measures_0 = stress_measures_0(&((*b_35)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S364 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S363, multiplier_1);
        var _S365 : f32 = _S364.z;
        var _S366 : f32 = _S364.w;
        var _S367 : bool = _S365 >= _S366;
        if(_S367)
        {
            psi_contact_0 = _S365;
        }
        else
        {
            psi_contact_0 = _S366;
        }
        if(_S367)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_2.kappa_c_0))
        {
            _S355 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S355 = false;
        }
        if(_S355)
        {
            _S355 = psi_c_0 > 0.0f;
        }
        else
        {
            _S355 = false;
        }
        if(_S355)
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
            var _S368 : f32 = inc_1.x;
            if(_S368 > (st_2.crush_1))
            {
                var _S369 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S369;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S368 - st_2.crush_1) - _S369, 0.0f);
                st_2.crush_1 = _S368;
                st_2.mode_0 = mode_c_0;
                if(_S368 >= 1.0f)
                {
                    _S355 = (st_2.damage_0) < 1.0f;
                }
                else
                {
                    _S355 = false;
                }
                if(_S355)
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
    var _S370 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_0 : vec3<f32>;
    if((st_2.damage_0) == 0.0f)
    {
        if(((flags_1 & (u32(8)))) == u32(0))
        {
            var _S371 : vec3<f32> = contact_offsets_0(&((*mat_8)), &((*b_35)), st_2.crush_1, plastic_4, d_lin_2, d_ang_2);
            st_2.plastic_x_0 = _S371.x;
            st_2.plastic_y_0 = _S371.y;
            st_2.plastic_t_0 = _S371.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S370;
        qc_ang_0 = _S370;
        psi_contact_0 = 0.0f;
    }
    else
    {
        var _S372 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), st_2.crush_1, plastic_4, d_lin_2, d_ang_2);
        st_2.plastic_x_0 = _S372.plastic_1.x;
        st_2.plastic_y_0 = _S372.plastic_1.y;
        st_2.plastic_t_0 = _S372.plastic_1.z;
        diss_contact_0 = _S372.diss_4;
        qc_lin_0 = _S372.q_lin_1;
        qc_ang_0 = _S372.q_ang_1;
        psi_contact_0 = _S372.energy_2;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S354)
    {
        intact_normal_0 = kn_3 * _S353;
    }
    else
    {
        intact_normal_0 = (1.0f - st_2.crush_1) * kn_3 * _S353;
    }
    var _S373 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S373 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S373 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S373 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S373) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S373 * (psi_ts_0 + (1.0f - st_2.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_2)
    {
        _S355 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S355 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S355)
    {
        var k_axial_0 : f32 = (*b_35).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_35).rebar0_0.y;
        var yield_force_0 : f32 = (*b_35).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_35).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S353, st_2.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S350, st_2.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S351, st_2.rebar_slip1_0, dowel_capacity_0);
        var _S374 : f32 = nr_0.y;
        var _S375 : f32 = v1_0.y;
        var _S376 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S374) + dowel_capacity_0 * (abs(_S375) + abs(_S376));
        st_2.rebar_plastic_0 = st_2.rebar_plastic_0 + _S374;
        st_2.rebar_slip0_0 = st_2.rebar_slip0_0 + _S375;
        st_2.rebar_slip1_0 = st_2.rebar_slip1_0 + _S376;
        st_2.rebar_work_0 = st_2.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S377 : f32 = nr_0.x;
        var _S378 : f32 = v1_0.x;
        var _S379 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S377), k_axial_0) + fdiv_0(sq_0(_S378) + sq_0(_S379), k_dowel_0));
        if(fracture_1)
        {
            _S355 = (st_2.rebar_work_0) >= ((*b_35).rebar1_0.x);
        }
        else
        {
            _S355 = false;
        }
        if(_S355)
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
            force_lin_3 = force_lin_2 + vec3<f32>(_S378, _S379, _S377);
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
        _S355 = _S343;
    }
    else
    {
        _S355 = false;
    }
    if(_S355)
    {
        _S355 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S355 = false;
    }
    if(_S355)
    {
        var _S380 : Measures_0 = stress_measures_0(&((*b_35)), force_lin_3, force_ang_2);
        var _S381 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S380, weibull_0);
        var _S382 : f32 = life_rate_0(&((*mat_8)), max(max(_S381.x, _S381.y), _S381.z));
        st_2.life_0 = max(st_2.life_0 - _S382 * dt_13, 0.0f);
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
        _S355 = !connected_1(st_2, has_rebar_2);
    }
    else
    {
        _S355 = false;
    }
    resp_0.disconnected_0 = _S355;
    resp_0.measures_0 = _S341;
    return resp_0;
}

fn joint_evaluate_1( mat_9 : ptr<function, JointMaterial_std140_0>,  b_36 : ptr<function, JointBond_std430_0>,  state_3 : JointState_0,  d_lin_3 : vec3<f32>,  d_ang_3 : vec3<f32>,  dt_14 : f32,  fracture_2 : bool) -> JointResponse_0
{
    var kn_4 : f32 = (*b_36).stiff0_0.x;
    var ks_3 : f32 = (*b_36).stiff0_0.y;
    var kb1_1 : f32 = (*b_36).stiff0_0.z;
    var kb2_1 : f32 = (*b_36).stiff0_0.w;
    var _S383 : vec4<f32> = (*b_36).stiff1_0;
    var kt_3 : f32 = (*b_36).stiff1_0.x;
    var has_rebar_3 : bool = ((*b_36).stiff1_0.w) != 0.0f;
    var kind_5 : u32 = (*mat_9).kind_flags_0.x;
    var flags_2 : u32 = (*mat_9).kind_flags_0.y;
    var softening_1 : bool = ((flags_2 & (u32(1)))) != u32(0);
    var st_3 : JointState_0 = state_3;
    var was_connected_1 : bool = connected_1(state_3, has_rebar_3);
    var qe_lin_1 : vec3<f32> = d_lin_3 * vec3<f32>(ks_3, ks_3, kn_4);
    var qe_ang_1 : vec3<f32> = d_ang_3 * vec3<f32>(kb1_1, kb2_1, kt_3);
    var _S384 : Measures_0 = stress_measures_0(&((*b_36)), qe_lin_1, qe_ang_1);
    var _S385 : f32 = max(max(_S384.tension_0, _S384.shear_0), _S384.compression_0);
    var _S386 : bool = dt_14 > 0.0f;
    var dif_2 : f32;
    if(_S386)
    {
        var raw_1 : f32 = fdiv_0(max(fdiv_0(_S385 - st_3.governing_stress_0, dt_14), 0.0f), (*mat_9).misc_0.w);
        var tau_3 : f32 = _S383.z;
        if(((flags_2 & (u32(16)))) != u32(0))
        {
            dif_2 = - expm1_accurate_0(- fdiv_0(dt_14, tau_3));
        }
        else
        {
            dif_2 = min(fdiv_0(dt_14, tau_3), 1.0f);
        }
        st_3.strain_rate_0 = st_3.strain_rate_0 + (raw_1 - st_3.strain_rate_0) * dif_2;
        st_3.governing_stress_0 = _S385;
    }
    if(((flags_2 & (u32(32)))) != u32(0))
    {
        var _S387 : f32 = dif_factor_0(&((*mat_9)), st_3.strain_rate_0);
        dif_2 = _S387;
    }
    else
    {
        dif_2 = 1.0f;
    }
    var weibull_1 : f32 = (*b_36).geom1_0.w;
    var _S388 : f32 = weibull_1 * dif_2;
    var _S389 : f32 = fatigue_factor_1(&((*mat_9)), st_3.life_0);
    var multiplier_2 : f32 = _S388 * _S389;
    var _S390 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S384, multiplier_2);
    var _S391 : f32 = _S390.x;
    var _S392 : f32 = _S390.y;
    st_3.utilization_0 = max(max(_S391, _S392), max(_S390.z, _S390.w));
    var _S393 : f32 = d_lin_3.x;
    var _S394 : f32 = d_lin_3.y;
    var _S395 : f32 = ks_3 * (sq_0(_S393) + sq_0(_S394)) + kb1_1 * sq_0(d_ang_3.x) + kb2_1 * sq_0(d_ang_3.y) + kt_3 * sq_0(d_ang_3.z);
    var _S396 : f32 = d_lin_3.z;
    var _S397 : bool = _S396 > 0.0f;
    if(_S397)
    {
        dif_2 = kn_4 * sq_0(_S396);
    }
    else
    {
        dif_2 = 0.0f;
    }
    var psi_ts_1 : f32 = 0.5f * (_S395 + dif_2);
    var psi_c_1 : f32;
    if(_S396 < 0.0f)
    {
        psi_c_1 = 0.5f * kn_4 * sq_0(_S396);
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
    var _S398 : bool;
    var qc_lin_1 : vec3<f32>;
    if(fracture_2)
    {
        var _S399 : bool = _S391 >= _S392;
        if(_S399)
        {
            diss_contact_1 = _S391;
        }
        else
        {
            diss_contact_1 = _S392;
        }
        var mode_ts_1 : u32;
        if(_S399)
        {
            mode_ts_1 = u32(1);
        }
        else
        {
            mode_ts_1 = u32(2);
        }
        if(diss_contact_1 > (st_3.kappa_0))
        {
            _S398 = diss_contact_1 > 1.0f;
        }
        else
        {
            _S398 = false;
        }
        if(_S398)
        {
            _S398 = psi_ts_1 > 0.0f;
        }
        else
        {
            _S398 = false;
        }
        var mode_c_1 : u32;
        if(_S398)
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
            var _S400 : f32 = inc_2.x;
            if(_S400 > (st_3.damage_0))
            {
                var _S401 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), st_3.crush_1, plastic_5, d_lin_3, d_ang_3);
                var _S402 : f32 = max(_S401.energy_2 - (1.0f - st_3.crush_1) * psi_c_1, 0.0f);
                var _S403 : f32 = max(inc_2.y - _S402 * (_S400 - st_3.damage_0), 0.0f);
                var _S404 : f32 = max((psi_ts_1 - _S402) * (_S400 - st_3.damage_0) - _S403, 0.0f);
                st_3.damage_0 = _S400;
                st_3.mode_0 = mode_ts_1;
                dissipated_10 = _S403;
                overshoot_3 = _S404;
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
            var _S405 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), state_3.crush_1, vec3<f32>(state_3.plastic_x_0, state_3.plastic_y_0, state_3.plastic_t_0), d_lin_3, d_ang_3);
            qc_lin_1 = qe_ang_1 * vec3<f32>((1.0f - state_3.damage_0)) + _S405.q_ang_1 * vec3<f32>(state_3.damage_0);
        }
        else
        {
            qc_lin_1 = qe_ang_1;
        }
        var _S406 : Measures_0 = stress_measures_0(&((*b_36)), vec3<f32>(0.0f, 0.0f, min(qe_lin_1.z, 0.0f)), qc_lin_1);
        var _S407 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S406, multiplier_2);
        var _S408 : f32 = _S407.z;
        var _S409 : f32 = _S407.w;
        var _S410 : bool = _S408 >= _S409;
        if(_S410)
        {
            psi_contact_1 = _S408;
        }
        else
        {
            psi_contact_1 = _S409;
        }
        if(_S410)
        {
            mode_c_1 = u32(3);
        }
        else
        {
            mode_c_1 = u32(4);
        }
        if(psi_contact_1 > (st_3.kappa_c_0))
        {
            _S398 = psi_contact_1 > 1.0f;
        }
        else
        {
            _S398 = false;
        }
        if(_S398)
        {
            _S398 = psi_c_1 > 0.0f;
        }
        else
        {
            _S398 = false;
        }
        if(_S398)
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
            var _S411 : f32 = inc_3.x;
            if(_S411 > (st_3.crush_1))
            {
                var _S412 : f32 = inc_3.y;
                var dissipated_11 : f32 = dissipated_10 + _S412;
                var overshoot_4 : f32 = overshoot_3 + max(psi_c_1 * (_S411 - st_3.crush_1) - _S412, 0.0f);
                st_3.crush_1 = _S411;
                st_3.mode_0 = mode_c_1;
                if(_S411 >= 1.0f)
                {
                    _S398 = (st_3.damage_0) < 1.0f;
                }
                else
                {
                    _S398 = false;
                }
                if(_S398)
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
    var _S413 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_1 : vec3<f32>;
    if((st_3.damage_0) == 0.0f)
    {
        if(((flags_2 & (u32(8)))) == u32(0))
        {
            var _S414 : vec3<f32> = contact_offsets_0(&((*mat_9)), &((*b_36)), st_3.crush_1, plastic_5, d_lin_3, d_ang_3);
            st_3.plastic_x_0 = _S414.x;
            st_3.plastic_y_0 = _S414.y;
            st_3.plastic_t_0 = _S414.z;
        }
        diss_contact_1 = 0.0f;
        qc_lin_1 = _S413;
        qc_ang_1 = _S413;
        psi_contact_1 = 0.0f;
    }
    else
    {
        var _S415 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), st_3.crush_1, plastic_5, d_lin_3, d_ang_3);
        st_3.plastic_x_0 = _S415.plastic_1.x;
        st_3.plastic_y_0 = _S415.plastic_1.y;
        st_3.plastic_t_0 = _S415.plastic_1.z;
        diss_contact_1 = _S415.diss_4;
        qc_lin_1 = _S415.q_lin_1;
        qc_ang_1 = _S415.q_ang_1;
        psi_contact_1 = _S415.energy_2;
    }
    var dissipated_13 : f32 = dissipated_10 + dmg_1 * diss_contact_1;
    if(_S397)
    {
        intact_normal_1 = kn_4 * _S396;
    }
    else
    {
        intact_normal_1 = (1.0f - st_3.crush_1) * kn_4 * _S396;
    }
    var _S416 : f32 = 1.0f - dmg_1;
    var force_lin_4 : vec3<f32> = vec3<f32>(_S416 * qe_lin_1.x + dmg_1 * qc_lin_1.x, _S416 * qe_lin_1.y + dmg_1 * qc_lin_1.y, _S416 * intact_normal_1 + dmg_1 * qc_lin_1.z);
    var force_ang_3 : vec3<f32> = qe_ang_1 * vec3<f32>(_S416) + qc_ang_1 * vec3<f32>(dmg_1);
    var stored_10 : f32 = _S416 * (psi_ts_1 + (1.0f - st_3.crush_1) * psi_c_1) + dmg_1 * psi_contact_1;
    if(has_rebar_3)
    {
        _S398 = (st_3.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S398 = false;
    }
    var stored_11 : f32;
    var force_lin_5 : vec3<f32>;
    if(_S398)
    {
        var k_axial_1 : f32 = (*b_36).rebar0_0.x;
        var k_dowel_1 : f32 = (*b_36).rebar0_0.y;
        var yield_force_1 : f32 = (*b_36).rebar0_0.z;
        var dowel_capacity_1 : f32 = (*b_36).rebar0_0.w;
        var nr_1 : vec2<f32> = return_map_0(k_axial_1, _S396, st_3.rebar_plastic_0, yield_force_1);
        var v1_1 : vec2<f32> = return_map_0(k_dowel_1, _S393, st_3.rebar_slip0_0, dowel_capacity_1);
        var v2_1 : vec2<f32> = return_map_0(k_dowel_1, _S394, st_3.rebar_slip1_0, dowel_capacity_1);
        var _S417 : f32 = nr_1.y;
        var _S418 : f32 = v1_1.y;
        var _S419 : f32 = v2_1.y;
        var work_1 : f32 = yield_force_1 * abs(_S417) + dowel_capacity_1 * (abs(_S418) + abs(_S419));
        st_3.rebar_plastic_0 = st_3.rebar_plastic_0 + _S417;
        st_3.rebar_slip0_0 = st_3.rebar_slip0_0 + _S418;
        st_3.rebar_slip1_0 = st_3.rebar_slip1_0 + _S419;
        st_3.rebar_work_0 = st_3.rebar_work_0 + work_1;
        var dissipated_14 : f32 = dissipated_13 + work_1;
        var _S420 : f32 = nr_1.x;
        var _S421 : f32 = v1_1.x;
        var _S422 : f32 = v2_1.x;
        var elastic_1 : f32 = 0.5f * (fdiv_0(sq_0(_S420), k_axial_1) + fdiv_0(sq_0(_S421) + sq_0(_S422), k_dowel_1));
        if(fracture_2)
        {
            _S398 = (st_3.rebar_work_0) >= ((*b_36).rebar1_0.x);
        }
        else
        {
            _S398 = false;
        }
        if(_S398)
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
            force_lin_5 = force_lin_4 + vec3<f32>(_S421, _S422, _S420);
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
        _S398 = _S386;
    }
    else
    {
        _S398 = false;
    }
    if(_S398)
    {
        _S398 = ((flags_2 & (u32(64)))) != u32(0);
    }
    else
    {
        _S398 = false;
    }
    if(_S398)
    {
        var _S423 : Measures_0 = stress_measures_0(&((*b_36)), force_lin_5, force_ang_3);
        var _S424 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S423, weibull_1);
        var _S425 : f32 = life_rate_0(&((*mat_9)), max(max(_S424.x, _S424.y), _S424.z));
        st_3.life_0 = max(st_3.life_0 - _S425 * dt_14, 0.0f);
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
        _S398 = !connected_1(st_3, has_rebar_3);
    }
    else
    {
        _S398 = false;
    }
    resp_1.disconnected_0 = _S398;
    resp_1.measures_0 = _S384;
    return resp_1;
}

fn joint_evaluate_2( mat_10 : ptr<function, JointMaterial_std140_0>,  b_37 : ptr<function, JointBond_std430_0>,  state_4 : ptr<function, JointState_std430_0>,  d_lin_4 : vec3<f32>,  d_ang_4 : vec3<f32>,  dt_15 : f32,  fracture_3 : bool) -> JointResponse_0
{
    var kn_5 : f32 = (*b_37).stiff0_0.x;
    var ks_4 : f32 = (*b_37).stiff0_0.y;
    var kb1_2 : f32 = (*b_37).stiff0_0.z;
    var kb2_2 : f32 = (*b_37).stiff0_0.w;
    var _S426 : vec4<f32> = (*b_37).stiff1_0;
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
    st_4.life_0 = (*state_4).life_0;
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
    var _S427 : bool = connected_0(&((*state_4)), has_rebar_4);
    var qe_lin_2 : vec3<f32> = d_lin_4 * vec3<f32>(ks_4, ks_4, kn_5);
    var qe_ang_2 : vec3<f32> = d_ang_4 * vec3<f32>(kb1_2, kb2_2, kt_4);
    var _S428 : Measures_0 = stress_measures_0(&((*b_37)), qe_lin_2, qe_ang_2);
    var _S429 : f32 = max(max(_S428.tension_0, _S428.shear_0), _S428.compression_0);
    var _S430 : bool = dt_15 > 0.0f;
    var dif_3 : f32;
    if(_S430)
    {
        var raw_2 : f32 = fdiv_0(max(fdiv_0(_S429 - st_4.governing_stress_0, dt_15), 0.0f), (*mat_10).misc_0.w);
        var tau_4 : f32 = _S426.z;
        if(((flags_3 & (u32(16)))) != u32(0))
        {
            dif_3 = - expm1_accurate_0(- fdiv_0(dt_15, tau_4));
        }
        else
        {
            dif_3 = min(fdiv_0(dt_15, tau_4), 1.0f);
        }
        st_4.strain_rate_0 = st_4.strain_rate_0 + (raw_2 - st_4.strain_rate_0) * dif_3;
        st_4.governing_stress_0 = _S429;
    }
    if(((flags_3 & (u32(32)))) != u32(0))
    {
        var _S431 : f32 = dif_factor_0(&((*mat_10)), st_4.strain_rate_0);
        dif_3 = _S431;
    }
    else
    {
        dif_3 = 1.0f;
    }
    var weibull_2 : f32 = (*b_37).geom1_0.w;
    var _S432 : f32 = weibull_2 * dif_3;
    var _S433 : f32 = fatigue_factor_1(&((*mat_10)), st_4.life_0);
    var multiplier_3 : f32 = _S432 * _S433;
    var _S434 : vec4<f32> = failure_indices_0(&((*mat_10)), &((*b_37)), _S428, multiplier_3);
    var _S435 : f32 = _S434.x;
    var _S436 : f32 = _S434.y;
    st_4.utilization_0 = max(max(_S435, _S436), max(_S434.z, _S434.w));
    var _S437 : f32 = d_lin_4.x;
    var _S438 : f32 = d_lin_4.y;
    var _S439 : f32 = ks_4 * (sq_0(_S437) + sq_0(_S438)) + kb1_2 * sq_0(d_ang_4.x) + kb2_2 * sq_0(d_ang_4.y) + kt_4 * sq_0(d_ang_4.z);
    var _S440 : f32 = d_lin_4.z;
    var _S441 : bool = _S440 > 0.0f;
    if(_S441)
    {
        dif_3 = kn_5 * sq_0(_S440);
    }
    else
    {
        dif_3 = 0.0f;
    }
    var psi_ts_2 : f32 = 0.5f * (_S439 + dif_3);
    var psi_c_2 : f32;
    if(_S440 < 0.0f)
    {
        psi_c_2 = 0.5f * kn_5 * sq_0(_S440);
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
    var _S442 : bool;
    var qc_lin_2 : vec3<f32>;
    if(fracture_3)
    {
        var _S443 : bool = _S435 >= _S436;
        if(_S443)
        {
            diss_contact_2 = _S435;
        }
        else
        {
            diss_contact_2 = _S436;
        }
        var mode_ts_2 : u32;
        if(_S443)
        {
            mode_ts_2 = u32(1);
        }
        else
        {
            mode_ts_2 = u32(2);
        }
        if(diss_contact_2 > (st_4.kappa_0))
        {
            _S442 = diss_contact_2 > 1.0f;
        }
        else
        {
            _S442 = false;
        }
        if(_S442)
        {
            _S442 = psi_ts_2 > 0.0f;
        }
        else
        {
            _S442 = false;
        }
        var mode_c_2 : u32;
        if(_S442)
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
            var _S444 : f32 = inc_4.x;
            if(_S444 > (st_4.damage_0))
            {
                var _S445 : Contact_0 = contact_part_0(&((*mat_10)), &((*b_37)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
                var _S446 : f32 = max(_S445.energy_2 - (1.0f - st_4.crush_1) * psi_c_2, 0.0f);
                var _S447 : f32 = max(inc_4.y - _S446 * (_S444 - st_4.damage_0), 0.0f);
                var _S448 : f32 = max((psi_ts_2 - _S446) * (_S444 - st_4.damage_0) - _S447, 0.0f);
                st_4.damage_0 = _S444;
                st_4.mode_0 = mode_ts_2;
                dissipated_16 = _S447;
                overshoot_5 = _S448;
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
        var _S449 : f32 = (*state_4).damage_0;
        if(((*state_4).damage_0) > 0.0f)
        {
            var _S450 : Contact_0 = contact_part_0(&((*mat_10)), &((*b_37)), (*state_4).crush_1, vec3<f32>((*state_4).plastic_x_0, (*state_4).plastic_y_0, (*state_4).plastic_t_0), d_lin_4, d_ang_4);
            qc_lin_2 = qe_ang_2 * vec3<f32>((1.0f - _S449)) + _S450.q_ang_1 * vec3<f32>(_S449);
        }
        else
        {
            qc_lin_2 = qe_ang_2;
        }
        var _S451 : Measures_0 = stress_measures_0(&((*b_37)), vec3<f32>(0.0f, 0.0f, min(qe_lin_2.z, 0.0f)), qc_lin_2);
        var _S452 : vec4<f32> = failure_indices_0(&((*mat_10)), &((*b_37)), _S451, multiplier_3);
        var _S453 : f32 = _S452.z;
        var _S454 : f32 = _S452.w;
        var _S455 : bool = _S453 >= _S454;
        if(_S455)
        {
            psi_contact_2 = _S453;
        }
        else
        {
            psi_contact_2 = _S454;
        }
        if(_S455)
        {
            mode_c_2 = u32(3);
        }
        else
        {
            mode_c_2 = u32(4);
        }
        if(psi_contact_2 > (st_4.kappa_c_0))
        {
            _S442 = psi_contact_2 > 1.0f;
        }
        else
        {
            _S442 = false;
        }
        if(_S442)
        {
            _S442 = psi_c_2 > 0.0f;
        }
        else
        {
            _S442 = false;
        }
        if(_S442)
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
            var _S456 : f32 = inc_5.x;
            if(_S456 > (st_4.crush_1))
            {
                var _S457 : f32 = inc_5.y;
                var dissipated_17 : f32 = dissipated_16 + _S457;
                var overshoot_6 : f32 = overshoot_5 + max(psi_c_2 * (_S456 - st_4.crush_1) - _S457, 0.0f);
                st_4.crush_1 = _S456;
                st_4.mode_0 = mode_c_2;
                if(_S456 >= 1.0f)
                {
                    _S442 = (st_4.damage_0) < 1.0f;
                }
                else
                {
                    _S442 = false;
                }
                if(_S442)
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
    var _S458 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_2 : vec3<f32>;
    if((st_4.damage_0) == 0.0f)
    {
        if(((flags_3 & (u32(8)))) == u32(0))
        {
            var _S459 : vec3<f32> = contact_offsets_0(&((*mat_10)), &((*b_37)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
            st_4.plastic_x_0 = _S459.x;
            st_4.plastic_y_0 = _S459.y;
            st_4.plastic_t_0 = _S459.z;
        }
        diss_contact_2 = 0.0f;
        qc_lin_2 = _S458;
        qc_ang_2 = _S458;
        psi_contact_2 = 0.0f;
    }
    else
    {
        var _S460 : Contact_0 = contact_part_0(&((*mat_10)), &((*b_37)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
        st_4.plastic_x_0 = _S460.plastic_1.x;
        st_4.plastic_y_0 = _S460.plastic_1.y;
        st_4.plastic_t_0 = _S460.plastic_1.z;
        diss_contact_2 = _S460.diss_4;
        qc_lin_2 = _S460.q_lin_1;
        qc_ang_2 = _S460.q_ang_1;
        psi_contact_2 = _S460.energy_2;
    }
    var dissipated_19 : f32 = dissipated_16 + dmg_2 * diss_contact_2;
    if(_S441)
    {
        intact_normal_2 = kn_5 * _S440;
    }
    else
    {
        intact_normal_2 = (1.0f - st_4.crush_1) * kn_5 * _S440;
    }
    var _S461 : f32 = 1.0f - dmg_2;
    var force_lin_6 : vec3<f32> = vec3<f32>(_S461 * qe_lin_2.x + dmg_2 * qc_lin_2.x, _S461 * qe_lin_2.y + dmg_2 * qc_lin_2.y, _S461 * intact_normal_2 + dmg_2 * qc_lin_2.z);
    var force_ang_4 : vec3<f32> = qe_ang_2 * vec3<f32>(_S461) + qc_ang_2 * vec3<f32>(dmg_2);
    var stored_13 : f32 = _S461 * (psi_ts_2 + (1.0f - st_4.crush_1) * psi_c_2) + dmg_2 * psi_contact_2;
    if(has_rebar_4)
    {
        _S442 = (st_4.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S442 = false;
    }
    var stored_14 : f32;
    var force_lin_7 : vec3<f32>;
    if(_S442)
    {
        var k_axial_2 : f32 = (*b_37).rebar0_0.x;
        var k_dowel_2 : f32 = (*b_37).rebar0_0.y;
        var yield_force_2 : f32 = (*b_37).rebar0_0.z;
        var dowel_capacity_2 : f32 = (*b_37).rebar0_0.w;
        var nr_2 : vec2<f32> = return_map_0(k_axial_2, _S440, st_4.rebar_plastic_0, yield_force_2);
        var v1_2 : vec2<f32> = return_map_0(k_dowel_2, _S437, st_4.rebar_slip0_0, dowel_capacity_2);
        var v2_2 : vec2<f32> = return_map_0(k_dowel_2, _S438, st_4.rebar_slip1_0, dowel_capacity_2);
        var _S462 : f32 = nr_2.y;
        var _S463 : f32 = v1_2.y;
        var _S464 : f32 = v2_2.y;
        var work_2 : f32 = yield_force_2 * abs(_S462) + dowel_capacity_2 * (abs(_S463) + abs(_S464));
        st_4.rebar_plastic_0 = st_4.rebar_plastic_0 + _S462;
        st_4.rebar_slip0_0 = st_4.rebar_slip0_0 + _S463;
        st_4.rebar_slip1_0 = st_4.rebar_slip1_0 + _S464;
        st_4.rebar_work_0 = st_4.rebar_work_0 + work_2;
        var dissipated_20 : f32 = dissipated_19 + work_2;
        var _S465 : f32 = nr_2.x;
        var _S466 : f32 = v1_2.x;
        var _S467 : f32 = v2_2.x;
        var elastic_2 : f32 = 0.5f * (fdiv_0(sq_0(_S465), k_axial_2) + fdiv_0(sq_0(_S466) + sq_0(_S467), k_dowel_2));
        if(fracture_3)
        {
            _S442 = (st_4.rebar_work_0) >= ((*b_37).rebar1_0.x);
        }
        else
        {
            _S442 = false;
        }
        if(_S442)
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
            force_lin_7 = force_lin_6 + vec3<f32>(_S466, _S467, _S465);
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
        _S442 = _S430;
    }
    else
    {
        _S442 = false;
    }
    if(_S442)
    {
        _S442 = ((flags_3 & (u32(64)))) != u32(0);
    }
    else
    {
        _S442 = false;
    }
    if(_S442)
    {
        var _S468 : Measures_0 = stress_measures_0(&((*b_37)), force_lin_7, force_ang_4);
        var _S469 : vec4<f32> = failure_indices_0(&((*mat_10)), &((*b_37)), _S468, weibull_2);
        var _S470 : f32 = life_rate_0(&((*mat_10)), max(max(_S469.x, _S469.y), _S469.z));
        st_4.life_0 = max(st_4.life_0 - _S470 * dt_15, 0.0f);
    }
    st_4.dissipated_0 = st_4.dissipated_0 + dissipated_16;
    var resp_2 : JointResponse_0;
    resp_2.force_lin_1 = force_lin_7;
    resp_2.force_ang_1 = force_ang_4;
    resp_2.state_1 = st_4;
    resp_2.dissipated_3 = dissipated_16;
    resp_2.overshoot_0 = overshoot_5;
    resp_2.stored_6 = stored_14;
    if(_S427)
    {
        _S442 = !connected_1(st_4, has_rebar_4);
    }
    else
    {
        _S442 = false;
    }
    resp_2.disconnected_0 = _S442;
    resp_2.measures_0 = _S428;
    return resp_2;
}

fn secant_factors_0( b_38 : ptr<function, JointBond_std430_0>,  st_5 : ptr<function, JointState_std430_0>,  d_lin_5 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var _S471 : f32 = (*st_5).damage_0;
    var compressed_0 : bool = (d_lin_5.z) < 0.0f;
    var contact_3 : f32;
    if(compressed_0)
    {
        contact_3 = _S471;
    }
    else
    {
        contact_3 = 0.0f;
    }
    var _S472 : f32 = 1.0f - _S471;
    var _S473 : f32 = max(_S472 + contact_3, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - (*st_5).crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S472, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S473, _S473, normal_6);
    (*f_ang_0) = vec3<f32>(_S473);
    var _S474 : bool;
    if(((*b_38).stiff1_0.w) != 0.0f)
    {
        _S474 = ((*st_5).rebar_broken_0) == 0.0f;
    }
    else
    {
        _S474 = false;
    }
    if(_S474)
    {
        var _S475 : vec4<f32> = (*b_38).rebar0_0;
        var _S476 : vec4<f32> = (*b_38).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_38).rebar0_0.x, (*b_38).stiff0_0.x);
        var _S477 : f32 = fdiv_0(_S475.y, _S476.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S477;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S477;
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
    var _S478 : f32 = 1.0f - st_6.damage_0;
    var _S479 : f32 = max(_S478 + contact_4, 9.99999997475242708e-07f);
    var normal_7 : f32;
    if(compressed_1)
    {
        normal_7 = max(1.0f - st_6.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_7 = max(_S478, 9.99999997475242708e-07f);
    }
    (*f_lin_1) = vec3<f32>(_S479, _S479, normal_7);
    (*f_ang_1) = vec3<f32>(_S479);
    var _S480 : bool;
    if(((*b_39).stiff1_0.w) != 0.0f)
    {
        _S480 = (st_6.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S480 = false;
    }
    if(_S480)
    {
        var _S481 : vec4<f32> = (*b_39).rebar0_0;
        var _S482 : vec4<f32> = (*b_39).stiff0_0;
        (*f_lin_1)[i32(2)] = (*f_lin_1)[i32(2)] + fdiv_0((*b_39).rebar0_0.x, (*b_39).stiff0_0.x);
        var _S483 : f32 = fdiv_0(_S481.y, _S482.y);
        (*f_lin_1)[i32(0)] = (*f_lin_1)[i32(0)] + _S483;
        (*f_lin_1)[i32(1)] = (*f_lin_1)[i32(1)] + _S483;
    }
    return;
}

fn is_damaged_0( st_7 : JointState_0) -> bool
{
    var _S484 : bool;
    if((st_7.damage_0) > 0.0f)
    {
        _S484 = true;
    }
    else
    {
        _S484 = (st_7.crush_1) > 0.0f;
    }
    return _S484;
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

fn to_local_0( _S485 : u32,  _S486 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S486, bonds_0[_S485].t1_0.xyz), dot(_S486, bonds_0[_S485].t2_0.xyz), dot(_S486, bonds_0[_S485].normal_0.xyz));
}

fn to_body_0( _S487 : u32,  _S488 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S487].t1_0.xyz * vec3<f32>(_S488.x) + bonds_0[_S487].t2_0.xyz * vec3<f32>(_S488.y) + bonds_0[_S487].normal_0.xyz * vec3<f32>(_S488.z);
}

fn bond_update_0( i_9 : u32,  dt_16 : f32,  fracture_4 : bool,  abs_step_0 : u32) -> bool
{
    var _S489 : JointState_0 = JointState_0( bond_dyn_0[i_9].js_0.damage_0, bond_dyn_0[i_9].js_0.crush_1, bond_dyn_0[i_9].js_0.kappa_0, bond_dyn_0[i_9].js_0.kappa_c_0, bond_dyn_0[i_9].js_0.ductility_0, bond_dyn_0[i_9].js_0.ductility_c_0, bond_dyn_0[i_9].js_0.life_0, bond_dyn_0[i_9].js_0.plastic_x_0, bond_dyn_0[i_9].js_0.plastic_y_0, bond_dyn_0[i_9].js_0.plastic_t_0, bond_dyn_0[i_9].js_0.rebar_plastic_0, bond_dyn_0[i_9].js_0.rebar_slip0_0, bond_dyn_0[i_9].js_0.rebar_slip1_0, bond_dyn_0[i_9].js_0.rebar_work_0, bond_dyn_0[i_9].js_0.rebar_broken_0, bond_dyn_0[i_9].js_0.strain_rate_0, bond_dyn_0[i_9].js_0.governing_stress_0, bond_dyn_0[i_9].js_0.dissipated_0, bond_dyn_0[i_9].js_0.utilization_0, bond_dyn_0[i_9].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S489;
    bd_0.force_lin_0 = bond_dyn_0[i_9].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_9].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_9].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_9].comps_0;
    bd_0.events_0 = bond_dyn_0[i_9].events_0;
    var _S490 : JointBond_std430_0 = bonds_0[i_9].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_9].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_9].rb_0.xyz;
    var _S491 : u32 = u32(4) * _S490.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S491 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S491 + u32(3)].xyz;
    var _S492 : u32 = u32(4) * _S490.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S492 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S492 + u32(3)].xyz;
    var _S493 : vec3<f32> = to_local_0(i_9, state_0[_S492].xyz + cross(tb_3, rb_1) - (state_0[_S491].xyz + cross(ta_3, ra_1)));
    var _S494 : vec3<f32> = to_local_0(i_9, tb_3 - ta_3);
    var _S495 : vec3<f32> = to_local_0(i_9, state_0[_S492 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S491 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S496 : vec3<f32> = to_local_0(i_9, wb_0 - wa_0);
    var _S497 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S490.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S498 : JointResponse_0 = joint_evaluate_0(&(_S497), &(_S490), bd_0.js_0, _S493, _S494, dt_16, fracture_4);
    var f_lin_2 : vec3<f32>;
    var f_ang_2 : vec3<f32>;
    secant_factors_1(&(_S490), _S498.state_1, _S493, &(f_lin_2), &(f_ang_2));
    var qd_lin_0 : vec3<f32> = _S495 * bonds_0[i_9].c_lin_0.xyz * f_lin_2;
    var qd_ang_0 : vec3<f32> = _S496 * bonds_0[i_9].c_ang_0.xyz * f_ang_2;
    var q_lin_2 : vec3<f32> = _S498.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S498.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S495) + dot(qd_ang_0, _S496)) * dt_16;
    var _S499 : vec3<f32> = to_body_0(i_9, q_lin_2);
    var _S500 : vec3<f32> = to_body_0(i_9, q_ang_2);
    var _S501 : u32 = u32(3) * i_9;
    scratch_0[_S501] = vec4<f32>(_S499, max(_S498.measures_0.tension_0, _S498.measures_0.compression_0));
    scratch_0[_S501 + u32(1)] = vec4<f32>(_S500 + cross(ra_1, _S499), 0.0f);
    scratch_0[_S501 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S500) + cross(rb_1, (vec3<f32>(0) - _S499)), 0.0f);
    var _S502 : f32 = bd_0.sums_0[i32(0)];
    var _S503 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S502), &(_S503), _S498.dissipated_3);
    bd_0.sums_0[i32(0)] = _S502;
    bd_0.comps_0[i32(0)] = _S503;
    var _S504 : f32 = bd_0.sums_0[i32(1)];
    var _S505 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S504), &(_S505), _S498.overshoot_0);
    bd_0.sums_0[i32(1)] = _S504;
    bd_0.comps_0[i32(1)] = _S505;
    var _S506 : f32 = bd_0.sums_0[i32(2)];
    var _S507 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S506), &(_S507), damped_0);
    bd_0.sums_0[i32(2)] = _S506;
    bd_0.comps_0[i32(2)] = _S507;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S498.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S498.state_1.utilization_0));
    var _S508 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S508 = is_damaged_0(_S498.state_1);
    }
    else
    {
        _S508 = false;
    }
    if(_S508)
    {
        _S508 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S508 = false;
    }
    if(_S508)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S498.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S509 : f32 = fatigue_factor_0(&(_S497), previous_0.life_0);
        _S508 = _S509 > 0.99000000953674316f;
    }
    else
    {
        _S508 = false;
    }
    if(_S508)
    {
        var _S510 : f32 = fatigue_factor_0(&(_S497), _S498.state_1.life_0);
        _S508 = _S510 <= 0.99000000953674316f;
    }
    else
    {
        _S508 = false;
    }
    if(_S508)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S498.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S498.state_1;
    bond_dyn_0[i_9].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_9].js_0.crush_1 = bd_0.js_0.crush_1;
    bond_dyn_0[i_9].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_9].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_9].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_9].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_9].js_0.life_0 = bd_0.js_0.life_0;
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
    return _S498.disconnected_0;
}

fn chunk_update_0( c_15 : u32,  isl_11 : ptr<function, Island_std430_0>,  rg_9 : Rigid_0,  dt_17 : f32,  rml_0 : bool,  step_0 : u32,  contact_5 : bool,  work_3 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S511 : vec3<f32> = vec3<f32>(0.0f);
    var _S512 : u32 = index_0[c_15];
    var peak_0 : f32 = 0.0f;
    var e_3 : u32 = _S512;
    var fi_0 : vec3<f32> = _S511;
    var mi_0 : vec3<f32> = _S511;
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
        var _S513 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S513];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S513 + u32(1)].xyz;
            fi_0 = fi_0 + fa_2.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S513 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_2.xyz);
            mi_0 = mi_2;
        }
        var _S514 : f32 = max(peak_0, fa_2.w);
        var _S515 : u32 = e_3 + u32(1);
        peak_0 = _S514;
        e_3 = _S515;
    }
    var _S516 : u32 = u32(4) * c_15;
    var u_0 : vec3<f32> = state_0[_S516].xyz;
    var _S517 : u32 = _S516 + u32(1);
    var th_1 : vec3<f32> = state_0[_S517].xyz;
    var _S518 : u32 = _S516 + u32(2);
    var v_10 : vec3<f32> = state_0[_S518].xyz;
    var _S519 : u32 = _S516 + u32(3);
    var w_5 : vec3<f32> = state_0[_S519].xyz;
    var mass_0 : f32 = chunks_0[c_15].center_0.w;
    var _S520 : vec3<f32> = chunks_0[c_15].center_0.xyz;
    var _S521 : vec3<f32> = (*isl_11).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_9.rot_0, _S520 + u_0 - _S521);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_1(c_15, c_15, rg_9.rot_0, step_0, dt_17, contact_5, &(f_load_0), &(t_load_0));
    record_chunk_load_0(c_15, f_load_0, t_load_0);
    var _S522 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S522;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.alpha_0) + cross(rg_9.w_4, world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.w_4)));
        f_world_1 = f_world_0 - (rg_9.a_8 + cross(rg_9.alpha_0, r_world_0) + cross(rg_9.w_4, cross(rg_9.w_4, r_world_0))) * _S522;
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
        f_ext_1 = f_ext_0 - cross(wb_1, v_10) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var _S523 : vec4<u32> = chunks_0[c_15].load_range_0;
    var term_5 : u32 = chunks_0[c_15].load_range_0.x;
    loop
    {
        if(term_5 < (_S523.y))
        {
        }
        else
        {
            break;
        }
        var _S524 : u32 = u32(5) * term_5;
        if(((bitcast<vec4<u32>>((loads_0[_S524]))).y) != u32(2))
        {
            term_5 = term_5 + u32(1);
            continue;
        }
        var _S525 : vec3<f32> = vec3<f32>(eval_function_0(term_5, step_0, dt_17, dt_17));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S524 + u32(2)].xyz * _S525;
        f_ext_1 = f_ext_1 + loads_0[_S524 + u32(1)].xyz * _S525;
        m_ext_1 = m_ext_3;
        term_5 = term_5 + u32(1);
    }
    var f_16 : vec3<f32> = f_ext_1 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_15].info_1.x;
    var _S526 : vec3<f32> = vec3<f32>(state_0[_S517].w, state_0[_S518].w, state_0[_S519].w);
    var reaction_0 : vec3<f32>;
    var u_1 : vec3<f32>;
    var th_2 : vec3<f32>;
    var v_11 : vec3<f32>;
    var w_6 : vec3<f32>;
    if(support_0 == u32(1))
    {
        reaction_0 = (vec3<f32>(0) - f_16);
        u_1 = u_0;
        th_2 = th_1;
        v_11 = _S511;
        w_6 = _S511;
    }
    else
    {
        var _S527 : vec4<f32> = chunks_0[c_15].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_15].inv0_1, chunks_0[c_15].inv1_1, chunks_0[c_15].inv2_1, m_5) * vec3<f32>((dt_17 * chunks_0[c_15].scale_0.z));
        var _S528 : vec3<f32> = vec3<f32>(dt_17);
        var th_3 : vec3<f32> = th_1 + w_7 * _S528;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_16);
            u_1 = u_0;
            th_2 = _S511;
        }
        else
        {
            var v_12 : vec3<f32> = v_10 + f_16 * vec3<f32>((dt_17 * _S527.y));
            var u_2 : vec3<f32> = u_0 + v_12 * _S528;
            reaction_0 = _S526;
            u_1 = u_2;
            th_2 = v_12;
        }
        var _S529 : vec3<f32> = th_2;
        th_2 = th_3;
        v_11 = _S529;
        w_6 = w_7;
    }
    state_0[_S516] = vec4<f32>(u_1, peak_0);
    state_0[_S517] = vec4<f32>(th_2, reaction_0.x);
    state_0[_S518] = vec4<f32>(v_11, reaction_0.y);
    state_0[_S519] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_2(&((*work_3)), &((*work_err_0)), (dot(f_load_0, rg_9.vel_1 + rg_9.vel_err_1 + cross(rg_9.w_4, rotate_0(rg_9.rot_0, _S520 + u_1 - _S521)) + rotate_0(rg_9.rot_0, v_11)) + dot(t_load_0, rg_9.w_4 + rotate_0(rg_9.rot_0, w_6))) * dt_17);
    return;
}

fn chunk_update_1( c_16 : u32,  isl_12 : Island_0,  rg_10 : Rigid_0,  dt_18 : f32,  rml_1 : bool,  step_1 : u32,  contact_6 : bool,  work_4 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S530 : vec3<f32> = vec3<f32>(0.0f);
    var _S531 : u32 = index_0[c_16];
    var peak_1 : f32 = 0.0f;
    var e_4 : u32 = _S531;
    var fi_1 : vec3<f32> = _S530;
    var mi_3 : vec3<f32> = _S530;
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
        var _S532 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var fa_3 : vec4<f32> = scratch_0[_S532];
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            var mi_4 : vec3<f32> = mi_3 + scratch_0[_S532 + u32(1)].xyz;
            fi_1 = fi_1 + fa_3.xyz;
            mi_3 = mi_4;
        }
        else
        {
            var mi_5 : vec3<f32> = mi_3 + scratch_0[_S532 + u32(2)].xyz;
            fi_1 = fi_1 + (vec3<f32>(0) - fa_3.xyz);
            mi_3 = mi_5;
        }
        var _S533 : f32 = max(peak_1, fa_3.w);
        var _S534 : u32 = e_4 + u32(1);
        peak_1 = _S533;
        e_4 = _S534;
    }
    var _S535 : u32 = u32(4) * c_16;
    var u_3 : vec3<f32> = state_0[_S535].xyz;
    var _S536 : u32 = _S535 + u32(1);
    var th_4 : vec3<f32> = state_0[_S536].xyz;
    var _S537 : u32 = _S535 + u32(2);
    var v_13 : vec3<f32> = state_0[_S537].xyz;
    var _S538 : u32 = _S535 + u32(3);
    var w_8 : vec3<f32> = state_0[_S538].xyz;
    var mass_1 : f32 = chunks_0[c_16].center_0.w;
    var _S539 : vec3<f32> = chunks_0[c_16].center_0.xyz;
    var _S540 : vec3<f32> = isl_12.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_10.rot_0, _S539 + u_3 - _S540);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    chunk_external_1(c_16, c_16, rg_10.rot_0, step_1, dt_18, contact_6, &(f_load_1), &(t_load_1));
    record_chunk_load_0(c_16, f_load_1, t_load_1);
    var _S541 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S541;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.alpha_0) + cross(rg_10.w_4, world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.w_4)));
        f_world_3 = f_world_2 - (rg_10.a_8 + cross(rg_10.alpha_0, r_world_1) + cross(rg_10.w_4, cross(rg_10.w_4, r_world_1))) * _S541;
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
        f_ext_3 = f_ext_2 - cross(wb_2, v_13) * vec3<f32>((2.0f * mass_1));
        m_ext_5 = m_ext_6;
    }
    else
    {
        f_ext_3 = f_ext_2;
        m_ext_5 = m_ext_4;
    }
    var _S542 : vec4<u32> = chunks_0[c_16].load_range_0;
    var term_6 : u32 = chunks_0[c_16].load_range_0.x;
    loop
    {
        if(term_6 < (_S542.y))
        {
        }
        else
        {
            break;
        }
        var _S543 : u32 = u32(5) * term_6;
        if(((bitcast<vec4<u32>>((loads_0[_S543]))).y) != u32(2))
        {
            term_6 = term_6 + u32(1);
            continue;
        }
        var _S544 : vec3<f32> = vec3<f32>(eval_function_0(term_6, step_1, dt_18, dt_18));
        var m_ext_7 : vec3<f32> = m_ext_5 + loads_0[_S543 + u32(2)].xyz * _S544;
        f_ext_3 = f_ext_3 + loads_0[_S543 + u32(1)].xyz * _S544;
        m_ext_5 = m_ext_7;
        term_6 = term_6 + u32(1);
    }
    var f_17 : vec3<f32> = f_ext_3 + fi_1;
    var m_6 : vec3<f32> = m_ext_5 + mi_3;
    var support_1 : u32 = chunks_0[c_16].info_1.x;
    var _S545 : vec3<f32> = vec3<f32>(state_0[_S536].w, state_0[_S537].w, state_0[_S538].w);
    var reaction_1 : vec3<f32>;
    var u_4 : vec3<f32>;
    var th_5 : vec3<f32>;
    var v_14 : vec3<f32>;
    var w_9 : vec3<f32>;
    if(support_1 == u32(1))
    {
        reaction_1 = (vec3<f32>(0) - f_17);
        u_4 = u_3;
        th_5 = th_4;
        v_14 = _S530;
        w_9 = _S530;
    }
    else
    {
        var _S546 : vec4<f32> = chunks_0[c_16].scale_0;
        var w_10 : vec3<f32> = w_8 + rows_mul_0(chunks_0[c_16].inv0_1, chunks_0[c_16].inv1_1, chunks_0[c_16].inv2_1, m_6) * vec3<f32>((dt_18 * chunks_0[c_16].scale_0.z));
        var _S547 : vec3<f32> = vec3<f32>(dt_18);
        var th_6 : vec3<f32> = th_4 + w_10 * _S547;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_17);
            u_4 = u_3;
            th_5 = _S530;
        }
        else
        {
            var v_15 : vec3<f32> = v_13 + f_17 * vec3<f32>((dt_18 * _S546.y));
            var u_5 : vec3<f32> = u_3 + v_15 * _S547;
            reaction_1 = _S545;
            u_4 = u_5;
            th_5 = v_15;
        }
        var _S548 : vec3<f32> = th_5;
        th_5 = th_6;
        v_14 = _S548;
        w_9 = w_10;
    }
    state_0[_S535] = vec4<f32>(u_4, peak_1);
    state_0[_S536] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S537] = vec4<f32>(v_14, reaction_1.y);
    state_0[_S538] = vec4<f32>(w_9, reaction_1.z);
    comp_add1_2(&((*work_4)), &((*work_err_1)), (dot(f_load_1, rg_10.vel_1 + rg_10.vel_err_1 + cross(rg_10.w_4, rotate_0(rg_10.rot_0, _S539 + u_4 - _S540)) + rotate_0(rg_10.rot_0, v_14)) + dot(t_load_1, rg_10.w_4 + rotate_0(rg_10.rot_0, w_9))) * dt_18);
    return;
}

fn drift_moments_0( c_17 : u32,  tu_0 : ptr<function, vec3<f32>>,  pv_0 : ptr<function, vec3<f32>>)
{
    var _S549 : u32 = u32(4) * c_17;
    var _S550 : vec3<f32> = vec3<f32>((chunks_0[c_17].center_0.w * chunks_0[c_17].scale_0.x));
    (*tu_0) = (*tu_0) + state_0[_S549].xyz * _S550;
    (*pv_0) = (*pv_0) + state_0[_S549 + u32(2)].xyz * _S550;
    return;
}

fn drift_angular_0( c_18 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_12 : vec3<f32> = chunks_0[c_18].center_0.xyz - wcom_1;
    var _S551 : u32 = u32(4) * c_18;
    var _S552 : vec3<f32> = vec3<f32>(chunks_0[c_18].center_0.w);
    var _S553 : vec4<f32> = chunks_0[c_18].inertia0_1;
    var _S554 : vec4<f32> = chunks_0[c_18].inertia1_1;
    var _S555 : vec4<f32> = chunks_0[c_18].inertia2_1;
    var _S556 : vec3<f32> = vec3<f32>(chunks_0[c_18].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_12, state_0[_S551].xyz - tr_0) * _S552 + rows_mul_0(chunks_0[c_18].inertia0_1, chunks_0[c_18].inertia1_1, chunks_0[c_18].inertia2_1, state_0[_S551 + u32(1)].xyz)) * _S556;
    (*lv_0) = (*lv_0) + (cross(r_12, state_0[_S551 + u32(2)].xyz - dv_0) * _S552 + rows_mul_0(_S553, _S554, _S555, state_0[_S551 + u32(3)].xyz)) * _S556;
    return;
}

fn drift_apply_0( c_19 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  phi_0 : vec3<f32>,  dv_1 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_13 : vec3<f32> = chunks_0[c_19].center_0.xyz - wcom_2;
    var _S557 : u32 = u32(4) * c_19;
    state_0[_S557] = vec4<f32>(state_0[_S557].xyz - (tr_1 + cross(phi_0, r_13)), state_0[_S557].w);
    var _S558 : u32 = _S557 + u32(1);
    state_0[_S558] = vec4<f32>(state_0[_S558].xyz - phi_0, state_0[_S558].w);
    var _S559 : u32 = _S557 + u32(2);
    state_0[_S559] = vec4<f32>(state_0[_S559].xyz - (dv_1 + cross(dw_0, r_13)), state_0[_S559].w);
    var _S560 : u32 = _S557 + u32(3);
    state_0[_S560] = vec4<f32>(state_0[_S560].xyz - dw_0, state_0[_S560].w);
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
    dq_1.x_1 = d_16.x;
    dq_1.y_1 = d_16.y;
    dq_1.z_0 = d_16.z;
    dq_1.w_0 = d_16.w;
    quat_accumulate_0(&((*hi_3)), &((*lo_3)), quat_vec_0(quat_mul_0((*hi_3), dq_1)));
    return;
}

fn drift_rigid_0( isl_13 : ptr<function, Island_std430_0>,  rg_11 : ptr<function, Rigid_0>,  tr_2 : vec3<f32>,  phi_2 : vec3<f32>,  dv_2 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_3 : vec3<f32> = (*isl_13).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_11).rot_0;
    var _S561 : vec3<f32> = rotate_0((*rg_11).rot_0, tr_2 - cross(phi_2, wcom_3));
    var _S562 : vec3<f32> = (*rg_11).pos_1;
    var _S563 : vec3<f32> = (*rg_11).pos_err_1;
    comp_add_0(&(_S562), &(_S563), _S561);
    (*rg_11).pos_1 = _S562;
    (*rg_11).pos_err_1 = _S563;
    var b_40 : vec3<f32> = inverse_rotate_0((*rg_11).rot_0, (*rg_11).w_4);
    var _S564 : vec4<f32> = (*isl_13).inertia0_0;
    var _S565 : vec4<f32> = (*isl_13).inertia1_0;
    var _S566 : vec4<f32> = (*isl_13).inertia2_0;
    var dl_turn_0 : vec3<f32> = rotate_0((*rg_11).rot_0, cross(phi_2, rows_mul_0((*isl_13).inertia0_0, (*isl_13).inertia1_0, (*isl_13).inertia2_0, b_40)) - rows_mul_0((*isl_13).inertia0_0, (*isl_13).inertia1_0, (*isl_13).inertia2_0, cross(phi_2, b_40)));
    var _S567 : Quat_0 = (*rg_11).rot_0;
    var _S568 : vec4<f32> = (*rg_11).rot_err_0;
    turn_right_0(&(_S567), &(_S568), phi_2);
    (*rg_11).rot_0 = _S567;
    (*rg_11).rot_err_0 = _S568;
    var _S569 : vec3<f32> = rotate_0(rot_2, dv_2 + cross(dw_1, (*isl_13).com_0.xyz - wcom_3));
    var _S570 : vec3<f32> = (*rg_11).vel_1;
    var _S571 : vec3<f32> = (*rg_11).vel_err_1;
    comp_add_0(&(_S570), &(_S571), _S569);
    (*rg_11).vel_1 = _S570;
    (*rg_11).vel_err_1 = _S571;
    var _S572 : vec3<f32> = rotate_0(rot_2, dw_1);
    (*rg_11).w_4 = (*rg_11).w_4 + _S572;
    var _S573 : vec3<f32> = dl_turn_0 + world_mul_0(_S567, _S564, _S565, _S566, _S572);
    var _S574 : vec3<f32> = (*rg_11).l_2;
    var _S575 : vec3<f32> = (*rg_11).l_err_1;
    comp_add_0(&(_S574), &(_S575), _S573);
    (*rg_11).l_2 = _S574;
    (*rg_11).l_err_1 = _S575;
    return;
}

fn drift_rigid_1( isl_14 : Island_0,  rg_12 : ptr<function, Rigid_0>,  tr_3 : vec3<f32>,  phi_3 : vec3<f32>,  dv_3 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = isl_14.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_12).rot_0;
    var _S576 : vec3<f32> = rotate_0((*rg_12).rot_0, tr_3 - cross(phi_3, wcom_4));
    var _S577 : vec3<f32> = (*rg_12).pos_1;
    var _S578 : vec3<f32> = (*rg_12).pos_err_1;
    comp_add_0(&(_S577), &(_S578), _S576);
    (*rg_12).pos_1 = _S577;
    (*rg_12).pos_err_1 = _S578;
    var b_41 : vec3<f32> = inverse_rotate_0((*rg_12).rot_0, (*rg_12).w_4);
    var dl_turn_1 : vec3<f32> = rotate_0((*rg_12).rot_0, cross(phi_3, rows_mul_0(isl_14.inertia0_0, isl_14.inertia1_0, isl_14.inertia2_0, b_41)) - rows_mul_0(isl_14.inertia0_0, isl_14.inertia1_0, isl_14.inertia2_0, cross(phi_3, b_41)));
    var _S579 : Quat_0 = (*rg_12).rot_0;
    var _S580 : vec4<f32> = (*rg_12).rot_err_0;
    turn_right_0(&(_S579), &(_S580), phi_3);
    (*rg_12).rot_0 = _S579;
    (*rg_12).rot_err_0 = _S580;
    var _S581 : vec3<f32> = rotate_0(rot_3, dv_3 + cross(dw_2, isl_14.com_0.xyz - wcom_4));
    var _S582 : vec3<f32> = (*rg_12).vel_1;
    var _S583 : vec3<f32> = (*rg_12).vel_err_1;
    comp_add_0(&(_S582), &(_S583), _S581);
    (*rg_12).vel_1 = _S582;
    (*rg_12).vel_err_1 = _S583;
    var _S584 : vec3<f32> = rotate_0(rot_3, dw_2);
    (*rg_12).w_4 = (*rg_12).w_4 + _S584;
    var _S585 : vec3<f32> = dl_turn_1 + world_mul_0(_S579, isl_14.inertia0_0, isl_14.inertia1_0, isl_14.inertia2_0, _S584);
    var _S586 : vec3<f32> = (*rg_12).l_2;
    var _S587 : vec3<f32> = (*rg_12).l_err_1;
    comp_add_0(&(_S586), &(_S587), _S585);
    (*rg_12).l_2 = _S586;
    (*rg_12).l_err_1 = _S587;
    return;
}

fn contact_split_at_0( at_6 : u32)
{
    var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S588 : u32;
    if(previous_1 == u32(0))
    {
        _S588 = at_6;
    }
    else
    {
        _S588 = min(previous_1, at_6);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S588;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var woke_0 : bool;
    var tid_5 : u32 = thread_2.x;
    var _S589 : u32 = group_2.x;
    var isl_15 : Island_0;
    isl_15.range_0 = islands_0[_S589].range_0;
    isl_15.info_0 = islands_0[_S589].info_0;
    isl_15.com_0 = islands_0[_S589].com_0;
    isl_15.inertia0_0 = islands_0[_S589].inertia0_0;
    isl_15.inertia1_0 = islands_0[_S589].inertia1_0;
    isl_15.inertia2_0 = islands_0[_S589].inertia2_0;
    isl_15.inv0_0 = islands_0[_S589].inv0_0;
    isl_15.inv1_0 = islands_0[_S589].inv1_0;
    isl_15.inv2_0 = islands_0[_S589].inv2_0;
    isl_15.wcom_0 = islands_0[_S589].wcom_0;
    isl_15.winv0_0 = islands_0[_S589].winv0_0;
    isl_15.winv1_0 = islands_0[_S589].winv1_0;
    isl_15.winv2_0 = islands_0[_S589].winv2_0;
    isl_15.rotation_0 = islands_0[_S589].rotation_0;
    isl_15.position_0 = islands_0[_S589].position_0;
    isl_15.position_err_0 = islands_0[_S589].position_err_0;
    isl_15.velocity_0 = islands_0[_S589].velocity_0;
    isl_15.velocity_err_0 = islands_0[_S589].velocity_err_0;
    isl_15.angular_velocity_0 = islands_0[_S589].angular_velocity_0;
    isl_15.done_0 = islands_0[_S589].done_0;
    isl_15.probes_0 = islands_0[_S589].probes_0;
    isl_15.energy_0 = islands_0[_S589].energy_0;
    isl_15.rotation_err_0 = islands_0[_S589].rotation_err_0;
    isl_15.momentum_0 = islands_0[_S589].momentum_0;
    isl_15.momentum_err_0 = islands_0[_S589].momentum_err_0;
    var driven_0 : bool = (((isl_15.info_0.x) & (u32(2)))) != u32(0);
    var _S590 : bool = !((((isl_15.info_0.x) & (u32(1)))) != u32(0));
    var _S591 : bool;
    if(_S590)
    {
        _S591 = !driven_0;
    }
    else
    {
        _S591 = false;
    }
    var contact_island_0 : bool = (((isl_15.info_0.x) & (u32(4)))) != u32(0);
    var _S592 : bool = (((isl_15.info_0.x) & (u32(16)))) != u32(0);
    var _S593 : bool = tid_5 == u32(0);
    var settled_0 : bool;
    var run_0 : u32;
    if(_S593)
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
    var _S594 : f32 = params_0.dt_0;
    var _S595 : bool = (params_0.fracture_0) != u32(0);
    var _S596 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_13 : Rigid_0 = rigid_of_1(isl_15);
    var work_5 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S592;
    var done_1 : u32 = u32(0);
    var woke_1 : bool = false;
    var s_9 : u32 = u32(0);
    loop
    {
        if(s_9 < run_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        var abs_step_1 : u32 = isl_15.info_0.w + s_9 + u32(1);
        var k_21 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var _S597 : bool;
        var settled_1 : bool;
        if((((isl_15.info_0.x) & (u32(32)))) != u32(0))
        {
            if(_S593)
            {
                _S597 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S597 = false;
            }
            if(_S597)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            var _S598 : u32 = s_9 + u32(1);
            settled_1 = settled_0;
            done_1 = _S598;
            woke_0 = woke_1;
            var _S599 : u32 = s_9 + u32(1);
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_9 = _S599;
            continue;
        }
        var i_10 : u32;
        if(settled_0)
        {
            var _S600 : vec3<f32> = vec3<f32>(0.0f);
            var norm_0 : vec3<f32> = _S600;
            var unused0_0 : vec3<f32> = _S600;
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
                var _S601 : f32 = settled_chunk_load_0(i_10, rg_13.rot_0, k_21, _S594, contact_island_0);
                norm_0[i32(0)] = norm_0[i32(0)] + _S601;
                i_10 = i_10 + u32(256);
            }
            group_sum3_0(tid_5, &(norm_0), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S597 = (abs(norm_0.x - isl_15.energy_0.z)) > (isl_15.energy_0.w);
            }
            else
            {
                _S597 = false;
            }
            if(_S597)
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
        if(_S590)
        {
            var _S602 : vec3<f32> = vec3<f32>(0.0f);
            var f_18 : vec3<f32> = _S602;
            var t_16 : vec3<f32> = _S602;
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
                net_load_1(i_10, isl_15, rg_13, k_21, _S594, contact_island_0, &(f_18), &(t_16));
                i_10 = i_10 + u32(256);
            }
            group_sum3_0(tid_5, &(f_18), &(t_16));
            rigid_acceleration_1(isl_15, &(rg_13), f_18, t_16);
        }
        if(settled_1)
        {
            if(_S591)
            {
                integrate_rigid_1(isl_15, &(rg_13), _S594);
            }
            if(_S593)
            {
                _S597 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S597 = false;
            }
            if(_S597)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            done_1 = s_9 + u32(1);
            var _S599 : u32 = s_9 + u32(1);
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_9 = _S599;
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
            var _S603 : bool = bond_update_0(i_10, _S594, _S595, abs_step_1);
            if(_S603)
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
            chunk_update_1(c_20, isl_15, rg_13, _S594, _S596, k_21, contact_island_0, &(work_5), &(work_err_2));
            c_20 = c_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S591)
        {
            integrate_rigid_1(isl_15, &(rg_13), _S594);
        }
        if(_S590)
        {
            var _S604 : vec3<f32> = isl_15.wcom_0.xyz;
            var _S605 : vec3<f32> = vec3<f32>(0.0f);
            var tu_1 : vec3<f32> = _S605;
            var pv_1 : vec3<f32> = _S605;
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
            var lu_1 : vec3<f32> = _S605;
            var lv_1 : vec3<f32> = _S605;
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
                drift_angular_0(c_22, _S604, tr_4, dv_4, &(lu_1), &(lv_1));
                c_22 = c_22 + u32(256);
            }
            group_sum3_0(tid_5, &(lu_1), &(lv_1));
            var phi_4 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lu_1);
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
                drift_apply_0(c_23, _S604, tr_4, phi_4, dv_4, dw_3);
                c_23 = c_23 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_15, &(rg_13), tr_4, phi_4, dv_4, dw_3);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S593)
        {
            _S597 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
        }
        else
        {
            _S597 = false;
        }
        if(_S597)
        {
            record_probes_0(isl_15, rg_13, k_21);
        }
        var _S606 : u32 = s_9 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S606;
            break;
        }
        done_1 = _S606;
        var _S599 : u32 = s_9 + u32(1);
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_9 = _S599;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_5, work_err_2, 0.0f);
    var unused_1 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_5, &(wsum_0), &(unused_1));
    if(_S593)
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
        isl_15.done_0[i32(0)] = done_1;
        isl_15.info_0[i32(1)] = isl_15.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S591 = contact_island_0;
        }
        else
        {
            _S591 = false;
        }
        if(_S591)
        {
            contact_split_at_0(isl_15.info_0.w + done_1);
        }
        var _S607 : f32 = wsum_0.x;
        var _S608 : f32 = isl_15.energy_0[i32(0)];
        var _S609 : f32 = isl_15.energy_0[i32(1)];
        comp_add1_2(&(_S608), &(_S609), _S607);
        isl_15.energy_0[i32(0)] = _S608;
        isl_15.energy_0[i32(1)] = _S609 + wsum_0.y;
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
        islands_0[_S589].range_0 = isl_15.range_0;
        islands_0[_S589].info_0 = isl_15.info_0;
        islands_0[_S589].com_0 = isl_15.com_0;
        islands_0[_S589].inertia0_0 = isl_15.inertia0_0;
        islands_0[_S589].inertia1_0 = isl_15.inertia1_0;
        islands_0[_S589].inertia2_0 = isl_15.inertia2_0;
        islands_0[_S589].inv0_0 = isl_15.inv0_0;
        islands_0[_S589].inv1_0 = isl_15.inv1_0;
        islands_0[_S589].inv2_0 = isl_15.inv2_0;
        islands_0[_S589].wcom_0 = isl_15.wcom_0;
        islands_0[_S589].winv0_0 = isl_15.winv0_0;
        islands_0[_S589].winv1_0 = isl_15.winv1_0;
        islands_0[_S589].winv2_0 = isl_15.winv2_0;
        islands_0[_S589].rotation_0 = isl_15.rotation_0;
        islands_0[_S589].position_0 = isl_15.position_0;
        islands_0[_S589].position_err_0 = isl_15.position_err_0;
        islands_0[_S589].velocity_0 = isl_15.velocity_0;
        islands_0[_S589].velocity_err_0 = isl_15.velocity_err_0;
        islands_0[_S589].angular_velocity_0 = isl_15.angular_velocity_0;
        islands_0[_S589].done_0 = isl_15.done_0;
        islands_0[_S589].probes_0 = isl_15.probes_0;
        islands_0[_S589].energy_0 = isl_15.energy_0;
        islands_0[_S589].rotation_err_0 = isl_15.rotation_err_0;
        islands_0[_S589].momentum_0 = isl_15.momentum_0;
        islands_0[_S589].momentum_err_0 = isl_15.momentum_err_0;
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
    var _S610 : u32 = table_0 + u32(4) * g_4;
    w_11.island_0 = index_0[_S610];
    w_11.begin_1 = index_0[_S610 + u32(1)];
    w_11.end_0 = index_0[_S610 + u32(2)];
    w_11.first_1 = index_0[_S610 + u32(3)];
    return w_11;
}

fn wide_runs_0( isl_16 : ptr<function, Island_std430_0>) -> bool
{
    var _S611 : vec4<u32> = (*isl_16).info_0;
    var _S612 : bool;
    if(((((*isl_16).info_0.z) & (u32(1)))) != u32(0))
    {
        _S612 = true;
    }
    else
    {
        _S612 = (_S611.y) == u32(0);
    }
    if(_S612)
    {
        return false;
    }
    if((((_S611.x) & (u32(4)))) == u32(0))
    {
        _S612 = true;
    }
    else
    {
        var _S613 : bool = contact_stopped_0(&((*isl_16)));
        _S612 = !_S613;
    }
    return _S612;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_6 : u32,  isl_17 : ptr<function, Island_std430_0>) -> bool
{
    if(tid_6 == u32(0))
    {
        var _S614 : bool = wide_runs_0(&((*isl_17)));
        var _S615 : i32;
        if(_S614)
        {
            _S615 = i32(1);
        }
        else
        {
            _S615 = i32(0);
        }
        g_wide_run_0 = u32(_S615);
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

fn contact_stopped_2( _S616 : u32) -> bool
{
    var _S617 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S618 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S618 = true;
    }
    else
    {
        var _S619 : u32 = _S617.y;
        if(_S619 != u32(0))
        {
            _S618 = _S619 <= (islands_0[_S616].info_0.w);
        }
        else
        {
            _S618 = false;
        }
    }
    return _S618;
}

fn wide_runs_1( _S620 : u32) -> bool
{
    var _S621 : vec4<u32> = islands_0[_S620].info_0;
    var _S622 : bool;
    if((((islands_0[_S620].info_0.z) & (u32(1)))) != u32(0))
    {
        _S622 = true;
    }
    else
    {
        _S622 = (_S621.y) == u32(0);
    }
    if(_S622)
    {
        return false;
    }
    if((((_S621.x) & (u32(4)))) == u32(0))
    {
        _S622 = true;
    }
    else
    {
        _S622 = !contact_stopped_2(_S620);
    }
    return _S622;
}

fn wide_enter_1( _S623 : u32,  _S624 : u32) -> bool
{
    if(_S623 == u32(0))
    {
        var _S625 : i32;
        if(wide_runs_1(_S624))
        {
            _S625 = i32(1);
        }
        else
        {
            _S625 = i32(0);
        }
        g_wide_run_0 = u32(_S625);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_7 : u32 = thread_3.x;
    var _S626 : u32 = group_3.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S626);
    if(_S626 != (wg_0.first_1))
    {
        return;
    }
    var _S627 : Island_std430_0 = islands_0[wg_0.island_0];
    var _S628 : vec4<u32> = _S627.info_0;
    var _S629 : u32 = _S627.info_0.x;
    var _S630 : bool;
    if(((_S629 & (u32(16)))) == u32(0))
    {
        _S630 = true;
    }
    else
    {
        var _S631 : bool = wide_enter_1(tid_7, wg_0.island_0);
        _S630 = !_S631;
    }
    if(_S630)
    {
        return;
    }
    var _S632 : Quat_0 = quat_of_0(_S627.rotation_0);
    var _S633 : bool = ((_S629 & (u32(4)))) != u32(0);
    var _S634 : vec3<f32> = vec3<f32>(0.0f);
    var norm_1 : vec3<f32> = _S634;
    var unused_2 : vec3<f32> = _S634;
    var _S635 : vec4<u32> = _S627.range_0;
    var c_24 : u32 = _S627.range_0.x + tid_7;
    loop
    {
        if(c_24 < (_S635.y))
        {
        }
        else
        {
            break;
        }
        var _S636 : u32 = wide_step_0(&(_S627));
        var _S637 : f32 = settled_chunk_load_0(c_24, _S632, _S636, params_0.dt_0, _S633);
        norm_1[i32(0)] = norm_1[i32(0)] + _S637;
        c_24 = c_24 + u32(256);
    }
    group_sum3_0(tid_7, &(norm_1), &(unused_2));
    if(tid_7 == u32(0))
    {
        _S630 = (params_0.solve_mode_0) == u32(1);
    }
    else
    {
        _S630 = false;
    }
    if(_S630)
    {
        _S630 = (abs(norm_1.x - _S627.energy_0.z)) > (_S627.energy_0.w);
    }
    else
    {
        _S630 = false;
    }
    if(_S630)
    {
        islands_0[wg_0.island_0].info_0[i32(0)] = (_S629 & (u32(4294967279)));
        islands_0[wg_0.island_0].info_0[i32(2)] = ((_S628.z) | (u32(4)));
    }
    return;
}

fn wide_store_0( slot_2 : u32,  p_16 : u32,  a_18 : vec3<f32>,  b_42 : vec3<f32>)
{
    var _S638 : u32 = u32(8) * slot_2;
    scratch_0[params_0.wide_base_0 + _S638 + p_16] = vec4<f32>(a_18, 0.0f);
    scratch_0[params_0.wide_base_0 + _S638 + p_16 + u32(1)] = vec4<f32>(b_42, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_8 : u32 = thread_4.x;
    var _S639 : u32 = group_4.x;
    var bond_group_0 : bool = _S639 < (params_0.wide_bond_groups_0);
    var wg_1 : WideGroup_0;
    if(bond_group_0)
    {
        wg_1 = wide_group_0(params_0.wide_bond_table_0, _S639);
    }
    else
    {
        wg_1 = wide_group_0(params_0.wide_chunk_table_0, _S639 - params_0.wide_bond_groups_0);
    }
    var _S640 : WideGroup_0 = wg_1;
    var _S641 : Island_std430_0 = islands_0[wg_1.island_0];
    var _S642 : bool = wide_enter_1(tid_8, wg_1.island_0);
    if(!_S642)
    {
        return;
    }
    var _S643 : u32 = wide_step_0(&(_S641));
    if(bond_group_0)
    {
        var _S644 : vec4<u32> = _S641.info_0;
        if((((_S641.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_11 : u32 = wg_1.begin_1 + tid_8;
        var _S645 : bool;
        if(i_11 < (wg_1.end_0))
        {
            var _S646 : bool = bond_update_0(i_11, params_0.dt_0, (params_0.fracture_0) != u32(0), _S644.w + u32(1));
            _S645 = _S646;
        }
        else
        {
            _S645 = false;
        }
        if(_S645)
        {
            islands_0[_S640.island_0].info_0[i32(2)] = ((_S644.z) | (u32(2)));
        }
        return;
    }
    var _S647 : u32 = _S641.info_0.x;
    if(((_S647 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S648 : vec3<f32> = vec3<f32>(0.0f);
    var f_19 : vec3<f32> = _S648;
    var t_17 : vec3<f32> = _S648;
    var c_25 : u32 = wg_1.begin_1 + tid_8;
    if(c_25 < (wg_1.end_0))
    {
        var _S649 : Rigid_0 = rigid_of_0(&(_S641));
        net_load_0(c_25, &(_S641), _S649, _S643, params_0.dt_0, ((_S647 & (u32(4)))) != u32(0), &(f_19), &(t_17));
    }
    group_sum3_0(tid_8, &(f_19), &(t_17));
    if(tid_8 == u32(0))
    {
        wide_store_0(_S639 - params_0.wide_bond_groups_0, u32(0), f_19, t_17);
    }
    return;
}

fn wide_partials_0( tid_9 : u32,  first_2 : u32,  count_5 : u32,  p_17 : u32,  a_19 : ptr<function, vec3<f32>>,  b_43 : ptr<function, vec3<f32>>)
{
    var _S650 : vec4<f32> = vec4<f32>(0.0f);
    var x_12 : vec4<f32> = _S650;
    var y_2 : vec4<f32> = _S650;
    var s_10 : u32 = tid_9;
    loop
    {
        if(s_10 < count_5)
        {
        }
        else
        {
            break;
        }
        var _S651 : u32 = u32(8) * (first_2 + s_10);
        x_12 = x_12 + scratch_0[params_0.wide_base_0 + _S651 + p_17];
        y_2 = y_2 + scratch_0[params_0.wide_base_0 + _S651 + p_17 + u32(1)];
        s_10 = s_10 + u32(256);
    }
    group_sum2_0(tid_9, &(x_12), &(y_2));
    (*a_19) = x_12.xyz;
    (*b_43) = y_2.xyz;
    return;
}

fn wide_rigid_frame_0( tid_10 : u32,  isl_20 : ptr<function, Island_std430_0>,  wg_2 : WideGroup_0) -> Rigid_0
{
    var _S652 : Rigid_0 = rigid_of_0(&((*isl_20)));
    var rg_14 : Rigid_0 = _S652;
    if(((((*isl_20).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_20 : vec3<f32>;
        var t_18 : vec3<f32>;
        wide_partials_0(tid_10, wg_2.first_1, (*isl_20).done_0.z, u32(0), &(f_20), &(t_18));
        rigid_acceleration_0(&((*isl_20)), &(rg_14), f_20, t_18);
    }
    return rg_14;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var tid_11 : u32 = thread_5.x;
    var _S653 : u32 = group_5.x;
    var wg_3 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S653);
    var _S654 : Island_std430_0 = islands_0[wg_3.island_0];
    var _S655 : bool = wide_enter_1(tid_11, wg_3.island_0);
    if(!_S655)
    {
        return;
    }
    var _S656 : u32 = _S654.info_0.x;
    var anchored_0 : bool = ((_S656 & (u32(1)))) != u32(0);
    if(((_S656 & (u32(16)))) != u32(0))
    {
        if(tid_11 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * _S653 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S657 : Rigid_0 = wide_rigid_frame_0(tid_11, &(_S654), wg_3);
    var work_6 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S658 : vec3<f32> = vec3<f32>(0.0f);
    var tu_2 : vec3<f32> = _S658;
    var pv_2 : vec3<f32> = _S658;
    var c_26 : u32 = wg_3.begin_1 + tid_11;
    if(c_26 < (wg_3.end_0))
    {
        var _S659 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S660 : u32 = wide_step_0(&(_S654));
        chunk_update_0(c_26, &(_S654), _S657, params_0.dt_0, _S659, _S660, ((_S656 & (u32(4)))) != u32(0), &(work_6), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_26, &(tu_2), &(pv_2));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_6, work_err_3, 0.0f);
    var unused_3 : vec3<f32> = _S658;
    group_sum3_0(tid_11, &(wsum_1), &(unused_3));
    var _S661 : bool = !anchored_0;
    if(_S661)
    {
        group_sum3_0(tid_11, &(tu_2), &(pv_2));
    }
    if(tid_11 == u32(0))
    {
        scratch_0[params_0.wide_base_0 + u32(8) * _S653 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S661)
        {
            wide_store_0(_S653, u32(2), tu_2, pv_2);
        }
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_12 : u32 = thread_6.x;
    var _S662 : u32 = group_6.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S662);
    var isl_21 : Island_std430_0 = islands_0[wg_4.island_0];
    var _S663 : bool;
    if((((islands_0[wg_4.island_0].info_0.x) & (u32(17)))) != u32(0))
    {
        _S663 = true;
    }
    else
    {
        var _S664 : bool = wide_enter_1(tid_12, wg_4.island_0);
        _S663 = !_S664;
    }
    if(_S663)
    {
        return;
    }
    var tu_3 : vec3<f32>;
    var pv_3 : vec3<f32>;
    wide_partials_0(tid_12, wg_4.first_1, isl_21.done_0.z, u32(2), &(tu_3), &(pv_3));
    var _S665 : vec3<f32> = vec3<f32>(isl_21.wcom_0.w);
    var tr_5 : vec3<f32> = tu_3 / _S665;
    var dv_5 : vec3<f32> = pv_3 / _S665;
    var _S666 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S666;
    var lv_2 : vec3<f32> = _S666;
    var c_27 : u32 = wg_4.begin_1 + tid_12;
    if(c_27 < (wg_4.end_0))
    {
        drift_angular_0(c_27, isl_21.wcom_0.xyz, tr_5, dv_5, &(lu_2), &(lv_2));
    }
    group_sum3_0(tid_12, &(lu_2), &(lv_2));
    if(tid_12 == u32(0))
    {
        wide_store_0(_S662, u32(4), lu_2, lv_2);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_13 : u32 = thread_7.x;
    var _S667 : u32 = group_7.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S667);
    var _S668 : Island_std430_0 = islands_0[wg_5.island_0];
    var _S669 : u32 = _S668.info_0.x;
    var _S670 : bool;
    if(((_S669 & (u32(1)))) != u32(0))
    {
        _S670 = true;
    }
    else
    {
        var _S671 : bool = wide_enter_1(tid_13, wg_5.island_0);
        _S670 = !_S671;
    }
    if(_S670)
    {
        return;
    }
    if(((_S669 & (u32(16)))) != u32(0))
    {
        if(_S667 != (wg_5.first_1))
        {
            return;
        }
        var _S672 : Rigid_0 = wide_rigid_frame_0(tid_13, &(_S668), wg_5);
        var rs_0 : Rigid_0 = _S672;
        if(tid_13 != u32(0))
        {
            _S670 = true;
        }
        else
        {
            _S670 = ((_S669 & (u32(2)))) != u32(0);
        }
        if(_S670)
        {
            return;
        }
        integrate_rigid_0(&(_S668), &(rs_0), params_0.dt_0);
        islands_0[wg_5.island_0].rotation_0 = quat_vec_0(rs_0.rot_0);
        islands_0[wg_5.island_0].rotation_err_0 = rs_0.rot_err_0;
        islands_0[wg_5.island_0].position_0 = vec4<f32>(rs_0.pos_1, 0.0f);
        islands_0[wg_5.island_0].position_err_0 = vec4<f32>(rs_0.pos_err_1, 0.0f);
        islands_0[wg_5.island_0].velocity_0 = vec4<f32>(rs_0.vel_1, 0.0f);
        islands_0[wg_5.island_0].velocity_err_0 = vec4<f32>(rs_0.vel_err_1, 0.0f);
        islands_0[wg_5.island_0].angular_velocity_0 = vec4<f32>(rs_0.w_4, 0.0f);
        islands_0[wg_5.island_0].momentum_0 = vec4<f32>(rs_0.l_2, 0.0f);
        islands_0[wg_5.island_0].momentum_err_0 = vec4<f32>(rs_0.l_err_1, 0.0f);
        return;
    }
    var _S673 : u32 = _S668.done_0.z;
    var tu_4 : vec3<f32>;
    var pv_4 : vec3<f32>;
    wide_partials_0(tid_13, wg_5.first_1, _S673, u32(2), &(tu_4), &(pv_4));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_0(tid_13, wg_5.first_1, _S673, u32(4), &(lu_3), &(lv_3));
    var _S674 : vec4<f32> = _S668.wcom_0;
    var _S675 : vec3<f32> = vec3<f32>(_S668.wcom_0.w);
    var tr_6 : vec3<f32> = tu_4 / _S675;
    var dv_6 : vec3<f32> = pv_4 / _S675;
    var phi_5 : vec3<f32> = rows_mul_0(_S668.winv0_0, _S668.winv1_0, _S668.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S668.winv0_0, _S668.winv1_0, _S668.winv2_0, lv_3);
    var c_28 : u32 = wg_5.begin_1 + tid_13;
    if(c_28 < (wg_5.end_0))
    {
        drift_apply_0(c_28, _S674.xyz, tr_6, phi_5, dv_6, dw_4);
    }
    if(_S667 != (wg_5.first_1))
    {
        return;
    }
    var _S676 : Rigid_0 = wide_rigid_frame_0(tid_13, &(_S668), wg_5);
    var rg_15 : Rigid_0 = _S676;
    if(tid_13 != u32(0))
    {
        return;
    }
    if(!(((_S669 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S668), &(rg_15), params_0.dt_0);
        drift_rigid_0(&(_S668), &(rg_15), tr_6, phi_5, dv_6, dw_4);
    }
    islands_0[wg_5.island_0].rotation_0 = quat_vec_0(rg_15.rot_0);
    islands_0[wg_5.island_0].rotation_err_0 = rg_15.rot_err_0;
    islands_0[wg_5.island_0].position_0 = vec4<f32>(rg_15.pos_1, 0.0f);
    islands_0[wg_5.island_0].position_err_0 = vec4<f32>(rg_15.pos_err_1, 0.0f);
    islands_0[wg_5.island_0].velocity_0 = vec4<f32>(rg_15.vel_1, 0.0f);
    islands_0[wg_5.island_0].velocity_err_0 = vec4<f32>(rg_15.vel_err_1, 0.0f);
    islands_0[wg_5.island_0].angular_velocity_0 = vec4<f32>(rg_15.w_4, 0.0f);
    islands_0[wg_5.island_0].momentum_0 = vec4<f32>(rg_15.l_2, 0.0f);
    islands_0[wg_5.island_0].momentum_err_0 = vec4<f32>(rg_15.l_err_1, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_end(@builtin(workgroup_id) group_8 : vec3<u32>, @builtin(local_invocation_id) thread_8 : vec3<u32>)
{
    var tid_14 : u32 = thread_8.x;
    var _S677 : u32 = group_8.x;
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S677);
    if(_S677 != (wg_6.first_1))
    {
        return;
    }
    var _S678 : Island_std430_0 = islands_0[wg_6.island_0];
    var isl_22 : Island_0;
    isl_22.range_0 = _S678.range_0;
    isl_22.info_0 = _S678.info_0;
    isl_22.com_0 = _S678.com_0;
    isl_22.inertia0_0 = _S678.inertia0_0;
    isl_22.inertia1_0 = _S678.inertia1_0;
    isl_22.inertia2_0 = _S678.inertia2_0;
    isl_22.inv0_0 = _S678.inv0_0;
    isl_22.inv1_0 = _S678.inv1_0;
    isl_22.inv2_0 = _S678.inv2_0;
    isl_22.wcom_0 = _S678.wcom_0;
    isl_22.winv0_0 = _S678.winv0_0;
    isl_22.winv1_0 = _S678.winv1_0;
    isl_22.winv2_0 = _S678.winv2_0;
    isl_22.rotation_0 = _S678.rotation_0;
    isl_22.position_0 = _S678.position_0;
    isl_22.position_err_0 = _S678.position_err_0;
    isl_22.velocity_0 = _S678.velocity_0;
    isl_22.velocity_err_0 = _S678.velocity_err_0;
    isl_22.angular_velocity_0 = _S678.angular_velocity_0;
    isl_22.done_0 = _S678.done_0;
    isl_22.probes_0 = _S678.probes_0;
    isl_22.energy_0 = _S678.energy_0;
    isl_22.rotation_err_0 = _S678.rotation_err_0;
    isl_22.momentum_0 = _S678.momentum_0;
    isl_22.momentum_err_0 = _S678.momentum_err_0;
    var _S679 : bool = wide_enter_0(tid_14, &(_S678));
    if(!_S679)
    {
        return;
    }
    var work_7 : vec3<f32>;
    var unused_4 : vec3<f32>;
    wide_partials_0(tid_14, wg_6.first_1, isl_22.done_0.z, u32(6), &(work_7), &(unused_4));
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
    var _S680 : bool;
    if(halt_0)
    {
        _S680 = (((isl_22.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        _S680 = false;
    }
    if(_S680)
    {
        contact_split_at_0(isl_22.info_0.w + u32(1));
    }
    var _S681 : f32 = work_7.x;
    var _S682 : f32 = isl_22.energy_0[i32(0)];
    var _S683 : f32 = isl_22.energy_0[i32(1)];
    comp_add1_2(&(_S682), &(_S683), _S681);
    isl_22.energy_0[i32(0)] = _S682;
    isl_22.energy_0[i32(1)] = _S683 + work_7.y;
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
    islands_0[wg_6.island_0].rotation_err_0 = isl_22.rotation_err_0;
    islands_0[wg_6.island_0].momentum_0 = isl_22.momentum_0;
    islands_0[wg_6.island_0].momentum_err_0 = isl_22.momentum_err_0;
    return;
}

fn sv_0( c_29 : u32,  slot_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * c_29 + slot_3;
}

fn project_load_slot_0( tid_15 : u32,  isl_23 : ptr<function, Island_std430_0>,  slot_4 : u32)
{
    var _S684 : u32;
    var _S685 : vec3<f32> = vec3<f32>(0.0f);
    var net_f_0 : vec3<f32> = _S685;
    var net_m_0 : vec3<f32> = _S685;
    var _S686 : vec4<u32> = (*isl_23).range_0;
    var _S687 : u32 = (*isl_23).range_0.x + tid_15;
    var c_30 : u32 = _S687;
    loop
    {
        var _S688 : u32 = _S686.y;
        _S684 = _S688;
        if(c_30 < _S688)
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
    var _S689 : vec4<f32> = (*isl_23).com_0;
    var _S690 : vec3<f32> = net_f_0 / vec3<f32>((*isl_23).com_0.w);
    var _S691 : vec3<f32> = rows_mul_0((*isl_23).inv0_0, (*isl_23).inv1_0, (*isl_23).inv2_0, net_m_0);
    c_30 = _S687;
    loop
    {
        if(c_30 < _S684)
        {
        }
        else
        {
            break;
        }
        var _S692 : u32 = sv_0(c_30, slot_4);
        scratch_0[_S692] = vec4<f32>(scratch_0[_S692].xyz - (_S690 + cross(_S691, chunks_0[c_30].center_0.xyz - _S689.xyz)) * vec3<f32>(chunks_0[c_30].center_0.w), 0.0f);
        var _S693 : u32 = sv_0(c_30, slot_4 + u32(1));
        scratch_0[_S693] = vec4<f32>(scratch_0[_S693].xyz - rows_mul_0(chunks_0[c_30].inertia0_1, chunks_0[c_30].inertia1_1, chunks_0[c_30].inertia2_1, _S691), 0.0f);
        c_30 = c_30 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn island_dot_0( tid_16 : u32,  c0_0 : u32,  c1_0 : u32,  sa_0 : u32,  sb_0 : u32) -> f32
{
    var _S694 : vec4<f32> = vec4<f32>(0.0f);
    var acc_0 : vec4<f32> = _S694;
    var unused_5 : vec4<f32> = _S694;
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
    group_sum2_1(tid_16, &(acc_0), &(unused_5));
    return acc_0.x;
}

fn static_kinematics_0( _S695 : u32,  _S696 : ptr<function, vec3<f32>>,  _S697 : ptr<function, vec3<f32>>)
{
    var ca_1 : u32 = bonds_0[_S695].law_0.ids_0.y;
    var cb_4 : u32 = bonds_0[_S695].law_0.ids_0.z;
    var _S698 : u32 = u32(4) * cb_4;
    var _S699 : u32 = u32(4) * ca_1;
    var _S700 : u32 = _S698 + u32(1);
    var _S701 : u32 = _S699 + u32(1);
    var _S702 : u32 = sv_0(cb_4, u32(22));
    var _S703 : u32 = sv_0(ca_1, u32(22));
    var dth_0 : vec3<f32> = state_0[_S700].xyz - state_0[_S701].xyz + (scratch_0[_S702].xyz - scratch_0[_S703].xyz);
    (*_S696) = to_local_0(_S695, state_0[_S698].xyz - state_0[_S699].xyz + (scratch_0[sv_0(cb_4, u32(21))].xyz - scratch_0[sv_0(ca_1, u32(21))].xyz) + (cross(state_0[_S700].xyz + scratch_0[_S702].xyz, bonds_0[_S695].rb_0.xyz) - cross(state_0[_S701].xyz + scratch_0[_S703].xyz, bonds_0[_S695].ra_0.xyz)));
    (*_S697) = to_local_0(_S695, dth_0);
    return;
}

fn static_response_0( i_12 : u32) -> JointResponse_0
{
    var d_lin_7 : vec3<f32>;
    var d_ang_5 : vec3<f32>;
    static_kinematics_0(i_12, &(d_lin_7), &(d_ang_5));
    var _S704 : JointBond_std430_0 = bonds_0[i_12].law_0;
    var _S705 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S704.ids_0.x];
    var _S706 : JointState_std430_0 = bond_dyn_0[i_12].js_0;
    var _S707 : JointResponse_0 = joint_evaluate_2(&(_S705), &(_S704), &(_S706), d_lin_7, d_ang_5, 0.0f, false);
    return _S707;
}

fn gather_loads_0( c_32 : u32,  fi_3 : ptr<function, vec3<f32>>,  mi_6 : ptr<function, vec3<f32>>)
{
    var _S708 : vec3<f32> = vec3<f32>(0.0f);
    (*fi_3) = _S708;
    (*mi_6) = _S708;
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
            var _S709 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) + scratch_0[_S709].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S709 + u32(1)].xyz;
        }
        else
        {
            var _S710 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) - scratch_0[_S710].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S710 + u32(2)].xyz;
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
        var _S711 : u32 = u32(3) * ((entry_5 >> (u32(1))));
        var f_21 : vec3<f32> = scratch_0[_S711].xyz;
        var t_19 : vec3<f32>;
        if(((entry_5 & (u32(1)))) == u32(0))
        {
            t_19 = scratch_0[_S711 + u32(1)].xyz;
        }
        else
        {
            t_19 = scratch_0[_S711 + u32(2)].xyz;
        }
        var m_8 : f32 = m_7 + (dot(f_21, f_21) + dot(t_19, t_19));
        e_6 = e_6 + u32(1);
        m_7 = m_8;
    }
    return m_7;
}

fn fixed_mask_0( c_34 : u32) -> u32
{
    var support_2 : u32 = chunks_0[c_34].info_1.x;
    var _S712 : u32;
    if(support_2 == u32(1))
    {
        _S712 = u32(63);
    }
    else
    {
        if(support_2 == u32(2))
        {
            _S712 = u32(7);
        }
        else
        {
            _S712 = u32(0);
        }
    }
    return _S712;
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

fn statics_bond_slot_0( i_13 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * i_13;
}

fn store_inverse_0( c_35 : u32,  a_20 : array<f32, i32(36)>)
{
    var j_7 : u32;
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
    var i_14 : u32 = u32(0);
    loop
    {
        var _S713 : bool;
        if(i_14 < u32(6))
        {
            _S713 = spd_0;
        }
        else
        {
            _S713 = false;
        }
        if(_S713)
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
            var _S714 : u32 = i_14 * u32(6);
            var _S715 : u32 = _S714 + j_7;
            k_23 = u32(0);
            sum_6 = a_20[_S715];
            loop
            {
                if(k_23 < j_7)
                {
                }
                else
                {
                    break;
                }
                var sum_7 : f32 = sum_6 - l_5[_S714 + k_23] * l_5[j_7 * u32(6) + k_23];
                k_23 = k_23 + u32(1);
                sum_6 = sum_7;
            }
            if(i_14 == j_7)
            {
                if(sum_6 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S714 + i_14] = sqrt(sum_6);
            }
            else
            {
                l_5[_S715] = sum_6 / l_5[j_7 * u32(6) + j_7];
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
            var _S716 : u32 = k_23 * u32(6) + k_23;
            if((a_20[_S716]) > 0.0f)
            {
                sum_6 = 1.0f / a_20[_S716];
            }
            else
            {
                sum_6 = 0.0f;
            }
            inv_0[_S716] = sum_6;
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
                    sum_6 = 1.0f;
                }
                else
                {
                    sum_6 = 0.0f;
                }
                k_23 = u32(0);
                var s_11 : f32 = sum_6;
                loop
                {
                    if(k_23 < i_14)
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_12 : f32 = s_11 - l_5[i_14 * u32(6) + k_23] * y_3[k_23];
                    k_23 = k_23 + u32(1);
                    s_11 = s_12;
                }
                y_3[i_14] = s_11 / l_5[i_14 * u32(6) + i_14];
                i_14 = i_14 + u32(1);
            }
            var x_13 : array<f32, i32(6)>;
            x_13[i32(0)] = 0.0f;
            x_13[i32(1)] = 0.0f;
            x_13[i32(2)] = 0.0f;
            x_13[i32(3)] = 0.0f;
            x_13[i32(4)] = 0.0f;
            x_13[i32(5)] = 0.0f;
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
                sum_6 = y_3[i_15];
                loop
                {
                    if(k_23 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_13 : f32 = sum_6 - l_5[k_23 * u32(6) + i_15] * x_13[k_23];
                    k_23 = k_23 + u32(1);
                    sum_6 = s_13;
                }
                x_13[i_15] = sum_6 / l_5[i_15 * u32(6) + i_15];
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
                inv_0[i_16 * u32(6) + j_7] = x_13[i_16];
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
        var _S717 : u32 = u32(4) * j_7;
        scratch_0[sv_0(c_35, u32(12) + j_7)] = vec4<f32>(inv_0[_S717], inv_0[_S717 + u32(1)], inv_0[_S717 + u32(2)], inv_0[_S717 + u32(3)]);
        j_7 = j_7 + u32(1);
    }
    return;
}

fn assemble_block_0( c_36 : u32)
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
        var _S718 : bool = ((entry_6 & (u32(1)))) != u32(0);
        var _S719 : u32 = statics_bond_slot_0(i_17);
        var _S720 : vec4<f32> = scratch_0[_S719];
        var _S721 : vec4<f32> = scratch_0[_S719 + u32(1)];
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
            var _S722 : u32 = p_18 % u32(3);
            var t_20 : vec3<f32>;
            if(_S722 == u32(0))
            {
                t_20 = bonds_0[i_17].t1_0.xyz;
            }
            else
            {
                if(_S722 == u32(1))
                {
                    t_20 = bonds_0[i_17].t2_0.xyz;
                }
                else
                {
                    t_20 = bonds_0[i_17].normal_0.xyz;
                }
            }
            var _S723 : bool = p_18 < u32(3);
            var row_u_0 : vec3<f32>;
            var row_t_0 : vec3<f32>;
            if(_S723)
            {
                if(_S718)
                {
                    row_u_0 = t_20;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_20);
                }
                if(_S718)
                {
                    row_t_0 = cross(bonds_0[i_17].rb_0.xyz, t_20);
                }
                else
                {
                    row_t_0 = (vec3<f32>(0) - cross(bonds_0[i_17].ra_0.xyz, t_20));
                }
            }
            else
            {
                var _S724 : vec3<f32> = vec3<f32>(0.0f);
                if(_S718)
                {
                    row_u_0 = t_20;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_20);
                }
                var _S725 : vec3<f32> = row_u_0;
                row_u_0 = _S724;
                row_t_0 = _S725;
            }
            var kp_0 : f32;
            if(_S723)
            {
                kp_0 = _S720[p_18];
            }
            else
            {
                kp_0 = _S721[p_18 - u32(3)];
            }
            if(kp_0 == 0.0f)
            {
                p_18 = p_18 + u32(1);
                continue;
            }
            var _S726 : array<f32, i32(6)> = array<f32, i32(6)>( row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z );
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
                    a_21[r_14 * u32(6) + q_14] = a_21[r_14 * u32(6) + q_14] + kp_0 * _S726[r_14] * _S726[q_14];
                    q_14 = q_14 + u32(1);
                }
                r_14 = r_14 + u32(1);
            }
            p_18 = p_18 + u32(1);
        }
        e_7 = e_7 + u32(1);
    }
    var _S727 : u32 = fixed_mask_0(c_36);
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
        if(((_S727 & (((u32(1) << (p_18)))))) != u32(0))
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
    store_inverse_0(c_36, a_21);
    return;
}

fn block_get_0( c_37 : u32,  i_18 : u32,  j_8 : u32) -> f32
{
    var k_25 : u32 = i_18 * u32(6) + j_8;
    return scratch_0[sv_0(c_37, u32(12) + k_25 / u32(4))][k_25 % u32(4)];
}

fn precondition_0( c_38 : u32)
{
    var _S728 : array<f32, i32(6)> = array<f32, i32(6)>( scratch_0[sv_0(c_38, u32(4))].x, scratch_0[sv_0(c_38, u32(4))].y, scratch_0[sv_0(c_38, u32(4))].z, scratch_0[sv_0(c_38, u32(5))].x, scratch_0[sv_0(c_38, u32(5))].y, scratch_0[sv_0(c_38, u32(5))].z );
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
        var s_14 : f32 = 0.0f;
        loop
        {
            if(j_9 < u32(6))
            {
            }
            else
            {
                break;
            }
            var s_15 : f32 = s_14 + block_get_0(c_38, i_19, j_9) * _S728[j_9];
            j_9 = j_9 + u32(1);
            s_14 = s_15;
        }
        z_1[i_19] = s_14;
        i_19 = i_19 + u32(1);
    }
    scratch_0[sv_0(c_38, u32(6))] = vec4<f32>(z_1[i32(0)], z_1[i32(1)], z_1[i32(2)], 0.0f);
    scratch_0[sv_0(c_38, u32(7))] = vec4<f32>(z_1[i32(3)], z_1[i32(4)], z_1[i32(5)], 0.0f);
    return;
}

fn project_displacement_slot_0( tid_17 : u32,  isl_24 : ptr<function, Island_std430_0>,  slot_5 : u32)
{
    var _S729 : u32;
    var _S730 : vec3<f32> = vec3<f32>(0.0f);
    var p_19 : vec3<f32> = _S730;
    var l_6 : vec3<f32> = _S730;
    var _S731 : vec4<u32> = (*isl_24).range_0;
    var _S732 : u32 = (*isl_24).range_0.x + tid_17;
    var c_39 : u32 = _S732;
    loop
    {
        var _S733 : u32 = _S731.y;
        _S729 = _S733;
        if(c_39 < _S733)
        {
        }
        else
        {
            break;
        }
        var u_6 : vec3<f32> = scratch_0[sv_0(c_39, slot_5)].xyz;
        var th_7 : vec3<f32> = scratch_0[sv_0(c_39, slot_5 + u32(1))].xyz;
        var r_15 : vec3<f32> = chunks_0[c_39].center_0.xyz - (*isl_24).com_0.xyz;
        var _S734 : vec3<f32> = vec3<f32>(chunks_0[c_39].center_0.w);
        p_19 = p_19 + u_6 * _S734;
        l_6 = l_6 + (cross(r_15, u_6) * _S734 + rows_mul_0(chunks_0[c_39].inertia0_1, chunks_0[c_39].inertia1_1, chunks_0[c_39].inertia2_1, th_7));
        c_39 = c_39 + u32(256);
    }
    group_sum3_0(tid_17, &(p_19), &(l_6));
    var _S735 : vec4<f32> = (*isl_24).com_0;
    var _S736 : vec3<f32> = p_19 / vec3<f32>((*isl_24).com_0.w);
    var _S737 : vec3<f32> = rows_mul_0((*isl_24).inv0_0, (*isl_24).inv1_0, (*isl_24).inv2_0, l_6);
    c_39 = _S732;
    loop
    {
        if(c_39 < _S729)
        {
        }
        else
        {
            break;
        }
        var _S738 : u32 = sv_0(c_39, slot_5);
        scratch_0[_S738] = vec4<f32>(scratch_0[_S738].xyz - _S736 - cross(_S737, chunks_0[c_39].center_0.xyz - _S735.xyz), 0.0f);
        var _S739 : u32 = sv_0(c_39, slot_5 + u32(1));
        scratch_0[_S739] = vec4<f32>(scratch_0[_S739].xyz - _S737, 0.0f);
        c_39 = c_39 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn statics_result_slot_0( island_1 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * params_0.statics_bonds_0 + island_1;
}

fn write_bond_loads_0( _S740 : u32,  _S741 : u32,  _S742 : vec3<f32>,  _S743 : vec3<f32>,  _S744 : f32)
{
    var _S745 : vec3<f32> = to_body_0(_S741, _S742);
    var _S746 : vec3<f32> = to_body_0(_S741, _S743);
    var _S747 : u32 = u32(3) * _S740;
    scratch_0[_S747] = vec4<f32>(_S745, _S744);
    scratch_0[_S747 + u32(1)] = vec4<f32>(_S746 + cross(bonds_0[_S741].ra_0.xyz, _S745), 0.0f);
    scratch_0[_S747 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S746) + cross(bonds_0[_S741].rb_0.xyz, (vec3<f32>(0) - _S745)), 0.0f);
    return;
}

fn static_kinematics_1( _S748 : u32,  _S749 : ptr<function, vec3<f32>>,  _S750 : ptr<function, vec3<f32>>)
{
    var ca_2 : u32 = bonds_0[_S748].law_0.ids_0.y;
    var cb_5 : u32 = bonds_0[_S748].law_0.ids_0.z;
    var _S751 : u32 = u32(4) * cb_5;
    var _S752 : u32 = u32(4) * ca_2;
    var _S753 : u32 = _S751 + u32(1);
    var _S754 : u32 = _S752 + u32(1);
    var _S755 : u32 = sv_0(cb_5, u32(22));
    var _S756 : u32 = sv_0(ca_2, u32(22));
    var dth_1 : vec3<f32> = state_0[_S753].xyz - state_0[_S754].xyz + (scratch_0[_S755].xyz - scratch_0[_S756].xyz);
    (*_S749) = to_local_0(_S748, state_0[_S751].xyz - state_0[_S752].xyz + (scratch_0[sv_0(cb_5, u32(21))].xyz - scratch_0[sv_0(ca_2, u32(21))].xyz) + (cross(state_0[_S753].xyz + scratch_0[_S755].xyz, bonds_0[_S748].rb_0.xyz) - cross(state_0[_S754].xyz + scratch_0[_S756].xyz, bonds_0[_S748].ra_0.xyz)));
    (*_S750) = to_local_0(_S748, dth_1);
    return;
}

fn bond_kinematics_0( _S757 : u32,  _S758 : vec3<f32>,  _S759 : vec3<f32>,  _S760 : vec3<f32>,  _S761 : vec3<f32>,  _S762 : ptr<function, vec3<f32>>,  _S763 : ptr<function, vec3<f32>>)
{
    (*_S762) = to_local_0(_S757, _S760 + cross(_S761, bonds_0[_S757].rb_0.xyz) - (_S758 + cross(_S759, bonds_0[_S757].ra_0.xyz)));
    (*_S763) = to_local_0(_S757, _S761 - _S759);
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
    var _S764 : u32 = group_9.x;
    var _S765 : Island_std430_0 = islands_0[_S764];
    var _S766 : vec4<u32> = _S765.info_0;
    var _S767 : u32 = _S765.info_0.z;
    if(((_S767 & (u32(8)))) == u32(0))
    {
        return;
    }
    var free_0 : bool = (((_S766.x) & (u32(1)))) == u32(0);
    var c0_1 : u32 = _S765.range_0.x;
    var c1_1 : u32 = _S765.range_0.y;
    var b0_0 : u32 = _S765.range_0.z;
    var _S768 : u32 = _S765.range_0.w;
    var _S769 : u32 = c0_1 + tid_18;
    var c_41 : u32 = _S769;
    loop
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        var _S770 : vec4<f32> = vec4<f32>(0.0f);
        scratch_0[sv_0(c_41, u32(21))] = _S770;
        scratch_0[sv_0(c_41, u32(22))] = _S770;
        c_41 = c_41 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    if(free_0)
    {
        project_load_slot_0(tid_18, &(_S765), u32(0));
    }
    var _S771 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(0), u32(0));
    var _S772 : f32 = max(sqrt(_S771), 1.00000000317107685e-30f);
    var _S773 : f32 = params_0.statics_tol_0;
    var _S774 : u32 = min(params_0.statics_cg_0, u32(20) * (c1_1 - c0_1) * u32(6) + u32(200));
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
        var _S775 : u32 = b0_0 + tid_18;
        i_20 = _S775;
        loop
        {
            if(i_20 < _S768)
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
        var _S776 : vec4<f32> = vec4<f32>(0.0f);
        var magnitude_0 : vec4<f32> = _S776;
        var unused_m_0 : vec4<f32> = _S776;
        c_41 = _S769;
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
            hold_0(fixed_mask_0(c_41), &(r_lin_0), &(r_ang_0), _S776, _S776);
            scratch_0[sv_0(c_41, u32(4))] = r_lin_0;
            scratch_0[sv_0(c_41, u32(5))] = r_ang_0;
            c_41 = c_41 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        group_sum2_0(tid_18, &(magnitude_0), &(unused_m_0));
        if(free_0)
        {
            project_load_slot_0(tid_18, &(_S765), u32(4));
        }
        var _S777 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
        var residual_1 : f32 = sqrt(_S777) / _S772;
        var _S778 : f32 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S772);
        if(residual_1 <= _S773)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S778)
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
        var i_21 : u32 = _S775;
        loop
        {
            if(i_21 < _S768)
            {
            }
            else
            {
                break;
            }
            var d_lin_8 : vec3<f32>;
            var d_ang_6 : vec3<f32>;
            static_kinematics_1(i_21, &(d_lin_8), &(d_ang_6));
            var _S779 : JointBond_std430_0 = bonds_0[i_21].law_0;
            var _S780 : JointState_std430_0 = bond_dyn_0[i_21].js_0;
            var f_lin_3 : vec3<f32>;
            var f_ang_3 : vec3<f32>;
            secant_factors_0(&(_S779), &(_S780), d_lin_8, &(f_lin_3), &(f_ang_3));
            var _S781 : u32 = statics_bond_slot_0(i_21);
            var _S782 : f32 = _S779.stiff0_0.y;
            scratch_0[_S781] = vec4<f32>(_S782 * f_lin_3.x, _S782 * f_lin_3.y, _S779.stiff0_0.x * f_lin_3.z, 0.0f);
            scratch_0[_S781 + u32(1)] = vec4<f32>(_S779.stiff0_0.z * f_ang_3.x, _S779.stiff0_0.w * f_ang_3.y, _S779.stiff1_0.x * f_ang_3.z, 0.0f);
            i_21 = i_21 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_42 : u32 = _S769;
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
            scratch_0[sv_0(c_42, u32(2))] = _S776;
            scratch_0[sv_0(c_42, u32(3))] = _S776;
            c_42 = c_42 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_43 : u32 = _S769;
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
            project_displacement_slot_0(tid_18, &(_S765), u32(6));
        }
        var c_44 : u32 = _S769;
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
        var _S783 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(6));
        var _S784 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
        var _S785 : f32 = sqrt(_S784);
        var rz_0 : f32 = _S783;
        var k_26 : u32 = u32(0);
        var cg_total_1 : u32 = cg_total_0;
        loop
        {
            var _S786 : bool;
            if(k_26 < _S774)
            {
                _S786 = _S785 > 0.0f;
            }
            else
            {
                _S786 = false;
            }
            if(_S786)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            var i_22 : u32 = _S775;
            loop
            {
                if(i_22 < _S768)
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
                var _S787 : u32 = statics_bond_slot_0(i_22);
                write_bond_loads_0(i_22, i_22, d_lin_9 * scratch_0[_S787].xyz, d_ang_7 * scratch_0[_S787 + u32(1)].xyz, 0.0f);
                i_22 = i_22 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_40 = _S769;
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
            var _S788 : u32 = cg_total_1 + u32(1);
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S788;
                break;
            }
            var _S789 : f32 = rz_0 / pap_0;
            var c_45 : u32 = _S769;
            loop
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S790 : u32 = sv_0(c_45, u32(2));
                var _S791 : vec3<f32> = vec3<f32>(_S789);
                scratch_0[_S790] = vec4<f32>(scratch_0[_S790].xyz + _S791 * scratch_0[sv_0(c_45, u32(8))].xyz, 0.0f);
                var _S792 : u32 = sv_0(c_45, u32(3));
                scratch_0[_S792] = vec4<f32>(scratch_0[_S792].xyz + _S791 * scratch_0[sv_0(c_45, u32(9))].xyz, 0.0f);
                var _S793 : u32 = sv_0(c_45, u32(4));
                scratch_0[_S793] = vec4<f32>(scratch_0[_S793].xyz - _S791 * scratch_0[sv_0(c_45, u32(10))].xyz, 0.0f);
                var _S794 : u32 = sv_0(c_45, u32(5));
                scratch_0[_S794] = vec4<f32>(scratch_0[_S794].xyz - _S791 * scratch_0[sv_0(c_45, u32(11))].xyz, 0.0f);
                c_45 = c_45 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S795 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
            if((sqrt(_S795)) <= (0.00009999999747379f * _S785))
            {
                cg_total_0 = _S788;
                break;
            }
            var c_46 : u32 = _S769;
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
                project_displacement_slot_0(tid_18, &(_S765), u32(6));
            }
            var rz_new_0 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(6));
            var _S796 : f32 = rz_new_0 / rz_0;
            var c_47 : u32 = _S769;
            loop
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S797 : u32 = sv_0(c_47, u32(8));
                var _S798 : vec3<f32> = vec3<f32>(_S796);
                scratch_0[_S797] = vec4<f32>(scratch_0[sv_0(c_47, u32(6))].xyz + _S798 * scratch_0[_S797].xyz, 0.0f);
                var _S799 : u32 = sv_0(c_47, u32(9));
                scratch_0[_S799] = vec4<f32>(scratch_0[sv_0(c_47, u32(7))].xyz + _S798 * scratch_0[_S799].xyz, 0.0f);
                c_47 = c_47 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S800 : u32 = k_26 + u32(1);
            rz_0 = rz_new_0;
            k_26 = _S800;
            cg_total_1 = _S788;
        }
        c_40 = _S769;
        loop
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            var _S801 : u32 = u32(4) * c_40;
            var u_7 : vec3<f32> = state_0[_S801].xyz;
            var _S802 : u32 = sv_0(c_40, u32(21));
            var u_lo_0 : vec3<f32> = scratch_0[_S802].xyz;
            var _S803 : u32 = _S801 + u32(1);
            var th_8 : vec3<f32> = state_0[_S803].xyz;
            var _S804 : u32 = sv_0(c_40, u32(22));
            var th_lo_0 : vec3<f32> = scratch_0[_S804].xyz;
            comp_add_0(&(u_7), &(u_lo_0), scratch_0[sv_0(c_40, u32(2))].xyz);
            comp_add_0(&(th_8), &(th_lo_0), scratch_0[sv_0(c_40, u32(3))].xyz);
            state_0[_S801] = vec4<f32>(u_7, state_0[_S801].w);
            state_0[_S803] = vec4<f32>(th_8, state_0[_S803].w);
            scratch_0[_S802] = vec4<f32>(u_lo_0, 0.0f);
            scratch_0[_S804] = vec4<f32>(th_lo_0, 0.0f);
            c_40 = c_40 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S805 : u32 = newton_0 + u32(1);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S805;
    }
    i_20 = b0_0 + tid_18;
    loop
    {
        if(i_20 < _S768)
        {
        }
        else
        {
            break;
        }
        var resp_4 : JointResponse_0 = static_response_0(i_20);
        var _S806 : JointState_0 = JointState_0( bond_dyn_0[i_20].js_0.damage_0, bond_dyn_0[i_20].js_0.crush_1, bond_dyn_0[i_20].js_0.kappa_0, bond_dyn_0[i_20].js_0.kappa_c_0, bond_dyn_0[i_20].js_0.ductility_0, bond_dyn_0[i_20].js_0.ductility_c_0, bond_dyn_0[i_20].js_0.life_0, bond_dyn_0[i_20].js_0.plastic_x_0, bond_dyn_0[i_20].js_0.plastic_y_0, bond_dyn_0[i_20].js_0.plastic_t_0, bond_dyn_0[i_20].js_0.rebar_plastic_0, bond_dyn_0[i_20].js_0.rebar_slip0_0, bond_dyn_0[i_20].js_0.rebar_slip1_0, bond_dyn_0[i_20].js_0.rebar_work_0, bond_dyn_0[i_20].js_0.rebar_broken_0, bond_dyn_0[i_20].js_0.strain_rate_0, bond_dyn_0[i_20].js_0.governing_stress_0, bond_dyn_0[i_20].js_0.dissipated_0, bond_dyn_0[i_20].js_0.utilization_0, bond_dyn_0[i_20].js_0.mode_0 );
        var bd_1 : BondDyn_0;
        bd_1.js_0 = _S806;
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
        bond_dyn_0[i_20].js_0.life_0 = bd_1.js_0.life_0;
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
    c_41 = _S769;
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
            var _S807 : u32 = u32(4) * c_41;
            reaction_2 = vec3<f32>(state_0[_S807 + u32(1)].w, state_0[_S807 + u32(2)].w, state_0[_S807 + u32(3)].w);
        }
        var _S808 : u32 = u32(4) * c_41;
        var _S809 : u32 = _S808 + u32(1);
        state_0[_S809] = vec4<f32>(state_0[_S809].xyz, reaction_2.x);
        state_0[_S808 + u32(2)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.y);
        state_0[_S808 + u32(3)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.z);
        c_41 = c_41 + u32(256);
    }
    if(tid_18 == u32(0))
    {
        var _S810 : f32 = (bitcast<f32>((newton_0)));
        var _S811 : f32 = (bitcast<f32>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        scratch_0[statics_result_slot_0(_S764)] = vec4<f32>(residual_0, _S810, _S811, previous_2);
        islands_0[_S764].info_0[i32(2)] = (_S767 & (u32(4294967287)));
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn settled_fatigue(@builtin(workgroup_id) group_10 : vec3<u32>, @builtin(local_invocation_id) thread_10 : vec3<u32>)
{
    var tid_19 : u32 = thread_10.x;
    var _S812 : u32 = group_10.x;
    var isl_25 : Island_std430_0 = islands_0[_S812];
    var _S813 : bool;
    if((((islands_0[_S812].info_0.x) & (u32(16)))) == u32(0))
    {
        _S813 = true;
    }
    else
    {
        _S813 = (isl_25.range_0.w) == (isl_25.range_0.z);
    }
    if(_S813)
    {
        return;
    }
    var _S814 : bool = tid_19 == u32(0);
    if(_S814)
    {
        g_halt_0 = u32(0);
        g_run_0 = u32(0);
    }
    workgroupBarrier();
    var _S815 : u32 = isl_25.info_0.w;
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
        var _S816 : JointState_0 = JointState_0( bond_dyn_0[i_23].js_0.damage_0, bond_dyn_0[i_23].js_0.crush_1, bond_dyn_0[i_23].js_0.kappa_0, bond_dyn_0[i_23].js_0.kappa_c_0, bond_dyn_0[i_23].js_0.ductility_0, bond_dyn_0[i_23].js_0.ductility_c_0, bond_dyn_0[i_23].js_0.life_0, bond_dyn_0[i_23].js_0.plastic_x_0, bond_dyn_0[i_23].js_0.plastic_y_0, bond_dyn_0[i_23].js_0.plastic_t_0, bond_dyn_0[i_23].js_0.rebar_plastic_0, bond_dyn_0[i_23].js_0.rebar_slip0_0, bond_dyn_0[i_23].js_0.rebar_slip1_0, bond_dyn_0[i_23].js_0.rebar_work_0, bond_dyn_0[i_23].js_0.rebar_broken_0, bond_dyn_0[i_23].js_0.strain_rate_0, bond_dyn_0[i_23].js_0.governing_stress_0, bond_dyn_0[i_23].js_0.dissipated_0, bond_dyn_0[i_23].js_0.utilization_0, bond_dyn_0[i_23].js_0.mode_0 );
        var bd_2 : BondDyn_0;
        bd_2.js_0 = _S816;
        bd_2.force_lin_0 = bond_dyn_0[i_23].force_lin_0;
        bd_2.force_ang_0 = bond_dyn_0[i_23].force_ang_0;
        bd_2.sums_0 = bond_dyn_0[i_23].sums_0;
        bd_2.comps_0 = bond_dyn_0[i_23].comps_0;
        bd_2.events_0 = bond_dyn_0[i_23].events_0;
        var _S817 : JointBond_std430_0 = bonds_0[i_23].law_0;
        var _S818 : u32 = u32(4) * _S817.ids_0.y;
        var _S819 : u32 = u32(4) * _S817.ids_0.z;
        var d_lin_10 : vec3<f32>;
        var d_ang_8 : vec3<f32>;
        bond_kinematics_0(i_23, state_0[_S818].xyz, state_0[_S818 + u32(1)].xyz, state_0[_S819].xyz, state_0[_S819 + u32(1)].xyz, &(d_lin_10), &(d_ang_8));
        var _S820 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S817.ids_0.x];
        var previous_3 : JointState_0 = bd_2.js_0;
        var _S821 : JointResponse_0 = joint_evaluate_1(&(_S820), &(_S817), bd_2.js_0, d_lin_10, d_ang_8, params_0.dt_0, (params_0.fracture_0) != u32(0));
        if((_S821.state_1.damage_0) > (bd_2.js_0.damage_0 + 9.99999971718068537e-10f))
        {
            _S813 = true;
        }
        else
        {
            _S813 = (_S821.state_1.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        var flags_4 : u32;
        if(_S813)
        {
            flags_4 = u32(16);
        }
        else
        {
            flags_4 = u32(0);
        }
        var _S822 : f32 = bd_2.sums_0[i32(0)];
        var _S823 : f32 = bd_2.comps_0[i32(0)];
        comp_add1_2(&(_S822), &(_S823), _S821.dissipated_3);
        bd_2.sums_0[i32(0)] = _S822;
        bd_2.comps_0[i32(0)] = _S823;
        var _S824 : f32 = bd_2.sums_0[i32(1)];
        var _S825 : f32 = bd_2.comps_0[i32(1)];
        comp_add1_2(&(_S824), &(_S825), _S821.overshoot_0);
        bd_2.sums_0[i32(1)] = _S824;
        bd_2.comps_0[i32(1)] = _S825;
        bd_2.force_lin_0 = vec4<f32>(_S821.force_lin_1, _S821.stored_6);
        bd_2.force_ang_0 = vec4<f32>(_S821.force_ang_1, max(bd_2.force_ang_0.w, _S821.state_1.utilization_0));
        var _S826 : bool;
        if(!is_damaged_0(previous_3))
        {
            _S826 = is_damaged_0(_S821.state_1);
        }
        else
        {
            _S826 = false;
        }
        var _S827 : bool;
        if(_S826)
        {
            _S827 = (bd_2.events_0.x) == u32(0);
        }
        else
        {
            _S827 = false;
        }
        if(_S827)
        {
            bd_2.events_0[i32(0)] = _S815;
            bd_2.events_0[i32(3)] = _S821.state_1.mode_0;
        }
        var _S828 : bool;
        if((bd_2.events_0.y) == u32(0))
        {
            var _S829 : f32 = fatigue_factor_1(&(_S820), previous_3.life_0);
            _S828 = _S829 > 0.99000000953674316f;
        }
        else
        {
            _S828 = false;
        }
        var _S830 : bool;
        if(_S828)
        {
            var _S831 : f32 = fatigue_factor_1(&(_S820), _S821.state_1.life_0);
            _S830 = _S831 <= 0.99000000953674316f;
        }
        else
        {
            _S830 = false;
        }
        if(_S830)
        {
            bd_2.events_0[i32(1)] = _S815;
        }
        var flags_5 : u32;
        if(_S821.disconnected_0)
        {
            bd_2.events_0[i32(2)] = _S815;
            flags_5 = (flags_4 | (u32(32)));
        }
        else
        {
            flags_5 = flags_4;
        }
        bd_2.js_0 = _S821.state_1;
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
        write_bond_loads_0(i_23, i_23, _S821.force_lin_1, _S821.force_ang_1, max(_S821.measures_0.tension_0, _S821.measures_0.compression_0));
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
    if(_S814)
    {
        _S813 = ((g_halt_0 | (g_run_0))) != u32(0);
    }
    else
    {
        _S813 = false;
    }
    if(_S813)
    {
        var _S832 : u32 = isl_25.info_0.z;
        if(g_halt_0 != u32(0))
        {
            i_23 = u32(16);
        }
        else
        {
            i_23 = u32(0);
        }
        var _S833 : u32 = (_S832 | (i_23));
        if(g_run_0 != u32(0))
        {
            i_23 = u32(32);
        }
        else
        {
            i_23 = u32(0);
        }
        islands_0[_S812].info_0[i32(2)] = (_S833 | (i_23));
    }
    return;
}

