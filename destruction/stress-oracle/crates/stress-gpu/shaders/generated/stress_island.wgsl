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
};

@binding(8) @group(0) var<storage, read_write> islands_0 : array<Island_std430_0>;

struct Params_std140_0
{
    @align(16) gravity_0 : vec4<f32>,
    @align(16) dt_0 : f32,
    @align(4) fracture_0 : u32,
    @align(8) rigid_motion_loads_0 : u32,
    @align(4) pad_0 : u32,
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
};

@binding(3) @group(0) var<storage, read> chunks_0 : array<ChunkStatic_std430_0>;

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
    @align(16) energy_0 : vec4<f32>,
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

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_0, q_1.y_0, q_1.z_0);
    var t_0 : vec3<f32> = cross(qv_0, v_0) * vec3<f32>(2.0f);
    return v_0 + t_0 * vec3<f32>(q_1.w_0) + cross(qv_0, t_0);
}

var<workgroup> g_red_a_0 : array<vec4<f32>, i32(256)>;

var<workgroup> g_red_b_0 : array<vec4<f32>, i32(256)>;

fn group_sum2_0( tid_0 : u32,  a_0 : ptr<function, vec3<f32>>,  b_0 : ptr<function, vec3<f32>>)
{
    g_red_a_0[tid_0] = vec4<f32>((*a_0), 0.0f);
    g_red_b_0[tid_0] = vec4<f32>((*b_0), 0.0f);
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
    (*a_0) = g_red_a_0[i32(0)].xyz;
    (*b_0) = g_red_b_0[i32(0)].xyz;
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
    var _S2 : bool;
    if((st_0.damage_0) < 1.0f)
    {
        _S2 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S2 = (st_0.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S2 = false;
        }
    }
    return _S2;
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_1 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_0 : f32 = (*b_1).geom0_0.x;
    var _S3 : f32 = q_lin_0.z;
    var axial_0 : f32 = _S3 / area_0;
    var bending_0 : f32 = abs(q_ang_0.x) / (*b_1).geom1_0.x + abs(q_ang_0.y) / (*b_1).geom1_0.y;
    var _S4 : f32 = q_lin_0.x;
    var _S5 : f32 = q_lin_0.y;
    var shear_1 : f32 = sqrt(_S4 * _S4 + _S5 * _S5) / area_0 + abs(q_ang_0.z) / (*b_1).geom0_0.w;
    var m_1 : Measures_0;
    m_1.tension_0 = axial_0 + bending_0;
    m_1.shear_0 = shear_1;
    var _S6 : f32 = - axial_0;
    m_1.normal_compression_0 = max(_S6, 0.0f);
    m_1.compression_0 = _S6 + bending_0;
    m_1.compressive_force_0 = max(- _S3, 0.0f);
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
    var _S7 : vec4<f32> = (*mat_0).dif_0;
    var ref_0 : f32 = (*mat_0).dif_0.x;
    if(r_1 <= ref_0)
    {
        return 1.0f;
    }
    var _S8 : f32 = _S7.z;
    var f_0 : f32;
    if(r_1 <= _S8)
    {
        f_0 = pow(r_1 / ref_0, _S7.y);
    }
    else
    {
        f_0 = pow(_S8 / ref_0, _S7.y) * pow(r_1 / _S8, _S7.w);
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

fn failure_indices_0( mat_3 : ptr<function, JointMaterial_std140_0>,  b_2 : ptr<function, JointBond_std430_0>,  m_2 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_0 : f32 = (*mat_3).strength_0.y * multiplier_0;
    var _S9 : f32 = min((*mat_3).strength_0.z * multiplier_0 + (*mat_3).strength_0.w * m_2.normal_compression_0, (*mat_3).energy_0.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(m_2.tension_0 / ((*mat_3).strength_0.x * multiplier_0), 0.0f);
    var _S10 : f32;
    if(_S9 > 0.0f)
    {
        _S10 = m_2.shear_0 / _S9;
    }
    else
    {
        _S10 = infinity_0();
    }
    idx_0[i32(1)] = _S10;
    idx_0[i32(2)] = max(m_2.compression_0 / fc_0, 0.0f);
    var _S11 : f32 = (*b_2).stiff1_0.y;
    if(_S11 > 0.0f)
    {
        _S10 = m_2.compressive_force_0 / _S11;
    }
    else
    {
        _S10 = 0.0f;
    }
    idx_0[i32(3)] = _S10;
    return idx_0;
}

fn sq_0( x_2 : f32) -> f32
{
    return x_2 * x_2;
}

fn damage_law_0( kind_0 : u32,  kappa_1 : f32,  r_2 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_0 == u32(0))
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

fn damage_increment_0( kind_1 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_3 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S12 : f32 = max(damage_law_0(kind_1, lambda_0, r_3), d_old_0);
    var _S13 : bool;
    if(_S12 <= d_old_0)
    {
        _S13 = true;
    }
    else
    {
        _S13 = d_old_0 >= 1.0f;
    }
    if(_S13)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = psi_0 / (lambda_0 * lambda_0);
    var _S14 : f32 = max(kappa_old_0, 1.0f);
    if(kind_1 == u32(0))
    {
        if(r_3 > 1.0f)
        {
            return vec2<f32>(_S12, u0_0 * r_3 / (r_3 - 1.0f) * max(min(lambda_0, r_3) - min(_S14, r_3), 0.0f));
        }
        return vec2<f32>(_S12, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_3 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S14, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S12 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S12, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_0 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S15 : f32 = - h0_0;
    var _S16 : f32 = - h1_0;
    var _S17 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S15, _S16), vec2<f32>(h0_0, _S16), vec2<f32>(h0_0, h1_0), vec2<f32>(_S15, h1_0) );
    var poly_0 : array<vec2<f32>, i32(8)>;
    var i_0 : u32 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S18 : u32 = i_0;
        var _S19 : u32 = i_0 + u32(1);
        var _S20 : u32 = _S19 % u32(4);
        var _S21 : f32 = _S17[i_0].y;
        var _S22 : f32 = _S17[i_0].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S21 - ay_0 * _S22;
        var _S23 : f32 = _S17[_S20].y;
        var _S24 : f32 = _S17[_S20].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S23 - ay_0 * _S24;
        var _S25 : bool = fp_0 < 0.0f;
        if(_S25)
        {
            var _S26 : u32 = count_1 + u32(1);
            poly_0[count_1] = _S17[_S18];
            count_0 = _S26;
        }
        else
        {
            count_0 = count_1;
        }
        if(_S25 != (fq_0 < 0.0f))
        {
            var t_1 : f32 = fp_0 / (fp_0 - fq_0);
            var _S27 : u32 = count_0 + u32(1);
            poly_0[count_0] = vec2<f32>(_S22 + t_1 * (_S24 - _S22), _S21 + t_1 * (_S23 - _S21));
            count_1 = _S27;
        }
        else
        {
            count_1 = count_0;
        }
        i_0 = _S19;
    }
    count_0 = u32(0);
    loop
    {
        if(count_0 < u32(6))
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_0] = 0.0f;
        count_0 = count_0 + u32(1);
    }
    if(count_1 < u32(3))
    {
        return;
    }
    var o_0 : vec2<f32> = poly_0[i32(0)];
    i_0 = u32(0);
    var a_1 : f32 = 0.0f;
    var sx_0 : f32 = 0.0f;
    var sy_0 : f32 = 0.0f;
    var ixx_0 : f32 = 0.0f;
    var iyy_0 : f32 = 0.0f;
    var ixy_0 : f32 = 0.0f;
    loop
    {
        if(i_0 < count_1)
        {
        }
        else
        {
            break;
        }
        var _S28 : f32 = o_0.x;
        var x0_0 : f32 = poly_0[i_0].x - _S28;
        var _S29 : f32 = o_0.y;
        var y0_0 : f32 = poly_0[i_0].y - _S29;
        var _S30 : u32 = i_0 + u32(1);
        var _S31 : u32 = _S30 % count_1;
        var x1_0 : f32 = poly_0[_S31].x - _S28;
        var y1_0 : f32 = poly_0[_S31].y - _S29;
        var _S32 : f32 = x0_0 * y1_0;
        var _S33 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S32 - _S33;
        var a_2 : f32 = a_1 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S32 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S33) * cr_0 / 24.0f;
        i_0 = _S30;
        a_1 = a_2;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_1 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_1;
    var cy_0 : f32 = sy_0 / a_1;
    (*region_0)[i32(0)] = a_1;
    (*region_0)[i32(1)] = o_0.x + cx_0;
    (*region_0)[i32(2)] = o_0.y + cy_0;
    var _S34 : f32 = a_1 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S34 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_1 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S34 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_4 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_4));
    var a_3 : f32 = r_4[i32(0)];
    if((r_4[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_0 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_1 : f32 = dz_1 + ax_1 * r_4[i32(2)] - ay_1 * r_4[i32(1)];
    var _S35 : f32 = a_3 * fc_1;
    var _S36 : f32 = - ay_1;
    return vec4<f32>(k_0 * a_3 * fc_1, k_0 * (_S35 * r_4[i32(2)] + (_S36 * r_4[i32(5)] + ax_1 * r_4[i32(4)])), - k_0 * (_S35 * r_4[i32(1)] + (_S36 * r_4[i32(3)] + ax_1 * r_4[i32(5)])), 0.5f * k_0 * (_S35 * fc_1 + ay_1 * ay_1 * r_4[i32(3)] + ax_1 * ax_1 * r_4[i32(4)] - 2.0f * ax_1 * ay_1 * r_4[i32(5)]));
}

fn signum_0( x_3 : f32) -> f32
{
    var _S37 : f32;
    if((((bitcast<u32>((x_3))) & (u32(2147483648)))) != u32(0))
    {
        _S37 = -1.0f;
    }
    else
    {
        _S37 = 1.0f;
    }
    return _S37;
}

fn return_map_0( k_1 : f32,  total_0 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_1 * (total_0 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_1 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_1, (trial_0 - f_1) / k_1);
}

struct Contact_0
{
     q_lin_1 : vec3<f32>,
     q_ang_1 : vec3<f32>,
     energy_1 : f32,
     diss_0 : f32,
     plastic_1 : vec3<f32>,
};

fn contact_part_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_3 : ptr<function, JointBond_std430_0>,  crush_1 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_1 : Contact_0;
    var _S38 : vec3<f32> = vec3<f32>(0.0f);
    c_1.q_lin_1 = _S38;
    c_1.q_ang_1 = _S38;
    c_1.energy_1 = 0.0f;
    c_1.diss_0 = 0.0f;
    c_1.plastic_1 = plastic_2;
    var _S39 : u32 = (*mat_4).kind_flags_0.y;
    if(((_S39 & (u32(2)))) == u32(0))
    {
        return c_1;
    }
    var kn_1 : f32 = (*b_3).stiff0_0.x;
    var ks_0 : f32 = (*b_3).stiff0_0.y;
    var kt_0 : f32 = (*b_3).stiff1_0.x;
    var w0_2 : f32 = (*b_3).geom0_0.y;
    var w1_2 : f32 = (*b_3).geom0_0.z;
    var diss_1 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_2 : f32;
    if(((_S39 & (u32(4)))) != u32(0))
    {
        var p_0 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_1), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S40 : f32 = p_0.y;
        var _S41 : f32 = p_0.z;
        var _S42 : f32 = p_0.w;
        nc_sum_0 = p_0.x;
        m1_0 = _S40;
        m2_0 = _S41;
        energy_2 = _S42;
    }
    else
    {
        var _S43 : f32 = kn_1 * (1.0f - crush_1) / 36.0f;
        var i_1 : u32 = u32(0);
        diss_1 = 0.0f;
        var m1_1 : f32 = 0.0f;
        var m2_1 : f32 = 0.0f;
        var energy_3 : f32 = 0.0f;
        loop
        {
            if(i_1 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S44 : f32 = ((f32(i_1) + 0.5f) / 6.0f - 0.5f) * w0_2;
            var j_0 : u32 = u32(0);
            nc_sum_0 = diss_1;
            m1_0 = m1_1;
            m2_0 = m2_1;
            energy_2 = energy_3;
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
                var di_0 : f32 = d_lin_0.z + d_ang_0.x * s2_0 - d_ang_0.y * _S44;
                if(di_0 < 0.0f)
                {
                    var f_2 : f32 = _S43 * di_0;
                    var m1_2 : f32 = m1_0 + f_2 * s2_0;
                    var m2_2 : f32 = m2_0 - f_2 * _S44;
                    var energy_4 : f32 = energy_2 + 0.5f * _S43 * di_0 * di_0;
                    nc_sum_0 = nc_sum_0 + f_2;
                    m1_0 = m1_2;
                    m2_0 = m2_2;
                    energy_2 = energy_4;
                }
                j_0 = j_0 + u32(1);
            }
            i_1 = i_1 + u32(1);
            diss_1 = nc_sum_0;
            m1_1 = m1_0;
            m2_1 = m2_0;
            energy_3 = energy_2;
        }
        nc_sum_0 = diss_1;
        m1_0 = m1_1;
        m2_0 = m2_1;
        energy_2 = energy_3;
    }
    var nc_0 : f32 = - nc_sum_0;
    var p_1 : vec3<f32> = plastic_2;
    c_1.q_lin_1 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_1.q_ang_1 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_4).strength_0.w * nc_0;
    var _S45 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S46 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var trial_1 : vec2<f32> = vec2<f32>(_S45, _S46);
    var tn_0 : f32 = sqrt(_S45 * _S45 + _S46 * _S46);
    var _S47 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S47 = tn_0 > 0.0f;
    }
    else
    {
        _S47 = false;
    }
    if(_S47)
    {
        var dir_0 : vec2<f32> = trial_1 / vec2<f32>(tn_0);
        var dslip_0 : f32 = (tn_0 - slide_cap_0) / ks_0;
        var _S48 : f32 = dir_0.x;
        p_1[i32(0)] = p_1[i32(0)] + _S48 * dslip_0;
        var _S49 : f32 = dir_0.y;
        p_1[i32(1)] = p_1[i32(1)] + _S49 * dslip_0;
        c_1.q_lin_1[i32(0)] = _S48 * slide_cap_0;
        c_1.q_lin_1[i32(1)] = _S49 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_1.q_lin_1[i32(0)] = _S45;
        c_1.q_lin_1[i32(1)] = _S46;
        diss_1 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_1.z, slide_cap_0 * (*b_3).geom1_0.z);
    var _S50 : f32 = tq_0.x;
    var _S51 : f32 = tq_0.y;
    var diss_2 : f32 = diss_1 + abs(_S50) * abs(_S51);
    p_1[i32(2)] = p_1[i32(2)] + _S51;
    c_1.q_ang_1[i32(2)] = _S50;
    c_1.energy_1 = energy_2 + 0.5f * (sq_0(c_1.q_lin_1.x) / ks_0 + sq_0(c_1.q_lin_1.y) / ks_0 + sq_0(_S50) / kt_0);
    c_1.diss_0 = diss_2;
    c_1.plastic_1 = p_1;
    return c_1;
}

