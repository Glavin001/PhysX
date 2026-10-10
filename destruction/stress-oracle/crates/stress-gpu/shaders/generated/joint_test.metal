#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
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

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S1;
    if((st_0->damage_0) < 1.0f)
    {
        _S1 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S1 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S1 = false;
        }
    }
    return _S1;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
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

Measures_0 stress_measures_0(const JointBond_natural_0 thread* b_0, float3 q_lin_0, float3 q_ang_0)
{
    float4 _S2 = float4(b_0->geom0_0) ;
    float area_0 = _S2.x;
    float _S3 = q_lin_0.z;
    float axial_0 = _S3 / area_0;
    float4 _S4 = float4(b_0->geom1_0) ;
    float bending_0 = abs(q_ang_0.x) / _S4.x + abs(q_ang_0.y) / _S4.y;
    float _S5 = q_lin_0.x;
    float _S6 = q_lin_0.y;
    float shear_1 = sqrt(_S5 * _S5 + _S6 * _S6) / area_0 + abs(q_ang_0.z) / _S2.w;
    thread Measures_0 m_0;
    (&m_0)->tension_0 = axial_0 + bending_0;
    (&m_0)->shear_0 = shear_1;
    float _S7 = - axial_0;
    (&m_0)->normal_compression_0 = max(_S7, 0.0f);
    (&m_0)->compression_0 = _S7 + bending_0;
    (&m_0)->compressive_force_0 = max(- _S3, 0.0f);
    return m_0;
}

float expm1_accurate_0(float x_0)
{
    if((abs(x_0)) < 0.00100000004749745f)
    {
        return x_0 * (1.0f + x_0 * (0.5f + x_0 * 0.1666666716337204f));
    }
    return exp(x_0) - 1.0f;
}

struct JointMaterial_natural_0
{
    packed_float4 strength_0;
    packed_float4 energy_0;
    packed_float4 dif_0;
    packed_float4 misc_0;
    packed_uint4 kind_flags_0;
};

float dif_factor_0(const JointMaterial_natural_0 thread* mat_0, float strain_rate_1)
{
    float r_0 = abs(strain_rate_1);
    float4 _S8 = float4(mat_0->dif_0) ;
    float ref_0 = _S8.x;
    if(r_0 <= ref_0)
    {
        return 1.0f;
    }
    float _S9 = _S8.z;
    float f_0;
    if(r_0 <= _S9)
    {
        f_0 = pow(r_0 / ref_0, _S8.y);
    }
    else
    {
        f_0 = pow(_S9 / ref_0, _S8.y) * pow(r_0 / _S9, _S8.w);
    }
    return clamp(f_0, 1.0f, (float4(mat_0->misc_0) ).x);
}

