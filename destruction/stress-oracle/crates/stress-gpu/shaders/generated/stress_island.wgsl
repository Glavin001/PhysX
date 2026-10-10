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

@binding(8) @group(0) var<storage, read_write> islands_0 : array<Island_std430_0>;

struct Params_std140_0
{
    @align(16) gravity_0 : vec4<f32>,
    @align(16) dt_0 : f32,
    @align(4) fracture_0 : u32,
    @align(8) rigid_motion_loads_0 : u32,
    @align(4) step_start_0 : u32,
    @align(16) t_hi_0 : f32,
    @align(4) t_lo_0 : f32,
    @align(8) probe_base_0 : u32,
    @align(4) probe_stride_0 : u32,
    @align(16) max_steps_0 : u32,
    @align(4) contact_mode_0 : u32,
    @align(8) contact_base_0 : u32,
    @align(4) halt_index_0 : u32,
};

@binding(0) @group(0) var<uniform> params_0 : Params_std140_0;
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

@binding(3) @group(0) var<storage, read> chunks_0 : array<ChunkStatic_std430_0>;

@binding(9) @group(0) var<storage, read> loads_0 : array<vec4<f32>>;

@binding(10) @group(0) var<storage, read> contact_out_0 : array<vec4<f32>>;

@binding(5) @group(0) var<storage, read_write> state_0 : array<vec4<f32>>;

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
    @align(4) crush_0 : f32,
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

@binding(6) @group(0) var<storage, read_write> bond_dyn_0 : array<BondDyn_std430_0>;

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
@binding(7) @group(0) var<storage, read_write> bond_loads_0 : array<vec4<f32>>;

@binding(4) @group(0) var<storage, read> csr_0 : array<u32>;

var<workgroup> g_run_0 : u32;

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

var<workgroup> g_halt_0 : u32;

fn time_since_0( origin_0 : vec4<f32>,  k_0 : u32,  dt_1 : f32) -> f32
{
    return params_0.t_hi_0 - origin_0.x + (params_0.t_lo_0 - origin_0.y) + f32(k_0) * dt_1;
}

fn table_eval_0( offset_0 : u32,  count_0 : u32,  tau_0 : f32) -> f32
{
    var first_0 : vec4<f32> = loads_0[offset_0];
    if(tau_0 <= (first_0.x))
    {
        return first_0.y;
    }
    var i_0 : u32 = u32(1);
    loop
    {
        if(i_0 < count_0)
        {
        }
        else
        {
            break;
        }
        var _S1 : u32 = offset_0 + i_0;
        var b_0 : vec4<f32> = loads_0[_S1];
        var _S2 : f32 = b_0.x;
        if(tau_0 <= _S2)
        {
            var a_0 : vec4<f32> = loads_0[_S1 - u32(1)];
            var _S3 : f32 = a_0.x;
            var _S4 : f32 = a_0.y;
            return _S4 + (tau_0 - _S3) / max(_S2 - _S3, 1.00000000317107685e-30f) * (b_0.y - _S4);
        }
        i_0 = i_0 + u32(1);
    }
    return loads_0[offset_0 + count_0 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_1 : u32,  dt_2 : f32,  shift_0 : f32) -> f32
{
    var _S5 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S5])));
    var origin_1 : vec4<f32> = loads_0[_S5 + u32(3)];
    var p_0 : vec4<f32> = loads_0[_S5 + u32(4)];
    var kind_0 : u32 = info_2.z;
    if(kind_0 == u32(0))
    {
        return origin_1.z;
    }
    var tau_1 : f32 = time_since_0(origin_1, k_1, dt_2) + shift_0;
    var shape_0 : f32;
    if(kind_0 == u32(1))
    {
        if(tau_1 <= 0.0f)
        {
            shape_0 = 0.0f;
        }
        else
        {
            var _S6 : f32 = p_0.x;
            if(tau_1 >= _S6)
            {
                shape_0 = p_0.y;
            }
            else
            {
                shape_0 = p_0.y * tau_1 / _S6;
            }
        }
        return shape_0;
    }
    var _S7 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S7 = true;
        }
        else
        {
            _S7 = tau_1 > (p_0.x);
        }
        if(_S7)
        {
            shape_0 = 0.0f;
        }
        else
        {
            shape_0 = p_0.y * sin(3.14159274101257324f * tau_1 / p_0.x);
        }
        return shape_0;
    }
    if(kind_0 == u32(3))
    {
        var sn_0 : f32 = tau_1 / p_0.y;
        if(sn_0 < 0.0f)
        {
            _S7 = true;
        }
        else
        {
            _S7 = sn_0 > 1.0f;
        }
        if(_S7)
        {
            shape_0 = 0.0f;
        }
        else
        {
            shape_0 = p_0.x * (1.0f - sn_0) * exp(- p_0.z * sn_0);
        }
        return shape_0;
    }
    if(kind_0 == u32(4))
    {
        return table_eval_0(info_2.w, (bitcast<u32>((p_0.x))), tau_1);
    }
    if(kind_0 == u32(5))
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var sn_1 : f32 = tau_1 / p_0.x;
        if(sn_1 < 0.0f)
        {
            _S7 = true;
        }
        else
        {
            _S7 = sn_1 > 1.0f;
        }
        if(_S7)
        {
            shape_0 = 0.0f;
        }
        else
        {
            shape_0 = (1.0f - sn_1) * exp(- p_0.y * sn_1);
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
        var _S8 : f32 = p_0.w;
        return (_S8 + (p_0.z - _S8) * relax_0) * shape_0;
    }
    var _S9 : f32 = p_0.x;
    if(_S9 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S9, 0.0f, 1.0f);
}

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_0, q_1.y_0, q_1.z_0);
    var t_0 : vec3<f32> = cross(qv_0, v_0) * vec3<f32>(2.0f);
    return v_0 + t_0 * vec3<f32>(q_1.w_0) + cross(qv_0, t_0);
}

var<workgroup> g_red_a_0 : array<vec4<f32>, i32(256)>;

var<workgroup> g_red_b_0 : array<vec4<f32>, i32(256)>;

fn group_sum2_0( tid_0 : u32,  a_1 : ptr<function, vec3<f32>>,  b_1 : ptr<function, vec3<f32>>)
{
    g_red_a_0[tid_0] = vec4<f32>((*a_1), 0.0f);
    g_red_b_0[tid_0] = vec4<f32>((*b_1), 0.0f);
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
            var _S10 : u32 = tid_0 + s_0;
            g_red_a_0[tid_0] = g_red_a_0[tid_0] + g_red_a_0[_S10];
            g_red_b_0[tid_0] = g_red_b_0[tid_0] + g_red_b_0[_S10];
        }
        workgroupBarrier();
        s_0 = (s_0 >> (u32(1)));
    }
    (*a_1) = g_red_a_0[i32(0)].xyz;
    (*b_1) = g_red_b_0[i32(0)].xyz;
    workgroupBarrier();
    return;
}

fn inverse_rotate_0( q_2 : Quat_0,  v_1 : vec3<f32>) -> vec3<f32>
{
    var c_0 : Quat_0;
    c_0.w_0 = q_2.w_0;
    c_0.x_0 = - q_2.x_0;
    c_0.y_0 = - q_2.y_0;
    c_0.z_0 = - q_2.z_0;
    return rotate_0(c_0, v_1);
}

fn rows_mul_0( r0_0 : vec4<f32>,  r1_0 : vec4<f32>,  r2_0 : vec4<f32>,  v_2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r0_0.xyz, v_2), dot(r1_0.xyz, v_2), dot(r2_0.xyz, v_2));
}

fn world_mul_0( q_3 : Quat_0,  r0_1 : vec4<f32>,  r1_1 : vec4<f32>,  r2_1 : vec4<f32>,  v_3 : vec3<f32>) -> vec3<f32>
{
    return rotate_0(q_3, rows_mul_0(r0_1, r1_1, r2_1, inverse_rotate_0(q_3, v_3)));
}

struct JointState_0
{
     damage_0 : f32,
     crush_0 : f32,
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
    var _S11 : bool;
    if((st_0.damage_0) < 1.0f)
    {
        _S11 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S11 = (st_0.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S11 = false;
        }
    }
    return _S11;
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_2 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_0 : f32 = (*b_2).geom0_0.x;
    var _S12 : f32 = q_lin_0.z;
    var axial_0 : f32 = _S12 / area_0;
    var bending_0 : f32 = abs(q_ang_0.x) / (*b_2).geom1_0.x + abs(q_ang_0.y) / (*b_2).geom1_0.y;
    var _S13 : f32 = q_lin_0.x;
    var _S14 : f32 = q_lin_0.y;
    var shear_1 : f32 = sqrt(_S13 * _S13 + _S14 * _S14) / area_0 + abs(q_ang_0.z) / (*b_2).geom0_0.w;
    var m_1 : Measures_0;
    m_1.tension_0 = axial_0 + bending_0;
    m_1.shear_0 = shear_1;
    var _S15 : f32 = - axial_0;
    m_1.normal_compression_0 = max(_S15, 0.0f);
    m_1.compression_0 = _S15 + bending_0;
    m_1.compressive_force_0 = max(- _S12, 0.0f);
    return m_1;
}

fn expm1_accurate_0( x_1 : f32) -> f32
{
    if((abs(x_1)) < 0.00100000004749745f)
    {
        return x_1 * (1.0f + x_1 * (0.5f + x_1 * 0.1666666716337204f));
    }
    return exp(x_1) - 1.0f;
}

fn dif_factor_0( mat_0 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_1 : f32 = abs(strain_rate_1);
    var _S16 : vec4<f32> = (*mat_0).dif_0;
    var ref_0 : f32 = (*mat_0).dif_0.x;
    if(r_1 <= ref_0)
    {
        return 1.0f;
    }
    var _S17 : f32 = _S16.z;
    var f_0 : f32;
    if(r_1 <= _S17)
    {
        f_0 = pow(r_1 / ref_0, _S16.y);
    }
    else
    {
        f_0 = pow(_S17 / ref_0, _S16.y) * pow(r_1 / _S17, _S16.w);
    }
    return clamp(f_0, 1.0f, (*mat_0).misc_0.x);
}

