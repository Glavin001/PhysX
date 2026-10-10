#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
struct Quat_0
{
    float w_0;
    float x_0;
    float y_0;
    float z_0;
};

Quat_0 quat_of_0(float4 q_0)
{
    thread Quat_0 r_0;
    (&r_0)->x_0 = q_0.x;
    (&r_0)->y_0 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_0 = q_0.w;
    return r_0;
}

float3 rotate_0(const Quat_0 thread* q_1, float3 v_0)
{
    float3 qv_0 = float3(q_1->x_0, q_1->y_0, q_1->z_0);
    float3 t_0 = cross(qv_0, v_0) * float3(2.0f) ;
    return v_0 + t_0 * float3(q_1->w_0)  + cross(qv_0, t_0);
}

float3 rotate_1(const Quat_0 thread* q_2, float3 v_1)
{
    float3 qv_1 = float3(q_2->x_0, q_2->y_0, q_2->z_0);
    float3 t_1 = cross(qv_1, v_1) * float3(2.0f) ;
    return v_1 + t_1 * float3(q_2->w_0)  + cross(qv_1, t_1);
}

struct Island_natural_0
{
    packed_uint4 range_0;
    packed_uint4 info_0;
    packed_float4 com_0;
    packed_float4 inertia0_0;
    packed_float4 inertia1_0;
    packed_float4 inertia2_0;
    packed_float4 inv0_0;
    packed_float4 inv1_0;
    packed_float4 inv2_0;
    packed_float4 wcom_0;
    packed_float4 winv0_0;
    packed_float4 winv1_0;
    packed_float4 winv2_0;
    packed_float4 rotation_0;
    packed_float4 position_0;
    packed_float4 position_err_0;
    packed_float4 velocity_0;
    packed_float4 velocity_err_0;
    packed_float4 angular_velocity_0;
    packed_uint4 done_0;
};

struct Params_0
{
    float4 gravity_0;
    float dt_0;
    uint fracture_0;
    uint rigid_motion_loads_0;
    uint pad_0;
};

struct ChunkStatic_natural_0
{
    packed_float4 center_0;
    packed_float4 inertia0_1;
    packed_float4 inertia1_1;
    packed_float4 inertia2_1;
    packed_float4 inv0_1;
    packed_float4 inv1_1;
    packed_float4 inv2_1;
    packed_float4 scale_0;
    packed_uint4 info_1;
};

struct JointBond_natural_0
{
    packed_float4 geom0_0;
    packed_float4 geom1_0;
    packed_float4 stiff0_0;
    packed_float4 stiff1_0;
    packed_float4 rebar0_0;
    packed_float4 rebar1_0;
    packed_uint4 ids_0;
};

struct BondStatic_natural_0
{
    packed_float4 t1_0;
    packed_float4 t2_0;
    packed_float4 normal_0;
    packed_float4 ra_0;
    packed_float4 rb_0;
    packed_float4 centroid_0;
    packed_float4 c_lin_0;
    packed_float4 c_ang_0;
    JointBond_natural_0 law_0;
};

struct JointState_0
{
    float damage_0;
    float crush_0;
    float kappa_0;
    float kappa_c_0;
    float ductility_0;
    float ductility_c_0;
    float fatigue_0;
    float plastic_x_0;
    float plastic_y_0;
    float plastic_t_0;
    float rebar_plastic_0;
    float rebar_slip0_0;
    float rebar_slip1_0;
    float rebar_work_0;
    float rebar_broken_0;
    float strain_rate_0;
    float governing_stress_0;
    float dissipated_0;
    float utilization_0;
    uint mode_0;
};

struct BondDyn_natural_0
{
    JointState_0 js_0;
    packed_float4 force_lin_0;
    packed_float4 force_ang_0;
    packed_float4 sums_0;
    packed_float4 comps_0;
    packed_uint4 events_0;
};

struct JointMaterial_0
{
    float4 strength_0;
    float4 energy_0;
    float4 dif_0;
    float4 misc_0;
    uint4 kind_flags_0;
};

struct MaterialTable_0
{
    array<JointMaterial_0, int(64)> m_0;
};

struct KernelContext_0
{
    Island_natural_0 device* islands_0;
    Params_0 constant* params_0;
    ChunkStatic_natural_0 device* chunks_0;
    packed_float4 device* state_0;
    BondStatic_natural_0 device* bonds_0;
    BondDyn_natural_0 device* bond_dyn_0;
    MaterialTable_0 constant* materials_0;
    packed_float4 device* bond_loads_0;
    uint device* csr_0;
    uint threadgroup* g_halt_0;
    array<float4, int(256)> threadgroup* g_red_a_0;
    array<float4, int(256)> threadgroup* g_red_b_0;
};

void group_sum2_0(uint tid_0, float3 thread* a_0, float3 thread* b_0, KernelContext_0 thread* kernelContext_0)
{
    (*kernelContext_0->g_red_a_0)[tid_0] = float4(*a_0, 0.0f);
    (*kernelContext_0->g_red_b_0)[tid_0] = float4(*b_0, 0.0f);
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint s_0 = 128U;
    for(;;)
    {
        if(s_0 > 0U)
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_0)
        {
            uint _S1 = tid_0 + s_0;
            (*kernelContext_0->g_red_a_0)[tid_0] = (*kernelContext_0->g_red_a_0)[tid_0] + (*kernelContext_0->g_red_a_0)[_S1];
            (*kernelContext_0->g_red_b_0)[tid_0] = (*kernelContext_0->g_red_b_0)[tid_0] + (*kernelContext_0->g_red_b_0)[_S1];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        s_0 = s_0 >> 1U;
    }
    *a_0 = (*kernelContext_0->g_red_a_0)[int(0)].xyz;
    *b_0 = (*kernelContext_0->g_red_b_0)[int(0)].xyz;
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_3, float3 v_2)
{
    thread Quat_0 c_0;
    (&c_0)->w_0 = q_3->w_0;
    (&c_0)->x_0 = - q_3->x_0;
    (&c_0)->y_0 = - q_3->y_0;
    (&c_0)->z_0 = - q_3->z_0;
    thread Quat_0 _S2 = c_0;
    float3 _S3 = rotate_0(&_S2, v_2);
    return _S3;
}

float3 inverse_rotate_1(const Quat_0 thread* q_4, float3 v_3)
{
    thread Quat_0 c_1;
    (&c_1)->w_0 = q_4->w_0;
    (&c_1)->x_0 = - q_4->x_0;
    (&c_1)->y_0 = - q_4->y_0;
    (&c_1)->z_0 = - q_4->z_0;
    thread Quat_0 _S4 = c_1;
    float3 _S5 = rotate_0(&_S4, v_3);
    return _S5;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_4)
{
    return float3(dot(r0_0.xyz, v_4), dot(r1_0.xyz, v_4), dot(r2_0.xyz, v_4));
}

float3 world_mul_0(const Quat_0 thread* q_5, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_5)
{
    float3 _S6 = inverse_rotate_1(q_5, v_5);
    float3 _S7 = rotate_1(q_5, rows_mul_0(r0_1, r1_1, r2_1, _S6));
    return _S7;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S8;
    if((st_0->damage_0) < 1.0f)
    {
        _S8 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S8 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S8 = false;
        }
    }
    return _S8;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

Measures_0 stress_measures_0(const JointBond_natural_0 thread* b_1, float3 q_lin_0, float3 q_ang_0)
{
    float4 _S9 = float4(b_1->geom0_0) ;
    float area_0 = _S9.x;
    float _S10 = q_lin_0.z;
    float axial_0 = _S10 / area_0;
    float4 _S11 = float4(b_1->geom1_0) ;
    float bending_0 = abs(q_ang_0.x) / _S11.x + abs(q_ang_0.y) / _S11.y;
    float _S12 = q_lin_0.x;
    float _S13 = q_lin_0.y;
    float shear_1 = sqrt(_S12 * _S12 + _S13 * _S13) / area_0 + abs(q_ang_0.z) / _S9.w;
    thread Measures_0 m_1;
    (&m_1)->tension_0 = axial_0 + bending_0;
    (&m_1)->shear_0 = shear_1;
    float _S14 = - axial_0;
    (&m_1)->normal_compression_0 = max(_S14, 0.0f);
    (&m_1)->compression_0 = _S14 + bending_0;
    (&m_1)->compressive_force_0 = max(- _S10, 0.0f);
    return m_1;
}