float fatigue_factor_0(const JointMaterial_natural_0 thread* mat_1, float fatigue_1)
{
    if((((uint4(mat_1->kind_flags_0) ).y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_1, 0.0f, 1.0f), 1.0f / ((float4(mat_1->misc_0) ).y - 2.0f));
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_natural_0 thread* mat_2, const JointBond_natural_0 thread* b_1, const Measures_0 thread* m_1, float multiplier_0)
{
    float4 _S10 = float4(mat_2->strength_0) ;
    float fc_0 = _S10.y * multiplier_0;
    float _S11 = min(_S10.z * multiplier_0 + _S10.w * m_1->normal_compression_0, (float4(mat_2->energy_0) ).x * multiplier_0);
    thread float4 idx_0;
    idx_0.x = max(m_1->tension_0 / (_S10.x * multiplier_0), 0.0f);
    float _S12;
    if(_S11 > 0.0f)
    {
        _S12 = m_1->shear_0 / _S11;
    }
    else
    {
        _S12 = infinity_0();
    }
    idx_0.y = _S12;
    idx_0.z = max(m_1->compression_0 / fc_0, 0.0f);
    float _S13 = (float4(b_1->stiff1_0) ).y;
    if(_S13 > 0.0f)
    {
        _S12 = m_1->compressive_force_0 / _S13;
    }
    else
    {
        _S12 = 0.0f;
    }
    idx_0.w = _S12;
    return idx_0;
}

float sq_0(float x_1)
{
    return x_1 * x_1;
}

float damage_law_0(uint kind_0, float kappa_1, float r_1)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_0 == 0U)
    {
        if(r_1 <= 1.0f)
        {
            return 1.0f;
        }
        return min(r_1 * (kappa_1 - 1.0f) / (kappa_1 * (r_1 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_1 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - 1.0f / kappa_1;
}

float2 damage_increment_0(uint kind_1, float kappa_old_0, float lambda_0, float r_2, float d_old_0, float psi_0)
{
    float _S14 = max(damage_law_0(kind_1, lambda_0, r_2), d_old_0);
    bool _S15;
    if(_S14 <= d_old_0)
    {
        _S15 = true;
    }
    else
    {
        _S15 = d_old_0 >= 1.0f;
    }
    if(_S15)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = psi_0 / (lambda_0 * lambda_0);
    float _S16 = max(kappa_old_0, 1.0f);
    if(kind_1 == 0U)
    {
        if(r_2 > 1.0f)
        {
            return float2(_S14, u0_0 * r_2 / (r_2 - 1.0f) * max(min(lambda_0, r_2) - min(_S16, r_2), 0.0f));
        }
        return float2(_S14, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_2 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S16, ku_0), 0.0f);
    float snap_0;
    if(_S14 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S14, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_0;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S17 = - h0_0;
    float _S18 = - h1_0;
    array<float2, int(4)> _S19 = { { float2(_S17, _S18), float2(h0_0, _S18), float2(h0_0, h1_0), float2(_S17, h1_0) } };
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
        uint _S20 = i_0;
        uint _S21 = i_0 + 1U;
        uint _S22 = _S21 % 4U;
        float _S23 = _S19[i_0].y;
        float _S24 = _S19[i_0].x;
        float fp_0 = dz_0 + ax_0 * _S23 - ay_0 * _S24;
        float _S25 = _S19[_S22].y;
        float _S26 = _S19[_S22].x;
        float fq_0 = dz_0 + ax_0 * _S25 - ay_0 * _S26;
        bool _S27 = fp_0 < 0.0f;
        if(_S27)
        {
            uint _S28 = count_1 + 1U;
            poly_0[count_1] = _S19[_S20];
            count_0 = _S28;
        }
        else
        {
            count_0 = count_1;
        }
        if(_S27 != (fq_0 < 0.0f))
        {
            float t_0 = fp_0 / (fp_0 - fq_0);
            uint _S29 = count_0 + 1U;
            poly_0[count_0] = float2(_S24 + t_0 * (_S26 - _S24), _S23 + t_0 * (_S25 - _S23));
            count_1 = _S29;
        }
        else
        {
            count_1 = count_0;
        }
        i_0 = _S21;
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
    float a_0 = 0.0f;
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
        float _S30 = o_0.x;
        float x0_0 = poly_0[i_0].x - _S30;
        float _S31 = o_0.y;
        float y0_0 = poly_0[i_0].y - _S31;
        uint _S32 = i_0 + 1U;
        uint _S33 = _S32 % count_1;
        float x1_0 = poly_0[_S33].x - _S30;
        float y1_0 = poly_0[_S33].y - _S31;
        float _S34 = x0_0 * y1_0;
        float _S35 = x1_0 * y0_0;
        float cr_0 = _S34 - _S35;
        float a_1 = a_0 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S34 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S35) * cr_0 / 24.0f;
        i_0 = _S32;
        a_0 = a_1;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_0 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_0;
    float cy_0 = sy_0 / a_0;
    (*region_0)[int(0)] = a_0;
    (*region_0)[int(1)] = o_0.x + cx_0;
    (*region_0)[int(2)] = o_0.y + cy_0;
    float _S36 = a_0 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S36 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_0 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S36 * cy_0;
    return;
}

float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_3;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_3);
    float a_2 = r_3[int(0)];
    if((r_3[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_0 = kn_0 / (w0_1 * w1_1);
    float fc_1 = dz_1 + ax_1 * r_3[int(2)] - ay_1 * r_3[int(1)];
    float _S37 = a_2 * fc_1;
    float _S38 = - ay_1;
    return float4(k_0 * a_2 * fc_1, k_0 * (_S37 * r_3[int(2)] + (_S38 * r_3[int(5)] + ax_1 * r_3[int(4)])), - k_0 * (_S37 * r_3[int(1)] + (_S38 * r_3[int(3)] + ax_1 * r_3[int(5)])), 0.5f * k_0 * (_S37 * fc_1 + ay_1 * ay_1 * r_3[int(3)] + ax_1 * ax_1 * r_3[int(4)] - 2.0f * ax_1 * ay_1 * r_3[int(5)]));
}

float signum_0(float x_2)
{
    float _S39;
    if(((as_type<uint>((x_2))) & 2147483648U) != 0U)
    {
        _S39 = -1.0f;
    }
    else
    {
        _S39 = 1.0f;
    }
    return _S39;
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

Contact_0 contact_part_0(const JointMaterial_natural_0 thread* mat_3, const JointBond_natural_0 thread* b_2, float crush_1, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_0;
    float3 _S40 = float3(0.0f) ;
    (&c_0)->q_lin_1 = _S40;
    (&c_0)->q_ang_1 = _S40;
    (&c_0)->energy_1 = 0.0f;
    (&c_0)->diss_0 = 0.0f;
    (&c_0)->plastic_1 = plastic_2;
    uint _S41 = (uint4(mat_3->kind_flags_0) ).y;
    if((_S41 & 2U) == 0U)
    {
        return c_0;
    }
    float4 _S42 = float4(b_2->stiff0_0) ;
    float kn_1 = _S42.x;
    float ks_0 = _S42.y;
    float kt_0 = (float4(b_2->stiff1_0) ).x;
    float4 _S43 = float4(b_2->geom0_0) ;
    float w0_2 = _S43.y;
    float w1_2 = _S43.z;
    float diss_1;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_2;
    if((_S41 & 4U) != 0U)
    {
        float4 p_0 = no_tension_patch_0(kn_1 * (1.0f - crush_1), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S44 = p_0.y;
        float _S45 = p_0.z;
        float _S46 = p_0.w;
        nc_sum_0 = p_0.x;
        m1_0 = _S44;
        m2_0 = _S45;
        energy_2 = _S46;
    }
    else
    {
        float _S47 = kn_1 * (1.0f - crush_1) / 36.0f;
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
            float _S48 = ((float(i_1) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                float di_0 = d_lin_0.z + d_ang_0.x * s2_0 - d_ang_0.y * _S48;
                if(di_0 < 0.0f)
                {
                    float f_2 = _S47 * di_0;
                    float m1_2 = m1_0 + f_2 * s2_0;
                    float m2_2 = m2_0 - f_2 * _S48;
                    float energy_4 = energy_2 + 0.5f * _S47 * di_0 * di_0;
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
    (&c_0)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_0)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = (float4(mat_3->strength_0) ).w * nc_0;
    float _S49 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S50 = ks_0 * (d_lin_0.y - plastic_2.y);
    float2 trial_1 = float2(_S49, _S50);
    float tn_0 = sqrt(_S49 * _S49 + _S50 * _S50);
    bool _S51;
    if(tn_0 > slide_cap_0)
    {
        _S51 = tn_0 > 0.0f;
    }
    else
    {
        _S51 = false;
    }
    if(_S51)
    {
        float2 dir_0 = trial_1 / float2(tn_0) ;
        float dslip_0 = (tn_0 - slide_cap_0) / ks_0;
        float _S52 = dir_0.x;
        p_1.x = p_1.x + _S52 * dslip_0;
        float _S53 = dir_0.y;
        p_1.y = p_1.y + _S53 * dslip_0;
        (&c_0)->q_lin_1.x = _S52 * slide_cap_0;
        (&c_0)->q_lin_1.y = _S53 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_0)->q_lin_1.x = _S49;
        (&c_0)->q_lin_1.y = _S50;
        diss_1 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_1.z, slide_cap_0 * (float4(b_2->geom1_0) ).z);
    float _S54 = tq_0.x;
    float _S55 = tq_0.y;
    float diss_2 = diss_1 + abs(_S54) * abs(_S55);
    p_1.z = p_1.z + _S55;
    (&c_0)->q_ang_1.z = _S54;
    (&c_0)->energy_1 = energy_2 + 0.5f * (sq_0((&c_0)->q_lin_1.x) / ks_0 + sq_0((&c_0)->q_lin_1.y) / ks_0 + sq_0(_S54) / kt_0);
    (&c_0)->diss_0 = diss_2;
    (&c_0)->plastic_1 = p_1;
    return c_0;
}

float life_rate_0(const JointMaterial_natural_0 thread* mat_4, float s_0)
{
    if(s_0 <= 0.0f)
    {
        return 0.0f;
    }
    float4 _S56 = float4(mat_4->misc_0) ;
    float _S57 = _S56.y;
    return (_S57 + 1.0f) * pow(s_0, _S57) / _S56.z;
}

struct JointResponse_0
{
    float3 force_lin_0;
    float3 force_ang_0;
    JointState_0 state_0;
    float dissipated_1;
    float overshoot_0;
    float stored_0;
    bool disconnected_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_natural_0 thread* mat_5, const JointBond_natural_0 thread* b_3, const JointState_0 thread* state_1, float3 d_lin_1, float3 d_ang_1, float dt_0, bool fracture_0)
{
    float4 _S58 = float4(b_3->stiff0_0) ;
    float kn_2 = _S58.x;
    float ks_1 = _S58.y;
    float kb1_0 = _S58.z;
    float kb2_0 = _S58.w;
    float4 _S59 = float4(b_3->stiff1_0) ;
    float kt_1 = _S59.x;
    bool has_rebar_1 = (_S59.w) != 0.0f;
    uint4 _S60 = uint4(mat_5->kind_flags_0) ;
    uint kind_2 = _S60.x;
    uint flags_0 = _S60.y;
    bool softening_0 = (flags_0 & 1U) != 0U;
    thread JointState_0 st_1 = *state_1;
    bool _S61 = connected_0(state_1, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S62 = stress_measures_0(b_3, qe_lin_0, qe_ang_0);
    float _S63 = max(max(_S62.tension_0, _S62.shear_0), _S62.compression_0);
    bool _S64 = dt_0 > 0.0f;
    float dif_1;
    if(_S64)
    {
        float raw_0 = max((_S63 - (&st_1)->governing_stress_0) / dt_0, 0.0f) / (float4(mat_5->misc_0) ).w;
        float tau_0 = _S59.z;
        if((flags_0 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- dt_0 / tau_0);
        }
        else
        {
            dif_1 = min(dt_0 / tau_0, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S63;
    }
    if((flags_0 & 32U) != 0U)
    {
        float _S65 = dif_factor_0(mat_5, (&st_1)->strain_rate_0);
        dif_1 = _S65;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_3->geom1_0) ).w;
    float _S66 = weibull_0 * dif_1;
    float _S67 = fatigue_factor_0(mat_5, (&st_1)->fatigue_0);
    float multiplier_1 = _S66 * _S67;
    thread Measures_0 _S68 = _S62;
    float4 _S69 = failure_indices_0(mat_5, b_3, &_S68, multiplier_1);
    float _S70 = _S69.x;
    float _S71 = _S69.y;
    (&st_1)->utilization_0 = max(max(_S70, _S71), max(_S69.z, _S69.w));
    float _S72 = d_lin_1.x;
    float _S73 = d_lin_1.y;
    float _S74 = ks_1 * (sq_0(_S72) + sq_0(_S73)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S75 = d_lin_1.z;
    bool _S76 = _S75 > 0.0f;
    if(_S76)
    {
        dif_1 = kn_2 * sq_0(_S75);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S74 + dif_1);
    float psi_c_0;
    if(_S75 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S75);
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
    bool _S77;
    float3 qc_lin_0;
    if(fracture_0)
    {
        bool _S78 = _S70 >= _S71;
        if(_S78)
        {
            diss_contact_0 = _S70;
        }
        else
        {
            diss_contact_0 = _S71;
        }
        uint mode_ts_0;
        if(_S78)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
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
        uint mode_c_0;
        if(_S77)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = (float4(mat_5->energy_0) ).y;
            }
            else
            {
                psi_contact_0 = (float4(mat_5->energy_0) ).z;
            }
            if(softening_0)
            {
                intact_normal_0 = psi_contact_0 * (float4(b_3->geom0_0) ).x * diss_contact_0 * diss_contact_0 / psi_ts_0;
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
            float _S79 = inc_0.x;
            if(_S79 > ((&st_1)->damage_0))
            {
                Contact_0 _S80 = contact_part_0(mat_5, b_3, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
                float _S81 = max(_S80.energy_1 - (1.0f - (&st_1)->crush_0) * psi_c_0, 0.0f);
                float _S82 = max(inc_0.y - _S81 * (_S79 - (&st_1)->damage_0), 0.0f);
                float _S83 = max((psi_ts_0 - _S81) * (_S79 - (&st_1)->damage_0) - _S82, 0.0f);
                (&st_1)->damage_0 = _S79;
                (&st_1)->mode_0 = mode_ts_0;
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
        (&st_1)->kappa_0 = max((&st_1)->kappa_0, diss_contact_0);
        float _S84 = state_1->damage_0;
        if((state_1->damage_0) > 0.0f)
        {
            Contact_0 _S85 = contact_part_0(mat_5, b_3, state_1->crush_0, float3(state_1->plastic_x_0, state_1->plastic_y_0, state_1->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S84))  + _S85.q_ang_1 * float3(_S84) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S86 = stress_measures_0(b_3, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S87 = _S86;
        float4 _S88 = failure_indices_0(mat_5, b_3, &_S87, multiplier_1);
        float _S89 = _S88.z;
        float _S90 = _S88.w;
        bool _S91 = _S89 >= _S90;
        if(_S91)
        {
            psi_contact_0 = _S89;
        }
        else
        {
            psi_contact_0 = _S90;
        }
        if(_S91)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
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
                intact_normal_0 = (float4(mat_5->energy_0) ).w * (float4(b_3->geom0_0) ).x * psi_contact_0 * psi_contact_0 / psi_c_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_1)->ductility_c_0 = intact_normal_0;
            uint law_0;
            if(!softening_0)
            {
                law_0 = 0U;
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
                law_0 = mode_ts_0;
            }
            float2 inc_1 = damage_increment_0(law_0, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_0, psi_c_0);
            float _S92 = inc_1.x;
            if(_S92 > ((&st_1)->crush_0))
            {
                float _S93 = inc_1.y;
                float dissipated_3 = dissipated_2 + _S93;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S92 - (&st_1)->crush_0) - _S93, 0.0f);
                (&st_1)->crush_0 = _S92;
                (&st_1)->mode_0 = mode_c_0;
                if(_S92 >= 1.0f)
                {
                    _S77 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S77 = false;
                }
                if(_S77)
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
    float3 _S94 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S77 = (flags_0 & 8U) != 0U;
    }
    else
    {
        _S77 = false;
    }
    float3 qc_ang_0;
    if(!_S77)
    {
        Contact_0 _S95 = contact_part_0(mat_5, b_3, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S95.plastic_1.x;
        (&st_1)->plastic_y_0 = _S95.plastic_1.y;
        (&st_1)->plastic_t_0 = _S95.plastic_1.z;
        diss_contact_0 = _S95.diss_0;
        qc_lin_0 = _S95.q_lin_1;
        qc_ang_0 = _S95.q_ang_1;
        psi_contact_0 = _S95.energy_1;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S94;
        qc_ang_0 = _S94;
        psi_contact_0 = 0.0f;
    }
    float dissipated_5 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S76)
    {
        intact_normal_0 = kn_2 * _S75;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_2 * _S75;
    }
    float _S96 = 1.0f - dmg_0;
    float3 force_lin_1 = float3(_S96 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S96 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S96 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_1 = qe_ang_0 * float3(_S96)  + qc_ang_0 * float3(dmg_0) ;
    float stored_1 = _S96 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S77 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S77 = false;
    }
    float stored_2;
    float3 force_lin_2;
    if(_S77)
    {
        float4 _S97 = float4(b_3->rebar0_0) ;
        float k_axial_0 = _S97.x;
        float k_dowel_0 = _S97.y;
        float yield_force_0 = _S97.z;
        float dowel_capacity_0 = _S97.w;
        float2 nr_0 = return_map_0(k_axial_0, _S75, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S72, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S73, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S98 = nr_0.y;
        float _S99 = v1_0.y;
        float _S100 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S98) + dowel_capacity_0 * (abs(_S99) + abs(_S100));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S98;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S99;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S100;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_6 = dissipated_5 + work_0;
        float _S101 = nr_0.x;
        float _S102 = v1_0.x;
        float _S103 = v2_0.x;
        float elastic_0 = 0.5f * (sq_0(_S101) / k_axial_0 + (sq_0(_S102) + sq_0(_S103)) / k_dowel_0);
        if(fracture_0)
        {
            _S77 = ((&st_1)->rebar_work_0) >= ((float4(b_3->rebar1_0) ).x);
        }
        else
        {
            _S77 = false;
        }
        if(_S77)
        {
            (&st_1)->rebar_broken_0 = 1.0f;
            float dissipated_7 = dissipated_6 + elastic_0;
            force_lin_2 = force_lin_1;
            dissipated_2 = dissipated_7;
            stored_2 = stored_1;
        }
        else
        {
            float stored_3 = stored_1 + elastic_0;
            force_lin_2 = force_lin_1 + float3(_S102, _S103, _S101);
            dissipated_2 = dissipated_6;
            stored_2 = stored_3;
        }
    }
    else
    {
        force_lin_2 = force_lin_1;
        dissipated_2 = dissipated_5;
        stored_2 = stored_1;
    }
    if(fracture_0)
    {
        _S77 = _S64;
    }
    else
    {
        _S77 = false;
    }
    if(_S77)
    {
        _S77 = (flags_0 & 64U) != 0U;
    }
    else
    {
        _S77 = false;
    }
    if(_S77)
    {
        Measures_0 _S104 = stress_measures_0(b_3, force_lin_2, force_ang_1);
        thread Measures_0 _S105 = _S104;
        float4 _S106 = failure_indices_0(mat_5, b_3, &_S105, weibull_0);
        float _S107 = life_rate_0(mat_5, max(max(_S106.x, _S106.y), _S106.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S107 * dt_0, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_2;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_0 = force_lin_2;
    (&resp_0)->force_ang_0 = force_ang_1;
    (&resp_0)->state_0 = st_1;
    (&resp_0)->dissipated_1 = dissipated_2;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_0 = stored_2;
    if(_S61)
    {
        thread JointState_0 _S108 = st_1;
        bool _S109 = connected_0(&_S108, has_rebar_1);
        _S77 = !_S109;
    }
    else
    {
        _S77 = false;
    }
    (&resp_0)->disconnected_0 = _S77;
    (&resp_0)->measures_0 = _S62;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_4, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S110 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_0;
    if(compressed_0)
    {
        contact_0 = _S110;
    }
    else
    {
        contact_0 = 0.0f;
    }
    float _S111 = 1.0f - _S110;
    float _S112 = max(_S111 + contact_0, 9.99999997475242708e-07f);
    float normal_0;
    if(compressed_0)
    {
        normal_0 = max(1.0f - st_2->crush_0, 9.99999997475242708e-07f);
    }
    else
    {
        normal_0 = max(_S111, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S112, _S112, normal_0);
    *f_ang_0 = float3(_S112) ;
    bool _S113;
    if(((float4(b_4->stiff1_0) ).w) != 0.0f)
    {
        _S113 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S113 = false;
    }
    if(_S113)
    {
        float4 _S114 = float4(b_4->rebar0_0) ;
        float4 _S115 = float4(b_4->stiff0_0) ;
        (*f_lin_0).z = (*f_lin_0).z + _S114.x / _S115.x;
        float _S116 = _S114.y;
        float _S117 = _S115.y;
        (*f_lin_0).x = (*f_lin_0).x + _S116 / _S117;
        (*f_lin_0).y = (*f_lin_0).y + _S116 / _S117;
    }
    return;
}

struct TestParams_0
{
    uint count_2;
    uint pad0_0;
    uint pad1_0;
    uint pad2_0;
};

struct KernelContext_0
{
    TestParams_0 constant* params_0;
    JointBond_natural_0 device* bonds_0;
    JointMaterial_natural_0 device* materials_0;
    packed_float4 device* inputs_0;
    JointState_0 device* states_in_0;
    JointState_0 device* states_out_0;
    packed_float4 device* outputs_0;
};

[[kernel]] void joint_eval_test(uint3 id_0 [[thread_position_in_grid]], TestParams_0 constant* params_1 [[buffer(0)]], JointBond_natural_0 device* bonds_1 [[buffer(2)]], JointMaterial_natural_0 device* materials_1 [[buffer(1)]], packed_float4 device* inputs_1 [[buffer(4)]], JointState_0 device* states_in_1 [[buffer(3)]], JointState_0 device* states_out_1 [[buffer(5)]], packed_float4 device* outputs_1 [[buffer(6)]])
{
    thread KernelContext_0 kernelContext_0;
    (&kernelContext_0)->params_0 = params_1;
    (&kernelContext_0)->bonds_0 = bonds_1;
    (&kernelContext_0)->materials_0 = materials_1;
    (&kernelContext_0)->inputs_0 = inputs_1;
    (&kernelContext_0)->states_in_0 = states_in_1;
    (&kernelContext_0)->states_out_0 = states_out_1;
    (&kernelContext_0)->outputs_0 = outputs_1;
    uint i_2 = id_0.x;
    if(i_2 >= (params_1->count_2))
    {
        return;
    }
    JointBond_natural_0 b_5 = (&kernelContext_0)->bonds_0[i_2];
    thread JointBond_natural_0 _S118 = b_5;
    uint _S119 = 2U * i_2;
    float4 _S120 = float4(*((&kernelContext_0)->inputs_0+_S119)) ;
    float4 _S121 = float4(*((&kernelContext_0)->inputs_0+(_S119 + 1U))) ;
    JointState_0 _S122 = (&kernelContext_0)->states_in_0[i_2];
    float3 _S123 = _S120.xyz;
    float3 _S124 = _S121.xyz;
    float _S125 = _S120.w;
    bool _S126 = (_S121.w) != 0.0f;
    thread JointMaterial_natural_0 _S127 = (&kernelContext_0)->materials_0[(uint4((&_S118)->ids_0) ).x];
    _S118 = b_5;
    thread JointState_0 _S128 = _S122;
    JointResponse_0 _S129 = joint_evaluate_0(&_S127, &_S118, &_S128, _S123, _S124, _S125, _S126);
    thread JointState_0 _S130 = _S129.state_0;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S118, &_S130, _S123, &f_lin_1, &f_ang_1);
    *((&kernelContext_0)->states_out_0+i_2) = _S129.state_0;
    uint _S131 = 5U * i_2;
    *((&kernelContext_0)->outputs_0+_S131) = packed_float4(float4(_S129.force_lin_0, _S129.dissipated_1)) ;
    *((&kernelContext_0)->outputs_0+(_S131 + 1U)) = packed_float4(float4(_S129.force_ang_0, _S129.overshoot_0)) ;
    *((&kernelContext_0)->outputs_0+(_S131 + 2U)) = packed_float4(float4(f_lin_1, _S129.stored_0)) ;
    packed_float4 device* _S132 = (&kernelContext_0)->outputs_0+(_S131 + 3U);
    float3 _S133 = f_ang_1;
    float _S134;
    if(_S129.disconnected_0)
    {
        _S134 = 1.0f;
    }
    else
    {
        _S134 = 0.0f;
    }
    *_S132 = packed_float4(float4(_S133, _S134)) ;
    *((&kernelContext_0)->outputs_0+(_S131 + 4U)) = packed_float4(float4(_S129.measures_0.tension_0, _S129.measures_0.shear_0, _S129.measures_0.compression_0, _S129.measures_0.compressive_force_0)) ;
    return;
}

