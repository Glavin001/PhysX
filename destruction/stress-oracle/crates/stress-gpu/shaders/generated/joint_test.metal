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
        float ki_0 = kn_1 * (1.0f - crush_1) / 36.0f;
        float _S47 = d_ang_0.x;
        float _S48 = d_ang_0.y;
        float spread_0 = abs(_S47) * 0.4166666567325592f * w1_2 + abs(_S48) * 0.4166666567325592f * w0_2;
        float _S49 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S49) + spread_0);
        if((_S49 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_2 = 0.0f;
        }
        else
        {
            if((_S49 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S50 = ki_0 * _S47 * i2_0;
                float _S51 = ki_0 * _S48 * i1_0;
                float _S52 = 0.5f * ki_0 * (36.0f * _S49 * _S49 + _S47 * _S47 * i2_0 + _S48 * _S48 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S49;
                m1_0 = _S50;
                m2_0 = _S51;
                energy_2 = _S52;
            }
            else
            {
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
                    float _S53 = ((float(i_1) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                        float di_0 = _S49 + _S47 * s2_0 - _S48 * _S53;
                        if(di_0 < 0.0f)
                        {
                            float f_2 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_2 * s2_0;
                            float m2_2 = m2_0 - f_2 * _S53;
                            float energy_4 = energy_2 + 0.5f * ki_0 * di_0 * di_0;
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
        }
    }
    float nc_0 = - nc_sum_0;
    thread float3 p_1 = plastic_2;
    (&c_0)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_0)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = (float4(mat_3->strength_0) ).w * nc_0;
    float _S54 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S55 = ks_0 * (d_lin_0.y - plastic_2.y);
    float2 trial_1 = float2(_S54, _S55);
    float tn_0 = sqrt(_S54 * _S54 + _S55 * _S55);
    bool _S56;
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
        float2 dir_0 = trial_1 / float2(tn_0) ;
        float dslip_0 = (tn_0 - slide_cap_0) / ks_0;
        float _S57 = dir_0.x;
        p_1.x = p_1.x + _S57 * dslip_0;
        float _S58 = dir_0.y;
        p_1.y = p_1.y + _S58 * dslip_0;
        (&c_0)->q_lin_1.x = _S57 * slide_cap_0;
        (&c_0)->q_lin_1.y = _S58 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_0)->q_lin_1.x = _S54;
        (&c_0)->q_lin_1.y = _S55;
        diss_1 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_1.z, slide_cap_0 * (float4(b_2->geom1_0) ).z);
    float _S59 = tq_0.x;
    float _S60 = tq_0.y;
    float diss_2 = diss_1 + abs(_S59) * abs(_S60);
    p_1.z = p_1.z + _S60;
    (&c_0)->q_ang_1.z = _S59;
    (&c_0)->energy_1 = energy_2 + 0.5f * (sq_0((&c_0)->q_lin_1.x) / ks_0 + sq_0((&c_0)->q_lin_1.y) / ks_0 + sq_0(_S59) / kt_0);
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
    float4 _S61 = float4(mat_4->misc_0) ;
    float _S62 = _S61.y;
    return (_S62 + 1.0f) * pow(s_0, _S62) / _S61.z;
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
    float4 _S63 = float4(b_3->stiff0_0) ;
    float kn_2 = _S63.x;
    float ks_1 = _S63.y;
    float kb1_0 = _S63.z;
    float kb2_0 = _S63.w;
    float4 _S64 = float4(b_3->stiff1_0) ;
    float kt_1 = _S64.x;
    bool has_rebar_1 = (_S64.w) != 0.0f;
    uint4 _S65 = uint4(mat_5->kind_flags_0) ;
    uint kind_2 = _S65.x;
    uint flags_0 = _S65.y;
    bool softening_0 = (flags_0 & 1U) != 0U;
    thread JointState_0 st_1 = *state_1;
    bool _S66 = connected_0(state_1, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S67 = stress_measures_0(b_3, qe_lin_0, qe_ang_0);
    float _S68 = max(max(_S67.tension_0, _S67.shear_0), _S67.compression_0);
    bool _S69 = dt_0 > 0.0f;
    float dif_1;
    if(_S69)
    {
        float raw_0 = max((_S68 - (&st_1)->governing_stress_0) / dt_0, 0.0f) / (float4(mat_5->misc_0) ).w;
        float tau_0 = _S64.z;
        if((flags_0 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- dt_0 / tau_0);
        }
        else
        {
            dif_1 = min(dt_0 / tau_0, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S68;
    }
    if((flags_0 & 32U) != 0U)
    {
        float _S70 = dif_factor_0(mat_5, (&st_1)->strain_rate_0);
        dif_1 = _S70;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_3->geom1_0) ).w;
    float _S71 = weibull_0 * dif_1;
    float _S72 = fatigue_factor_0(mat_5, (&st_1)->fatigue_0);
    float multiplier_1 = _S71 * _S72;
    thread Measures_0 _S73 = _S67;
    float4 _S74 = failure_indices_0(mat_5, b_3, &_S73, multiplier_1);
    float _S75 = _S74.x;
    float _S76 = _S74.y;
    (&st_1)->utilization_0 = max(max(_S75, _S76), max(_S74.z, _S74.w));
    float _S77 = d_lin_1.x;
    float _S78 = d_lin_1.y;
    float _S79 = ks_1 * (sq_0(_S77) + sq_0(_S78)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S80 = d_lin_1.z;
    bool _S81 = _S80 > 0.0f;
    if(_S81)
    {
        dif_1 = kn_2 * sq_0(_S80);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S79 + dif_1);
    float psi_c_0;
    if(_S80 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S80);
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
    bool _S82;
    float3 qc_lin_0;
    if(fracture_0)
    {
        bool _S83 = _S75 >= _S76;
        if(_S83)
        {
            diss_contact_0 = _S75;
        }
        else
        {
            diss_contact_0 = _S76;
        }
        uint mode_ts_0;
        if(_S83)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S82 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S82 = false;
        }
        if(_S82)
        {
            _S82 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S82 = false;
        }
        uint mode_c_0;
        if(_S82)
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
            float _S84 = inc_0.x;
            if(_S84 > ((&st_1)->damage_0))
            {
                Contact_0 _S85 = contact_part_0(mat_5, b_3, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
                float _S86 = max(_S85.energy_1 - (1.0f - (&st_1)->crush_0) * psi_c_0, 0.0f);
                float _S87 = max(inc_0.y - _S86 * (_S84 - (&st_1)->damage_0), 0.0f);
                float _S88 = max((psi_ts_0 - _S86) * (_S84 - (&st_1)->damage_0) - _S87, 0.0f);
                (&st_1)->damage_0 = _S84;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_2 = _S87;
                overshoot_1 = _S88;
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
        float _S89 = state_1->damage_0;
        if((state_1->damage_0) > 0.0f)
        {
            Contact_0 _S90 = contact_part_0(mat_5, b_3, state_1->crush_0, float3(state_1->plastic_x_0, state_1->plastic_y_0, state_1->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S89))  + _S90.q_ang_1 * float3(_S89) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S91 = stress_measures_0(b_3, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S92 = _S91;
        float4 _S93 = failure_indices_0(mat_5, b_3, &_S92, multiplier_1);
        float _S94 = _S93.z;
        float _S95 = _S93.w;
        bool _S96 = _S94 >= _S95;
        if(_S96)
        {
            psi_contact_0 = _S94;
        }
        else
        {
            psi_contact_0 = _S95;
        }
        if(_S96)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S82 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S82 = false;
        }
        if(_S82)
        {
            _S82 = psi_c_0 > 0.0f;
        }
        else
        {
            _S82 = false;
        }
        if(_S82)
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
            float _S97 = inc_1.x;
            if(_S97 > ((&st_1)->crush_0))
            {
                float _S98 = inc_1.y;
                float dissipated_3 = dissipated_2 + _S98;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S97 - (&st_1)->crush_0) - _S98, 0.0f);
                (&st_1)->crush_0 = _S97;
                (&st_1)->mode_0 = mode_c_0;
                if(_S97 >= 1.0f)
                {
                    _S82 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S82 = false;
                }
                if(_S82)
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
    float3 _S99 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S82 = (flags_0 & 8U) != 0U;
    }
    else
    {
        _S82 = false;
    }
    float3 qc_ang_0;
    if(!_S82)
    {
        Contact_0 _S100 = contact_part_0(mat_5, b_3, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S100.plastic_1.x;
        (&st_1)->plastic_y_0 = _S100.plastic_1.y;
        (&st_1)->plastic_t_0 = _S100.plastic_1.z;
        diss_contact_0 = _S100.diss_0;
        qc_lin_0 = _S100.q_lin_1;
        qc_ang_0 = _S100.q_ang_1;
        psi_contact_0 = _S100.energy_1;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S99;
        qc_ang_0 = _S99;
        psi_contact_0 = 0.0f;
    }
    float dissipated_5 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S81)
    {
        intact_normal_0 = kn_2 * _S80;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_2 * _S80;
    }
    float _S101 = 1.0f - dmg_0;
    float3 force_lin_1 = float3(_S101 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S101 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S101 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_1 = qe_ang_0 * float3(_S101)  + qc_ang_0 * float3(dmg_0) ;
    float stored_1 = _S101 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S82 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S82 = false;
    }
    float stored_2;
    float3 force_lin_2;
    if(_S82)
    {
        float4 _S102 = float4(b_3->rebar0_0) ;
        float k_axial_0 = _S102.x;
        float k_dowel_0 = _S102.y;
        float yield_force_0 = _S102.z;
        float dowel_capacity_0 = _S102.w;
        float2 nr_0 = return_map_0(k_axial_0, _S80, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S77, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S78, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S103 = nr_0.y;
        float _S104 = v1_0.y;
        float _S105 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S103) + dowel_capacity_0 * (abs(_S104) + abs(_S105));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S103;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S104;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S105;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_6 = dissipated_5 + work_0;
        float _S106 = nr_0.x;
        float _S107 = v1_0.x;
        float _S108 = v2_0.x;
        float elastic_0 = 0.5f * (sq_0(_S106) / k_axial_0 + (sq_0(_S107) + sq_0(_S108)) / k_dowel_0);
        if(fracture_0)
        {
            _S82 = ((&st_1)->rebar_work_0) >= ((float4(b_3->rebar1_0) ).x);
        }
        else
        {
            _S82 = false;
        }
        if(_S82)
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
            force_lin_2 = force_lin_1 + float3(_S107, _S108, _S106);
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
        _S82 = _S69;
    }
    else
    {
        _S82 = false;
    }
    if(_S82)
    {
        _S82 = (flags_0 & 64U) != 0U;
    }
    else
    {
        _S82 = false;
    }
    if(_S82)
    {
        Measures_0 _S109 = stress_measures_0(b_3, force_lin_2, force_ang_1);
        thread Measures_0 _S110 = _S109;
        float4 _S111 = failure_indices_0(mat_5, b_3, &_S110, weibull_0);
        float _S112 = life_rate_0(mat_5, max(max(_S111.x, _S111.y), _S111.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S112 * dt_0, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_2;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_0 = force_lin_2;
    (&resp_0)->force_ang_0 = force_ang_1;
    (&resp_0)->state_0 = st_1;
    (&resp_0)->dissipated_1 = dissipated_2;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_0 = stored_2;
    if(_S66)
    {
        thread JointState_0 _S113 = st_1;
        bool _S114 = connected_0(&_S113, has_rebar_1);
        _S82 = !_S114;
    }
    else
    {
        _S82 = false;
    }
    (&resp_0)->disconnected_0 = _S82;
    (&resp_0)->measures_0 = _S67;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_4, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S115 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_0;
    if(compressed_0)
    {
        contact_0 = _S115;
    }
    else
    {
        contact_0 = 0.0f;
    }
    float _S116 = 1.0f - _S115;
    float _S117 = max(_S116 + contact_0, 9.99999997475242708e-07f);
    float normal_0;
    if(compressed_0)
    {
        normal_0 = max(1.0f - st_2->crush_0, 9.99999997475242708e-07f);
    }
    else
    {
        normal_0 = max(_S116, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S117, _S117, normal_0);
    *f_ang_0 = float3(_S117) ;
    bool _S118;
    if(((float4(b_4->stiff1_0) ).w) != 0.0f)
    {
        _S118 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S118 = false;
    }
    if(_S118)
    {
        float4 _S119 = float4(b_4->rebar0_0) ;
        float4 _S120 = float4(b_4->stiff0_0) ;
        (*f_lin_0).z = (*f_lin_0).z + _S119.x / _S120.x;
        float _S121 = _S119.y;
        float _S122 = _S120.y;
        (*f_lin_0).x = (*f_lin_0).x + _S121 / _S122;
        (*f_lin_0).y = (*f_lin_0).y + _S121 / _S122;
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
    thread JointBond_natural_0 _S123 = b_5;
    uint _S124 = 2U * i_2;
    float4 _S125 = float4(*((&kernelContext_0)->inputs_0+_S124)) ;
    float4 _S126 = float4(*((&kernelContext_0)->inputs_0+(_S124 + 1U))) ;
    JointState_0 _S127 = (&kernelContext_0)->states_in_0[i_2];
    float3 _S128 = _S125.xyz;
    float3 _S129 = _S126.xyz;
    float _S130 = _S125.w;
    bool _S131 = (_S126.w) != 0.0f;
    thread JointMaterial_natural_0 _S132 = (&kernelContext_0)->materials_0[(uint4((&_S123)->ids_0) ).x];
    _S123 = b_5;
    thread JointState_0 _S133 = _S127;
    JointResponse_0 _S134 = joint_evaluate_0(&_S132, &_S123, &_S133, _S128, _S129, _S130, _S131);
    thread JointState_0 _S135 = _S134.state_0;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S123, &_S135, _S128, &f_lin_1, &f_ang_1);
    *((&kernelContext_0)->states_out_0+i_2) = _S134.state_0;
    uint _S136 = 5U * i_2;
    *((&kernelContext_0)->outputs_0+_S136) = packed_float4(float4(_S134.force_lin_0, _S134.dissipated_1)) ;
    *((&kernelContext_0)->outputs_0+(_S136 + 1U)) = packed_float4(float4(_S134.force_ang_0, _S134.overshoot_0)) ;
    *((&kernelContext_0)->outputs_0+(_S136 + 2U)) = packed_float4(float4(f_lin_1, _S134.stored_0)) ;
    packed_float4 device* _S137 = (&kernelContext_0)->outputs_0+(_S136 + 3U);
    float3 _S138 = f_ang_1;
    float _S139;
    if(_S134.disconnected_0)
    {
        _S139 = 1.0f;
    }
    else
    {
        _S139 = 0.0f;
    }
    *_S137 = packed_float4(float4(_S138, _S139)) ;
    *((&kernelContext_0)->outputs_0+(_S136 + 4U)) = packed_float4(float4(_S134.measures_0.tension_0, _S134.measures_0.shear_0, _S134.measures_0.compression_0, _S134.measures_0.compressive_force_0)) ;
    return;
}