float expm1_accurate_0(float x_1)
{
    if((abs(x_1)) < 0.00100000004749745f)
    {
        return x_1 * (1.0f + x_1 * (0.5f + x_1 * 0.1666666716337204f));
    }
    return exp(x_1) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_0, float strain_rate_1)
{
    float r_1 = abs(strain_rate_1);
    float4 _S15 = mat_0->dif_0;
    float ref_0 = mat_0->dif_0.x;
    if(r_1 <= ref_0)
    {
        return 1.0f;
    }
    float _S16 = _S15.z;
    float f_0;
    if(r_1 <= _S16)
    {
        f_0 = pow(r_1 / ref_0, _S15.y);
    }
    else
    {
        f_0 = pow(_S16 / ref_0, _S15.y) * pow(r_1 / _S16, _S15.w);
    }
    return clamp(f_0, 1.0f, mat_0->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_1, float fatigue_1)
{
    if(((mat_1->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_1, 0.0f, 1.0f), 1.0f / (mat_1->misc_0.y - 2.0f));
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_2, const JointBond_natural_0 thread* b_2, const Measures_0 thread* m_2, float multiplier_0)
{
    float fc_0 = mat_2->strength_0.y * multiplier_0;
    float _S17 = min(mat_2->strength_0.z * multiplier_0 + mat_2->strength_0.w * m_2->normal_compression_0, mat_2->energy_0.x * multiplier_0);
    thread float4 idx_0;
    idx_0.x = max(m_2->tension_0 / (mat_2->strength_0.x * multiplier_0), 0.0f);
    float _S18;
    if(_S17 > 0.0f)
    {
        _S18 = m_2->shear_0 / _S17;
    }
    else
    {
        _S18 = infinity_0();
    }
    idx_0.y = _S18;
    idx_0.z = max(m_2->compression_0 / fc_0, 0.0f);
    float _S19 = (float4(b_2->stiff1_0) ).y;
    if(_S19 > 0.0f)
    {
        _S18 = m_2->compressive_force_0 / _S19;
    }
    else
    {
        _S18 = 0.0f;
    }
    idx_0.w = _S18;
    return idx_0;
}

float sq_0(float x_2)
{
    return x_2 * x_2;
}

float damage_law_0(uint kind_0, float kappa_1, float r_2)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_0 == 0U)
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

float2 damage_increment_0(uint kind_1, float kappa_old_0, float lambda_0, float r_3, float d_old_0, float psi_0)
{
    float _S20 = max(damage_law_0(kind_1, lambda_0, r_3), d_old_0);
    bool _S21;
    if(_S20 <= d_old_0)
    {
        _S21 = true;
    }
    else
    {
        _S21 = d_old_0 >= 1.0f;
    }
    if(_S21)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = psi_0 / (lambda_0 * lambda_0);
    float _S22 = max(kappa_old_0, 1.0f);
    if(kind_1 == 0U)
    {
        if(r_3 > 1.0f)
        {
            return float2(_S20, u0_0 * r_3 / (r_3 - 1.0f) * max(min(lambda_0, r_3) - min(_S22, r_3), 0.0f));
        }
        return float2(_S20, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_3 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S22, ku_0), 0.0f);
    float snap_0;
    if(_S20 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S20, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_0;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S23 = - h0_0;
    float _S24 = - h1_0;
    array<float2, int(4)> _S25 = { { float2(_S23, _S24), float2(h0_0, _S24), float2(h0_0, h1_0), float2(_S23, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_0 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        if(i_0 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S26 = i_0;
        uint _S27 = i_0 + 1U;
        uint _S28 = _S27 % 4U;
        float _S29 = _S25[i_0].y;
        float _S30 = _S25[i_0].x;
        float fp_0 = dz_0 + ax_0 * _S29 - ay_0 * _S30;
        float _S31 = _S25[_S28].y;
        float _S32 = _S25[_S28].x;
        float fq_0 = dz_0 + ax_0 * _S31 - ay_0 * _S32;
        bool _S33 = fp_0 < 0.0f;
        if(_S33)
        {
            uint _S34 = count_1 + 1U;
            poly_0[count_1] = _S25[_S26];
            count_0 = _S34;
        }
        else
        {
            count_0 = count_1;
        }
        if(_S33 != (fq_0 < 0.0f))
        {
            float t_2 = fp_0 / (fp_0 - fq_0);
            uint _S35 = count_0 + 1U;
            poly_0[count_0] = float2(_S30 + t_2 * (_S32 - _S30), _S29 + t_2 * (_S31 - _S29));
            count_1 = _S35;
        }
        else
        {
            count_1 = count_0;
        }
        i_0 = _S27;
    }
    count_0 = 0U;
    for(;;)
    {
        if(count_0 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_0] = 0.0f;
        count_0 = count_0 + 1U;
    }
    if(count_1 < 3U)
    {
        return;
    }
    float2 o_0 = poly_0[int(0)];
    i_0 = 0U;
    float a_1 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_0 < count_1)
        {
        }
        else
        {
            break;
        }
        float _S36 = o_0.x;
        float x0_0 = poly_0[i_0].x - _S36;
        float _S37 = o_0.y;
        float y0_0 = poly_0[i_0].y - _S37;
        uint _S38 = i_0 + 1U;
        uint _S39 = _S38 % count_1;
        float x1_0 = poly_0[_S39].x - _S36;
        float y1_0 = poly_0[_S39].y - _S37;
        float _S40 = x0_0 * y1_0;
        float _S41 = x1_0 * y0_0;
        float cr_0 = _S40 - _S41;
        float a_2 = a_1 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S40 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S41) * cr_0 / 24.0f;
        i_0 = _S38;
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
    float cx_0 = sx_0 / a_1;
    float cy_0 = sy_0 / a_1;
    (*region_0)[int(0)] = a_1;
    (*region_0)[int(1)] = o_0.x + cx_0;
    (*region_0)[int(2)] = o_0.y + cy_0;
    float _S42 = a_1 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S42 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_1 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S42 * cy_0;
    return;
}

float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_4;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_4);
    float a_3 = r_4[int(0)];
    if((r_4[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_0 = kn_0 / (w0_1 * w1_1);
    float fc_1 = dz_1 + ax_1 * r_4[int(2)] - ay_1 * r_4[int(1)];
    float _S43 = a_3 * fc_1;
    float _S44 = - ay_1;
    return float4(k_0 * a_3 * fc_1, k_0 * (_S43 * r_4[int(2)] + (_S44 * r_4[int(5)] + ax_1 * r_4[int(4)])), - k_0 * (_S43 * r_4[int(1)] + (_S44 * r_4[int(3)] + ax_1 * r_4[int(5)])), 0.5f * k_0 * (_S43 * fc_1 + ay_1 * ay_1 * r_4[int(3)] + ax_1 * ax_1 * r_4[int(4)] - 2.0f * ax_1 * ay_1 * r_4[int(5)]));
}

float signum_0(float x_3)
{
    float _S45;
    if(((as_type<uint>((x_3))) & 2147483648U) != 0U)
    {
        _S45 = -1.0f;
    }
    else
    {
        _S45 = 1.0f;
    }
    return _S45;
}

float2 return_map_0(float k_1, float total_0, float plastic_0, float cap_0)
{
    float trial_0 = k_1 * (total_0 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_1 = cap_0 * signum_0(trial_0);
    return float2(f_1, (trial_0 - f_1) / k_1);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_1;
    float diss_0;
    float3 plastic_1;
};

Contact_0 contact_part_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_3, float crush_1, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_2;
    float3 _S46 = float3(0.0f) ;
    (&c_2)->q_lin_1 = _S46;
    (&c_2)->q_ang_1 = _S46;
    (&c_2)->energy_1 = 0.0f;
    (&c_2)->diss_0 = 0.0f;
    (&c_2)->plastic_1 = plastic_2;
    uint _S47 = mat_3->kind_flags_0.y;
    if((_S47 & 2U) == 0U)
    {
        return c_2;
    }
    float4 _S48 = float4(b_3->stiff0_0) ;
    float kn_1 = _S48.x;
    float ks_0 = _S48.y;
    float kt_0 = (float4(b_3->stiff1_0) ).x;
    float4 _S49 = float4(b_3->geom0_0) ;
    float w0_2 = _S49.y;
    float w1_2 = _S49.z;
    float diss_1;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_2;
    if((_S47 & 4U) != 0U)
    {
        float4 p_0 = no_tension_patch_0(kn_1 * (1.0f - crush_1), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S50 = p_0.y;
        float _S51 = p_0.z;
        float _S52 = p_0.w;
        nc_sum_0 = p_0.x;
        m1_0 = _S50;
        m2_0 = _S51;
        energy_2 = _S52;
    }
    else
    {
        float _S53 = kn_1 * (1.0f - crush_1) / 36.0f;
        uint i_1 = 0U;
        diss_1 = 0.0f;
        float m1_1 = 0.0f;
        float m2_1 = 0.0f;
        float energy_3 = 0.0f;
        for(;;)
        {
            if(i_1 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S54 = ((float(i_1) + 0.5f) / 6.0f - 0.5f) * w0_2;
            uint j_0 = 0U;
            nc_sum_0 = diss_1;
            m1_0 = m1_1;
            m2_0 = m2_1;
            energy_2 = energy_3;
            for(;;)
            {
                if(j_0 < 6U)
                {
                }
                else
                {
                    break;
                }
                float s2_0 = ((float(j_0) + 0.5f) / 6.0f - 0.5f) * w1_2;
                float di_0 = d_lin_0.z + d_ang_0.x * s2_0 - d_ang_0.y * _S54;
                if(di_0 < 0.0f)
                {
                    float f_2 = _S53 * di_0;
                    float m1_2 = m1_0 + f_2 * s2_0;
                    float m2_2 = m2_0 - f_2 * _S54;
                    float energy_4 = energy_2 + 0.5f * _S53 * di_0 * di_0;
                    nc_sum_0 = nc_sum_0 + f_2;
                    m1_0 = m1_2;
                    m2_0 = m2_2;
                    energy_2 = energy_4;
                }
                j_0 = j_0 + 1U;
            }
            i_1 = i_1 + 1U;
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
    float nc_0 = - nc_sum_0;
    thread float3 p_1 = plastic_2;
    (&c_2)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_2)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_3->strength_0.w * nc_0;
    float _S55 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S56 = ks_0 * (d_lin_0.y - plastic_2.y);
    float2 trial_1 = float2(_S55, _S56);
    float tn_0 = sqrt(_S55 * _S55 + _S56 * _S56);
    bool _S57;
    if(tn_0 > slide_cap_0)
    {
        _S57 = tn_0 > 0.0f;
    }
    else
    {
        _S57 = false;
    }
    if(_S57)
    {
        float2 dir_0 = trial_1 / float2(tn_0) ;
        float dslip_0 = (tn_0 - slide_cap_0) / ks_0;
        float _S58 = dir_0.x;
        p_1.x = p_1.x + _S58 * dslip_0;
        float _S59 = dir_0.y;
        p_1.y = p_1.y + _S59 * dslip_0;
        (&c_2)->q_lin_1.x = _S58 * slide_cap_0;
        (&c_2)->q_lin_1.y = _S59 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_2)->q_lin_1.x = _S55;
        (&c_2)->q_lin_1.y = _S56;
        diss_1 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_1.z, slide_cap_0 * (float4(b_3->geom1_0) ).z);
    float _S60 = tq_0.x;
    float _S61 = tq_0.y;
    float diss_2 = diss_1 + abs(_S60) * abs(_S61);
    p_1.z = p_1.z + _S61;
    (&c_2)->q_ang_1.z = _S60;
    (&c_2)->energy_1 = energy_2 + 0.5f * (sq_0((&c_2)->q_lin_1.x) / ks_0 + sq_0((&c_2)->q_lin_1.y) / ks_0 + sq_0(_S60) / kt_0);
    (&c_2)->diss_0 = diss_2;
    (&c_2)->plastic_1 = p_1;
    return c_2;
}

float life_rate_0(const JointMaterial_0 constant* mat_4, float s_1)
{
    if(s_1 <= 0.0f)
    {
        return 0.0f;
    }
    float _S62 = mat_4->misc_0.y;
    return (_S62 + 1.0f) * pow(s_1, _S62) / mat_4->misc_0.z;
}

struct JointResponse_0
{
    float3 force_lin_1;
    float3 force_ang_1;
    JointState_0 state_1;
    float dissipated_1;
    float overshoot_0;
    float stored_0;
    bool disconnected_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_4, const JointState_0 thread* state_2, float3 d_lin_1, float3 d_ang_1, float dt_1, bool fracture_1)
{
    float4 _S63 = float4(b_4->stiff0_0) ;
    float kn_2 = _S63.x;
    float ks_1 = _S63.y;
    float kb1_0 = _S63.z;
    float kb2_0 = _S63.w;
    float4 _S64 = float4(b_4->stiff1_0) ;
    float kt_1 = _S64.x;
    bool has_rebar_1 = (_S64.w) != 0.0f;
    uint kind_2 = mat_5->kind_flags_0.x;
    uint flags_0 = mat_5->kind_flags_0.y;
    bool softening_0 = (flags_0 & 1U) != 0U;
    thread JointState_0 st_1 = *state_2;
    bool _S65 = connected_0(state_2, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S66 = stress_measures_0(b_4, qe_lin_0, qe_ang_0);
    float _S67 = max(max(_S66.tension_0, _S66.shear_0), _S66.compression_0);
    bool _S68 = dt_1 > 0.0f;
    float dif_1;
    if(_S68)
    {
        float raw_0 = max((_S67 - (&st_1)->governing_stress_0) / dt_1, 0.0f) / mat_5->misc_0.w;
        float tau_0 = _S64.z;
        if((flags_0 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- dt_1 / tau_0);
        }
        else
        {
            dif_1 = min(dt_1 / tau_0, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S67;
    }
    if((flags_0 & 32U) != 0U)
    {
        float _S69 = dif_factor_0(mat_5, (&st_1)->strain_rate_0);
        dif_1 = _S69;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_4->geom1_0) ).w;
    float _S70 = weibull_0 * dif_1;
    float _S71 = fatigue_factor_0(mat_5, (&st_1)->fatigue_0);
    float multiplier_1 = _S70 * _S71;
    thread Measures_0 _S72 = _S66;
    float4 _S73 = failure_indices_0(mat_5, b_4, &_S72, multiplier_1);
    float _S74 = _S73.x;
    float _S75 = _S73.y;
    (&st_1)->utilization_0 = max(max(_S74, _S75), max(_S73.z, _S73.w));
    float _S76 = d_lin_1.x;
    float _S77 = d_lin_1.y;
    float _S78 = ks_1 * (sq_0(_S76) + sq_0(_S77)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S79 = d_lin_1.z;
    bool _S80 = _S79 > 0.0f;
    if(_S80)
    {
        dif_1 = kn_2 * sq_0(_S79);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S78 + dif_1);
    float psi_c_0;
    if(_S79 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S79);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3 plastic_3 = float3((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_2;
    float overshoot_1;
    bool _S81;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S82 = _S74 >= _S75;
        if(_S82)
        {
            diss_contact_0 = _S74;
        }
        else
        {
            diss_contact_0 = _S75;
        }
        uint mode_ts_0;
        if(_S82)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S81 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S81 = false;
        }
        if(_S81)
        {
            _S81 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S81 = false;
        }
        uint mode_c_0;
        if(_S81)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_5->energy_0.y;
            }
            else
            {
                psi_contact_0 = mat_5->energy_0.z;
            }
            if(softening_0)
            {
                intact_normal_0 = psi_contact_0 * (float4(b_4->geom0_0) ).x * diss_contact_0 * diss_contact_0 / psi_ts_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_1)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_2;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2 inc_0 = damage_increment_0(mode_c_0, (&st_1)->kappa_0, diss_contact_0, intact_normal_0, (&st_1)->damage_0, psi_ts_0);
            float _S83 = inc_0.x;
            if(_S83 > ((&st_1)->damage_0))
            {
                Contact_0 _S84 = contact_part_0(mat_5, b_4, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
                float _S85 = max(_S84.energy_1 - (1.0f - (&st_1)->crush_0) * psi_c_0, 0.0f);
                float _S86 = max(inc_0.y - _S85 * (_S83 - (&st_1)->damage_0), 0.0f);
                float _S87 = max((psi_ts_0 - _S85) * (_S83 - (&st_1)->damage_0) - _S86, 0.0f);
                (&st_1)->damage_0 = _S83;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_2 = _S86;
                overshoot_1 = _S87;
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
        (&st_1)->kappa_0 = max((&st_1)->kappa_0, diss_contact_0);
        float _S88 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S89 = contact_part_0(mat_5, b_4, state_2->crush_0, float3(state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S88))  + _S89.q_ang_1 * float3(_S88) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S90 = stress_measures_0(b_4, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S91 = _S90;
        float4 _S92 = failure_indices_0(mat_5, b_4, &_S91, multiplier_1);
        float _S93 = _S92.z;
        float _S94 = _S92.w;
        bool _S95 = _S93 >= _S94;
        if(_S95)
        {
            psi_contact_0 = _S93;
        }
        else
        {
            psi_contact_0 = _S94;
        }
        if(_S95)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S81 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S81 = false;
        }
        if(_S81)
        {
            _S81 = psi_c_0 > 0.0f;
        }
        else
        {
            _S81 = false;
        }
        if(_S81)
        {
            if(softening_0)
            {
                intact_normal_0 = mat_5->energy_0.w * (float4(b_4->geom0_0) ).x * psi_contact_0 * psi_contact_0 / psi_c_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_1)->ductility_c_0 = intact_normal_0;
            uint law_1;
            if(!softening_0)
            {
                law_1 = 0U;
            }
            else
            {
                if(mode_c_0 == 4U)
                {
                    mode_ts_0 = 1U;
                }
                else
                {
                    mode_ts_0 = kind_2;
                }
                law_1 = mode_ts_0;
            }
            float2 inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_0, psi_c_0);
            float _S96 = inc_1.x;
            if(_S96 > ((&st_1)->crush_0))
            {
                float _S97 = inc_1.y;
                float dissipated_3 = dissipated_2 + _S97;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S96 - (&st_1)->crush_0) - _S97, 0.0f);
                (&st_1)->crush_0 = _S96;
                (&st_1)->mode_0 = mode_c_0;
                if(_S96 >= 1.0f)
                {
                    _S81 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S81 = false;
                }
                if(_S81)
                {
                    float dissipated_4 = dissipated_3 + psi_ts_0 * (1.0f - (&st_1)->damage_0);
                    (&st_1)->damage_0 = 1.0f;
                    dissipated_2 = dissipated_4;
                }
                else
                {
                    dissipated_2 = dissipated_3;
                }
                overshoot_1 = overshoot_2;
            }
        }
        (&st_1)->kappa_c_0 = max((&st_1)->kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_2 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_1)->damage_0;
    float3 _S98 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S81 = (flags_0 & 8U) != 0U;
    }
    else
    {
        _S81 = false;
    }
    float3 qc_ang_0;
    if(!_S81)
    {
        Contact_0 _S99 = contact_part_0(mat_5, b_4, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S99.plastic_1.x;
        (&st_1)->plastic_y_0 = _S99.plastic_1.y;
        (&st_1)->plastic_t_0 = _S99.plastic_1.z;
        diss_contact_0 = _S99.diss_0;
        qc_lin_0 = _S99.q_lin_1;
        qc_ang_0 = _S99.q_ang_1;
        psi_contact_0 = _S99.energy_1;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S98;
        qc_ang_0 = _S98;
        psi_contact_0 = 0.0f;
    }
    float dissipated_5 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S80)
    {
        intact_normal_0 = kn_2 * _S79;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_2 * _S79;
    }
    float _S100 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S100 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S100 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S100 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S100)  + qc_ang_0 * float3(dmg_0) ;
    float stored_1 = _S100 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S81 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S81 = false;
    }
    float stored_2;
    float3 force_lin_3;
    if(_S81)
    {
        float4 _S101 = float4(b_4->rebar0_0) ;
        float k_axial_0 = _S101.x;
        float k_dowel_0 = _S101.y;
        float yield_force_0 = _S101.z;
        float dowel_capacity_0 = _S101.w;
        float2 nr_0 = return_map_0(k_axial_0, _S79, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S76, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S77, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S102 = nr_0.y;
        float _S103 = v1_0.y;
        float _S104 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S102) + dowel_capacity_0 * (abs(_S103) + abs(_S104));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S102;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S103;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S104;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_6 = dissipated_5 + work_0;
        float _S105 = nr_0.x;
        float _S106 = v1_0.x;
        float _S107 = v2_0.x;
        float elastic_0 = 0.5f * (sq_0(_S105) / k_axial_0 + (sq_0(_S106) + sq_0(_S107)) / k_dowel_0);
        if(fracture_1)
        {
            _S81 = ((&st_1)->rebar_work_0) >= ((float4(b_4->rebar1_0) ).x);
        }
        else
        {
            _S81 = false;
        }
        if(_S81)
        {
            (&st_1)->rebar_broken_0 = 1.0f;
            float dissipated_7 = dissipated_6 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_2 = dissipated_7;
            stored_2 = stored_1;
        }
        else
        {
            float stored_3 = stored_1 + elastic_0;
            force_lin_3 = force_lin_2 + float3(_S106, _S107, _S105);
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
        _S81 = _S68;
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        _S81 = (flags_0 & 64U) != 0U;
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        Measures_0 _S108 = stress_measures_0(b_4, force_lin_3, force_ang_2);
        thread Measures_0 _S109 = _S108;
        float4 _S110 = failure_indices_0(mat_5, b_4, &_S109, weibull_0);
        float _S111 = life_rate_0(mat_5, max(max(_S110.x, _S110.y), _S110.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S111 * dt_1, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_2;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_1 = dissipated_2;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_0 = stored_2;
    if(_S65)
    {
        thread JointState_0 _S112 = st_1;
        bool _S113 = connected_0(&_S112, has_rebar_1);
        _S81 = !_S113;
    }
    else
    {
        _S81 = false;
    }
    (&resp_0)->disconnected_0 = _S81;
    (&resp_0)->measures_0 = _S66;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_5, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S114 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_0;
    if(compressed_0)
    {
        contact_0 = _S114;
    }
    else
    {
        contact_0 = 0.0f;
    }
    float _S115 = 1.0f - _S114;
    float _S116 = max(_S115 + contact_0, 9.99999997475242708e-07f);
    float normal_1;
    if(compressed_0)
    {
        normal_1 = max(1.0f - st_2->crush_0, 9.99999997475242708e-07f);
    }
    else
    {
        normal_1 = max(_S115, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S116, _S116, normal_1);
    *f_ang_0 = float3(_S116) ;
    bool _S117;
    if(((float4(b_5->stiff1_0) ).w) != 0.0f)
    {
        _S117 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S117 = false;
    }
    if(_S117)
    {
        float4 _S118 = float4(b_5->rebar0_0) ;
        float4 _S119 = float4(b_5->stiff0_0) ;
        (*f_lin_0).z = (*f_lin_0).z + _S118.x / _S119.x;
        float _S120 = _S118.y;
        float _S121 = _S119.y;
        (*f_lin_0).x = (*f_lin_0).x + _S120 / _S121;
        (*f_lin_0).y = (*f_lin_0).y + _S120 / _S121;
    }
    return;
}

void comp_add1_0(float thread* sum_0, float thread* err_0, float x_4)
{
    float t_3 = *sum_0 + x_4;
    if((abs(*sum_0)) >= (abs(x_4)))
    {
        *err_0 = *err_0 + (*sum_0 - t_3 + x_4);
    }
    else
    {
        *err_0 = *err_0 + (x_4 - t_3 + *sum_0);
    }
    *sum_0 = t_3;
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S122;
    if((st_3->damage_0) > 0.0f)
    {
        _S122 = true;
    }
    else
    {
        _S122 = (st_3->crush_0) > 0.0f;
    }
    return _S122;
}

struct BondDyn_0
{
    JointState_0 js_0;
    float4 force_lin_0;
    float4 force_ang_0;
    float4 sums_0;
    float4 comps_0;
    uint4 events_0;
};

float3 to_local_0(uint _S123, float3 _S124, KernelContext_0 thread* kernelContext_1)
{
    BondStatic_natural_0 device* _S125 = kernelContext_1->bonds_0+_S123;
    return float3(dot(_S124, (float4(_S125->t1_0) ).xyz), dot(_S124, (float4(_S125->t2_0) ).xyz), dot(_S124, (float4(_S125->normal_0) ).xyz));
}

float3 to_body_0(uint _S126, float3 _S127, KernelContext_0 thread* kernelContext_2)
{
    BondStatic_natural_0 device* _S128 = kernelContext_2->bonds_0+_S126;
    return (float4(_S128->t1_0) ).xyz * float3(_S127.x)  + (float4(_S128->t2_0) ).xyz * float3(_S127.y)  + (float4(_S128->normal_0) ).xyz * float3(_S127.z) ;
}

void bond_update_0(uint i_2, float dt_2, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_3)
{
    BondStatic_natural_0 device* _S129 = kernelContext_3->bonds_0+i_2;
    BondDyn_natural_0 device* _S130 = kernelContext_3->bond_dyn_0+i_2;
    float4 _S131 = float4((*_S130).force_lin_0) ;
    float4 _S132 = float4((*_S130).force_ang_0) ;
    float4 _S133 = float4((*_S130).sums_0) ;
    float4 _S134 = float4((*_S130).comps_0) ;
    uint4 _S135 = uint4((*_S130).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S130).js_0;
    (&bd_0)->force_lin_0 = _S131;
    (&bd_0)->force_ang_0 = _S132;
    (&bd_0)->sums_0 = _S133;
    (&bd_0)->comps_0 = _S134;
    (&bd_0)->events_0 = _S135;
    JointBond_natural_0 _S136 = _S129->law_0;
    thread JointBond_natural_0 _S137 = _S129->law_0;
    uint4 _S138 = uint4((&_S137)->ids_0) ;
    float3 ra_1 = (float4(_S129->ra_0) ).xyz;
    float3 rb_1 = (float4(_S129->rb_0) ).xyz;
    uint _S139 = 4U * _S138.y;
    float3 ta_0 = (float4(*(kernelContext_3->state_0+(_S139 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_3->state_0+(_S139 + 2U))) ).xyz;
    float3 wa_0 = (float4(*(kernelContext_3->state_0+(_S139 + 3U))) ).xyz;
    uint _S140 = 4U * _S138.z;
    float3 tb_0 = (float4(*(kernelContext_3->state_0+(_S140 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_3->state_0+(_S140 + 2U))) ).xyz;
    float3 wb_0 = (float4(*(kernelContext_3->state_0+(_S140 + 3U))) ).xyz;
    float3 _S141 = to_local_0(i_2, (float4(*(kernelContext_3->state_0+_S140)) ).xyz + cross(tb_0, rb_1) - ((float4(*(kernelContext_3->state_0+_S139)) ).xyz + cross(ta_0, ra_1)), kernelContext_3);
    float3 _S142 = to_local_0(i_2, tb_0 - ta_0, kernelContext_3);
    float3 _S143 = to_local_0(i_2, vb_0 + cross(wb_0, rb_1) - (va_0 + cross(wa_0, ra_1)), kernelContext_3);
    float3 _S144 = to_local_0(i_2, wb_0 - wa_0, kernelContext_3);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S137 = _S136;
    thread JointState_0 _S145 = (&bd_0)->js_0;
    JointResponse_0 _S146 = joint_evaluate_0(&kernelContext_3->materials_0->m_0[_S138.x], &_S137, &_S145, _S141, _S142, dt_2, fracture_2);
    thread JointState_0 _S147 = _S146.state_1;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S137, &_S147, _S141, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S143 * (float4(_S129->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S144 * (float4(_S129->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S146.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S146.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S143) + dot(qd_ang_0, _S144)) * dt_2;
    float3 _S148 = to_body_0(i_2, q_lin_2, kernelContext_3);
    float3 _S149 = to_body_0(i_2, q_ang_2, kernelContext_3);
    uint _S150 = 3U * i_2;
    *(kernelContext_3->bond_loads_0+_S150) = packed_float4(float4(_S148, max(_S146.measures_0.tension_0, _S146.measures_0.compression_0))) ;
    *(kernelContext_3->bond_loads_0+(_S150 + 1U)) = packed_float4(float4(_S149 + cross(ra_1, _S148), 0.0f)) ;
    *(kernelContext_3->bond_loads_0+(_S150 + 2U)) = packed_float4(float4(- _S149 + cross(rb_1, - _S148), 0.0f)) ;
    thread float _S151 = (&bd_0)->sums_0.x;
    thread float _S152 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S151, &_S152, _S146.dissipated_1);
    (&bd_0)->comps_0.x = _S152;
    (&bd_0)->sums_0.x = _S151;
    thread float _S153 = (&bd_0)->sums_0.y;
    thread float _S154 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S153, &_S154, _S146.overshoot_0);
    (&bd_0)->comps_0.y = _S154;
    (&bd_0)->sums_0.y = _S153;
    thread float _S155 = (&bd_0)->sums_0.z;
    thread float _S156 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S155, &_S156, damped_0);
    (&bd_0)->comps_0.z = _S156;
    (&bd_0)->sums_0.z = _S155;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S146.stored_0);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S146.state_1.utilization_0));
    thread JointState_0 _S157 = previous_0;
    bool _S158 = is_damaged_0(&_S157);
    bool _S159;
    if(!_S158)
    {
        thread JointState_0 _S160 = _S146.state_1;
        bool _S161 = is_damaged_0(&_S160);
        _S159 = _S161;
    }
    else
    {
        _S159 = false;
    }
    if(_S159)
    {
        _S159 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S159 = false;
    }
    if(_S159)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S146.state_1.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S162 = fatigue_factor_0(&kernelContext_3->materials_0->m_0[_S138.x], previous_0.fatigue_0);
        _S159 = _S162 > 0.99000000953674316f;
    }
    else
    {
        _S159 = false;
    }
    if(_S159)
    {
        float _S163 = fatigue_factor_0(&kernelContext_3->materials_0->m_0[_S138.x], _S146.state_1.fatigue_0);
        _S159 = _S163 <= 0.99000000953674316f;
    }
    else
    {
        _S159 = false;
    }
    if(_S159)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S146.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
        *kernelContext_3->g_halt_0 = 1U;
    }
    (&bd_0)->js_0 = _S146.state_1;
    BondDyn_natural_0 device* _S164 = kernelContext_3->bond_dyn_0+i_2;
    _S164->js_0 = bd_0.js_0;
    _S164->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S164->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S164->sums_0 = packed_float4(bd_0.sums_0) ;
    _S164->comps_0 = packed_float4(bd_0.comps_0) ;
    _S164->events_0 = packed_uint4(bd_0.events_0) ;
    return;
}

struct Island_0
{
    uint4 range_0;
    uint4 info_0;
    float4 com_0;
    float4 inertia0_0;
    float4 inertia1_0;
    float4 inertia2_0;
    float4 inv0_0;
    float4 inv1_0;
    float4 inv2_0;
    float4 wcom_0;
    float4 winv0_0;
    float4 winv1_0;
    float4 winv2_0;
    float4 rotation_0;
    float4 position_0;
    float4 position_err_0;
    float4 velocity_0;
    float4 velocity_err_0;
    float4 angular_velocity_0;
    uint4 done_0;
};

struct Rigid_0
{
    Quat_0 rot_0;
    float3 pos_0;
    float3 pos_err_0;
    float3 vel_0;
    float3 vel_err_0;
    float3 w_1;
    float3 a_4;
    float3 alpha_0;
};

void chunk_update_0(uint c_3, const Island_0 thread* isl_0, const Rigid_0 thread* rg_0, float dt_3, bool rml_0, KernelContext_0 thread* kernelContext_4)
{
    ChunkStatic_natural_0 device* _S165 = kernelContext_4->chunks_0+c_3;
    float3 _S166 = float3(0.0f) ;
    uint _S167 = kernelContext_4->csr_0[c_3];
    float peak_0 = 0.0f;
    uint k_2 = _S167;
    float3 fi_0 = _S166;
    float3 mi_0 = _S166;
    for(;;)
    {
        if(k_2 < (kernelContext_4->csr_0)[c_3 + 1U])
        {
        }
        else
        {
            break;
        }
        uint e_0 = kernelContext_4->csr_0[k_2];
        uint _S168 = 3U * (e_0 >> 1U);
        float4 _S169 = float4(*(kernelContext_4->bond_loads_0+_S168)) ;
        if((e_0 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_4->bond_loads_0+(_S168 + 1U))) ).xyz;
            fi_0 = fi_0 + _S169.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_4->bond_loads_0+(_S168 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S169.xyz;
            mi_0 = mi_2;
        }
        float _S170 = max(peak_0, _S169.w);
        uint _S171 = k_2 + 1U;
        peak_0 = _S170;
        k_2 = _S171;
    }
    uint _S172 = 4U * c_3;
    float3 u_0 = (float4(*(kernelContext_4->state_0+_S172)) ).xyz;
    uint _S173 = _S172 + 1U;
    float3 th_0 = (float4(*(kernelContext_4->state_0+_S173)) ).xyz;
    uint _S174 = _S172 + 2U;
    float3 v_6 = (float4(*(kernelContext_4->state_0+_S174)) ).xyz;
    uint _S175 = _S172 + 3U;
    float3 w_2 = (float4(*(kernelContext_4->state_0+_S175)) ).xyz;
    float4 _S176 = float4(_S165->center_0) ;
    float mass_0 = _S176.w;
    float3 _S177 = rotate_0(&rg_0->rot_0, _S176.xyz + u_0 - isl_0->com_0.xyz);
    float3 _S178 = float3(mass_0) ;
    float3 f_world_0 = kernelContext_4->params_0->gravity_0.xyz * _S178;
    float3 f_world_1;
    float3 t_world_0;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_0->a_4 + cross(rg_0->alpha_0, _S177) + cross(rg_0->w_1, cross(rg_0->w_1, _S177))) * _S178;
        float4 _S179 = float4(_S165->inertia0_1) ;
        float4 _S180 = float4(_S165->inertia1_1) ;
        float4 _S181 = float4(_S165->inertia2_1) ;
        float3 _S182 = world_mul_0(&rg_0->rot_0, _S179, _S180, _S181, rg_0->alpha_0);
        float3 _S183 = world_mul_0(&rg_0->rot_0, _S179, _S180, _S181, rg_0->w_1);
        float3 t_world_1 = _S166 - (_S182 + cross(rg_0->w_1, _S183));
        f_world_1 = f_world_2;
        t_world_0 = t_world_1;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_0 = _S166;
    }
    float3 _S184 = inverse_rotate_0(&rg_0->rot_0, f_world_1);
    float3 _S185 = inverse_rotate_0(&rg_0->rot_0, t_world_0);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S186 = inverse_rotate_0(&rg_0->rot_0, rg_0->w_1);
        float4 _S187 = float4(_S165->inertia0_1) ;
        float4 _S188 = float4(_S165->inertia1_1) ;
        float4 _S189 = float4(_S165->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S187, _S188, _S189, w_2);
        float3 m_ext_1 = _S185 - (cross(_S186, i_w_0) + cross(w_2, rows_mul_0(_S187, _S188, _S189, _S186)) + cross(w_2, i_w_0));
        f_ext_0 = _S184 - cross(_S186, v_6) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S184;
        m_ext_0 = _S185;
    }
    float3 f_3 = f_ext_0 + fi_0;
    float3 m_3 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S165->info_1) ).x;
    float3 u_1;
    float3 th_1;
    float3 v_7;
    float3 w_3;
    if(support_0 == 1U)
    {
        u_1 = u_0;
        th_1 = th_0;
        v_7 = _S166;
        w_3 = _S166;
    }
    else
    {
        float4 _S190 = float4(_S165->scale_0) ;
        float3 w_4 = w_2 + rows_mul_0(float4(_S165->inv0_1) , float4(_S165->inv1_1) , float4(_S165->inv2_1) , m_3) * float3((dt_3 * _S190.z)) ;
        float3 _S191 = float3(dt_3) ;
        float3 th_2 = th_0 + w_4 * _S191;
        if(support_0 == 2U)
        {
            u_1 = u_0;
            th_1 = _S166;
        }
        else
        {
            float3 v_8 = v_6 + f_3 * float3((dt_3 * _S190.y)) ;
            u_1 = u_0 + v_8 * _S191;
            th_1 = v_8;
        }
        float3 _S192 = th_1;
        th_1 = th_2;
        v_7 = _S192;
        w_3 = w_4;
    }
    *(kernelContext_4->state_0+_S172) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_4->state_0+_S173) = packed_float4(float4(th_1, 0.0f)) ;
    *(kernelContext_4->state_0+_S174) = packed_float4(float4(v_7, 0.0f)) ;
    *(kernelContext_4->state_0+_S175) = packed_float4(float4(w_3, 0.0f)) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_5)
{
    float3 t_4 = *sum_1 + x_5;
    float3 _S193 = abs(x_5);
    *err_1 = *err_1 + (select(x_5, *sum_1, (abs(*sum_1)) >= _S193) - t_4 + select(*sum_1, x_5, (abs(*sum_1)) >= _S193));
    *sum_1 = t_4;
    return;
}