fn fatigue_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  fatigue_1 : f32) -> f32
{
    if(((((*mat_1).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_1, 0.0f, 1.0f), 1.0f / ((*mat_1).misc_0.y - 2.0f));
}

fn fatigue_factor_1( mat_2 : ptr<function, JointMaterial_std140_0>,  fatigue_2 : f32) -> f32
{
    if(((((*mat_2).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_2, 0.0f, 1.0f), 1.0f / ((*mat_2).misc_0.y - 2.0f));
}

fn infinity_0() -> f32
{
    return (bitcast<f32>((u32(2139095040))));
}

fn failure_indices_0( mat_3 : ptr<function, JointMaterial_std140_0>,  b_3 : ptr<function, JointBond_std430_0>,  m_2 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_0 : f32 = (*mat_3).strength_0.y * multiplier_0;
    var _S18 : f32 = min((*mat_3).strength_0.z * multiplier_0 + (*mat_3).strength_0.w * m_2.normal_compression_0, (*mat_3).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(m_2.tension_0 / ((*mat_3).strength_0.x * multiplier_0), 0.0f);
    var _S19 : f32;
    if(_S18 > 0.0f)
    {
        _S19 = m_2.shear_0 / _S18;
    }
    else
    {
        _S19 = infinity_0();
    }
    idx_0[i32(1)] = _S19;
    idx_0[i32(2)] = max(m_2.compression_0 / fc_0, 0.0f);
    var _S20 : f32 = (*b_3).stiff1_0.y;
    if(_S20 > 0.0f)
    {
        _S19 = m_2.compressive_force_0 / _S20;
    }
    else
    {
        _S19 = 0.0f;
    }
    idx_0[i32(3)] = _S19;
    return idx_0;
}

fn sq_0( x_2 : f32) -> f32
{
    return x_2 * x_2;
}

fn damage_law_0( kind_1 : u32,  kappa_1 : f32,  r_2 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == u32(0))
    {
        if(r_2 <= 1.0f)
        {
            return 1.0f;
        }
        return min(r_2 * (kappa_1 - 1.0f) / (kappa_1 * (r_2 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_2 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - 1.0f / kappa_1;
}

fn damage_increment_0( kind_2 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_3 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S21 : f32 = max(damage_law_0(kind_2, lambda_0, r_3), d_old_0);
    var _S22 : bool;
    if(_S21 <= d_old_0)
    {
        _S22 = true;
    }
    else
    {
        _S22 = d_old_0 >= 1.0f;
    }
    if(_S22)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = psi_0 / (lambda_0 * lambda_0);
    var _S23 : f32 = max(kappa_old_0, 1.0f);
    if(kind_2 == u32(0))
    {
        if(r_3 > 1.0f)
        {
            return vec2<f32>(_S21, u0_0 * r_3 / (r_3 - 1.0f) * max(min(lambda_0, r_3) - min(_S23, r_3), 0.0f));
        }
        return vec2<f32>(_S21, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_3 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S23, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S21 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S21, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_1 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S24 : f32 = - h0_0;
    var _S25 : f32 = - h1_0;
    var _S26 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S24, _S25), vec2<f32>(h0_0, _S25), vec2<f32>(h0_0, h1_0), vec2<f32>(_S24, h1_0) );
    var poly_0 : array<vec2<f32>, i32(8)>;
    var i_1 : u32 = u32(0);
    var count_2 : u32 = u32(0);
    loop
    {
        if(i_1 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S27 : u32 = i_1;
        var _S28 : u32 = i_1 + u32(1);
        var _S29 : u32 = _S28 % u32(4);
        var _S30 : f32 = _S26[i_1].y;
        var _S31 : f32 = _S26[i_1].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S30 - ay_0 * _S31;
        var _S32 : f32 = _S26[_S29].y;
        var _S33 : f32 = _S26[_S29].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S32 - ay_0 * _S33;
        var _S34 : bool = fp_0 < 0.0f;
        if(_S34)
        {
            var _S35 : u32 = count_2 + u32(1);
            poly_0[count_2] = _S26[_S27];
            count_1 = _S35;
        }
        else
        {
            count_1 = count_2;
        }
        if(_S34 != (fq_0 < 0.0f))
        {
            var t_1 : f32 = fp_0 / (fp_0 - fq_0);
            var _S36 : u32 = count_1 + u32(1);
            poly_0[count_1] = vec2<f32>(_S31 + t_1 * (_S33 - _S31), _S30 + t_1 * (_S32 - _S30));
            count_2 = _S36;
        }
        else
        {
            count_2 = count_1;
        }
        i_1 = _S28;
    }
    count_1 = u32(0);
    loop
    {
        if(count_1 < u32(6))
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_1] = 0.0f;
        count_1 = count_1 + u32(1);
    }
    if(count_2 < u32(3))
    {
        return;
    }
    var o_0 : vec2<f32> = poly_0[i32(0)];
    i_1 = u32(0);
    var a_2 : f32 = 0.0f;
    var sx_0 : f32 = 0.0f;
    var sy_0 : f32 = 0.0f;
    var ixx_0 : f32 = 0.0f;
    var iyy_0 : f32 = 0.0f;
    var ixy_0 : f32 = 0.0f;
    loop
    {
        if(i_1 < count_2)
        {
        }
        else
        {
            break;
        }
        var _S37 : f32 = o_0.x;
        var x0_0 : f32 = poly_0[i_1].x - _S37;
        var _S38 : f32 = o_0.y;
        var y0_0 : f32 = poly_0[i_1].y - _S38;
        var _S39 : u32 = i_1 + u32(1);
        var _S40 : u32 = _S39 % count_2;
        var x1_0 : f32 = poly_0[_S40].x - _S37;
        var y1_0 : f32 = poly_0[_S40].y - _S38;
        var _S41 : f32 = x0_0 * y1_0;
        var _S42 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S41 - _S42;
        var a_3 : f32 = a_2 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S41 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S42) * cr_0 / 24.0f;
        i_1 = _S39;
        a_2 = a_3;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_2 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_2;
    var cy_0 : f32 = sy_0 / a_2;
    (*region_0)[i32(0)] = a_2;
    (*region_0)[i32(1)] = o_0.x + cx_0;
    (*region_0)[i32(2)] = o_0.y + cy_0;
    var _S43 : f32 = a_2 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S43 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_2 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S43 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_4 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_4));
    var a_4 : f32 = r_4[i32(0)];
    if((r_4[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_2 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_1 : f32 = dz_1 + ax_1 * r_4[i32(2)] - ay_1 * r_4[i32(1)];
    var _S44 : f32 = a_4 * fc_1;
    var _S45 : f32 = - ay_1;
    return vec4<f32>(k_2 * a_4 * fc_1, k_2 * (_S44 * r_4[i32(2)] + (_S45 * r_4[i32(5)] + ax_1 * r_4[i32(4)])), - k_2 * (_S44 * r_4[i32(1)] + (_S45 * r_4[i32(3)] + ax_1 * r_4[i32(5)])), 0.5f * k_2 * (_S44 * fc_1 + ay_1 * ay_1 * r_4[i32(3)] + ax_1 * ax_1 * r_4[i32(4)] - 2.0f * ax_1 * ay_1 * r_4[i32(5)]));
}

fn signum_0( x_3 : f32) -> f32
{
    var _S46 : f32;
    if((((bitcast<u32>((x_3))) & (u32(2147483648)))) != u32(0))
    {
        _S46 = -1.0f;
    }
    else
    {
        _S46 = 1.0f;
    }
    return _S46;
}

fn return_map_0( k_3 : f32,  total_0 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_3 * (total_0 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_1 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_1, (trial_0 - f_1) / k_3);
}

struct Contact_0
{
     q_lin_1 : vec3<f32>,
     q_ang_1 : vec3<f32>,
     energy_2 : f32,
     diss_0 : f32,
     plastic_1 : vec3<f32>,
};

fn contact_part_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_4 : ptr<function, JointBond_std430_0>,  crush_1 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_1 : Contact_0;
    var _S47 : vec3<f32> = vec3<f32>(0.0f);
    c_1.q_lin_1 = _S47;
    c_1.q_ang_1 = _S47;
    c_1.energy_2 = 0.0f;
    c_1.diss_0 = 0.0f;
    c_1.plastic_1 = plastic_2;
    var _S48 : u32 = (*mat_4).kind_flags_0.y;
    if(((_S48 & (u32(2)))) == u32(0))
    {
        return c_1;
    }
    var kn_1 : f32 = (*b_4).stiff0_0.x;
    var ks_0 : f32 = (*b_4).stiff0_0.y;
    var kt_0 : f32 = (*b_4).stiff1_0.x;
    var w0_2 : f32 = (*b_4).geom0_0.y;
    var w1_2 : f32 = (*b_4).geom0_0.z;
    var diss_1 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_3 : f32;
    if(((_S48 & (u32(4)))) != u32(0))
    {
        var p_1 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_1), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S49 : f32 = p_1.y;
        var _S50 : f32 = p_1.z;
        var _S51 : f32 = p_1.w;
        nc_sum_0 = p_1.x;
        m1_0 = _S49;
        m2_0 = _S50;
        energy_3 = _S51;
    }
    else
    {
        var _S52 : f32 = kn_1 * (1.0f - crush_1) / 36.0f;
        var i_2 : u32 = u32(0);
        diss_1 = 0.0f;
        var m1_1 : f32 = 0.0f;
        var m2_1 : f32 = 0.0f;
        var energy_4 : f32 = 0.0f;
        loop
        {
            if(i_2 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S53 : f32 = ((f32(i_2) + 0.5f) / 6.0f - 0.5f) * w0_2;
            var j_0 : u32 = u32(0);
            nc_sum_0 = diss_1;
            m1_0 = m1_1;
            m2_0 = m2_1;
            energy_3 = energy_4;
            loop
            {
                if(j_0 < u32(6))
                {
                }
                else
                {
                    break;
                }
                var s2_0 : f32 = ((f32(j_0) + 0.5f) / 6.0f - 0.5f) * w1_2;
                var di_0 : f32 = d_lin_0.z + d_ang_0.x * s2_0 - d_ang_0.y * _S53;
                if(di_0 < 0.0f)
                {
                    var f_2 : f32 = _S52 * di_0;
                    var m1_2 : f32 = m1_0 + f_2 * s2_0;
                    var m2_2 : f32 = m2_0 - f_2 * _S53;
                    var energy_5 : f32 = energy_3 + 0.5f * _S52 * di_0 * di_0;
                    nc_sum_0 = nc_sum_0 + f_2;
                    m1_0 = m1_2;
                    m2_0 = m2_2;
                    energy_3 = energy_5;
                }
                j_0 = j_0 + u32(1);
            }
            i_2 = i_2 + u32(1);
            diss_1 = nc_sum_0;
            m1_1 = m1_0;
            m2_1 = m2_0;
            energy_4 = energy_3;
        }
        nc_sum_0 = diss_1;
        m1_0 = m1_1;
        m2_0 = m2_1;
        energy_3 = energy_4;
    }
    var nc_0 : f32 = - nc_sum_0;
    var p_2 : vec3<f32> = plastic_2;
    c_1.q_lin_1 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_1.q_ang_1 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_4).strength_0.w * nc_0;
    var _S54 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S55 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var trial_1 : vec2<f32> = vec2<f32>(_S54, _S55);
    var tn_0 : f32 = sqrt(_S54 * _S54 + _S55 * _S55);
    var _S56 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S56 = tn_0 > 0.0f;
    }
    else
    {
        _S56 = false;
    }
    if(_S56)
    {
        var dir_0 : vec2<f32> = trial_1 / vec2<f32>(tn_0);
        var dslip_0 : f32 = (tn_0 - slide_cap_0) / ks_0;
        var _S57 : f32 = dir_0.x;
        p_2[i32(0)] = p_2[i32(0)] + _S57 * dslip_0;
        var _S58 : f32 = dir_0.y;
        p_2[i32(1)] = p_2[i32(1)] + _S58 * dslip_0;
        c_1.q_lin_1[i32(0)] = _S57 * slide_cap_0;
        c_1.q_lin_1[i32(1)] = _S58 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_1.q_lin_1[i32(0)] = _S54;
        c_1.q_lin_1[i32(1)] = _S55;
        diss_1 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_2.z, slide_cap_0 * (*b_4).geom1_0.z);
    var _S59 : f32 = tq_0.x;
    var _S60 : f32 = tq_0.y;
    var diss_2 : f32 = diss_1 + abs(_S59) * abs(_S60);
    p_2[i32(2)] = p_2[i32(2)] + _S60;
    c_1.q_ang_1[i32(2)] = _S59;
    c_1.energy_2 = energy_3 + 0.5f * (sq_0(c_1.q_lin_1.x) / ks_0 + sq_0(c_1.q_lin_1.y) / ks_0 + sq_0(_S59) / kt_0);
    c_1.diss_0 = diss_2;
    c_1.plastic_1 = p_2;
    return c_1;
}

fn life_rate_0( mat_5 : ptr<function, JointMaterial_std140_0>,  s_1 : f32) -> f32
{
    if(s_1 <= 0.0f)
    {
        return 0.0f;
    }
    var _S61 : f32 = (*mat_5).misc_0.y;
    return (_S61 + 1.0f) * pow(s_1, _S61) / (*mat_5).misc_0.z;
}

struct JointResponse_0
{
     force_lin_1 : vec3<f32>,
     force_ang_1 : vec3<f32>,
     state_1 : JointState_0,
     dissipated_1 : f32,
     overshoot_0 : f32,
     stored_0 : f32,
     disconnected_0 : bool,
     measures_0 : Measures_0,
};

fn joint_evaluate_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_5 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>,  dt_3 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_2 : f32 = (*b_5).stiff0_0.x;
    var ks_1 : f32 = (*b_5).stiff0_0.y;
    var kb1_0 : f32 = (*b_5).stiff0_0.z;
    var kb2_0 : f32 = (*b_5).stiff0_0.w;
    var _S62 : vec4<f32> = (*b_5).stiff1_0;
    var kt_1 : f32 = (*b_5).stiff1_0.x;
    var has_rebar_1 : bool = ((*b_5).stiff1_0.w) != 0.0f;
    var kind_3 : u32 = (*mat_6).kind_flags_0.x;
    var flags_0 : u32 = (*mat_6).kind_flags_0.y;
    var softening_0 : bool = ((flags_0 & (u32(1)))) != u32(0);
    var st_1 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_0(state_2, has_rebar_1);
    var qe_lin_0 : vec3<f32> = d_lin_1 * vec3<f32>(ks_1, ks_1, kn_2);
    var qe_ang_0 : vec3<f32> = d_ang_1 * vec3<f32>(kb1_0, kb2_0, kt_1);
    var _S63 : Measures_0 = stress_measures_0(&((*b_5)), qe_lin_0, qe_ang_0);
    var _S64 : f32 = max(max(_S63.tension_0, _S63.shear_0), _S63.compression_0);
    var _S65 : bool = dt_3 > 0.0f;
    var dif_1 : f32;
    if(_S65)
    {
        var raw_0 : f32 = max((_S64 - st_1.governing_stress_0) / dt_3, 0.0f) / (*mat_6).misc_0.w;
        var tau_2 : f32 = _S62.z;
        if(((flags_0 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- dt_3 / tau_2);
        }
        else
        {
            dif_1 = min(dt_3 / tau_2, 1.0f);
        }
        st_1.strain_rate_0 = st_1.strain_rate_0 + (raw_0 - st_1.strain_rate_0) * dif_1;
        st_1.governing_stress_0 = _S64;
    }
    if(((flags_0 & (u32(32)))) != u32(0))
    {
        var _S66 : f32 = dif_factor_0(&((*mat_6)), st_1.strain_rate_0);
        dif_1 = _S66;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_5).geom1_0.w;
    var _S67 : f32 = weibull_0 * dif_1;
    var _S68 : f32 = fatigue_factor_1(&((*mat_6)), st_1.fatigue_0);
    var multiplier_1 : f32 = _S67 * _S68;
    var _S69 : vec4<f32> = failure_indices_0(&((*mat_6)), &((*b_5)), _S63, multiplier_1);
    var _S70 : f32 = _S69.x;
    var _S71 : f32 = _S69.y;
    st_1.utilization_0 = max(max(_S70, _S71), max(_S69.z, _S69.w));
    var _S72 : f32 = d_lin_1.x;
    var _S73 : f32 = d_lin_1.y;
    var _S74 : f32 = ks_1 * (sq_0(_S72) + sq_0(_S73)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    var _S75 : f32 = d_lin_1.z;
    var _S76 : bool = _S75 > 0.0f;
    if(_S76)
    {
        dif_1 = kn_2 * sq_0(_S75);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S74 + dif_1);
    var psi_c_0 : f32;
    if(_S75 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S75);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_3 : vec3<f32> = vec3<f32>(st_1.plastic_x_0, st_1.plastic_y_0, st_1.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_2 : f32;
    var overshoot_1 : f32;
    var _S77 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S78 : bool = _S70 >= _S71;
        if(_S78)
        {
            diss_contact_0 = _S70;
        }
        else
        {
            diss_contact_0 = _S71;
        }
        var mode_ts_0 : u32;
        if(_S78)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_1.kappa_0))
        {
            _S77 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S77 = false;
        }
        if(_S77)
        {
            _S77 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S77 = false;
        }
        var mode_c_0 : u32;
        if(_S77)
        {
            if(mode_ts_0 == u32(1))
            {
                psi_contact_0 = (*mat_6).energy_1.y;
            }
            else
            {
                psi_contact_0 = (*mat_6).energy_1.z;
            }
            if(softening_0)
            {
                intact_normal_0 = psi_contact_0 * (*b_5).geom0_0.x * diss_contact_0 * diss_contact_0 / psi_ts_0;
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
            var _S79 : f32 = inc_0.x;
            if(_S79 > (st_1.damage_0))
            {
                var _S80 : Contact_0 = contact_part_0(&((*mat_6)), &((*b_5)), st_1.crush_0, plastic_3, d_lin_1, d_ang_1);
                var _S81 : f32 = max(_S80.energy_2 - (1.0f - st_1.crush_0) * psi_c_0, 0.0f);
                var _S82 : f32 = max(inc_0.y - _S81 * (_S79 - st_1.damage_0), 0.0f);
                var _S83 : f32 = max((psi_ts_0 - _S81) * (_S79 - st_1.damage_0) - _S82, 0.0f);
                st_1.damage_0 = _S79;
                st_1.mode_0 = mode_ts_0;
                dissipated_2 = _S82;
                overshoot_1 = _S83;
            }
            else
            {
                dissipated_2 = 0.0f;
                overshoot_1 = 0.0f;
            }
        }
        else
        {
            dissipated_2 = 0.0f;
            overshoot_1 = 0.0f;
        }
        st_1.kappa_0 = max(st_1.kappa_0, diss_contact_0);
        if((state_2.damage_0) > 0.0f)
        {
            var _S84 : Contact_0 = contact_part_0(&((*mat_6)), &((*b_5)), state_2.crush_0, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S84.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S85 : Measures_0 = stress_measures_0(&((*b_5)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S86 : vec4<f32> = failure_indices_0(&((*mat_6)), &((*b_5)), _S85, multiplier_1);
        var _S87 : f32 = _S86.z;
        var _S88 : f32 = _S86.w;
        var _S89 : bool = _S87 >= _S88;
        if(_S89)
        {
            psi_contact_0 = _S87;
        }
        else
        {
            psi_contact_0 = _S88;
        }
        if(_S89)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_1.kappa_c_0))
        {
            _S77 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S77 = false;
        }
        if(_S77)
        {
            _S77 = psi_c_0 > 0.0f;
        }
        else
        {
            _S77 = false;
        }
        if(_S77)
        {
            if(softening_0)
            {
                intact_normal_0 = (*mat_6).energy_1.w * (*b_5).geom0_0.x * psi_contact_0 * psi_contact_0 / psi_c_0;
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
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_1.kappa_c_0, psi_contact_0, intact_normal_0, st_1.crush_0, psi_c_0);
            var _S90 : f32 = inc_1.x;
            if(_S90 > (st_1.crush_0))
            {
                var _S91 : f32 = inc_1.y;
                var dissipated_3 : f32 = dissipated_2 + _S91;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S90 - st_1.crush_0) - _S91, 0.0f);
                st_1.crush_0 = _S90;
                st_1.mode_0 = mode_c_0;
                if(_S90 >= 1.0f)
                {
                    _S77 = (st_1.damage_0) < 1.0f;
                }
                else
                {
                    _S77 = false;
                }
                if(_S77)
                {
                    var dissipated_4 : f32 = dissipated_3 + psi_ts_0 * (1.0f - st_1.damage_0);
                    st_1.damage_0 = 1.0f;
                    dissipated_2 = dissipated_4;
                }
                else
                {
                    dissipated_2 = dissipated_3;
                }
                overshoot_1 = overshoot_2;
            }
        }
        st_1.kappa_c_0 = max(st_1.kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_2 = 0.0f;
        overshoot_1 = 0.0f;
    }
    var dmg_0 : f32 = st_1.damage_0;
    var _S92 : vec3<f32> = vec3<f32>(0.0f);
    if((st_1.damage_0) == 0.0f)
    {
        _S77 = ((flags_0 & (u32(8)))) != u32(0);
    }
    else
    {
        _S77 = false;
    }
    var qc_ang_0 : vec3<f32>;
    if(!_S77)
    {
        var _S93 : Contact_0 = contact_part_0(&((*mat_6)), &((*b_5)), st_1.crush_0, plastic_3, d_lin_1, d_ang_1);
        st_1.plastic_x_0 = _S93.plastic_1.x;
        st_1.plastic_y_0 = _S93.plastic_1.y;
        st_1.plastic_t_0 = _S93.plastic_1.z;
        diss_contact_0 = _S93.diss_0;
        qc_lin_0 = _S93.q_lin_1;
        qc_ang_0 = _S93.q_ang_1;
        psi_contact_0 = _S93.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S92;
        qc_ang_0 = _S92;
        psi_contact_0 = 0.0f;
    }
    var dissipated_5 : f32 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S76)
    {
        intact_normal_0 = kn_2 * _S75;
    }
    else
    {
        intact_normal_0 = (1.0f - st_1.crush_0) * kn_2 * _S75;
    }
    var _S94 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S94 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S94 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S94 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S94) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_1 : f32 = _S94 * (psi_ts_0 + (1.0f - st_1.crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S77 = (st_1.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S77 = false;
    }
    var stored_2 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S77)
    {
        var k_axial_0 : f32 = (*b_5).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_5).rebar0_0.y;
        var yield_force_0 : f32 = (*b_5).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_5).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S75, st_1.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S72, st_1.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S73, st_1.rebar_slip1_0, dowel_capacity_0);
        var _S95 : f32 = nr_0.y;
        var _S96 : f32 = v1_0.y;
        var _S97 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S95) + dowel_capacity_0 * (abs(_S96) + abs(_S97));
        st_1.rebar_plastic_0 = st_1.rebar_plastic_0 + _S95;
        st_1.rebar_slip0_0 = st_1.rebar_slip0_0 + _S96;
        st_1.rebar_slip1_0 = st_1.rebar_slip1_0 + _S97;
        st_1.rebar_work_0 = st_1.rebar_work_0 + work_0;
        var dissipated_6 : f32 = dissipated_5 + work_0;
        var _S98 : f32 = nr_0.x;
        var _S99 : f32 = v1_0.x;
        var _S100 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (sq_0(_S98) / k_axial_0 + (sq_0(_S99) + sq_0(_S100)) / k_dowel_0);
        if(fracture_1)
        {
            _S77 = (st_1.rebar_work_0) >= ((*b_5).rebar1_0.x);
        }
        else
        {
            _S77 = false;
        }
        if(_S77)
        {
            st_1.rebar_broken_0 = 1.0f;
            var dissipated_7 : f32 = dissipated_6 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_2 = dissipated_7;
            stored_2 = stored_1;
        }
        else
        {
            var stored_3 : f32 = stored_1 + elastic_0;
            force_lin_3 = force_lin_2 + vec3<f32>(_S99, _S100, _S98);
            dissipated_2 = dissipated_6;
            stored_2 = stored_3;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_2 = dissipated_5;
        stored_2 = stored_1;
    }
    if(fracture_1)
    {
        _S77 = _S65;
    }
    else
    {
        _S77 = false;
    }
    if(_S77)
    {
        _S77 = ((flags_0 & (u32(64)))) != u32(0);
    }
    else
    {
        _S77 = false;
    }
    if(_S77)
    {
        var _S101 : Measures_0 = stress_measures_0(&((*b_5)), force_lin_3, force_ang_2);
        var _S102 : vec4<f32> = failure_indices_0(&((*mat_6)), &((*b_5)), _S101, weibull_0);
        var _S103 : f32 = life_rate_0(&((*mat_6)), max(max(_S102.x, _S102.y), _S102.z));
        st_1.fatigue_0 = min(st_1.fatigue_0 + _S103 * dt_3, 1.0f);
    }
    st_1.dissipated_0 = st_1.dissipated_0 + dissipated_2;
    var resp_0 : JointResponse_0;
    resp_0.force_lin_1 = force_lin_3;
    resp_0.force_ang_1 = force_ang_2;
    resp_0.state_1 = st_1;
    resp_0.dissipated_1 = dissipated_2;
    resp_0.overshoot_0 = overshoot_1;
    resp_0.stored_0 = stored_2;
    if(was_connected_0)
    {
        _S77 = !connected_0(st_1, has_rebar_1);
    }
    else
    {
        _S77 = false;
    }
    resp_0.disconnected_0 = _S77;
    resp_0.measures_0 = _S63;
    return resp_0;
}

fn secant_factors_0( b_6 : ptr<function, JointBond_std430_0>,  st_2 : JointState_0,  d_lin_2 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
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
    var _S104 : f32 = 1.0f - st_2.damage_0;
    var _S105 : f32 = max(_S104 + contact_0, 9.99999997475242708e-07f);
    var normal_1 : f32;
    if(compressed_0)
    {
        normal_1 = max(1.0f - st_2.crush_0, 9.99999997475242708e-07f);
    }
    else
    {
        normal_1 = max(_S104, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S105, _S105, normal_1);
    (*f_ang_0) = vec3<f32>(_S105);
    var _S106 : bool;
    if(((*b_6).stiff1_0.w) != 0.0f)
    {
        _S106 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S106 = false;
    }
    if(_S106)
    {
        var _S107 : vec4<f32> = (*b_6).rebar0_0;
        var _S108 : vec4<f32> = (*b_6).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + (*b_6).rebar0_0.x / (*b_6).stiff0_0.x;
        var _S109 : f32 = _S107.y;
        var _S110 : f32 = _S108.y;
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S109 / _S110;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S109 / _S110;
    }
    return;
}

fn comp_add1_0( sum_0 : ptr<function, f32>,  err_0 : ptr<function, f32>,  x_4 : f32)
{
    var t_2 : f32 = (*sum_0) + x_4;
    if((abs((*sum_0))) >= (abs(x_4)))
    {
        (*err_0) = (*err_0) + ((*sum_0) - t_2 + x_4);
    }
    else
    {
        (*err_0) = (*err_0) + (x_4 - t_2 + (*sum_0));
    }
    (*sum_0) = t_2;
    return;
}

fn comp_add1_1( sum_1 : ptr<function, f32>,  err_1 : ptr<function, f32>,  x_5 : f32)
{
    var t_3 : f32 = (*sum_1) + x_5;
    if((abs((*sum_1))) >= (abs(x_5)))
    {
        (*err_1) = (*err_1) + ((*sum_1) - t_3 + x_5);
    }
    else
    {
        (*err_1) = (*err_1) + (x_5 - t_3 + (*sum_1));
    }
    (*sum_1) = t_3;
    return;
}

fn is_damaged_0( st_3 : JointState_0) -> bool
{
    var _S111 : bool;
    if((st_3.damage_0) > 0.0f)
    {
        _S111 = true;
    }
    else
    {
        _S111 = (st_3.crush_0) > 0.0f;
    }
    return _S111;
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

fn to_local_0( _S112 : u32,  _S113 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S113, bonds_0[_S112].t1_0.xyz), dot(_S113, bonds_0[_S112].t2_0.xyz), dot(_S113, bonds_0[_S112].normal_0.xyz));
}

fn to_body_0( _S114 : u32,  _S115 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S114].t1_0.xyz * vec3<f32>(_S115.x) + bonds_0[_S114].t2_0.xyz * vec3<f32>(_S115.y) + bonds_0[_S114].normal_0.xyz * vec3<f32>(_S115.z);
}

fn bond_update_0( i_3 : u32,  dt_4 : f32,  fracture_2 : bool,  abs_step_0 : u32)
{
    var _S116 : JointState_0 = JointState_0( bond_dyn_0[i_3].js_0.damage_0, bond_dyn_0[i_3].js_0.crush_0, bond_dyn_0[i_3].js_0.kappa_0, bond_dyn_0[i_3].js_0.kappa_c_0, bond_dyn_0[i_3].js_0.ductility_0, bond_dyn_0[i_3].js_0.ductility_c_0, bond_dyn_0[i_3].js_0.fatigue_0, bond_dyn_0[i_3].js_0.plastic_x_0, bond_dyn_0[i_3].js_0.plastic_y_0, bond_dyn_0[i_3].js_0.plastic_t_0, bond_dyn_0[i_3].js_0.rebar_plastic_0, bond_dyn_0[i_3].js_0.rebar_slip0_0, bond_dyn_0[i_3].js_0.rebar_slip1_0, bond_dyn_0[i_3].js_0.rebar_work_0, bond_dyn_0[i_3].js_0.rebar_broken_0, bond_dyn_0[i_3].js_0.strain_rate_0, bond_dyn_0[i_3].js_0.governing_stress_0, bond_dyn_0[i_3].js_0.dissipated_0, bond_dyn_0[i_3].js_0.utilization_0, bond_dyn_0[i_3].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S116;
    bd_0.force_lin_0 = bond_dyn_0[i_3].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_3].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_3].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_3].comps_0;
    bd_0.events_0 = bond_dyn_0[i_3].events_0;
    var _S117 : JointBond_std430_0 = bonds_0[i_3].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_3].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_3].rb_0.xyz;
    var _S118 : u32 = u32(4) * _S117.ids_0.y;
    var ta_0 : vec3<f32> = state_0[_S118 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S118 + u32(3)].xyz;
    var _S119 : u32 = u32(4) * _S117.ids_0.z;
    var tb_0 : vec3<f32> = state_0[_S119 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S119 + u32(3)].xyz;
    var _S120 : vec3<f32> = to_local_0(i_3, state_0[_S119].xyz + cross(tb_0, rb_1) - (state_0[_S118].xyz + cross(ta_0, ra_1)));
    var _S121 : vec3<f32> = to_local_0(i_3, tb_0 - ta_0);
    var _S122 : vec3<f32> = to_local_0(i_3, state_0[_S119 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S118 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S123 : vec3<f32> = to_local_0(i_3, wb_0 - wa_0);
    var _S124 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S117.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S125 : JointResponse_0 = joint_evaluate_0(&(_S124), &(_S117), bd_0.js_0, _S120, _S121, dt_4, fracture_2);
    var f_lin_1 : vec3<f32>;
    var f_ang_1 : vec3<f32>;
    secant_factors_0(&(_S117), _S125.state_1, _S120, &(f_lin_1), &(f_ang_1));
    var qd_lin_0 : vec3<f32> = _S122 * bonds_0[i_3].c_lin_0.xyz * f_lin_1;
    var qd_ang_0 : vec3<f32> = _S123 * bonds_0[i_3].c_ang_0.xyz * f_ang_1;
    var q_lin_2 : vec3<f32> = _S125.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S125.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S122) + dot(qd_ang_0, _S123)) * dt_4;
    var _S126 : vec3<f32> = to_body_0(i_3, q_lin_2);
    var _S127 : vec3<f32> = to_body_0(i_3, q_ang_2);
    var _S128 : u32 = u32(3) * i_3;
    bond_loads_0[_S128] = vec4<f32>(_S126, max(_S125.measures_0.tension_0, _S125.measures_0.compression_0));
    bond_loads_0[_S128 + u32(1)] = vec4<f32>(_S127 + cross(ra_1, _S126), 0.0f);
    bond_loads_0[_S128 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S127) + cross(rb_1, (vec3<f32>(0) - _S126)), 0.0f);
    var _S129 : f32 = bd_0.sums_0[i32(0)];
    var _S130 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S129), &(_S130), _S125.dissipated_1);
    bd_0.sums_0[i32(0)] = _S129;
    bd_0.comps_0[i32(0)] = _S130;
    var _S131 : f32 = bd_0.sums_0[i32(1)];
    var _S132 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S131), &(_S132), _S125.overshoot_0);
    bd_0.sums_0[i32(1)] = _S131;
    bd_0.comps_0[i32(1)] = _S132;
    var _S133 : f32 = bd_0.sums_0[i32(2)];
    var _S134 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S133), &(_S134), damped_0);
    bd_0.sums_0[i32(2)] = _S133;
    bd_0.comps_0[i32(2)] = _S134;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S125.stored_0);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S125.state_1.utilization_0));
    var _S135 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S135 = is_damaged_0(_S125.state_1);
    }
    else
    {
        _S135 = false;
    }
    if(_S135)
    {
        _S135 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S135 = false;
    }
    if(_S135)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S125.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S136 : f32 = fatigue_factor_0(&(_S124), previous_0.fatigue_0);
        _S135 = _S136 > 0.99000000953674316f;
    }
    else
    {
        _S135 = false;
    }
    if(_S135)
    {
        var _S137 : f32 = fatigue_factor_0(&(_S124), _S125.state_1.fatigue_0);
        _S135 = _S137 <= 0.99000000953674316f;
    }
    else
    {
        _S135 = false;
    }
    if(_S135)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S125.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
        g_halt_0 = u32(1);
    }
    bd_0.js_0 = _S125.state_1;
    bond_dyn_0[i_3].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_3].js_0.crush_0 = bd_0.js_0.crush_0;
    bond_dyn_0[i_3].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_3].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_3].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_3].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_3].js_0.fatigue_0 = bd_0.js_0.fatigue_0;
    bond_dyn_0[i_3].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
    bond_dyn_0[i_3].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
    bond_dyn_0[i_3].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
    bond_dyn_0[i_3].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
    bond_dyn_0[i_3].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
    bond_dyn_0[i_3].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
    bond_dyn_0[i_3].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
    bond_dyn_0[i_3].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
    bond_dyn_0[i_3].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
    bond_dyn_0[i_3].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
    bond_dyn_0[i_3].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
    bond_dyn_0[i_3].js_0.utilization_0 = bd_0.js_0.utilization_0;
    bond_dyn_0[i_3].js_0.mode_0 = bd_0.js_0.mode_0;
    bond_dyn_0[i_3].force_lin_0 = bd_0.force_lin_0;
    bond_dyn_0[i_3].force_ang_0 = bd_0.force_ang_0;
    bond_dyn_0[i_3].sums_0 = bd_0.sums_0;
    bond_dyn_0[i_3].comps_0 = bd_0.comps_0;
    bond_dyn_0[i_3].events_0 = bd_0.events_0;
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
     pos_0 : vec3<f32>,
     pos_err_0 : vec3<f32>,
     vel_0 : vec3<f32>,
     vel_err_0 : vec3<f32>,
     w_1 : vec3<f32>,
     a_5 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn chunk_external_0( _S138 : u32,  _S139 : u32,  _S140 : Quat_0,  _S141 : u32,  _S142 : f32,  _S143 : bool,  _S144 : ptr<function, vec3<f32>>,  _S145 : ptr<function, vec3<f32>>)
{
    var _S146 : vec3<f32> = vec3<f32>(0.0f);
    (*_S144) = _S146;
    (*_S145) = _S146;
    var _S147 : vec4<u32> = chunks_0[_S139].load_range_0;
    var term_1 : u32 = chunks_0[_S139].load_range_0.x;
    loop
    {
        if(term_1 < (_S147.y))
        {
        }
        else
        {
            break;
        }
        var _S148 : u32 = u32(5) * term_1;
        var _S149 : u32 = (bitcast<vec4<u32>>((loads_0[_S148]))).y;
        if(_S149 == u32(2))
        {
            term_1 = term_1 + u32(1);
            continue;
        }
        var dir_1 : vec4<f32> = loads_0[_S148 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S148 + u32(2)];
        var value_0 : f32 = eval_function_0(term_1, _S141, _S142, 0.0f);
        var fw_0 : vec3<f32>;
        if(_S149 == u32(0))
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S140, dir_1.xyz) * vec3<f32>((- value_0 * dir_1.w));
        }
        (*_S144) = (*_S144) + fw_0;
        (*_S145) = (*_S145) + cross(rotate_0(_S140, arm_0.xyz), fw_0);
        term_1 = term_1 + u32(1);
    }
    if(_S143)
    {
        var _S150 : u32 = u32(2) * _S138;
        (*_S144) = (*_S144) + contact_out_0[params_0.contact_base_0 + _S150].xyz;
        (*_S145) = (*_S145) + contact_out_0[params_0.contact_base_0 + _S150 + u32(1)].xyz;
    }
    return;
}