fn life_rate_0( mat_5 : ptr<function, JointMaterial_std140_0>,  s_1 : f32) -> f32
{
    if(s_1 <= 0.0f)
    {
        return 0.0f;
    }
    var _S52 : f32 = (*mat_5).misc_0.y;
    return (_S52 + 1.0f) * pow(s_1, _S52) / (*mat_5).misc_0.z;
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

fn joint_evaluate_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_4 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>,  dt_1 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_2 : f32 = (*b_4).stiff0_0.x;
    var ks_1 : f32 = (*b_4).stiff0_0.y;
    var kb1_0 : f32 = (*b_4).stiff0_0.z;
    var kb2_0 : f32 = (*b_4).stiff0_0.w;
    var _S53 : vec4<f32> = (*b_4).stiff1_0;
    var kt_1 : f32 = (*b_4).stiff1_0.x;
    var has_rebar_1 : bool = ((*b_4).stiff1_0.w) != 0.0f;
    var kind_2 : u32 = (*mat_6).kind_flags_0.x;
    var flags_0 : u32 = (*mat_6).kind_flags_0.y;
    var softening_0 : bool = ((flags_0 & (u32(1)))) != u32(0);
    var st_1 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_0(state_2, has_rebar_1);
    var qe_lin_0 : vec3<f32> = d_lin_1 * vec3<f32>(ks_1, ks_1, kn_2);
    var qe_ang_0 : vec3<f32> = d_ang_1 * vec3<f32>(kb1_0, kb2_0, kt_1);
    var _S54 : Measures_0 = stress_measures_0(&((*b_4)), qe_lin_0, qe_ang_0);
    var _S55 : f32 = max(max(_S54.tension_0, _S54.shear_0), _S54.compression_0);
    var _S56 : bool = dt_1 > 0.0f;
    var dif_1 : f32;
    if(_S56)
    {
        var raw_0 : f32 = max((_S55 - st_1.governing_stress_0) / dt_1, 0.0f) / (*mat_6).misc_0.w;
        var tau_0 : f32 = _S53.z;
        if(((flags_0 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- dt_1 / tau_0);
        }
        else
        {
            dif_1 = min(dt_1 / tau_0, 1.0f);
        }
        st_1.strain_rate_0 = st_1.strain_rate_0 + (raw_0 - st_1.strain_rate_0) * dif_1;
        st_1.governing_stress_0 = _S55;
    }
    if(((flags_0 & (u32(32)))) != u32(0))
    {
        var _S57 : f32 = dif_factor_0(&((*mat_6)), st_1.strain_rate_0);
        dif_1 = _S57;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_4).geom1_0.w;
    var _S58 : f32 = weibull_0 * dif_1;
    var _S59 : f32 = fatigue_factor_1(&((*mat_6)), st_1.fatigue_0);
    var multiplier_1 : f32 = _S58 * _S59;
    var _S60 : vec4<f32> = failure_indices_0(&((*mat_6)), &((*b_4)), _S54, multiplier_1);
    var _S61 : f32 = _S60.x;
    var _S62 : f32 = _S60.y;
    st_1.utilization_0 = max(max(_S61, _S62), max(_S60.z, _S60.w));
    var _S63 : f32 = d_lin_1.x;
    var _S64 : f32 = d_lin_1.y;
    var _S65 : f32 = ks_1 * (sq_0(_S63) + sq_0(_S64)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    var _S66 : f32 = d_lin_1.z;
    var _S67 : bool = _S66 > 0.0f;
    if(_S67)
    {
        dif_1 = kn_2 * sq_0(_S66);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S65 + dif_1);
    var psi_c_0 : f32;
    if(_S66 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S66);
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
    var _S68 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S69 : bool = _S61 >= _S62;
        if(_S69)
        {
            diss_contact_0 = _S61;
        }
        else
        {
            diss_contact_0 = _S62;
        }
        var mode_ts_0 : u32;
        if(_S69)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_1.kappa_0))
        {
            _S68 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S68 = false;
        }
        if(_S68)
        {
            _S68 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S68 = false;
        }
        var mode_c_0 : u32;
        if(_S68)
        {
            if(mode_ts_0 == u32(1))
            {
                psi_contact_0 = (*mat_6).energy_0.y;
            }
            else
            {
                psi_contact_0 = (*mat_6).energy_0.z;
            }
            if(softening_0)
            {
                intact_normal_0 = psi_contact_0 * (*b_4).geom0_0.x * diss_contact_0 * diss_contact_0 / psi_ts_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_1.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_2;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_1.kappa_0, diss_contact_0, intact_normal_0, st_1.damage_0, psi_ts_0);
            var _S70 : f32 = inc_0.x;
            if(_S70 > (st_1.damage_0))
            {
                var _S71 : Contact_0 = contact_part_0(&((*mat_6)), &((*b_4)), st_1.crush_0, plastic_3, d_lin_1, d_ang_1);
                var _S72 : f32 = max(_S71.energy_1 - (1.0f - st_1.crush_0) * psi_c_0, 0.0f);
                var _S73 : f32 = max(inc_0.y - _S72 * (_S70 - st_1.damage_0), 0.0f);
                var _S74 : f32 = max((psi_ts_0 - _S72) * (_S70 - st_1.damage_0) - _S73, 0.0f);
                st_1.damage_0 = _S70;
                st_1.mode_0 = mode_ts_0;
                dissipated_2 = _S73;
                overshoot_1 = _S74;
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
            var _S75 : Contact_0 = contact_part_0(&((*mat_6)), &((*b_4)), state_2.crush_0, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S75.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S76 : Measures_0 = stress_measures_0(&((*b_4)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S77 : vec4<f32> = failure_indices_0(&((*mat_6)), &((*b_4)), _S76, multiplier_1);
        var _S78 : f32 = _S77.z;
        var _S79 : f32 = _S77.w;
        var _S80 : bool = _S78 >= _S79;
        if(_S80)
        {
            psi_contact_0 = _S78;
        }
        else
        {
            psi_contact_0 = _S79;
        }
        if(_S80)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_1.kappa_c_0))
        {
            _S68 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S68 = false;
        }
        if(_S68)
        {
            _S68 = psi_c_0 > 0.0f;
        }
        else
        {
            _S68 = false;
        }
        if(_S68)
        {
            if(softening_0)
            {
                intact_normal_0 = (*mat_6).energy_0.w * (*b_4).geom0_0.x * psi_contact_0 * psi_contact_0 / psi_c_0;
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
                    mode_ts_0 = kind_2;
                }
                law_1 = mode_ts_0;
            }
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_1.kappa_c_0, psi_contact_0, intact_normal_0, st_1.crush_0, psi_c_0);
            var _S81 : f32 = inc_1.x;
            if(_S81 > (st_1.crush_0))
            {
                var _S82 : f32 = inc_1.y;
                var dissipated_3 : f32 = dissipated_2 + _S82;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S81 - st_1.crush_0) - _S82, 0.0f);
                st_1.crush_0 = _S81;
                st_1.mode_0 = mode_c_0;
                if(_S81 >= 1.0f)
                {
                    _S68 = (st_1.damage_0) < 1.0f;
                }
                else
                {
                    _S68 = false;
                }
                if(_S68)
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
    var _S83 : vec3<f32> = vec3<f32>(0.0f);
    if((st_1.damage_0) == 0.0f)
    {
        _S68 = ((flags_0 & (u32(8)))) != u32(0);
    }
    else
    {
        _S68 = false;
    }
    var qc_ang_0 : vec3<f32>;
    if(!_S68)
    {
        var _S84 : Contact_0 = contact_part_0(&((*mat_6)), &((*b_4)), st_1.crush_0, plastic_3, d_lin_1, d_ang_1);
        st_1.plastic_x_0 = _S84.plastic_1.x;
        st_1.plastic_y_0 = _S84.plastic_1.y;
        st_1.plastic_t_0 = _S84.plastic_1.z;
        diss_contact_0 = _S84.diss_0;
        qc_lin_0 = _S84.q_lin_1;
        qc_ang_0 = _S84.q_ang_1;
        psi_contact_0 = _S84.energy_1;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S83;
        qc_ang_0 = _S83;
        psi_contact_0 = 0.0f;
    }
    var dissipated_5 : f32 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S67)
    {
        intact_normal_0 = kn_2 * _S66;
    }
    else
    {
        intact_normal_0 = (1.0f - st_1.crush_0) * kn_2 * _S66;
    }
    var _S85 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S85 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S85 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S85 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S85) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_1 : f32 = _S85 * (psi_ts_0 + (1.0f - st_1.crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S68 = (st_1.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S68 = false;
    }
    var stored_2 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S68)
    {
        var k_axial_0 : f32 = (*b_4).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_4).rebar0_0.y;
        var yield_force_0 : f32 = (*b_4).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_4).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S66, st_1.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S63, st_1.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S64, st_1.rebar_slip1_0, dowel_capacity_0);
        var _S86 : f32 = nr_0.y;
        var _S87 : f32 = v1_0.y;
        var _S88 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S86) + dowel_capacity_0 * (abs(_S87) + abs(_S88));
        st_1.rebar_plastic_0 = st_1.rebar_plastic_0 + _S86;
        st_1.rebar_slip0_0 = st_1.rebar_slip0_0 + _S87;
        st_1.rebar_slip1_0 = st_1.rebar_slip1_0 + _S88;
        st_1.rebar_work_0 = st_1.rebar_work_0 + work_0;
        var dissipated_6 : f32 = dissipated_5 + work_0;
        var _S89 : f32 = nr_0.x;
        var _S90 : f32 = v1_0.x;
        var _S91 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (sq_0(_S89) / k_axial_0 + (sq_0(_S90) + sq_0(_S91)) / k_dowel_0);
        if(fracture_1)
        {
            _S68 = (st_1.rebar_work_0) >= ((*b_4).rebar1_0.x);
        }
        else
        {
            _S68 = false;
        }
        if(_S68)
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
            force_lin_3 = force_lin_2 + vec3<f32>(_S90, _S91, _S89);
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
        _S68 = _S56;
    }
    else
    {
        _S68 = false;
    }
    if(_S68)
    {
        _S68 = ((flags_0 & (u32(64)))) != u32(0);
    }
    else
    {
        _S68 = false;
    }
    if(_S68)
    {
        var _S92 : Measures_0 = stress_measures_0(&((*b_4)), force_lin_3, force_ang_2);
        var _S93 : vec4<f32> = failure_indices_0(&((*mat_6)), &((*b_4)), _S92, weibull_0);
        var _S94 : f32 = life_rate_0(&((*mat_6)), max(max(_S93.x, _S93.y), _S93.z));
        st_1.fatigue_0 = min(st_1.fatigue_0 + _S94 * dt_1, 1.0f);
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
        _S68 = !connected_0(st_1, has_rebar_1);
    }
    else
    {
        _S68 = false;
    }
    resp_0.disconnected_0 = _S68;
    resp_0.measures_0 = _S54;
    return resp_0;
}