float3 safe_normalize_0(float3 v_9)
{
    float n_0 = length(v_9);
    float3 _S194;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S194 = v_9 / float3(n_0) ;
    }
    else
    {
        _S194 = float3(0.0f) ;
    }
    return _S194;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_5 = safe_normalize_0(axis_0);
    float _S195 = 0.5f * angle_0;
    float s_2 = sin(_S195);
    thread Quat_0 q_6;
    (&q_6)->w_0 = cos(_S195);
    (&q_6)->x_0 = a_5.x * s_2;
    (&q_6)->y_0 = a_5.y * s_2;
    (&q_6)->z_0 = a_5.z * s_2;
    return q_6;
}

Quat_0 quat_mul_0(const Quat_0 thread* a_6, const Quat_0 thread* o_1)
{
    thread Quat_0 r_5;
    (&r_5)->w_0 = a_6->w_0 * o_1->w_0 - a_6->x_0 * o_1->x_0 - a_6->y_0 * o_1->y_0 - a_6->z_0 * o_1->z_0;
    (&r_5)->x_0 = a_6->w_0 * o_1->x_0 + a_6->x_0 * o_1->w_0 + a_6->y_0 * o_1->z_0 - a_6->z_0 * o_1->y_0;
    (&r_5)->y_0 = a_6->w_0 * o_1->y_0 - a_6->x_0 * o_1->z_0 + a_6->y_0 * o_1->w_0 + a_6->z_0 * o_1->x_0;
    (&r_5)->z_0 = a_6->w_0 * o_1->z_0 + a_6->x_0 * o_1->y_0 - a_6->y_0 * o_1->x_0 + a_6->z_0 * o_1->w_0;
    return r_5;
}