fn chunk_update_0( c_2 : u32,  isl_0 : Island_0,  rg_0 : Rigid_0,  dt_5 : f32,  rml_0 : bool,  k_4 : u32,  work_1 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S151 : vec3<f32> = vec3<f32>(0.0f);
    var _S152 : u32 = csr_0[c_2];
    var peak_0 : f32 = 0.0f;
    var k_5 : u32 = _S152;
    var fi_0 : vec3<f32> = _S151;
    var mi_0 : vec3<f32> = _S151;
    loop
    {
        if(k_5 < csr_0[c_2 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var e_0 : u32 = csr_0[k_5];
        var _S153 : u32 = u32(3) * ((e_0 >> (u32(1))));
        var fa_0 : vec4<f32> = bond_loads_0[_S153];
        if(((e_0 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + bond_loads_0[_S153 + u32(1)].xyz;
            fi_0 = fi_0 + fa_0.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + bond_loads_0[_S153 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_0.xyz);
            mi_0 = mi_2;
        }
        var _S154 : f32 = max(peak_0, fa_0.w);
        var _S155 : u32 = k_5 + u32(1);
        peak_0 = _S154;
        k_5 = _S155;
    }
    var _S156 : u32 = u32(4) * c_2;
    var u_0 : vec3<f32> = state_0[_S156].xyz;
    var _S157 : u32 = _S156 + u32(1);
    var th_0 : vec3<f32> = state_0[_S157].xyz;
    var _S158 : u32 = _S156 + u32(2);
    var v_4 : vec3<f32> = state_0[_S158].xyz;
    var _S159 : u32 = _S156 + u32(3);
    var w_2 : vec3<f32> = state_0[_S159].xyz;
    var mass_0 : f32 = chunks_0[c_2].center_0.w;
    var _S160 : vec3<f32> = chunks_0[c_2].center_0.xyz;
    var _S161 : vec3<f32> = isl_0.com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_0.rot_0, _S160 + u_0 - _S161);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_0(c_2, c_2, rg_0.rot_0, k_4, dt_5, (((isl_0.info_0.x) & (u32(4)))) != u32(0), &(f_load_0), &(t_load_0));
    var _S162 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S162;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_0.rot_0, chunks_0[c_2].inertia0_1, chunks_0[c_2].inertia1_1, chunks_0[c_2].inertia2_1, rg_0.alpha_0) + cross(rg_0.w_1, world_mul_0(rg_0.rot_0, chunks_0[c_2].inertia0_1, chunks_0[c_2].inertia1_1, chunks_0[c_2].inertia2_1, rg_0.w_1)));
        f_world_1 = f_world_0 - (rg_0.a_5 + cross(rg_0.alpha_0, r_world_0) + cross(rg_0.w_1, cross(rg_0.w_1, r_world_0))) * _S162;
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
        var wb_1 : vec3<f32> = inverse_rotate_0(rg_0.rot_0, rg_0.w_1);
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_2].inertia0_1, chunks_0[c_2].inertia1_1, chunks_0[c_2].inertia2_1, w_2);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_2, rows_mul_0(chunks_0[c_2].inertia0_1, chunks_0[c_2].inertia1_1, chunks_0[c_2].inertia2_1, wb_1)) + cross(w_2, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_4) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var _S163 : vec4<u32> = chunks_0[c_2].load_range_0;
    var term_2 : u32 = chunks_0[c_2].load_range_0.x;
    loop
    {
        if(term_2 < (_S163.y))
        {
        }
        else
        {
            break;
        }
        var _S164 : u32 = u32(5) * term_2;
        if(((bitcast<vec4<u32>>((loads_0[_S164]))).y) != u32(2))
        {
            term_2 = term_2 + u32(1);
            continue;
        }
        var _S165 : vec3<f32> = vec3<f32>(eval_function_0(term_2, k_4, dt_5, dt_5));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S164 + u32(2)].xyz * _S165;
        f_ext_1 = f_ext_1 + loads_0[_S164 + u32(1)].xyz * _S165;
        m_ext_1 = m_ext_3;
        term_2 = term_2 + u32(1);
    }
    var f_3 : vec3<f32> = f_ext_1 + fi_0;
    var m_3 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_2].info_1.x;
    var _S166 : vec3<f32> = vec3<f32>(state_0[_S157].w, state_0[_S158].w, state_0[_S159].w);
    var reaction_0 : vec3<f32>;
    var u_1 : vec3<f32>;
    var th_1 : vec3<f32>;
    var v_5 : vec3<f32>;
    var w_3 : vec3<f32>;
    if(support_0 == u32(1))
    {
        reaction_0 = (vec3<f32>(0) - f_3);
        u_1 = u_0;
        th_1 = th_0;
        v_5 = _S151;
        w_3 = _S151;
    }
    else
    {
        var _S167 : vec4<f32> = chunks_0[c_2].scale_0;
        var w_4 : vec3<f32> = w_2 + rows_mul_0(chunks_0[c_2].inv0_1, chunks_0[c_2].inv1_1, chunks_0[c_2].inv2_1, m_3) * vec3<f32>((dt_5 * chunks_0[c_2].scale_0.z));
        var _S168 : vec3<f32> = vec3<f32>(dt_5);
        var th_2 : vec3<f32> = th_0 + w_4 * _S168;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_3);
            u_1 = u_0;
            th_1 = _S151;
        }
        else
        {
            var v_6 : vec3<f32> = v_4 + f_3 * vec3<f32>((dt_5 * _S167.y));
            var u_2 : vec3<f32> = u_0 + v_6 * _S168;
            reaction_0 = _S166;
            u_1 = u_2;
            th_1 = v_6;
        }
        var _S169 : vec3<f32> = th_1;
        th_1 = th_2;
        v_5 = _S169;
        w_3 = w_4;
    }
    state_0[_S156] = vec4<f32>(u_1, peak_0);
    state_0[_S157] = vec4<f32>(th_1, reaction_0.x);
    state_0[_S158] = vec4<f32>(v_5, reaction_0.y);
    state_0[_S159] = vec4<f32>(w_3, reaction_0.z);
    comp_add1_1(&((*work_1)), &((*work_err_0)), (dot(f_load_0, rg_0.vel_0 + rg_0.vel_err_0 + cross(rg_0.w_1, rotate_0(rg_0.rot_0, _S160 + u_1 - _S161)) + rotate_0(rg_0.rot_0, v_5)) + dot(t_load_0, rg_0.w_1 + rotate_0(rg_0.rot_0, w_3))) * dt_5);
    return;
}