fn secant_factors_0( b_5 : ptr<function, JointBond_std430_0>,  st_2 : JointState_0,  d_lin_2 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
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
    var _S95 : f32 = 1.0f - st_2.damage_0;
    var _S96 : f32 = max(_S95 + contact_0, 9.99999997475242708e-07f);
    var normal_1 : f32;
    if(compressed_0)
    {
        normal_1 = max(1.0f - st_2.crush_0, 9.99999997475242708e-07f);
    }
    else
    {
        normal_1 = max(_S95, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S96, _S96, normal_1);
    (*f_ang_0) = vec3<f32>(_S96);
    var _S97 : bool;
    if(((*b_5).stiff1_0.w) != 0.0f)
    {
        _S97 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S97 = false;
    }
    if(_S97)
    {
        var _S98 : vec4<f32> = (*b_5).rebar0_0;
        var _S99 : vec4<f32> = (*b_5).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + (*b_5).rebar0_0.x / (*b_5).stiff0_0.x;
        var _S100 : f32 = _S98.y;
        var _S101 : f32 = _S99.y;
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S100 / _S101;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S100 / _S101;
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

fn is_damaged_0( st_3 : JointState_0) -> bool
{
    var _S102 : bool;
    if((st_3.damage_0) > 0.0f)
    {
        _S102 = true;
    }
    else
    {
        _S102 = (st_3.crush_0) > 0.0f;
    }
    return _S102;
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

fn to_local_0( _S103 : u32,  _S104 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S104, bonds_0[_S103].t1_0.xyz), dot(_S104, bonds_0[_S103].t2_0.xyz), dot(_S104, bonds_0[_S103].normal_0.xyz));
}

fn to_body_0( _S105 : u32,  _S106 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S105].t1_0.xyz * vec3<f32>(_S106.x) + bonds_0[_S105].t2_0.xyz * vec3<f32>(_S106.y) + bonds_0[_S105].normal_0.xyz * vec3<f32>(_S106.z);
}

fn bond_update_0( i_2 : u32,  dt_2 : f32,  fracture_2 : bool,  abs_step_0 : u32)
{
    var _S107 : JointState_0 = JointState_0( bond_dyn_0[i_2].js_0.damage_0, bond_dyn_0[i_2].js_0.crush_0, bond_dyn_0[i_2].js_0.kappa_0, bond_dyn_0[i_2].js_0.kappa_c_0, bond_dyn_0[i_2].js_0.ductility_0, bond_dyn_0[i_2].js_0.ductility_c_0, bond_dyn_0[i_2].js_0.fatigue_0, bond_dyn_0[i_2].js_0.plastic_x_0, bond_dyn_0[i_2].js_0.plastic_y_0, bond_dyn_0[i_2].js_0.plastic_t_0, bond_dyn_0[i_2].js_0.rebar_plastic_0, bond_dyn_0[i_2].js_0.rebar_slip0_0, bond_dyn_0[i_2].js_0.rebar_slip1_0, bond_dyn_0[i_2].js_0.rebar_work_0, bond_dyn_0[i_2].js_0.rebar_broken_0, bond_dyn_0[i_2].js_0.strain_rate_0, bond_dyn_0[i_2].js_0.governing_stress_0, bond_dyn_0[i_2].js_0.dissipated_0, bond_dyn_0[i_2].js_0.utilization_0, bond_dyn_0[i_2].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S107;
    bd_0.force_lin_0 = bond_dyn_0[i_2].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_2].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_2].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_2].comps_0;
    bd_0.events_0 = bond_dyn_0[i_2].events_0;
    var _S108 : JointBond_std430_0 = bonds_0[i_2].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_2].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_2].rb_0.xyz;
    var _S109 : u32 = u32(4) * _S108.ids_0.y;
    var ta_0 : vec3<f32> = state_0[_S109 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S109 + u32(3)].xyz;
    var _S110 : u32 = u32(4) * _S108.ids_0.z;
    var tb_0 : vec3<f32> = state_0[_S110 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S110 + u32(3)].xyz;
    var _S111 : vec3<f32> = to_local_0(i_2, state_0[_S110].xyz + cross(tb_0, rb_1) - (state_0[_S109].xyz + cross(ta_0, ra_1)));
    var _S112 : vec3<f32> = to_local_0(i_2, tb_0 - ta_0);
    var _S113 : vec3<f32> = to_local_0(i_2, state_0[_S110 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S109 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S114 : vec3<f32> = to_local_0(i_2, wb_0 - wa_0);
    var _S115 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S108.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S116 : JointResponse_0 = joint_evaluate_0(&(_S115), &(_S108), bd_0.js_0, _S111, _S112, dt_2, fracture_2);
    var f_lin_1 : vec3<f32>;
    var f_ang_1 : vec3<f32>;
    secant_factors_0(&(_S108), _S116.state_1, _S111, &(f_lin_1), &(f_ang_1));
    var qd_lin_0 : vec3<f32> = _S113 * bonds_0[i_2].c_lin_0.xyz * f_lin_1;
    var qd_ang_0 : vec3<f32> = _S114 * bonds_0[i_2].c_ang_0.xyz * f_ang_1;
    var q_lin_2 : vec3<f32> = _S116.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S116.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S113) + dot(qd_ang_0, _S114)) * dt_2;
    var _S117 : vec3<f32> = to_body_0(i_2, q_lin_2);
    var _S118 : vec3<f32> = to_body_0(i_2, q_ang_2);
    var _S119 : u32 = u32(3) * i_2;
    bond_loads_0[_S119] = vec4<f32>(_S117, max(_S116.measures_0.tension_0, _S116.measures_0.compression_0));
    bond_loads_0[_S119 + u32(1)] = vec4<f32>(_S118 + cross(ra_1, _S117), 0.0f);
    bond_loads_0[_S119 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S118) + cross(rb_1, (vec3<f32>(0) - _S117)), 0.0f);
    var _S120 : f32 = bd_0.sums_0[i32(0)];
    var _S121 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S120), &(_S121), _S116.dissipated_1);
    bd_0.sums_0[i32(0)] = _S120;
    bd_0.comps_0[i32(0)] = _S121;
    var _S122 : f32 = bd_0.sums_0[i32(1)];
    var _S123 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S122), &(_S123), _S116.overshoot_0);
    bd_0.sums_0[i32(1)] = _S122;
    bd_0.comps_0[i32(1)] = _S123;
    var _S124 : f32 = bd_0.sums_0[i32(2)];
    var _S125 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S124), &(_S125), damped_0);
    bd_0.sums_0[i32(2)] = _S124;
    bd_0.comps_0[i32(2)] = _S125;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S116.stored_0);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S116.state_1.utilization_0));
    var _S126 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S126 = is_damaged_0(_S116.state_1);
    }
    else
    {
        _S126 = false;
    }
    if(_S126)
    {
        _S126 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S126 = false;
    }
    if(_S126)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S116.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S127 : f32 = fatigue_factor_0(&(_S115), previous_0.fatigue_0);
        _S126 = _S127 > 0.99000000953674316f;
    }
    else
    {
        _S126 = false;
    }
    if(_S126)
    {
        var _S128 : f32 = fatigue_factor_0(&(_S115), _S116.state_1.fatigue_0);
        _S126 = _S128 <= 0.99000000953674316f;
    }
    else
    {
        _S126 = false;
    }
    if(_S126)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S116.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
        g_halt_0 = u32(1);
    }
    bd_0.js_0 = _S116.state_1;
    bond_dyn_0[i_2].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_2].js_0.crush_0 = bd_0.js_0.crush_0;
    bond_dyn_0[i_2].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_2].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_2].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_2].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_2].js_0.fatigue_0 = bd_0.js_0.fatigue_0;
    bond_dyn_0[i_2].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
    bond_dyn_0[i_2].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
    bond_dyn_0[i_2].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
    bond_dyn_0[i_2].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
    bond_dyn_0[i_2].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
    bond_dyn_0[i_2].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
    bond_dyn_0[i_2].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
    bond_dyn_0[i_2].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
    bond_dyn_0[i_2].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
    bond_dyn_0[i_2].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
    bond_dyn_0[i_2].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
    bond_dyn_0[i_2].js_0.utilization_0 = bd_0.js_0.utilization_0;
    bond_dyn_0[i_2].js_0.mode_0 = bd_0.js_0.mode_0;
    bond_dyn_0[i_2].force_lin_0 = bd_0.force_lin_0;
    bond_dyn_0[i_2].force_ang_0 = bd_0.force_ang_0;
    bond_dyn_0[i_2].sums_0 = bd_0.sums_0;
    bond_dyn_0[i_2].comps_0 = bd_0.comps_0;
    bond_dyn_0[i_2].events_0 = bd_0.events_0;
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
};