Quat_0 normalized_0(const Quat_0 thread* q_7)
{
    float n_1 = sqrt(q_7->w_0 * q_7->w_0 + q_7->x_0 * q_7->x_0 + q_7->y_0 * q_7->y_0 + q_7->z_0 * q_7->z_0);
    thread Quat_0 r_6;
    (&r_6)->w_0 = q_7->w_0 / n_1;
    (&r_6)->x_0 = q_7->x_0 / n_1;
    (&r_6)->y_0 = q_7->y_0 / n_1;
    (&r_6)->z_0 = q_7->z_0 / n_1;
    return r_6;
}

Quat_0 integrate_rotation_0(const Quat_0 thread* q_8, float3 omega_0, float dt_4)
{
    float angle_1 = length(omega_0) * dt_4;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_8;
    }
    thread Quat_0 _S196 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S197 = quat_mul_0(&_S196, q_8);
    thread Quat_0 _S198 = _S197;
    Quat_0 _S199 = normalized_0(&_S198);
    return _S199;
}

float4 quat_vec_0(const Quat_0 thread* q_9)
{
    return float4(q_9->x_0, q_9->y_0, q_9->z_0, q_9->w_0);
}

[[kernel]] void island_frame(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Island_natural_0 device* islands_1 [[buffer(8)]], Params_0 constant* params_1 [[buffer(0)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_3 [[buffer(5)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(6)]], MaterialTable_0 constant* materials_1 [[buffer(1)]], packed_float4 device* bond_loads_1 [[buffer(7)]], uint device* csr_1 [[buffer(4)]])
{
    thread KernelContext_0 kernelContext_5;
    (&kernelContext_5)->islands_0 = islands_1;
    (&kernelContext_5)->params_0 = params_1;
    (&kernelContext_5)->chunks_0 = chunks_1;
    (&kernelContext_5)->state_0 = state_3;
    (&kernelContext_5)->bonds_0 = bonds_1;
    (&kernelContext_5)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_5)->materials_0 = materials_1;
    (&kernelContext_5)->bond_loads_0 = bond_loads_1;
    (&kernelContext_5)->csr_0 = csr_1;
    threadgroup uint g_halt_1;
    (&kernelContext_5)->g_halt_0 = &g_halt_1;
    threadgroup array<float4, int(256)> g_red_a_1;
    (&kernelContext_5)->g_red_a_0 = &g_red_a_1;
    threadgroup array<float4, int(256)> g_red_b_1;
    (&kernelContext_5)->g_red_b_0 = &g_red_b_1;
    uint tid_1 = thread_0.x;
    uint _S200 = group_0.x;
    Island_natural_0 device* _S201 = islands_1+_S200;
    uint4 _S202 = uint4((*_S201).info_0) ;
    float4 _S203 = float4((*_S201).com_0) ;
    float4 _S204 = float4((*_S201).inertia0_0) ;
    float4 _S205 = float4((*_S201).inertia1_0) ;
    float4 _S206 = float4((*_S201).inertia2_0) ;
    float4 _S207 = float4((*_S201).inv0_0) ;
    float4 _S208 = float4((*_S201).inv1_0) ;
    float4 _S209 = float4((*_S201).inv2_0) ;
    float4 _S210 = float4((*_S201).wcom_0) ;
    float4 _S211 = float4((*_S201).winv0_0) ;
    float4 _S212 = float4((*_S201).winv1_0) ;
    float4 _S213 = float4((*_S201).winv2_0) ;
    float4 _S214 = float4((*_S201).rotation_0) ;
    float4 _S215 = float4((*_S201).position_0) ;
    float4 _S216 = float4((*_S201).position_err_0) ;
    float4 _S217 = float4((*_S201).velocity_0) ;
    float4 _S218 = float4((*_S201).velocity_err_0) ;
    float4 _S219 = float4((*_S201).angular_velocity_0) ;
    uint4 _S220 = uint4((*_S201).done_0) ;
    thread Island_0 isl_1;
    (&isl_1)->range_0 = uint4((*_S201).range_0) ;
    (&isl_1)->info_0 = _S202;
    (&isl_1)->com_0 = _S203;
    (&isl_1)->inertia0_0 = _S204;
    (&isl_1)->inertia1_0 = _S205;
    (&isl_1)->inertia2_0 = _S206;
    (&isl_1)->inv0_0 = _S207;
    (&isl_1)->inv1_0 = _S208;
    (&isl_1)->inv2_0 = _S209;
    (&isl_1)->wcom_0 = _S210;
    (&isl_1)->winv0_0 = _S211;
    (&isl_1)->winv1_0 = _S212;
    (&isl_1)->winv2_0 = _S213;
    (&isl_1)->rotation_0 = _S214;
    (&isl_1)->position_0 = _S215;
    (&isl_1)->position_err_0 = _S216;
    (&isl_1)->velocity_0 = _S217;
    (&isl_1)->velocity_err_0 = _S218;
    (&isl_1)->angular_velocity_0 = _S219;
    (&isl_1)->done_0 = _S220;
    bool driven_0 = (((&isl_1)->info_0.x) & 2U) != 0U;
    bool _S221 = !((((&isl_1)->info_0.x) & 1U) != 0U);
    bool _S222;
    if(_S221)
    {
        _S222 = !driven_0;
    }
    else
    {
        _S222 = false;
    }
    uint _S223;
    if((((&isl_1)->info_0.z) & 1U) != 0U)
    {
        _S223 = 0U;
    }
    else
    {
        _S223 = (&isl_1)->info_0.y;
    }
    float _S224 = (&kernelContext_5)->params_0->dt_0;
    bool _S225 = ((&kernelContext_5)->params_0->fracture_0) != 0U;
    bool _S226 = ((&kernelContext_5)->params_0->rigid_motion_loads_0) != 0U;
    float3 _S227 = (&kernelContext_5)->params_0->gravity_0.xyz;
    float _S228 = (&isl_1)->com_0.w;
    thread Rigid_0 rg_1;
    (&rg_1)->rot_0 = quat_of_0((&isl_1)->rotation_0);
    (&rg_1)->pos_0 = (&isl_1)->position_0.xyz;
    (&rg_1)->pos_err_0 = (&isl_1)->position_err_0.xyz;
    (&rg_1)->vel_0 = (&isl_1)->velocity_0.xyz;
    (&rg_1)->vel_err_0 = (&isl_1)->velocity_err_0.xyz;
    (&rg_1)->w_1 = (&isl_1)->angular_velocity_0.xyz;
    float3 _S229 = float3(0.0f) ;
    (&rg_1)->a_4 = _S229;
    (&rg_1)->alpha_0 = _S229;
    bool _S230 = tid_1 == 0U;
    if(_S230)
    {
        *(&kernelContext_5)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint done_1 = 0U;
    for(;;)
    {
        if(done_1 < _S223)
        {
        }
        else
        {
            break;
        }
        uint _S231 = (&isl_1)->info_0.w + done_1 + 1U;
        uint i_3;
        if(_S221)
        {
            thread float3 f_4 = _S229;
            thread float3 t_5 = _S229;
            i_3 = (&isl_1)->range_0.x + tid_1;
            for(;;)
            {
                if(i_3 < ((&isl_1)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                float4 _S232 = float4(((&kernelContext_5)->chunks_0+i_3)->center_0) ;
                float3 fc_2 = _S227 * float3(_S232.w) ;
                float3 _S233 = _S232.xyz + (float4(*((&kernelContext_5)->state_0+4U * i_3)) ).xyz - (&isl_1)->com_0.xyz;
                thread Quat_0 _S234 = (&rg_1)->rot_0;
                float3 _S235 = rotate_0(&_S234, _S233);
                f_4 = f_4 + fc_2;
                t_5 = t_5 + cross(_S235, fc_2);
                i_3 = i_3 + 256U;
            }
            group_sum2_0(tid_1, &f_4, &t_5, &kernelContext_5);
            thread Quat_0 _S236 = (&rg_1)->rot_0;
            float3 _S237 = world_mul_0(&_S236, (&isl_1)->inertia0_0, (&isl_1)->inertia1_0, (&isl_1)->inertia2_0, (&rg_1)->w_1);
            (&rg_1)->a_4 = f_4 / float3(_S228) ;
            float3 _S238 = t_5 - cross((&rg_1)->w_1, _S237);
            thread Quat_0 _S239 = (&rg_1)->rot_0;
            float3 _S240 = world_mul_0(&_S239, (&isl_1)->inv0_0, (&isl_1)->inv1_0, (&isl_1)->inv2_0, _S238);
            (&rg_1)->alpha_0 = _S240;
        }
        i_3 = (&isl_1)->range_0.z + tid_1;
        for(;;)
        {
            if(i_3 < ((&isl_1)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bond_update_0(i_3, _S224, _S225, _S231, &kernelContext_5);
            i_3 = i_3 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_4 = (&isl_1)->range_0.x + tid_1;
        for(;;)
        {
            if(c_4 < ((&isl_1)->range_0.y))
            {
            }
            else
            {
                break;
            }
            thread Island_0 _S241 = isl_1;
            thread Rigid_0 _S242 = rg_1;
            chunk_update_0(c_4, &_S241, &_S242, _S224, _S226, &kernelContext_5);
            c_4 = c_4 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S222)
        {
            thread Quat_0 _S243 = (&rg_1)->rot_0;
            float3 _S244 = world_mul_0(&_S243, (&isl_1)->inertia0_0, (&isl_1)->inertia1_0, (&isl_1)->inertia2_0, (&rg_1)->w_1);
            thread Quat_0 _S245 = (&rg_1)->rot_0;
            float3 _S246 = world_mul_0(&_S245, (&isl_1)->inertia0_0, (&isl_1)->inertia1_0, (&isl_1)->inertia2_0, (&rg_1)->alpha_0);
            float3 _S247 = float3(_S224) ;
            float3 l_0 = _S244 + (_S246 + cross((&rg_1)->w_1, _S244)) * _S247;
            comp_add_0(&(&rg_1)->vel_0, &(&rg_1)->vel_err_0, (&rg_1)->a_4 * _S247);
            float3 vel_1 = (&rg_1)->vel_0 + (&rg_1)->vel_err_0;
            thread Quat_0 _S248 = (&rg_1)->rot_0;
            float3 _S249 = world_mul_0(&_S248, (&isl_1)->inv0_0, (&isl_1)->inv1_0, (&isl_1)->inv2_0, l_0);
            thread Quat_0 _S250 = (&rg_1)->rot_0;
            Quat_0 _S251 = integrate_rotation_0(&_S250, _S249, _S224);
            float3 _S252 = vel_1 * _S247;
            float3 _S253 = (&isl_1)->com_0.xyz;
            thread Quat_0 _S254 = (&rg_1)->rot_0;
            float3 _S255 = rotate_0(&_S254, _S253);
            float3 _S256 = (&isl_1)->com_0.xyz;
            thread Quat_0 _S257 = _S251;
            float3 _S258 = rotate_0(&_S257, _S256);
            comp_add_0(&(&rg_1)->pos_0, &(&rg_1)->pos_err_0, _S252 + (_S255 - _S258));
            (&rg_1)->rot_0 = _S251;
            thread Quat_0 _S259 = _S251;
            float3 _S260 = world_mul_0(&_S259, (&isl_1)->inv0_0, (&isl_1)->inv1_0, (&isl_1)->inv2_0, l_0);
            (&rg_1)->w_1 = _S260;
        }
        if(_S221)
        {
            float3 wcom_1 = (&isl_1)->wcom_0.xyz;
            float wmass_0 = (&isl_1)->wcom_0.w;
            thread float3 tu_0 = _S229;
            thread float3 pv_0 = _S229;
            uint c_5 = (&isl_1)->range_0.x + tid_1;
            for(;;)
            {
                if(c_5 < ((&isl_1)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S261 = (&kernelContext_5)->chunks_0+c_5;
                uint _S262 = 4U * c_5;
                float3 _S263 = float3(((float4(_S261->center_0) ).w * (float4(_S261->scale_0) ).x)) ;
                tu_0 = tu_0 + (float4(*((&kernelContext_5)->state_0+_S262)) ).xyz * _S263;
                pv_0 = pv_0 + (float4(*((&kernelContext_5)->state_0+(_S262 + 2U))) ).xyz * _S263;
                c_5 = c_5 + 256U;
            }
            group_sum2_0(tid_1, &tu_0, &pv_0, &kernelContext_5);
            float3 _S264 = float3(wmass_0) ;
            float3 tr_0 = tu_0 / _S264;
            float3 dv_0 = pv_0 / _S264;
            thread float3 lu_0 = _S229;
            thread float3 lv_0 = _S229;
            uint c_6 = (&isl_1)->range_0.x + tid_1;
            for(;;)
            {
                if(c_6 < ((&isl_1)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S265 = (&kernelContext_5)->chunks_0+c_6;
                float4 _S266 = float4(_S265->center_0) ;
                float3 r_7 = _S266.xyz - wcom_1;
                uint _S267 = 4U * c_6;
                float3 _S268 = float3(_S266.w) ;
                float4 _S269 = float4(_S265->inertia0_1) ;
                float4 _S270 = float4(_S265->inertia1_1) ;
                float4 _S271 = float4(_S265->inertia2_1) ;
                float3 _S272 = float3((float4(_S265->scale_0) ).x) ;
                lu_0 = lu_0 + (cross(r_7, (float4(*((&kernelContext_5)->state_0+_S267)) ).xyz - tr_0) * _S268 + rows_mul_0(_S269, _S270, _S271, (float4(*((&kernelContext_5)->state_0+(_S267 + 1U))) ).xyz)) * _S272;
                lv_0 = lv_0 + (cross(r_7, (float4(*((&kernelContext_5)->state_0+(_S267 + 2U))) ).xyz - dv_0) * _S268 + rows_mul_0(_S269, _S270, _S271, (float4(*((&kernelContext_5)->state_0+(_S267 + 3U))) ).xyz)) * _S272;
                c_6 = c_6 + 256U;
            }
            group_sum2_0(tid_1, &lu_0, &lv_0, &kernelContext_5);
            float3 phi_0 = rows_mul_0((&isl_1)->winv0_0, (&isl_1)->winv1_0, (&isl_1)->winv2_0, lu_0);
            float3 dw_0 = rows_mul_0((&isl_1)->winv0_0, (&isl_1)->winv1_0, (&isl_1)->winv2_0, lv_0);
            uint c_7 = (&isl_1)->range_0.x + tid_1;
            for(;;)
            {
                if(c_7 < ((&isl_1)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                float3 r_8 = (float4(((&kernelContext_5)->chunks_0+c_7)->center_0) ).xyz - wcom_1;
                uint _S273 = 4U * c_7;
                *((&kernelContext_5)->state_0+_S273) = packed_float4(float4((float4(*((&kernelContext_5)->state_0+_S273)) ).xyz - (tr_0 + cross(phi_0, r_8)), (float4(*((&kernelContext_5)->state_0+_S273)) ).w)) ;
                uint _S274 = _S273 + 1U;
                *((&kernelContext_5)->state_0+_S274) = packed_float4(float4((float4(*((&kernelContext_5)->state_0+_S274)) ).xyz - phi_0, 0.0f)) ;
                uint _S275 = _S273 + 2U;
                *((&kernelContext_5)->state_0+_S275) = packed_float4(float4((float4(*((&kernelContext_5)->state_0+_S275)) ).xyz - (dv_0 + cross(dw_0, r_8)), 0.0f)) ;
                uint _S276 = _S273 + 3U;
                *((&kernelContext_5)->state_0+_S276) = packed_float4(float4((float4(*((&kernelContext_5)->state_0+_S276)) ).xyz - dw_0, 0.0f)) ;
                c_7 = c_7 + 256U;
            }
            if(!driven_0)
            {
                Quat_0 rot_1 = (&rg_1)->rot_0;
                float3 _S277 = tr_0 - cross(phi_0, wcom_1);
                thread Quat_0 _S278 = (&rg_1)->rot_0;
                float3 _S279 = rotate_0(&_S278, _S277);
                comp_add_0(&(&rg_1)->pos_0, &(&rg_1)->pos_err_0, _S279);
                Quat_0 _S280 = from_axis_angle_0(phi_0, length(phi_0));
                thread Quat_0 _S281 = (&rg_1)->rot_0;
                thread Quat_0 _S282 = _S280;
                Quat_0 _S283 = quat_mul_0(&_S281, &_S282);
                thread Quat_0 _S284 = _S283;
                Quat_0 _S285 = normalized_0(&_S284);
                (&rg_1)->rot_0 = _S285;
                float3 _S286 = dv_0 + cross(dw_0, (&isl_1)->com_0.xyz - wcom_1);
                thread Quat_0 _S287 = rot_1;
                float3 _S288 = rotate_0(&_S287, _S286);
                comp_add_0(&(&rg_1)->vel_0, &(&rg_1)->vel_err_0, _S288);
                thread Quat_0 _S289 = rot_1;
                float3 _S290 = rotate_0(&_S289, dw_0);
                (&rg_1)->w_1 = (&rg_1)->w_1 + _S290;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        uint _S291 = done_1 + 1U;
        if((*(&kernelContext_5)->g_halt_0) != 0U)
        {
            done_1 = _S291;
            break;
        }
        done_1 = _S291;
    }
    if(_S230)
    {
        thread Quat_0 _S292 = (&rg_1)->rot_0;
        float4 _S293 = quat_vec_0(&_S292);
        (&isl_1)->rotation_0 = _S293;
        (&isl_1)->position_0 = float4((&rg_1)->pos_0, 0.0f);
        (&isl_1)->position_err_0 = float4((&rg_1)->pos_err_0, 0.0f);
        (&isl_1)->velocity_0 = float4((&rg_1)->vel_0, 0.0f);
        (&isl_1)->velocity_err_0 = float4((&rg_1)->vel_err_0, 0.0f);
        (&isl_1)->angular_velocity_0 = float4((&rg_1)->w_1, 0.0f);
        (&isl_1)->done_0.x = done_1;
        (&isl_1)->info_0.w = (&isl_1)->info_0.w + done_1;
        if((*(&kernelContext_5)->g_halt_0) != 0U)
        {
            (&isl_1)->info_0.z = ((&isl_1)->info_0.z) | 1U;
        }
        Island_natural_0 device* _S294 = (&kernelContext_5)->islands_0+_S200;
        _S294->range_0 = packed_uint4(isl_1.range_0) ;
        _S294->info_0 = packed_uint4(isl_1.info_0) ;
        _S294->com_0 = packed_float4(isl_1.com_0) ;
        _S294->inertia0_0 = packed_float4(isl_1.inertia0_0) ;
        _S294->inertia1_0 = packed_float4(isl_1.inertia1_0) ;
        _S294->inertia2_0 = packed_float4(isl_1.inertia2_0) ;
        _S294->inv0_0 = packed_float4(isl_1.inv0_0) ;
        _S294->inv1_0 = packed_float4(isl_1.inv1_0) ;
        _S294->inv2_0 = packed_float4(isl_1.inv2_0) ;
        _S294->wcom_0 = packed_float4(isl_1.wcom_0) ;
        _S294->winv0_0 = packed_float4(isl_1.winv0_0) ;
        _S294->winv1_0 = packed_float4(isl_1.winv1_0) ;
        _S294->winv2_0 = packed_float4(isl_1.winv2_0) ;
        _S294->rotation_0 = packed_float4(isl_1.rotation_0) ;
        _S294->position_0 = packed_float4(isl_1.position_0) ;
        _S294->position_err_0 = packed_float4(isl_1.position_err_0) ;
        _S294->velocity_0 = packed_float4(isl_1.velocity_0) ;
        _S294->velocity_err_0 = packed_float4(isl_1.velocity_err_0) ;
        _S294->angular_velocity_0 = packed_float4(isl_1.angular_velocity_0) ;
        _S294->done_0 = packed_uint4(isl_1.done_0) ;
    }
    return;
}