fn comp_add_0( sum_2 : ptr<function, vec3<f32>>,  err_2 : ptr<function, vec3<f32>>,  x_6 : vec3<f32>)
{
    var t_4 : vec3<f32> = (*sum_2) + x_6;
    var _S170 : vec3<f32> = abs(x_6);
    (*err_2) = (*err_2) + (select(x_6, (*sum_2), (abs((*sum_2))) >= _S170) - t_4 + select((*sum_2), x_6, (abs((*sum_2))) >= _S170));
    (*sum_2) = t_4;
    return;
}

fn safe_normalize_0( v_7 : vec3<f32>) -> vec3<f32>
{
    var n_0 : f32 = length(v_7);
    var _S171 : vec3<f32>;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S171 = v_7 / vec3<f32>(n_0);
    }
    else
    {
        _S171 = vec3<f32>(0.0f);
    }
    return _S171;
}

fn from_axis_angle_0( axis_0 : vec3<f32>,  angle_0 : f32) -> Quat_0
{
    var a_6 : vec3<f32> = safe_normalize_0(axis_0);
    var _S172 : f32 = 0.5f * angle_0;
    var s_2 : f32 = sin(_S172);
    var q_4 : Quat_0;
    q_4.w_0 = cos(_S172);
    q_4.x_0 = a_6.x * s_2;
    q_4.y_0 = a_6.y * s_2;
    q_4.z_0 = a_6.z * s_2;
    return q_4;
}