struct Rigid_0
{
     rot_0 : Quat_0,
     pos_0 : vec3<f32>,
     pos_err_0 : vec3<f32>,
     vel_0 : vec3<f32>,
     vel_err_0 : vec3<f32>,
     w_1 : vec3<f32>,
     a_4 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn chunk_update_0( c_2 : u32,  isl_0 : Island_0,  rg_0 : Rigid_0,  dt_3 : f32,  rml_0 : bool)
{
    var _S129 : vec3<f32> = vec3<f32>(0.0f);
    var _S130 : u32 = csr_0[c_2];
    var peak_0 : f32 = 0.0f;
    var k_2 : u32 = _S130;
    var fi_0 : vec3<f32> = _S129;
    var mi_0 : vec3<f32> = _S129;
    loop
    {
        if(k_2 < csr_0[c_2 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var e_0 : u32 = csr_0[k_2];
        var _S131 : u32 = u32(3) * ((e_0 >> (u32(1))));
        var fa_0 : vec4<f32> = bond_loads_0[_S131];
        if(((e_0 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + bond_loads_0[_S131 + u32(1)].xyz;
            fi_0 = fi_0 + fa_0.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + bond_loads_0[_S131 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_0.xyz);
            mi_0 = mi_2;
        }
        var _S132 : f32 = max(peak_0, fa_0.w);
        var _S133 : u32 = k_2 + u32(1);
        peak_0 = _S132;
        k_2 = _S133;
    }
    var _S134 : u32 = u32(4) * c_2;
    var u_0 : vec3<f32> = state_0[_S134].xyz;
    var _S135 : u32 = _S134 + u32(1);
    var th_0 : vec3<f32> = state_0[_S135].xyz;
    var _S136 : u32 = _S134 + u32(2);
    var v_4 : vec3<f32> = state_0[_S136].xyz;
    var _S137 : u32 = _S134 + u32(3);
    var w_2 : vec3<f32> = state_0[_S137].xyz;
    var mass_0 : f32 = chunks_0[c_2].center_0.w;
    var r_world_0 : vec3<f32> = rotate_0(rg_0.rot_0, chunks_0[c_2].center_0.xyz + u_0 - isl_0.com_0.xyz);
    var _S138 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = params_0.gravity_0.xyz * _S138;
    var f_world_1 : vec3<f32>;
    var t_world_0 : vec3<f32>;
    if(rml_0)
    {
        var t_world_1 : vec3<f32> = _S129 - (world_mul_0(rg_0.rot_0, chunks_0[c_2].inertia0_1, chunks_0[c_2].inertia1_1, chunks_0[c_2].inertia2_1, rg_0.alpha_0) + cross(rg_0.w_1, world_mul_0(rg_0.rot_0, chunks_0[c_2].inertia0_1, chunks_0[c_2].inertia1_1, chunks_0[c_2].inertia2_1, rg_0.w_1)));
        f_world_1 = f_world_0 - (rg_0.a_4 + cross(rg_0.alpha_0, r_world_0) + cross(rg_0.w_1, cross(rg_0.w_1, r_world_0))) * _S138;
        t_world_0 = t_world_1;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_0 = _S129;
    }
    var f_ext_0 : vec3<f32> = inverse_rotate_0(rg_0.rot_0, f_world_1);
    var m_ext_0 : vec3<f32> = inverse_rotate_0(rg_0.rot_0, t_world_0);
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
    var f_3 : vec3<f32> = f_ext_1 + fi_0;
    var m_3 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_2].info_1.x;
    var u_1 : vec3<f32>;
    var th_1 : vec3<f32>;
    var v_5 : vec3<f32>;
    var w_3 : vec3<f32>;
    if(support_0 == u32(1))
    {
        u_1 = u_0;
        th_1 = th_0;
        v_5 = _S129;
        w_3 = _S129;
    }
    else
    {
        var _S139 : vec4<f32> = chunks_0[c_2].scale_0;
        var w_4 : vec3<f32> = w_2 + rows_mul_0(chunks_0[c_2].inv0_1, chunks_0[c_2].inv1_1, chunks_0[c_2].inv2_1, m_3) * vec3<f32>((dt_3 * chunks_0[c_2].scale_0.z));
        var _S140 : vec3<f32> = vec3<f32>(dt_3);
        var th_2 : vec3<f32> = th_0 + w_4 * _S140;
        if(support_0 == u32(2))
        {
            u_1 = u_0;
            th_1 = _S129;
        }
        else
        {
            var v_6 : vec3<f32> = v_4 + f_3 * vec3<f32>((dt_3 * _S139.y));
            u_1 = u_0 + v_6 * _S140;
            th_1 = v_6;
        }
        var _S141 : vec3<f32> = th_1;
        th_1 = th_2;
        v_5 = _S141;
        w_3 = w_4;
    }
    state_0[_S134] = vec4<f32>(u_1, peak_0);
    state_0[_S135] = vec4<f32>(th_1, 0.0f);
    state_0[_S136] = vec4<f32>(v_5, 0.0f);
    state_0[_S137] = vec4<f32>(w_3, 0.0f);
    return;
}

fn comp_add_0( sum_1 : ptr<function, vec3<f32>>,  err_1 : ptr<function, vec3<f32>>,  x_5 : vec3<f32>)
{
    var t_3 : vec3<f32> = (*sum_1) + x_5;
    var _S142 : vec3<f32> = abs(x_5);
    (*err_1) = (*err_1) + (select(x_5, (*sum_1), (abs((*sum_1))) >= _S142) - t_3 + select((*sum_1), x_5, (abs((*sum_1))) >= _S142));
    (*sum_1) = t_3;
    return;
}

fn safe_normalize_0( v_7 : vec3<f32>) -> vec3<f32>
{
    var n_0 : f32 = length(v_7);
    var _S143 : vec3<f32>;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S143 = v_7 / vec3<f32>(n_0);
    }
    else
    {
        _S143 = vec3<f32>(0.0f);
    }
    return _S143;
}

fn from_axis_angle_0( axis_0 : vec3<f32>,  angle_0 : f32) -> Quat_0
{
    var a_5 : vec3<f32> = safe_normalize_0(axis_0);
    var _S144 : f32 = 0.5f * angle_0;
    var s_2 : f32 = sin(_S144);
    var q_4 : Quat_0;
    q_4.w_0 = cos(_S144);
    q_4.x_0 = a_5.x * s_2;
    q_4.y_0 = a_5.y * s_2;
    q_4.z_0 = a_5.z * s_2;
    return q_4;
}

fn quat_mul_0( a_6 : Quat_0,  o_1 : Quat_0) -> Quat_0
{
    var r_5 : Quat_0;
    r_5.w_0 = a_6.w_0 * o_1.w_0 - a_6.x_0 * o_1.x_0 - a_6.y_0 * o_1.y_0 - a_6.z_0 * o_1.z_0;
    r_5.x_0 = a_6.w_0 * o_1.x_0 + a_6.x_0 * o_1.w_0 + a_6.y_0 * o_1.z_0 - a_6.z_0 * o_1.y_0;
    r_5.y_0 = a_6.w_0 * o_1.y_0 - a_6.x_0 * o_1.z_0 + a_6.y_0 * o_1.w_0 + a_6.z_0 * o_1.x_0;
    r_5.z_0 = a_6.w_0 * o_1.z_0 + a_6.x_0 * o_1.y_0 - a_6.y_0 * o_1.x_0 + a_6.z_0 * o_1.w_0;
    return r_5;
}

fn normalized_0( q_5 : Quat_0) -> Quat_0
{
    var _S145 : f32 = q_5.w_0;
    var _S146 : f32 = q_5.x_0;
    var _S147 : f32 = q_5.y_0;
    var _S148 : f32 = q_5.z_0;
    var n_1 : f32 = sqrt(_S145 * _S145 + _S146 * _S146 + _S147 * _S147 + _S148 * _S148);
    var r_6 : Quat_0;
    r_6.w_0 = q_5.w_0 / n_1;
    r_6.x_0 = q_5.x_0 / n_1;
    r_6.y_0 = q_5.y_0 / n_1;
    r_6.z_0 = q_5.z_0 / n_1;
    return r_6;
}

fn integrate_rotation_0( q_6 : Quat_0,  omega_0 : vec3<f32>,  dt_4 : f32) -> Quat_0
{
    var angle_1 : f32 = length(omega_0) * dt_4;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return q_6;
    }
    return normalized_0(quat_mul_0(from_axis_angle_0(omega_0, angle_1), q_6));
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
    var _S149 : u32 = group_0.x;
    var isl_1 : Island_0;
    isl_1.range_0 = islands_0[_S149].range_0;
    isl_1.info_0 = islands_0[_S149].info_0;
    isl_1.com_0 = islands_0[_S149].com_0;
    isl_1.inertia0_0 = islands_0[_S149].inertia0_0;
    isl_1.inertia1_0 = islands_0[_S149].inertia1_0;
    isl_1.inertia2_0 = islands_0[_S149].inertia2_0;
    isl_1.inv0_0 = islands_0[_S149].inv0_0;
    isl_1.inv1_0 = islands_0[_S149].inv1_0;
    isl_1.inv2_0 = islands_0[_S149].inv2_0;
    isl_1.wcom_0 = islands_0[_S149].wcom_0;
    isl_1.winv0_0 = islands_0[_S149].winv0_0;
    isl_1.winv1_0 = islands_0[_S149].winv1_0;
    isl_1.winv2_0 = islands_0[_S149].winv2_0;
    isl_1.rotation_0 = islands_0[_S149].rotation_0;
    isl_1.position_0 = islands_0[_S149].position_0;
    isl_1.position_err_0 = islands_0[_S149].position_err_0;
    isl_1.velocity_0 = islands_0[_S149].velocity_0;
    isl_1.velocity_err_0 = islands_0[_S149].velocity_err_0;
    isl_1.angular_velocity_0 = islands_0[_S149].angular_velocity_0;
    isl_1.done_0 = islands_0[_S149].done_0;
    var driven_0 : bool = (((isl_1.info_0.x) & (u32(2)))) != u32(0);
    var _S150 : bool = !((((isl_1.info_0.x) & (u32(1)))) != u32(0));
    var _S151 : bool;
    if(_S150)
    {
        _S151 = !driven_0;
    }
    else
    {
        _S151 = false;
    }
    var _S152 : u32;
    if((((isl_1.info_0.z) & (u32(1)))) != u32(0))
    {
        _S152 = u32(0);
    }
    else
    {
        _S152 = isl_1.info_0.y;
    }
    var _S153 : f32 = params_0.dt_0;
    var _S154 : bool = (params_0.fracture_0) != u32(0);
    var _S155 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var _S156 : vec3<f32> = params_0.gravity_0.xyz;
    var _S157 : f32 = isl_1.com_0.w;
    var rg_1 : Rigid_0;
    rg_1.rot_0 = quat_of_0(isl_1.rotation_0);
    rg_1.pos_0 = isl_1.position_0.xyz;
    rg_1.pos_err_0 = isl_1.position_err_0.xyz;
    rg_1.vel_0 = isl_1.velocity_0.xyz;
    rg_1.vel_err_0 = isl_1.velocity_err_0.xyz;
    rg_1.w_1 = isl_1.angular_velocity_0.xyz;
    var _S158 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.a_4 = _S158;
    rg_1.alpha_0 = _S158;
    var _S159 : bool = tid_1 == u32(0);
    if(_S159)
    {
        g_halt_0 = u32(0);
    }
    workgroupBarrier();
    var done_1 : u32 = u32(0);
    loop
    {
        if(done_1 < _S152)
        {
        }
        else
        {
            break;
        }
        var _S160 : u32 = isl_1.info_0.w + done_1 + u32(1);
        var i_3 : u32;
        if(_S150)
        {
            var f_4 : vec3<f32> = _S158;
            var t_4 : vec3<f32> = _S158;
            i_3 = isl_1.range_0.x + tid_1;
            loop
            {
                if(i_3 < (isl_1.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var fc_2 : vec3<f32> = _S156 * vec3<f32>(chunks_0[i_3].center_0.w);
                var r_7 : vec3<f32> = rotate_0(rg_1.rot_0, chunks_0[i_3].center_0.xyz + state_0[u32(4) * i_3].xyz - isl_1.com_0.xyz);
                f_4 = f_4 + fc_2;
                t_4 = t_4 + cross(r_7, fc_2);
                i_3 = i_3 + u32(256);
            }
            group_sum2_0(tid_1, &(f_4), &(t_4));
            var iw_w_0 : vec3<f32> = world_mul_0(rg_1.rot_0, isl_1.inertia0_0, isl_1.inertia1_0, isl_1.inertia2_0, rg_1.w_1);
            rg_1.a_4 = f_4 / vec3<f32>(_S157);
            rg_1.alpha_0 = world_mul_0(rg_1.rot_0, isl_1.inv0_0, isl_1.inv1_0, isl_1.inv2_0, t_4 - cross(rg_1.w_1, iw_w_0));
        }
        i_3 = isl_1.range_0.z + tid_1;
        loop
        {
            if(i_3 < (isl_1.range_0.w))
            {
            }
            else
            {
                break;
            }
            bond_update_0(i_3, _S153, _S154, _S160);
            i_3 = i_3 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_3 : u32 = isl_1.range_0.x + tid_1;
        loop
        {
            if(c_3 < (isl_1.range_0.y))
            {
            }
            else
            {
                break;
            }
            chunk_update_0(c_3, isl_1, rg_1, _S153, _S155);
            c_3 = c_3 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S151)
        {
            var iw_w_1 : vec3<f32> = world_mul_0(rg_1.rot_0, isl_1.inertia0_0, isl_1.inertia1_0, isl_1.inertia2_0, rg_1.w_1);
            var _S161 : vec3<f32> = vec3<f32>(_S153);
            var l_0 : vec3<f32> = iw_w_1 + (world_mul_0(rg_1.rot_0, isl_1.inertia0_0, isl_1.inertia1_0, isl_1.inertia2_0, rg_1.alpha_0) + cross(rg_1.w_1, iw_w_1)) * _S161;
            var _S162 : vec3<f32> = rg_1.a_4 * _S161;
            var _S163 : vec3<f32> = rg_1.vel_0;
            var _S164 : vec3<f32> = rg_1.vel_err_0;
            comp_add_0(&(_S163), &(_S164), _S162);
            rg_1.vel_0 = _S163;
            rg_1.vel_err_0 = _S164;
            var rot1_0 : Quat_0 = integrate_rotation_0(rg_1.rot_0, world_mul_0(rg_1.rot_0, isl_1.inv0_0, isl_1.inv1_0, isl_1.inv2_0, l_0), _S153);
            var delta_0 : vec3<f32> = (_S163 + _S164) * _S161 + (rotate_0(rg_1.rot_0, isl_1.com_0.xyz) - rotate_0(rot1_0, isl_1.com_0.xyz));
            var _S165 : vec3<f32> = rg_1.pos_0;
            var _S166 : vec3<f32> = rg_1.pos_err_0;
            comp_add_0(&(_S165), &(_S166), delta_0);
            rg_1.pos_0 = _S165;
            rg_1.pos_err_0 = _S166;
            rg_1.rot_0 = rot1_0;
            rg_1.w_1 = world_mul_0(rot1_0, isl_1.inv0_0, isl_1.inv1_0, isl_1.inv2_0, l_0);
        }
        if(_S150)
        {
            var wcom_1 : vec3<f32> = isl_1.wcom_0.xyz;
            var wmass_0 : f32 = isl_1.wcom_0.w;
            var tu_0 : vec3<f32> = _S158;
            var pv_0 : vec3<f32> = _S158;
            var c_4 : u32 = isl_1.range_0.x + tid_1;
            loop
            {
                if(c_4 < (isl_1.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S167 : u32 = u32(4) * c_4;
                var _S168 : vec3<f32> = vec3<f32>((chunks_0[c_4].center_0.w * chunks_0[c_4].scale_0.x));
                tu_0 = tu_0 + state_0[_S167].xyz * _S168;
                pv_0 = pv_0 + state_0[_S167 + u32(2)].xyz * _S168;
                c_4 = c_4 + u32(256);
            }
            group_sum2_0(tid_1, &(tu_0), &(pv_0));
            var _S169 : vec3<f32> = vec3<f32>(wmass_0);
            var tr_0 : vec3<f32> = tu_0 / _S169;
            var dv_0 : vec3<f32> = pv_0 / _S169;
            var lu_0 : vec3<f32> = _S158;
            var lv_0 : vec3<f32> = _S158;
            var c_5 : u32 = isl_1.range_0.x + tid_1;
            loop
            {
                if(c_5 < (isl_1.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var r_8 : vec3<f32> = chunks_0[c_5].center_0.xyz - wcom_1;
                var _S170 : u32 = u32(4) * c_5;
                var _S171 : vec3<f32> = vec3<f32>(chunks_0[c_5].center_0.w);
                var _S172 : vec3<f32> = vec3<f32>(chunks_0[c_5].scale_0.x);
                lu_0 = lu_0 + (cross(r_8, state_0[_S170].xyz - tr_0) * _S171 + rows_mul_0(chunks_0[c_5].inertia0_1, chunks_0[c_5].inertia1_1, chunks_0[c_5].inertia2_1, state_0[_S170 + u32(1)].xyz)) * _S172;
                lv_0 = lv_0 + (cross(r_8, state_0[_S170 + u32(2)].xyz - dv_0) * _S171 + rows_mul_0(chunks_0[c_5].inertia0_1, chunks_0[c_5].inertia1_1, chunks_0[c_5].inertia2_1, state_0[_S170 + u32(3)].xyz)) * _S172;
                c_5 = c_5 + u32(256);
            }
            group_sum2_0(tid_1, &(lu_0), &(lv_0));
            var phi_0 : vec3<f32> = rows_mul_0(isl_1.winv0_0, isl_1.winv1_0, isl_1.winv2_0, lu_0);
            var dw_0 : vec3<f32> = rows_mul_0(isl_1.winv0_0, isl_1.winv1_0, isl_1.winv2_0, lv_0);
            var c_6 : u32 = isl_1.range_0.x + tid_1;
            loop
            {
                if(c_6 < (isl_1.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var r_9 : vec3<f32> = chunks_0[c_6].center_0.xyz - wcom_1;
                var _S173 : u32 = u32(4) * c_6;
                state_0[_S173] = vec4<f32>(state_0[_S173].xyz - (tr_0 + cross(phi_0, r_9)), state_0[_S173].w);
                var _S174 : u32 = _S173 + u32(1);
                state_0[_S174] = vec4<f32>(state_0[_S174].xyz - phi_0, 0.0f);
                var _S175 : u32 = _S173 + u32(2);
                state_0[_S175] = vec4<f32>(state_0[_S175].xyz - (dv_0 + cross(dw_0, r_9)), 0.0f);
                var _S176 : u32 = _S173 + u32(3);
                state_0[_S176] = vec4<f32>(state_0[_S176].xyz - dw_0, 0.0f);
                c_6 = c_6 + u32(256);
            }
            if(!driven_0)
            {
                var rot_1 : Quat_0 = rg_1.rot_0;
                var _S177 : vec3<f32> = rotate_0(rg_1.rot_0, tr_0 - cross(phi_0, wcom_1));
                var _S178 : vec3<f32> = rg_1.pos_0;
                var _S179 : vec3<f32> = rg_1.pos_err_0;
                comp_add_0(&(_S178), &(_S179), _S177);
                rg_1.pos_0 = _S178;
                rg_1.pos_err_0 = _S179;
                rg_1.rot_0 = normalized_0(quat_mul_0(rg_1.rot_0, from_axis_angle_0(phi_0, length(phi_0))));
                var _S180 : vec3<f32> = rotate_0(rot_1, dv_0 + cross(dw_0, isl_1.com_0.xyz - wcom_1));
                var _S181 : vec3<f32> = rg_1.vel_0;
                var _S182 : vec3<f32> = rg_1.vel_err_0;
                comp_add_0(&(_S181), &(_S182), _S180);
                rg_1.vel_0 = _S181;
                rg_1.vel_err_0 = _S182;
                rg_1.w_1 = rg_1.w_1 + rotate_0(rot_1, dw_0);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S183 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S183;
            break;
        }
        done_1 = _S183;
    }
    if(_S159)
    {
        isl_1.rotation_0 = quat_vec_0(rg_1.rot_0);
        isl_1.position_0 = vec4<f32>(rg_1.pos_0, 0.0f);
        isl_1.position_err_0 = vec4<f32>(rg_1.pos_err_0, 0.0f);
        isl_1.velocity_0 = vec4<f32>(rg_1.vel_0, 0.0f);
        isl_1.velocity_err_0 = vec4<f32>(rg_1.vel_err_0, 0.0f);
        isl_1.angular_velocity_0 = vec4<f32>(rg_1.w_1, 0.0f);
        isl_1.done_0[i32(0)] = done_1;
        isl_1.info_0[i32(3)] = isl_1.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_1.info_0[i32(2)] = ((isl_1.info_0[i32(2)]) | (u32(1)));
        }
        islands_0[_S149].range_0 = isl_1.range_0;
        islands_0[_S149].info_0 = isl_1.info_0;
        islands_0[_S149].com_0 = isl_1.com_0;
        islands_0[_S149].inertia0_0 = isl_1.inertia0_0;
        islands_0[_S149].inertia1_0 = isl_1.inertia1_0;
        islands_0[_S149].inertia2_0 = isl_1.inertia2_0;
        islands_0[_S149].inv0_0 = isl_1.inv0_0;
        islands_0[_S149].inv1_0 = isl_1.inv1_0;
        islands_0[_S149].inv2_0 = isl_1.inv2_0;
        islands_0[_S149].wcom_0 = isl_1.wcom_0;
        islands_0[_S149].winv0_0 = isl_1.winv0_0;
        islands_0[_S149].winv1_0 = isl_1.winv1_0;
        islands_0[_S149].winv2_0 = isl_1.winv2_0;
        islands_0[_S149].rotation_0 = isl_1.rotation_0;
        islands_0[_S149].position_0 = isl_1.position_0;
        islands_0[_S149].position_err_0 = isl_1.position_err_0;
        islands_0[_S149].velocity_0 = isl_1.velocity_0;
        islands_0[_S149].velocity_err_0 = isl_1.velocity_err_0;
        islands_0[_S149].angular_velocity_0 = isl_1.angular_velocity_0;
        islands_0[_S149].done_0 = isl_1.done_0;
    }
    return;
}