fn quat_mul_0( a_7 : Quat_0,  o_1 : Quat_0) -> Quat_0
{
    var r_5 : Quat_0;
    r_5.w_0 = a_7.w_0 * o_1.w_0 - a_7.x_0 * o_1.x_0 - a_7.y_0 * o_1.y_0 - a_7.z_0 * o_1.z_0;
    r_5.x_0 = a_7.w_0 * o_1.x_0 + a_7.x_0 * o_1.w_0 + a_7.y_0 * o_1.z_0 - a_7.z_0 * o_1.y_0;
    r_5.y_0 = a_7.w_0 * o_1.y_0 - a_7.x_0 * o_1.z_0 + a_7.y_0 * o_1.w_0 + a_7.z_0 * o_1.x_0;
    r_5.z_0 = a_7.w_0 * o_1.z_0 + a_7.x_0 * o_1.y_0 - a_7.y_0 * o_1.x_0 + a_7.z_0 * o_1.w_0;
    return r_5;
}

fn normalized_0( q_5 : Quat_0) -> Quat_0
{
    var _S173 : f32 = q_5.w_0;
    var _S174 : f32 = q_5.x_0;
    var _S175 : f32 = q_5.y_0;
    var _S176 : f32 = q_5.z_0;
    var n_1 : f32 = sqrt(_S173 * _S173 + _S174 * _S174 + _S175 * _S175 + _S176 * _S176);
    var r_6 : Quat_0;
    r_6.w_0 = q_5.w_0 / n_1;
    r_6.x_0 = q_5.x_0 / n_1;
    r_6.y_0 = q_5.y_0 / n_1;
    r_6.z_0 = q_5.z_0 / n_1;
    return r_6;
}

fn integrate_rotation_0( q_6 : Quat_0,  omega_0 : vec3<f32>,  dt_6 : f32) -> Quat_0
{
    var angle_1 : f32 = length(omega_0) * dt_6;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return q_6;
    }
    return normalized_0(quat_mul_0(from_axis_angle_0(omega_0, angle_1), q_6));
}

fn write_probe_0( slot_0 : u32,  k_6 : u32,  value_1 : f32)
{
    var index_0 : u32 = params_0.probe_base_0 * u32(4) + slot_0 * params_0.probe_stride_0 + k_6;
    var v_8 : vec4<f32> = bond_loads_0[index_0 / u32(4)];
    v_8[index_0 % u32(4)] = value_1;
    bond_loads_0[index_0 / u32(4)] = v_8;
    return;
}

fn record_probes_0( isl_1 : Island_0,  rg_1 : Rigid_0,  k_7 : u32)
{
    var at_0 : u32 = isl_1.probes_0.x;
    loop
    {
        if(at_0 < (isl_1.probes_0.y))
        {
        }
        else
        {
            break;
        }
        var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[at_0])));
        var a_8 : vec4<f32> = loads_0[at_0 + u32(1)];
        var b_7 : vec4<f32> = loads_0[at_0 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_0 + u32(3)];
        var kind_4 : u32 = info_3.x;
        var index_1 : u32 = info_3.y;
        var value_2 : f32;
        if(kind_4 == u32(0))
        {
            value_2 = dot(rg_1.pos_0 - b_7.xyz + (rg_1.pos_err_0 - c4_0.xyz) + rotate_0(rg_1.rot_0, chunks_0[index_1].center_0.xyz + state_0[u32(4) * index_1].xyz), a_8.xyz);
        }
        else
        {
            if(kind_4 == u32(1))
            {
                var _S177 : u32 = u32(4) * index_1;
                value_2 = dot(rg_1.vel_0 + rg_1.vel_err_0 + cross(rg_1.w_1, rotate_0(rg_1.rot_0, chunks_0[index_1].center_0.xyz + state_0[_S177].xyz - isl_1.com_0.xyz)) + rotate_0(rg_1.rot_0, state_0[_S177 + u32(2)].xyz), a_8.xyz);
            }
            else
            {
                if(kind_4 == u32(2))
                {
                    var _S178 : u32 = u32(3) * index_1;
                    var f_4 : vec3<f32> = bond_loads_0[_S178].xyz;
                    var _S179 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S179)
                    {
                        mc_0 = bond_loads_0[_S178 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = bond_loads_0[_S178 + u32(2)].xyz;
                    }
                    var fc_2 : vec3<f32>;
                    if(_S179)
                    {
                        fc_2 = f_4;
                    }
                    else
                    {
                        fc_2 = (vec3<f32>(0) - f_4);
                    }
                    value_2 = dot(fc_2, a_8.xyz) + dot(mc_0, b_7.xyz);
                }
                else
                {
                    var _S180 : u32 = u32(4) * index_1;
                    value_2 = dot(rotate_0(rg_1.rot_0, vec3<f32>(state_0[_S180 + u32(1)].w, state_0[_S180 + u32(2)].w, state_0[_S180 + u32(3)].w)), a_8.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_7, value_2);
        at_0 = at_0 + u32(4);
    }
    return;
}

fn quat_vec_0( q_7 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_7.x_0, q_7.y_0, q_7.z_0, q_7.w_0);
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var tid_1 : u32 = thread_0.x;
    var _S181 : u32 = group_0.x;
    var isl_2 : Island_0;
    isl_2.range_0 = islands_0[_S181].range_0;
    isl_2.info_0 = islands_0[_S181].info_0;
    isl_2.com_0 = islands_0[_S181].com_0;
    isl_2.inertia0_0 = islands_0[_S181].inertia0_0;
    isl_2.inertia1_0 = islands_0[_S181].inertia1_0;
    isl_2.inertia2_0 = islands_0[_S181].inertia2_0;
    isl_2.inv0_0 = islands_0[_S181].inv0_0;
    isl_2.inv1_0 = islands_0[_S181].inv1_0;
    isl_2.inv2_0 = islands_0[_S181].inv2_0;
    isl_2.wcom_0 = islands_0[_S181].wcom_0;
    isl_2.winv0_0 = islands_0[_S181].winv0_0;
    isl_2.winv1_0 = islands_0[_S181].winv1_0;
    isl_2.winv2_0 = islands_0[_S181].winv2_0;
    isl_2.rotation_0 = islands_0[_S181].rotation_0;
    isl_2.position_0 = islands_0[_S181].position_0;
    isl_2.position_err_0 = islands_0[_S181].position_err_0;
    isl_2.velocity_0 = islands_0[_S181].velocity_0;
    isl_2.velocity_err_0 = islands_0[_S181].velocity_err_0;
    isl_2.angular_velocity_0 = islands_0[_S181].angular_velocity_0;
    isl_2.done_0 = islands_0[_S181].done_0;
    isl_2.probes_0 = islands_0[_S181].probes_0;
    isl_2.energy_0 = islands_0[_S181].energy_0;
    var driven_0 : bool = (((isl_2.info_0.x) & (u32(2)))) != u32(0);
    var _S182 : bool = !((((isl_2.info_0.x) & (u32(1)))) != u32(0));
    var _S183 : bool;
    if(_S182)
    {
        _S183 = !driven_0;
    }
    else
    {
        _S183 = false;
    }
    var contact_island_0 : bool = (((isl_2.info_0.x) & (u32(4)))) != u32(0);
    var _S184 : bool = tid_1 == u32(0);
    var _S185 : bool;
    var run_0 : u32;
    if(_S184)
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
            var _S186 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
            if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
            {
                _S185 = true;
            }
            else
            {
                var _S187 : u32 = _S186.y;
                if(_S187 != u32(0))
                {
                    _S185 = _S187 <= (isl_2.info_0.w);
                }
                else
                {
                    _S185 = false;
                }
            }
        }
        else
        {
            _S185 = false;
        }
        if(_S185)
        {
            run_0 = u32(0);
        }
        g_run_0 = run_0;
    }
    workgroupBarrier();
    if((((isl_2.info_0.z) & (u32(1)))) != u32(0))
    {
        _S185 = true;
    }
    else
    {
        _S185 = g_run_0 == u32(0);
    }
    if(_S185)
    {
        run_0 = u32(0);
    }
    else
    {
        run_0 = min(isl_2.info_0.y, params_0.max_steps_0);
    }
    var _S188 : f32 = params_0.dt_0;
    var _S189 : bool = (params_0.fracture_0) != u32(0);
    var _S190 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var _S191 : vec3<f32> = params_0.gravity_0.xyz;
    var _S192 : f32 = isl_2.com_0.w;
    var rg_2 : Rigid_0;
    rg_2.rot_0 = quat_of_0(isl_2.rotation_0);
    rg_2.pos_0 = isl_2.position_0.xyz;
    rg_2.pos_err_0 = isl_2.position_err_0.xyz;
    rg_2.vel_0 = isl_2.velocity_0.xyz;
    rg_2.vel_err_0 = isl_2.velocity_err_0.xyz;
    rg_2.w_1 = isl_2.angular_velocity_0.xyz;
    var _S193 : vec3<f32> = vec3<f32>(0.0f);
    rg_2.a_5 = _S193;
    rg_2.alpha_0 = _S193;
    if(_S184)
    {
        g_halt_0 = u32(0);
    }
    workgroupBarrier();
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
        var k_8 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var i_4 : u32;
        var c_3 : u32;
        if(_S182)
        {
            var f_5 : vec3<f32> = _S193;
            var t_5 : vec3<f32> = _S193;
            i_4 = isl_2.range_0.x + tid_1;
            loop
            {
                if(i_4 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var fl_0 : vec3<f32>;
                var tl_0 : vec3<f32>;
                chunk_external_0(i_4, i_4, rg_2.rot_0, k_8, _S188, contact_island_0, &(fl_0), &(tl_0));
                var fc_3 : vec3<f32> = fl_0 + _S191 * vec3<f32>(chunks_0[i_4].center_0.w);
                var _S194 : vec3<f32> = chunks_0[i_4].center_0.xyz;
                var r_7 : vec3<f32> = rotate_0(rg_2.rot_0, _S194 + state_0[u32(4) * i_4].xyz - isl_2.com_0.xyz);
                f_5 = f_5 + fc_3;
                t_5 = t_5 + (cross(r_7, fc_3) + tl_0);
                var _S195 : vec4<u32> = chunks_0[i_4].load_range_0;
                c_3 = chunks_0[i_4].load_range_0.x;
                loop
                {
                    if(c_3 < (_S195.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S196 : u32 = u32(5) * c_3;
                    if(((bitcast<vec4<u32>>((loads_0[_S196]))).y) != u32(2))
                    {
                        c_3 = c_3 + u32(1);
                        continue;
                    }
                    var _S197 : vec3<f32> = vec3<f32>(eval_function_0(c_3, k_8, _S188, 0.0f));
                    var fw_1 : vec3<f32> = rotate_0(rg_2.rot_0, loads_0[_S196 + u32(1)].xyz * _S197);
                    f_5 = f_5 + fw_1;
                    t_5 = t_5 + (cross(rotate_0(rg_2.rot_0, _S194 - isl_2.com_0.xyz), fw_1) + rotate_0(rg_2.rot_0, loads_0[_S196 + u32(2)].xyz * _S197));
                    c_3 = c_3 + u32(1);
                }
                i_4 = i_4 + u32(256);
            }
            group_sum2_0(tid_1, &(f_5), &(t_5));
            var iw_w_0 : vec3<f32> = world_mul_0(rg_2.rot_0, isl_2.inertia0_0, isl_2.inertia1_0, isl_2.inertia2_0, rg_2.w_1);
            rg_2.a_5 = f_5 / vec3<f32>(_S192);
            rg_2.alpha_0 = world_mul_0(rg_2.rot_0, isl_2.inv0_0, isl_2.inv1_0, isl_2.inv2_0, t_5 - cross(rg_2.w_1, iw_w_0));
        }
        i_4 = isl_2.range_0.z + tid_1;
        loop
        {
            if(i_4 < (isl_2.range_0.w))
            {
            }
            else
            {
                break;
            }
            bond_update_0(i_4, _S188, _S189, abs_step_1);
            i_4 = i_4 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        c_3 = isl_2.range_0.x + tid_1;
        loop
        {
            if(c_3 < (isl_2.range_0.y))
            {
            }
            else
            {
                break;
            }
            chunk_update_0(c_3, isl_2, rg_2, _S188, _S190, k_8, &(work_2), &(work_err_1));
            c_3 = c_3 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S183)
        {
            var iw_w_1 : vec3<f32> = world_mul_0(rg_2.rot_0, isl_2.inertia0_0, isl_2.inertia1_0, isl_2.inertia2_0, rg_2.w_1);
            var _S198 : vec3<f32> = vec3<f32>(_S188);
            var l_0 : vec3<f32> = iw_w_1 + (world_mul_0(rg_2.rot_0, isl_2.inertia0_0, isl_2.inertia1_0, isl_2.inertia2_0, rg_2.alpha_0) + cross(rg_2.w_1, iw_w_1)) * _S198;
            var _S199 : vec3<f32> = rg_2.a_5 * _S198;
            var _S200 : vec3<f32> = rg_2.vel_0;
            var _S201 : vec3<f32> = rg_2.vel_err_0;
            comp_add_0(&(_S200), &(_S201), _S199);
            rg_2.vel_0 = _S200;
            rg_2.vel_err_0 = _S201;
            var rot1_0 : Quat_0 = integrate_rotation_0(rg_2.rot_0, world_mul_0(rg_2.rot_0, isl_2.inv0_0, isl_2.inv1_0, isl_2.inv2_0, l_0), _S188);
            var delta_0 : vec3<f32> = (_S200 + _S201) * _S198 + (rotate_0(rg_2.rot_0, isl_2.com_0.xyz) - rotate_0(rot1_0, isl_2.com_0.xyz));
            var _S202 : vec3<f32> = rg_2.pos_0;
            var _S203 : vec3<f32> = rg_2.pos_err_0;
            comp_add_0(&(_S202), &(_S203), delta_0);
            rg_2.pos_0 = _S202;
            rg_2.pos_err_0 = _S203;
            rg_2.rot_0 = rot1_0;
            rg_2.w_1 = world_mul_0(rot1_0, isl_2.inv0_0, isl_2.inv1_0, isl_2.inv2_0, l_0);
        }
        if(_S182)
        {
            var wcom_1 : vec3<f32> = isl_2.wcom_0.xyz;
            var wmass_0 : f32 = isl_2.wcom_0.w;
            var tu_0 : vec3<f32> = _S193;
            var pv_0 : vec3<f32> = _S193;
            var c_4 : u32 = isl_2.range_0.x + tid_1;
            loop
            {
                if(c_4 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S204 : u32 = u32(4) * c_4;
                var _S205 : vec3<f32> = vec3<f32>((chunks_0[c_4].center_0.w * chunks_0[c_4].scale_0.x));
                tu_0 = tu_0 + state_0[_S204].xyz * _S205;
                pv_0 = pv_0 + state_0[_S204 + u32(2)].xyz * _S205;
                c_4 = c_4 + u32(256);
            }
            group_sum2_0(tid_1, &(tu_0), &(pv_0));
            var _S206 : vec3<f32> = vec3<f32>(wmass_0);
            var tr_0 : vec3<f32> = tu_0 / _S206;
            var dv_0 : vec3<f32> = pv_0 / _S206;
            var lu_0 : vec3<f32> = _S193;
            var lv_0 : vec3<f32> = _S193;
            var c_5 : u32 = isl_2.range_0.x + tid_1;
            loop
            {
                if(c_5 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var r_8 : vec3<f32> = chunks_0[c_5].center_0.xyz - wcom_1;
                var _S207 : u32 = u32(4) * c_5;
                var _S208 : vec3<f32> = vec3<f32>(chunks_0[c_5].center_0.w);
                var _S209 : vec3<f32> = vec3<f32>(chunks_0[c_5].scale_0.x);
                lu_0 = lu_0 + (cross(r_8, state_0[_S207].xyz - tr_0) * _S208 + rows_mul_0(chunks_0[c_5].inertia0_1, chunks_0[c_5].inertia1_1, chunks_0[c_5].inertia2_1, state_0[_S207 + u32(1)].xyz)) * _S209;
                lv_0 = lv_0 + (cross(r_8, state_0[_S207 + u32(2)].xyz - dv_0) * _S208 + rows_mul_0(chunks_0[c_5].inertia0_1, chunks_0[c_5].inertia1_1, chunks_0[c_5].inertia2_1, state_0[_S207 + u32(3)].xyz)) * _S209;
                c_5 = c_5 + u32(256);
            }
            group_sum2_0(tid_1, &(lu_0), &(lv_0));
            var phi_0 : vec3<f32> = rows_mul_0(isl_2.winv0_0, isl_2.winv1_0, isl_2.winv2_0, lu_0);
            var dw_0 : vec3<f32> = rows_mul_0(isl_2.winv0_0, isl_2.winv1_0, isl_2.winv2_0, lv_0);
            var c_6 : u32 = isl_2.range_0.x + tid_1;
            loop
            {
                if(c_6 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var r_9 : vec3<f32> = chunks_0[c_6].center_0.xyz - wcom_1;
                var _S210 : u32 = u32(4) * c_6;
                state_0[_S210] = vec4<f32>(state_0[_S210].xyz - (tr_0 + cross(phi_0, r_9)), state_0[_S210].w);
                var _S211 : u32 = _S210 + u32(1);
                state_0[_S211] = vec4<f32>(state_0[_S211].xyz - phi_0, state_0[_S211].w);
                var _S212 : u32 = _S210 + u32(2);
                state_0[_S212] = vec4<f32>(state_0[_S212].xyz - (dv_0 + cross(dw_0, r_9)), state_0[_S212].w);
                var _S213 : u32 = _S210 + u32(3);
                state_0[_S213] = vec4<f32>(state_0[_S213].xyz - dw_0, state_0[_S213].w);
                c_6 = c_6 + u32(256);
            }
            if(!driven_0)
            {
                var rot_1 : Quat_0 = rg_2.rot_0;
                var _S214 : vec3<f32> = rotate_0(rg_2.rot_0, tr_0 - cross(phi_0, wcom_1));
                var _S215 : vec3<f32> = rg_2.pos_0;
                var _S216 : vec3<f32> = rg_2.pos_err_0;
                comp_add_0(&(_S215), &(_S216), _S214);
                rg_2.pos_0 = _S215;
                rg_2.pos_err_0 = _S216;
                rg_2.rot_0 = normalized_0(quat_mul_0(rg_2.rot_0, from_axis_angle_0(phi_0, length(phi_0))));
                var _S217 : vec3<f32> = rotate_0(rot_1, dv_0 + cross(dw_0, isl_2.com_0.xyz - wcom_1));
                var _S218 : vec3<f32> = rg_2.vel_0;
                var _S219 : vec3<f32> = rg_2.vel_err_0;
                comp_add_0(&(_S218), &(_S219), _S217);
                rg_2.vel_0 = _S218;
                rg_2.vel_err_0 = _S219;
                rg_2.w_1 = rg_2.w_1 + rotate_0(rot_1, dw_0);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S184)
        {
            _S185 = (isl_2.probes_0.y) > (isl_2.probes_0.x);
        }
        else
        {
            _S185 = false;
        }
        if(_S185)
        {
            record_probes_0(isl_2, rg_2, k_8);
        }
        var _S220 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S220;
            break;
        }
        done_1 = _S220;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_2, work_err_1, 0.0f);
    var unused_0 : vec3<f32> = _S193;
    group_sum2_0(tid_1, &(wsum_0), &(unused_0));
    if(_S184)
    {
        isl_2.rotation_0 = quat_vec_0(rg_2.rot_0);
        isl_2.position_0 = vec4<f32>(rg_2.pos_0, 0.0f);
        isl_2.position_err_0 = vec4<f32>(rg_2.pos_err_0, 0.0f);
        isl_2.velocity_0 = vec4<f32>(rg_2.vel_0, 0.0f);
        isl_2.velocity_err_0 = vec4<f32>(rg_2.vel_err_0, 0.0f);
        isl_2.angular_velocity_0 = vec4<f32>(rg_2.w_1, 0.0f);
        isl_2.done_0[i32(0)] = done_1;
        isl_2.info_0[i32(1)] = isl_2.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S183 = contact_island_0;
        }
        else
        {
            _S183 = false;
        }
        if(_S183)
        {
            var at_1 : u32 = isl_2.info_0.w + done_1;
            var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
            if(previous_1 == u32(0))
            {
                run_0 = at_1;
            }
            else
            {
                run_0 = min(previous_1, at_1);
            }
            islands_0[params_0.halt_index_0].info_0[i32(1)] = run_0;
        }
        var _S221 : f32 = wsum_0.x;
        var _S222 : f32 = isl_2.energy_0[i32(0)];
        var _S223 : f32 = isl_2.energy_0[i32(1)];
        comp_add1_1(&(_S222), &(_S223), _S221);
        isl_2.energy_0[i32(0)] = _S222;
        isl_2.energy_0[i32(1)] = _S223 + wsum_0.y;
        isl_2.info_0[i32(3)] = isl_2.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_2.info_0[i32(2)] = ((isl_2.info_0[i32(2)]) | (u32(1)));
        }
        islands_0[_S181].range_0 = isl_2.range_0;
        islands_0[_S181].info_0 = isl_2.info_0;
        islands_0[_S181].com_0 = isl_2.com_0;
        islands_0[_S181].inertia0_0 = isl_2.inertia0_0;
        islands_0[_S181].inertia1_0 = isl_2.inertia1_0;
        islands_0[_S181].inertia2_0 = isl_2.inertia2_0;
        islands_0[_S181].inv0_0 = isl_2.inv0_0;
        islands_0[_S181].inv1_0 = isl_2.inv1_0;
        islands_0[_S181].inv2_0 = isl_2.inv2_0;
        islands_0[_S181].wcom_0 = isl_2.wcom_0;
        islands_0[_S181].winv0_0 = isl_2.winv0_0;
        islands_0[_S181].winv1_0 = isl_2.winv1_0;
        islands_0[_S181].winv2_0 = isl_2.winv2_0;
        islands_0[_S181].rotation_0 = isl_2.rotation_0;
        islands_0[_S181].position_0 = isl_2.position_0;
        islands_0[_S181].position_err_0 = isl_2.position_err_0;
        islands_0[_S181].velocity_0 = isl_2.velocity_0;
        islands_0[_S181].velocity_err_0 = isl_2.velocity_err_0;
        islands_0[_S181].angular_velocity_0 = isl_2.angular_velocity_0;
        islands_0[_S181].done_0 = isl_2.done_0;
        islands_0[_S181].probes_0 = isl_2.probes_0;
        islands_0[_S181].energy_0 = isl_2.energy_0;
    }
    return;
}

