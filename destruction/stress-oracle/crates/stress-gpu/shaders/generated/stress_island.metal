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
    packed_uint4 probes_0;
    packed_float4 energy_0;
};

struct Params_0
{
    float4 gravity_0;
    float dt_0;
    uint fracture_0;
    uint rigid_motion_loads_0;
    uint step_start_0;
    float t_hi_0;
    float t_lo_0;
    uint probe_base_0;
    uint probe_stride_0;
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
    packed_uint4 load_range_0;
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
    float4 energy_1;
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
    packed_float4 device* loads_0;
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

float time_since_0(float4 origin_0, uint k_0, float dt_1, KernelContext_0 thread* kernelContext_0)
{
    return kernelContext_0->params_0->t_hi_0 - origin_0.x + (kernelContext_0->params_0->t_lo_0 - origin_0.y) + float(k_0) * dt_1;
}

float table_eval_0(uint offset_0, uint count_0, float tau_0, KernelContext_0 thread* kernelContext_1)
{
    float4 _S1 = float4(*(kernelContext_1->loads_0+offset_0)) ;
    if(tau_0 <= (_S1.x))
    {
        return _S1.y;
    }
    uint i_0 = 1U;
    for(;;)
    {
        if(i_0 < count_0)
        {
        }
        else
        {
            break;
        }
        uint _S2 = offset_0 + i_0;
        float4 _S3 = float4(*(kernelContext_1->loads_0+_S2)) ;
        float _S4 = _S3.x;
        if(tau_0 <= _S4)
        {
            float4 _S5 = float4(*(kernelContext_1->loads_0+(_S2 - 1U))) ;
            float _S6 = _S5.x;
            float _S7 = _S5.y;
            return _S7 + (tau_0 - _S6) / max(_S4 - _S6, 1.00000000317107685e-30f) * (_S3.y - _S7);
        }
        i_0 = i_0 + 1U;
    }
    return (float4(*(kernelContext_1->loads_0+(offset_0 + count_0 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_1, float dt_2, float shift_0, KernelContext_0 thread* kernelContext_2)
{
    uint _S8 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_2->loads_0+_S8)) )));
    float4 _S9 = float4(*(kernelContext_2->loads_0+(_S8 + 3U))) ;
    float4 _S10 = float4(*(kernelContext_2->loads_0+(_S8 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S9.z;
    }
    float _S11 = time_since_0(_S9, k_1, dt_2, kernelContext_2);
    float tau_1 = _S11 + shift_0;
    float shape_0;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_0 = 0.0f;
        }
        else
        {
            float _S12 = _S10.x;
            if(tau_1 >= _S12)
            {
                shape_0 = _S10.y;
            }
            else
            {
                shape_0 = _S10.y * tau_1 / _S12;
            }
        }
        return shape_0;
    }
    bool _S13;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S13 = true;
        }
        else
        {
            _S13 = tau_1 > (_S10.x);
        }
        if(_S13)
        {
            shape_0 = 0.0f;
        }
        else
        {
            shape_0 = _S10.y * sin(3.14159274101257324f * tau_1 / _S10.x);
        }
        return shape_0;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S10.y;
        if(sn_0 < 0.0f)
        {
            _S13 = true;
        }
        else
        {
            _S13 = sn_0 > 1.0f;
        }
        if(_S13)
        {
            shape_0 = 0.0f;
        }
        else
        {
            shape_0 = _S10.x * (1.0f - sn_0) * exp(- _S10.z * sn_0);
        }
        return shape_0;
    }
    if(kind_0 == 4U)
    {
        float _S14 = table_eval_0(info_2.w, (as_type<uint>((_S10.x))), tau_1, kernelContext_2);
        return _S14;
    }
    if(kind_0 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S10.x;
        if(sn_1 < 0.0f)
        {
            _S13 = true;
        }
        else
        {
            _S13 = sn_1 > 1.0f;
        }
        if(_S13)
        {
            shape_0 = 0.0f;
        }
        else
        {
            shape_0 = (1.0f - sn_1) * exp(- _S10.y * sn_1);
        }
        float clearing_0 = _S9.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S15 = _S10.w;
        return (_S15 + (_S10.z - _S15) * relax_0) * shape_0;
    }
    float _S16 = _S10.x;
    if(_S16 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S16, 0.0f, 1.0f);
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

void group_sum2_0(uint tid_0, float3 thread* a_0, float3 thread* b_0, KernelContext_0 thread* kernelContext_3)
{
    (*kernelContext_3->g_red_a_0)[tid_0] = float4(*a_0, 0.0f);
    (*kernelContext_3->g_red_b_0)[tid_0] = float4(*b_0, 0.0f);
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
            uint _S17 = tid_0 + s_0;
            (*kernelContext_3->g_red_a_0)[tid_0] = (*kernelContext_3->g_red_a_0)[tid_0] + (*kernelContext_3->g_red_a_0)[_S17];
            (*kernelContext_3->g_red_b_0)[tid_0] = (*kernelContext_3->g_red_b_0)[tid_0] + (*kernelContext_3->g_red_b_0)[_S17];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        s_0 = s_0 >> 1U;
    }
    *a_0 = (*kernelContext_3->g_red_a_0)[int(0)].xyz;
    *b_0 = (*kernelContext_3->g_red_b_0)[int(0)].xyz;
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
    thread Quat_0 _S18 = c_0;
    float3 _S19 = rotate_0(&_S18, v_2);
    return _S19;
}

float3 inverse_rotate_1(const Quat_0 thread* q_4, float3 v_3)
{
    thread Quat_0 c_1;
    (&c_1)->w_0 = q_4->w_0;
    (&c_1)->x_0 = - q_4->x_0;
    (&c_1)->y_0 = - q_4->y_0;
    (&c_1)->z_0 = - q_4->z_0;
    thread Quat_0 _S20 = c_1;
    float3 _S21 = rotate_0(&_S20, v_3);
    return _S21;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_4)
{
    return float3(dot(r0_0.xyz, v_4), dot(r1_0.xyz, v_4), dot(r2_0.xyz, v_4));
}

float3 world_mul_0(const Quat_0 thread* q_5, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_5)
{
    float3 _S22 = inverse_rotate_1(q_5, v_5);
    float3 _S23 = rotate_1(q_5, rows_mul_0(r0_1, r1_1, r2_1, _S22));
    return _S23;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S24;
    if((st_0->damage_0) < 1.0f)
    {
        _S24 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S24 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S24 = false;
        }
    }
    return _S24;
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
    float4 _S25 = float4(b_1->geom0_0) ;
    float area_0 = _S25.x;
    float _S26 = q_lin_0.z;
    float axial_0 = _S26 / area_0;
    float4 _S27 = float4(b_1->geom1_0) ;
    float bending_0 = abs(q_ang_0.x) / _S27.x + abs(q_ang_0.y) / _S27.y;
    float _S28 = q_lin_0.x;
    float _S29 = q_lin_0.y;
    float shear_1 = sqrt(_S28 * _S28 + _S29 * _S29) / area_0 + abs(q_ang_0.z) / _S25.w;
    thread Measures_0 m_1;
    (&m_1)->tension_0 = axial_0 + bending_0;
    (&m_1)->shear_0 = shear_1;
    float _S30 = - axial_0;
    (&m_1)->normal_compression_0 = max(_S30, 0.0f);
    (&m_1)->compression_0 = _S30 + bending_0;
    (&m_1)->compressive_force_0 = max(- _S26, 0.0f);
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
    float4 _S31 = mat_0->dif_0;
    float ref_0 = mat_0->dif_0.x;
    if(r_1 <= ref_0)
    {
        return 1.0f;
    }
    float _S32 = _S31.z;
    float f_0;
    if(r_1 <= _S32)
    {
        f_0 = pow(r_1 / ref_0, _S31.y);
    }
    else
    {
        f_0 = pow(_S32 / ref_0, _S31.y) * pow(r_1 / _S32, _S31.w);
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
    float _S33 = min(mat_2->strength_0.z * multiplier_0 + mat_2->strength_0.w * m_2->normal_compression_0, mat_2->energy_1.x * multiplier_0);
    thread float4 idx_0;
    idx_0.x = max(m_2->tension_0 / (mat_2->strength_0.x * multiplier_0), 0.0f);
    float _S34;
    if(_S33 > 0.0f)
    {
        _S34 = m_2->shear_0 / _S33;
    }
    else
    {
        _S34 = infinity_0();
    }
    idx_0.y = _S34;
    idx_0.z = max(m_2->compression_0 / fc_0, 0.0f);
    float _S35 = (float4(b_2->stiff1_0) ).y;
    if(_S35 > 0.0f)
    {
        _S34 = m_2->compressive_force_0 / _S35;
    }
    else
    {
        _S34 = 0.0f;
    }
    idx_0.w = _S34;
    return idx_0;
}

float sq_0(float x_2)
{
    return x_2 * x_2;
}

float damage_law_0(uint kind_1, float kappa_1, float r_2)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == 0U)
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

float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_3, float d_old_0, float psi_0)
{
    float _S36 = max(damage_law_0(kind_2, lambda_0, r_3), d_old_0);
    bool _S37;
    if(_S36 <= d_old_0)
    {
        _S37 = true;
    }
    else
    {
        _S37 = d_old_0 >= 1.0f;
    }
    if(_S37)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = psi_0 / (lambda_0 * lambda_0);
    float _S38 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_3 > 1.0f)
        {
            return float2(_S36, u0_0 * r_3 / (r_3 - 1.0f) * max(min(lambda_0, r_3) - min(_S38, r_3), 0.0f));
        }
        return float2(_S36, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_3 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S38, ku_0), 0.0f);
    float snap_0;
    if(_S36 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S36, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_1;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S39 = - h0_0;
    float _S40 = - h1_0;
    array<float2, int(4)> _S41 = { { float2(_S39, _S40), float2(h0_0, _S40), float2(h0_0, h1_0), float2(_S39, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_1 = 0U;
    uint count_2 = 0U;
    for(;;)
    {
        if(i_1 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S42 = i_1;
        uint _S43 = i_1 + 1U;
        uint _S44 = _S43 % 4U;
        float _S45 = _S41[i_1].y;
        float _S46 = _S41[i_1].x;
        float fp_0 = dz_0 + ax_0 * _S45 - ay_0 * _S46;
        float _S47 = _S41[_S44].y;
        float _S48 = _S41[_S44].x;
        float fq_0 = dz_0 + ax_0 * _S47 - ay_0 * _S48;
        bool _S49 = fp_0 < 0.0f;
        if(_S49)
        {
            uint _S50 = count_2 + 1U;
            poly_0[count_2] = _S41[_S42];
            count_1 = _S50;
        }
        else
        {
            count_1 = count_2;
        }
        if(_S49 != (fq_0 < 0.0f))
        {
            float t_2 = fp_0 / (fp_0 - fq_0);
            uint _S51 = count_1 + 1U;
            poly_0[count_1] = float2(_S46 + t_2 * (_S48 - _S46), _S45 + t_2 * (_S47 - _S45));
            count_2 = _S51;
        }
        else
        {
            count_2 = count_1;
        }
        i_1 = _S43;
    }
    count_1 = 0U;
    for(;;)
    {
        if(count_1 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_1] = 0.0f;
        count_1 = count_1 + 1U;
    }
    if(count_2 < 3U)
    {
        return;
    }
    float2 o_0 = poly_0[int(0)];
    i_1 = 0U;
    float a_1 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_1 < count_2)
        {
        }
        else
        {
            break;
        }
        float _S52 = o_0.x;
        float x0_0 = poly_0[i_1].x - _S52;
        float _S53 = o_0.y;
        float y0_0 = poly_0[i_1].y - _S53;
        uint _S54 = i_1 + 1U;
        uint _S55 = _S54 % count_2;
        float x1_0 = poly_0[_S55].x - _S52;
        float y1_0 = poly_0[_S55].y - _S53;
        float _S56 = x0_0 * y1_0;
        float _S57 = x1_0 * y0_0;
        float cr_0 = _S56 - _S57;
        float a_2 = a_1 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S56 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S57) * cr_0 / 24.0f;
        i_1 = _S54;
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
    float _S58 = a_1 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S58 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_1 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S58 * cy_0;
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
    float k_2 = kn_0 / (w0_1 * w1_1);
    float fc_1 = dz_1 + ax_1 * r_4[int(2)] - ay_1 * r_4[int(1)];
    float _S59 = a_3 * fc_1;
    float _S60 = - ay_1;
    return float4(k_2 * a_3 * fc_1, k_2 * (_S59 * r_4[int(2)] + (_S60 * r_4[int(5)] + ax_1 * r_4[int(4)])), - k_2 * (_S59 * r_4[int(1)] + (_S60 * r_4[int(3)] + ax_1 * r_4[int(5)])), 0.5f * k_2 * (_S59 * fc_1 + ay_1 * ay_1 * r_4[int(3)] + ax_1 * ax_1 * r_4[int(4)] - 2.0f * ax_1 * ay_1 * r_4[int(5)]));
}

float signum_0(float x_3)
{
    float _S61;
    if(((as_type<uint>((x_3))) & 2147483648U) != 0U)
    {
        _S61 = -1.0f;
    }
    else
    {
        _S61 = 1.0f;
    }
    return _S61;
}

float2 return_map_0(float k_3, float total_0, float plastic_0, float cap_0)
{
    float trial_0 = k_3 * (total_0 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_1 = cap_0 * signum_0(trial_0);
    return float2(f_1, (trial_0 - f_1) / k_3);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_2;
    float diss_0;
    float3 plastic_1;
};

Contact_0 contact_part_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_3, float crush_1, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_2;
    float3 _S62 = float3(0.0f) ;
    (&c_2)->q_lin_1 = _S62;
    (&c_2)->q_ang_1 = _S62;
    (&c_2)->energy_2 = 0.0f;
    (&c_2)->diss_0 = 0.0f;
    (&c_2)->plastic_1 = plastic_2;
    uint _S63 = mat_3->kind_flags_0.y;
    if((_S63 & 2U) == 0U)
    {
        return c_2;
    }
    float4 _S64 = float4(b_3->stiff0_0) ;
    float kn_1 = _S64.x;
    float ks_0 = _S64.y;
    float kt_0 = (float4(b_3->stiff1_0) ).x;
    float4 _S65 = float4(b_3->geom0_0) ;
    float w0_2 = _S65.y;
    float w1_2 = _S65.z;
    float diss_1;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S63 & 4U) != 0U)
    {
        float4 p_0 = no_tension_patch_0(kn_1 * (1.0f - crush_1), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S66 = p_0.y;
        float _S67 = p_0.z;
        float _S68 = p_0.w;
        nc_sum_0 = p_0.x;
        m1_0 = _S66;
        m2_0 = _S67;
        energy_3 = _S68;
    }
    else
    {
        float _S69 = kn_1 * (1.0f - crush_1) / 36.0f;
        uint i_2 = 0U;
        diss_1 = 0.0f;
        float m1_1 = 0.0f;
        float m2_1 = 0.0f;
        float energy_4 = 0.0f;
        for(;;)
        {
            if(i_2 < 6U)
            {
            }
            else
            {
                break;
            }
            float _S70 = ((float(i_2) + 0.5f) / 6.0f - 0.5f) * w0_2;
            uint j_0 = 0U;
            nc_sum_0 = diss_1;
            m1_0 = m1_1;
            m2_0 = m2_1;
            energy_3 = energy_4;
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
                float di_0 = d_lin_0.z + d_ang_0.x * s2_0 - d_ang_0.y * _S70;
                if(di_0 < 0.0f)
                {
                    float f_2 = _S69 * di_0;
                    float m1_2 = m1_0 + f_2 * s2_0;
                    float m2_2 = m2_0 - f_2 * _S70;
                    float energy_5 = energy_3 + 0.5f * _S69 * di_0 * di_0;
                    nc_sum_0 = nc_sum_0 + f_2;
                    m1_0 = m1_2;
                    m2_0 = m2_2;
                    energy_3 = energy_5;
                }
                j_0 = j_0 + 1U;
            }
            i_2 = i_2 + 1U;
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
    float nc_0 = - nc_sum_0;
    thread float3 p_1 = plastic_2;
    (&c_2)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_2)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_3->strength_0.w * nc_0;
    float _S71 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S72 = ks_0 * (d_lin_0.y - plastic_2.y);
    float2 trial_1 = float2(_S71, _S72);
    float tn_0 = sqrt(_S71 * _S71 + _S72 * _S72);
    bool _S73;
    if(tn_0 > slide_cap_0)
    {
        _S73 = tn_0 > 0.0f;
    }
    else
    {
        _S73 = false;
    }
    if(_S73)
    {
        float2 dir_0 = trial_1 / float2(tn_0) ;
        float dslip_0 = (tn_0 - slide_cap_0) / ks_0;
        float _S74 = dir_0.x;
        p_1.x = p_1.x + _S74 * dslip_0;
        float _S75 = dir_0.y;
        p_1.y = p_1.y + _S75 * dslip_0;
        (&c_2)->q_lin_1.x = _S74 * slide_cap_0;
        (&c_2)->q_lin_1.y = _S75 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_2)->q_lin_1.x = _S71;
        (&c_2)->q_lin_1.y = _S72;
        diss_1 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_1.z, slide_cap_0 * (float4(b_3->geom1_0) ).z);
    float _S76 = tq_0.x;
    float _S77 = tq_0.y;
    float diss_2 = diss_1 + abs(_S76) * abs(_S77);
    p_1.z = p_1.z + _S77;
    (&c_2)->q_ang_1.z = _S76;
    (&c_2)->energy_2 = energy_3 + 0.5f * (sq_0((&c_2)->q_lin_1.x) / ks_0 + sq_0((&c_2)->q_lin_1.y) / ks_0 + sq_0(_S76) / kt_0);
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
    float _S78 = mat_4->misc_0.y;
    return (_S78 + 1.0f) * pow(s_1, _S78) / mat_4->misc_0.z;
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

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_5, const JointBond_natural_0 thread* b_4, const JointState_0 thread* state_2, float3 d_lin_1, float3 d_ang_1, float dt_3, bool fracture_1)
{
    float4 _S79 = float4(b_4->stiff0_0) ;
    float kn_2 = _S79.x;
    float ks_1 = _S79.y;
    float kb1_0 = _S79.z;
    float kb2_0 = _S79.w;
    float4 _S80 = float4(b_4->stiff1_0) ;
    float kt_1 = _S80.x;
    bool has_rebar_1 = (_S80.w) != 0.0f;
    uint kind_3 = mat_5->kind_flags_0.x;
    uint flags_0 = mat_5->kind_flags_0.y;
    bool softening_0 = (flags_0 & 1U) != 0U;
    thread JointState_0 st_1 = *state_2;
    bool _S81 = connected_0(state_2, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S82 = stress_measures_0(b_4, qe_lin_0, qe_ang_0);
    float _S83 = max(max(_S82.tension_0, _S82.shear_0), _S82.compression_0);
    bool _S84 = dt_3 > 0.0f;
    float dif_1;
    if(_S84)
    {
        float raw_0 = max((_S83 - (&st_1)->governing_stress_0) / dt_3, 0.0f) / mat_5->misc_0.w;
        float tau_2 = _S80.z;
        if((flags_0 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- dt_3 / tau_2);
        }
        else
        {
            dif_1 = min(dt_3 / tau_2, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S83;
    }
    if((flags_0 & 32U) != 0U)
    {
        float _S85 = dif_factor_0(mat_5, (&st_1)->strain_rate_0);
        dif_1 = _S85;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_4->geom1_0) ).w;
    float _S86 = weibull_0 * dif_1;
    float _S87 = fatigue_factor_0(mat_5, (&st_1)->fatigue_0);
    float multiplier_1 = _S86 * _S87;
    thread Measures_0 _S88 = _S82;
    float4 _S89 = failure_indices_0(mat_5, b_4, &_S88, multiplier_1);
    float _S90 = _S89.x;
    float _S91 = _S89.y;
    (&st_1)->utilization_0 = max(max(_S90, _S91), max(_S89.z, _S89.w));
    float _S92 = d_lin_1.x;
    float _S93 = d_lin_1.y;
    float _S94 = ks_1 * (sq_0(_S92) + sq_0(_S93)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S95 = d_lin_1.z;
    bool _S96 = _S95 > 0.0f;
    if(_S96)
    {
        dif_1 = kn_2 * sq_0(_S95);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S94 + dif_1);
    float psi_c_0;
    if(_S95 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S95);
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
    bool _S97;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S98 = _S90 >= _S91;
        if(_S98)
        {
            diss_contact_0 = _S90;
        }
        else
        {
            diss_contact_0 = _S91;
        }
        uint mode_ts_0;
        if(_S98)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S97 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S97 = false;
        }
        if(_S97)
        {
            _S97 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S97 = false;
        }
        uint mode_c_0;
        if(_S97)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_5->energy_1.y;
            }
            else
            {
                psi_contact_0 = mat_5->energy_1.z;
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
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2 inc_0 = damage_increment_0(mode_c_0, (&st_1)->kappa_0, diss_contact_0, intact_normal_0, (&st_1)->damage_0, psi_ts_0);
            float _S99 = inc_0.x;
            if(_S99 > ((&st_1)->damage_0))
            {
                Contact_0 _S100 = contact_part_0(mat_5, b_4, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
                float _S101 = max(_S100.energy_2 - (1.0f - (&st_1)->crush_0) * psi_c_0, 0.0f);
                float _S102 = max(inc_0.y - _S101 * (_S99 - (&st_1)->damage_0), 0.0f);
                float _S103 = max((psi_ts_0 - _S101) * (_S99 - (&st_1)->damage_0) - _S102, 0.0f);
                (&st_1)->damage_0 = _S99;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_2 = _S102;
                overshoot_1 = _S103;
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
        float _S104 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S105 = contact_part_0(mat_5, b_4, state_2->crush_0, float3(state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S104))  + _S105.q_ang_1 * float3(_S104) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S106 = stress_measures_0(b_4, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S107 = _S106;
        float4 _S108 = failure_indices_0(mat_5, b_4, &_S107, multiplier_1);
        float _S109 = _S108.z;
        float _S110 = _S108.w;
        bool _S111 = _S109 >= _S110;
        if(_S111)
        {
            psi_contact_0 = _S109;
        }
        else
        {
            psi_contact_0 = _S110;
        }
        if(_S111)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S97 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S97 = false;
        }
        if(_S97)
        {
            _S97 = psi_c_0 > 0.0f;
        }
        else
        {
            _S97 = false;
        }
        if(_S97)
        {
            if(softening_0)
            {
                intact_normal_0 = mat_5->energy_1.w * (float4(b_4->geom0_0) ).x * psi_contact_0 * psi_contact_0 / psi_c_0;
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
                    mode_ts_0 = kind_3;
                }
                law_1 = mode_ts_0;
            }
            float2 inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_0, psi_c_0);
            float _S112 = inc_1.x;
            if(_S112 > ((&st_1)->crush_0))
            {
                float _S113 = inc_1.y;
                float dissipated_3 = dissipated_2 + _S113;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S112 - (&st_1)->crush_0) - _S113, 0.0f);
                (&st_1)->crush_0 = _S112;
                (&st_1)->mode_0 = mode_c_0;
                if(_S112 >= 1.0f)
                {
                    _S97 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S97 = false;
                }
                if(_S97)
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
    float3 _S114 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S97 = (flags_0 & 8U) != 0U;
    }
    else
    {
        _S97 = false;
    }
    float3 qc_ang_0;
    if(!_S97)
    {
        Contact_0 _S115 = contact_part_0(mat_5, b_4, (&st_1)->crush_0, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S115.plastic_1.x;
        (&st_1)->plastic_y_0 = _S115.plastic_1.y;
        (&st_1)->plastic_t_0 = _S115.plastic_1.z;
        diss_contact_0 = _S115.diss_0;
        qc_lin_0 = _S115.q_lin_1;
        qc_ang_0 = _S115.q_ang_1;
        psi_contact_0 = _S115.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S114;
        qc_ang_0 = _S114;
        psi_contact_0 = 0.0f;
    }
    float dissipated_5 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S96)
    {
        intact_normal_0 = kn_2 * _S95;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_2 * _S95;
    }
    float _S116 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S116 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S116 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S116 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S116)  + qc_ang_0 * float3(dmg_0) ;
    float stored_1 = _S116 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S97 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S97 = false;
    }
    float stored_2;
    float3 force_lin_3;
    if(_S97)
    {
        float4 _S117 = float4(b_4->rebar0_0) ;
        float k_axial_0 = _S117.x;
        float k_dowel_0 = _S117.y;
        float yield_force_0 = _S117.z;
        float dowel_capacity_0 = _S117.w;
        float2 nr_0 = return_map_0(k_axial_0, _S95, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S92, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S93, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S118 = nr_0.y;
        float _S119 = v1_0.y;
        float _S120 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S118) + dowel_capacity_0 * (abs(_S119) + abs(_S120));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S118;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S119;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S120;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_6 = dissipated_5 + work_0;
        float _S121 = nr_0.x;
        float _S122 = v1_0.x;
        float _S123 = v2_0.x;
        float elastic_0 = 0.5f * (sq_0(_S121) / k_axial_0 + (sq_0(_S122) + sq_0(_S123)) / k_dowel_0);
        if(fracture_1)
        {
            _S97 = ((&st_1)->rebar_work_0) >= ((float4(b_4->rebar1_0) ).x);
        }
        else
        {
            _S97 = false;
        }
        if(_S97)
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
            force_lin_3 = force_lin_2 + float3(_S122, _S123, _S121);
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
        _S97 = _S84;
    }
    else
    {
        _S97 = false;
    }
    if(_S97)
    {
        _S97 = (flags_0 & 64U) != 0U;
    }
    else
    {
        _S97 = false;
    }
    if(_S97)
    {
        Measures_0 _S124 = stress_measures_0(b_4, force_lin_3, force_ang_2);
        thread Measures_0 _S125 = _S124;
        float4 _S126 = failure_indices_0(mat_5, b_4, &_S125, weibull_0);
        float _S127 = life_rate_0(mat_5, max(max(_S126.x, _S126.y), _S126.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S127 * dt_3, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_2;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_1 = dissipated_2;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_0 = stored_2;
    if(_S81)
    {
        thread JointState_0 _S128 = st_1;
        bool _S129 = connected_0(&_S128, has_rebar_1);
        _S97 = !_S129;
    }
    else
    {
        _S97 = false;
    }
    (&resp_0)->disconnected_0 = _S97;
    (&resp_0)->measures_0 = _S82;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_5, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S130 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_0;
    if(compressed_0)
    {
        contact_0 = _S130;
    }
    else
    {
        contact_0 = 0.0f;
    }
    float _S131 = 1.0f - _S130;
    float _S132 = max(_S131 + contact_0, 9.99999997475242708e-07f);
    float normal_1;
    if(compressed_0)
    {
        normal_1 = max(1.0f - st_2->crush_0, 9.99999997475242708e-07f);
    }
    else
    {
        normal_1 = max(_S131, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S132, _S132, normal_1);
    *f_ang_0 = float3(_S132) ;
    bool _S133;
    if(((float4(b_5->stiff1_0) ).w) != 0.0f)
    {
        _S133 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S133 = false;
    }
    if(_S133)
    {
        float4 _S134 = float4(b_5->rebar0_0) ;
        float4 _S135 = float4(b_5->stiff0_0) ;
        (*f_lin_0).z = (*f_lin_0).z + _S134.x / _S135.x;
        float _S136 = _S134.y;
        float _S137 = _S135.y;
        (*f_lin_0).x = (*f_lin_0).x + _S136 / _S137;
        (*f_lin_0).y = (*f_lin_0).y + _S136 / _S137;
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
    bool _S138;
    if((st_3->damage_0) > 0.0f)
    {
        _S138 = true;
    }
    else
    {
        _S138 = (st_3->crush_0) > 0.0f;
    }
    return _S138;
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

float3 to_local_0(uint _S139, float3 _S140, KernelContext_0 thread* kernelContext_4)
{
    BondStatic_natural_0 device* _S141 = kernelContext_4->bonds_0+_S139;
    return float3(dot(_S140, (float4(_S141->t1_0) ).xyz), dot(_S140, (float4(_S141->t2_0) ).xyz), dot(_S140, (float4(_S141->normal_0) ).xyz));
}

float3 to_body_0(uint _S142, float3 _S143, KernelContext_0 thread* kernelContext_5)
{
    BondStatic_natural_0 device* _S144 = kernelContext_5->bonds_0+_S142;
    return (float4(_S144->t1_0) ).xyz * float3(_S143.x)  + (float4(_S144->t2_0) ).xyz * float3(_S143.y)  + (float4(_S144->normal_0) ).xyz * float3(_S143.z) ;
}

void bond_update_0(uint i_3, float dt_4, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_6)
{
    BondStatic_natural_0 device* _S145 = kernelContext_6->bonds_0+i_3;
    BondDyn_natural_0 device* _S146 = kernelContext_6->bond_dyn_0+i_3;
    float4 _S147 = float4((*_S146).force_lin_0) ;
    float4 _S148 = float4((*_S146).force_ang_0) ;
    float4 _S149 = float4((*_S146).sums_0) ;
    float4 _S150 = float4((*_S146).comps_0) ;
    uint4 _S151 = uint4((*_S146).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S146).js_0;
    (&bd_0)->force_lin_0 = _S147;
    (&bd_0)->force_ang_0 = _S148;
    (&bd_0)->sums_0 = _S149;
    (&bd_0)->comps_0 = _S150;
    (&bd_0)->events_0 = _S151;
    JointBond_natural_0 _S152 = _S145->law_0;
    thread JointBond_natural_0 _S153 = _S145->law_0;
    uint4 _S154 = uint4((&_S153)->ids_0) ;
    float3 ra_1 = (float4(_S145->ra_0) ).xyz;
    float3 rb_1 = (float4(_S145->rb_0) ).xyz;
    uint _S155 = 4U * _S154.y;
    float3 ta_0 = (float4(*(kernelContext_6->state_0+(_S155 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_6->state_0+(_S155 + 2U))) ).xyz;
    float3 wa_0 = (float4(*(kernelContext_6->state_0+(_S155 + 3U))) ).xyz;
    uint _S156 = 4U * _S154.z;
    float3 tb_0 = (float4(*(kernelContext_6->state_0+(_S156 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_6->state_0+(_S156 + 2U))) ).xyz;
    float3 wb_0 = (float4(*(kernelContext_6->state_0+(_S156 + 3U))) ).xyz;
    float3 _S157 = to_local_0(i_3, (float4(*(kernelContext_6->state_0+_S156)) ).xyz + cross(tb_0, rb_1) - ((float4(*(kernelContext_6->state_0+_S155)) ).xyz + cross(ta_0, ra_1)), kernelContext_6);
    float3 _S158 = to_local_0(i_3, tb_0 - ta_0, kernelContext_6);
    float3 _S159 = to_local_0(i_3, vb_0 + cross(wb_0, rb_1) - (va_0 + cross(wa_0, ra_1)), kernelContext_6);
    float3 _S160 = to_local_0(i_3, wb_0 - wa_0, kernelContext_6);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S153 = _S152;
    thread JointState_0 _S161 = (&bd_0)->js_0;
    JointResponse_0 _S162 = joint_evaluate_0(&kernelContext_6->materials_0->m_0[_S154.x], &_S153, &_S161, _S157, _S158, dt_4, fracture_2);
    thread JointState_0 _S163 = _S162.state_1;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S153, &_S163, _S157, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S159 * (float4(_S145->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S160 * (float4(_S145->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S162.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S162.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S159) + dot(qd_ang_0, _S160)) * dt_4;
    float3 _S164 = to_body_0(i_3, q_lin_2, kernelContext_6);
    float3 _S165 = to_body_0(i_3, q_ang_2, kernelContext_6);
    uint _S166 = 3U * i_3;
    *(kernelContext_6->bond_loads_0+_S166) = packed_float4(float4(_S164, max(_S162.measures_0.tension_0, _S162.measures_0.compression_0))) ;
    *(kernelContext_6->bond_loads_0+(_S166 + 1U)) = packed_float4(float4(_S165 + cross(ra_1, _S164), 0.0f)) ;
    *(kernelContext_6->bond_loads_0+(_S166 + 2U)) = packed_float4(float4(- _S165 + cross(rb_1, - _S164), 0.0f)) ;
    thread float _S167 = (&bd_0)->sums_0.x;
    thread float _S168 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S167, &_S168, _S162.dissipated_1);
    (&bd_0)->comps_0.x = _S168;
    (&bd_0)->sums_0.x = _S167;
    thread float _S169 = (&bd_0)->sums_0.y;
    thread float _S170 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S169, &_S170, _S162.overshoot_0);
    (&bd_0)->comps_0.y = _S170;
    (&bd_0)->sums_0.y = _S169;
    thread float _S171 = (&bd_0)->sums_0.z;
    thread float _S172 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S171, &_S172, damped_0);
    (&bd_0)->comps_0.z = _S172;
    (&bd_0)->sums_0.z = _S171;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S162.stored_0);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S162.state_1.utilization_0));
    thread JointState_0 _S173 = previous_0;
    bool _S174 = is_damaged_0(&_S173);
    bool _S175;
    if(!_S174)
    {
        thread JointState_0 _S176 = _S162.state_1;
        bool _S177 = is_damaged_0(&_S176);
        _S175 = _S177;
    }
    else
    {
        _S175 = false;
    }
    if(_S175)
    {
        _S175 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S175 = false;
    }
    if(_S175)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S162.state_1.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S178 = fatigue_factor_0(&kernelContext_6->materials_0->m_0[_S154.x], previous_0.fatigue_0);
        _S175 = _S178 > 0.99000000953674316f;
    }
    else
    {
        _S175 = false;
    }
    if(_S175)
    {
        float _S179 = fatigue_factor_0(&kernelContext_6->materials_0->m_0[_S154.x], _S162.state_1.fatigue_0);
        _S175 = _S179 <= 0.99000000953674316f;
    }
    else
    {
        _S175 = false;
    }
    if(_S175)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S162.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
        *kernelContext_6->g_halt_0 = 1U;
    }
    (&bd_0)->js_0 = _S162.state_1;
    BondDyn_natural_0 device* _S180 = kernelContext_6->bond_dyn_0+i_3;
    _S180->js_0 = bd_0.js_0;
    _S180->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S180->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S180->sums_0 = packed_float4(bd_0.sums_0) ;
    _S180->comps_0 = packed_float4(bd_0.comps_0) ;
    _S180->events_0 = packed_uint4(bd_0.events_0) ;
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
    uint4 probes_0;
    float4 energy_0;
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

void chunk_external_0(uint _S181, uint _S182, const Quat_0 thread* _S183, uint _S184, float _S185, float3 thread* _S186, float3 thread* _S187, KernelContext_0 thread* kernelContext_7)
{
    ChunkStatic_natural_0 device* _S188 = kernelContext_7->chunks_0+_S182;
    float3 _S189 = float3(0.0f) ;
    *_S186 = _S189;
    *_S187 = _S189;
    uint4 _S190 = uint4(_S188->load_range_0) ;
    uint term_1 = _S190.x;
    for(;;)
    {
        if(term_1 < (_S190.y))
        {
        }
        else
        {
            break;
        }
        uint _S191 = 5U * term_1;
        uint _S192 = (as_type<uint4>((float4(*(kernelContext_7->loads_0+_S191)) ))).y;
        if(_S192 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S193 = float4(*(kernelContext_7->loads_0+(_S191 + 1U))) ;
        float4 _S194 = float4(*(kernelContext_7->loads_0+(_S191 + 2U))) ;
        float _S195 = eval_function_0(term_1, _S184, _S185, 0.0f, kernelContext_7);
        float3 fw_0;
        if(_S192 == 0U)
        {
            fw_0 = _S193.xyz * float3(_S195) ;
        }
        else
        {
            float3 _S196 = rotate_0(_S183, _S193.xyz);
            fw_0 = _S196 * float3((- _S195 * _S193.w)) ;
        }
        *_S186 = *_S186 + fw_0;
        float3 _S197 = rotate_0(_S183, _S194.xyz);
        *_S187 = *_S187 + cross(_S197, fw_0);
        term_1 = term_1 + 1U;
    }
    return;
}

void chunk_update_0(uint c_3, const Island_0 thread* isl_0, const Rigid_0 thread* rg_0, float dt_5, bool rml_0, uint k_4, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_8)
{
    ChunkStatic_natural_0 device* _S198 = kernelContext_8->chunks_0+c_3;
    float3 _S199 = float3(0.0f) ;
    uint _S200 = kernelContext_8->csr_0[c_3];
    float peak_0 = 0.0f;
    uint k_5 = _S200;
    float3 fi_0 = _S199;
    float3 mi_0 = _S199;
    for(;;)
    {
        if(k_5 < (kernelContext_8->csr_0)[c_3 + 1U])
        {
        }
        else
        {
            break;
        }
        uint e_0 = kernelContext_8->csr_0[k_5];
        uint _S201 = 3U * (e_0 >> 1U);
        float4 _S202 = float4(*(kernelContext_8->bond_loads_0+_S201)) ;
        if((e_0 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_8->bond_loads_0+(_S201 + 1U))) ).xyz;
            fi_0 = fi_0 + _S202.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_8->bond_loads_0+(_S201 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S202.xyz;
            mi_0 = mi_2;
        }
        float _S203 = max(peak_0, _S202.w);
        uint _S204 = k_5 + 1U;
        peak_0 = _S203;
        k_5 = _S204;
    }
    uint _S205 = 4U * c_3;
    float3 u_0 = (float4(*(kernelContext_8->state_0+_S205)) ).xyz;
    uint _S206 = _S205 + 1U;
    float3 th_0 = (float4(*(kernelContext_8->state_0+_S206)) ).xyz;
    uint _S207 = _S205 + 2U;
    float3 v_6 = (float4(*(kernelContext_8->state_0+_S207)) ).xyz;
    uint _S208 = _S205 + 3U;
    float3 w_2 = (float4(*(kernelContext_8->state_0+_S208)) ).xyz;
    float4 _S209 = float4(_S198->center_0) ;
    float mass_0 = _S209.w;
    float3 _S210 = _S209.xyz;
    float3 _S211 = isl_0->com_0.xyz;
    float3 _S212 = rotate_0(&rg_0->rot_0, _S210 + u_0 - _S211);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_3, c_3, &rg_0->rot_0, k_4, dt_5, &f_load_0, &t_load_0, kernelContext_8);
    float3 _S213 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_8->params_0->gravity_0.xyz * _S213;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_0->a_4 + cross(rg_0->alpha_0, _S212) + cross(rg_0->w_1, cross(rg_0->w_1, _S212))) * _S213;
        float4 _S214 = float4(_S198->inertia0_1) ;
        float4 _S215 = float4(_S198->inertia1_1) ;
        float4 _S216 = float4(_S198->inertia2_1) ;
        float3 _S217 = world_mul_0(&rg_0->rot_0, _S214, _S215, _S216, rg_0->alpha_0);
        float3 _S218 = world_mul_0(&rg_0->rot_0, _S214, _S215, _S216, rg_0->w_1);
        float3 t_world_2 = t_world_0 - (_S217 + cross(rg_0->w_1, _S218));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S219 = inverse_rotate_0(&rg_0->rot_0, f_world_1);
    float3 _S220 = inverse_rotate_0(&rg_0->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S221 = inverse_rotate_0(&rg_0->rot_0, rg_0->w_1);
        float4 _S222 = float4(_S198->inertia0_1) ;
        float4 _S223 = float4(_S198->inertia1_1) ;
        float4 _S224 = float4(_S198->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S222, _S223, _S224, w_2);
        float3 m_ext_1 = _S220 - (cross(_S221, i_w_0) + cross(w_2, rows_mul_0(_S222, _S223, _S224, _S221)) + cross(w_2, i_w_0));
        f_ext_0 = _S219 - cross(_S221, v_6) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S219;
        m_ext_0 = _S220;
    }
    uint4 _S225 = uint4(_S198->load_range_0) ;
    uint term_2 = _S225.x;
    for(;;)
    {
        if(term_2 < (_S225.y))
        {
        }
        else
        {
            break;
        }
        uint _S226 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_8->loads_0+_S226)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S227 = eval_function_0(term_2, k_4, dt_5, dt_5, kernelContext_8);
        float3 _S228 = float3(_S227) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_8->loads_0+(_S226 + 2U))) ).xyz * _S228;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_8->loads_0+(_S226 + 1U))) ).xyz * _S228;
        m_ext_0 = m_ext_2;
        term_2 = term_2 + 1U;
    }
    float3 f_3 = f_ext_0 + fi_0;
    float3 m_3 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S198->info_1) ).x;
    float3 _S229 = float3((float4(*(kernelContext_8->state_0+_S206)) ).w, (float4(*(kernelContext_8->state_0+_S207)) ).w, (float4(*(kernelContext_8->state_0+_S208)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_1;
    float3 v_7;
    float3 w_3;
    if(support_0 == 1U)
    {
        reaction_0 = - f_3;
        u_1 = u_0;
        th_1 = th_0;
        v_7 = _S199;
        w_3 = _S199;
    }
    else
    {
        float4 _S230 = float4(_S198->scale_0) ;
        float3 w_4 = w_2 + rows_mul_0(float4(_S198->inv0_1) , float4(_S198->inv1_1) , float4(_S198->inv2_1) , m_3) * float3((dt_5 * _S230.z)) ;
        float3 _S231 = float3(dt_5) ;
        float3 th_2 = th_0 + w_4 * _S231;
        if(support_0 == 2U)
        {
            reaction_0 = - f_3;
            u_1 = u_0;
            th_1 = _S199;
        }
        else
        {
            float3 v_8 = v_6 + f_3 * float3((dt_5 * _S230.y)) ;
            float3 u_2 = u_0 + v_8 * _S231;
            reaction_0 = _S229;
            u_1 = u_2;
            th_1 = v_8;
        }
        float3 _S232 = th_1;
        th_1 = th_2;
        v_7 = _S232;
        w_3 = w_4;
    }
    *(kernelContext_8->state_0+_S205) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_8->state_0+_S206) = packed_float4(float4(th_1, reaction_0.x)) ;
    *(kernelContext_8->state_0+_S207) = packed_float4(float4(v_7, reaction_0.y)) ;
    *(kernelContext_8->state_0+_S208) = packed_float4(float4(w_3, reaction_0.z)) ;
    float3 _S233 = rotate_0(&rg_0->rot_0, _S210 + u_1 - _S211);
    float3 _S234 = rg_0->vel_0 + rg_0->vel_err_0 + cross(rg_0->w_1, _S233);
    float3 _S235 = rotate_0(&rg_0->rot_0, v_7);
    float3 v_world_0 = _S234 + _S235;
    float3 _S236 = rotate_0(&rg_0->rot_0, w_3);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_0->w_1 + _S236)) * dt_5);
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_5)
{
    float3 t_4 = *sum_1 + x_5;
    float3 _S237 = abs(x_5);
    *err_1 = *err_1 + (select(x_5, *sum_1, (abs(*sum_1)) >= _S237) - t_4 + select(*sum_1, x_5, (abs(*sum_1)) >= _S237));
    *sum_1 = t_4;
    return;
}

float3 safe_normalize_0(float3 v_9)
{
    float n_0 = length(v_9);
    float3 _S238;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S238 = v_9 / float3(n_0) ;
    }
    else
    {
        _S238 = float3(0.0f) ;
    }
    return _S238;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_5 = safe_normalize_0(axis_0);
    float _S239 = 0.5f * angle_0;
    float s_2 = sin(_S239);
    thread Quat_0 q_6;
    (&q_6)->w_0 = cos(_S239);
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

Quat_0 integrate_rotation_0(const Quat_0 thread* q_8, float3 omega_0, float dt_6)
{
    float angle_1 = length(omega_0) * dt_6;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_8;
    }
    thread Quat_0 _S240 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S241 = quat_mul_0(&_S240, q_8);
    thread Quat_0 _S242 = _S241;
    Quat_0 _S243 = normalized_0(&_S242);
    return _S243;
}

void write_probe_0(uint slot_0, uint k_6, float value_0, KernelContext_0 thread* kernelContext_9)
{
    uint index_0 = kernelContext_9->params_0->probe_base_0 * 4U + slot_0 * kernelContext_9->params_0->probe_stride_0 + k_6;
    thread float4 v_10 = float4(*(kernelContext_9->bond_loads_0+index_0 / 4U)) ;
    v_10[index_0 % 4U] = value_0;
    *(kernelContext_9->bond_loads_0+index_0 / 4U) = packed_float4(v_10) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_1, const Rigid_0 thread* rg_1, uint k_7, KernelContext_0 thread* kernelContext_10)
{
    uint4 _S244 = isl_1->probes_0;
    uint at_0 = isl_1->probes_0.x;
    for(;;)
    {
        if(at_0 < (_S244.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_10->loads_0+at_0)) )));
        float4 _S245 = float4(*(kernelContext_10->loads_0+(at_0 + 1U))) ;
        float4 _S246 = float4(*(kernelContext_10->loads_0+(at_0 + 2U))) ;
        float4 _S247 = float4(*(kernelContext_10->loads_0+(at_0 + 3U))) ;
        uint kind_4 = info_3.x;
        uint index_1 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 _S248 = rg_1->pos_0 - _S246.xyz + (rg_1->pos_err_0 - _S247.xyz);
            float3 _S249 = rotate_0(&rg_1->rot_0, (float4((kernelContext_10->chunks_0+index_1)->center_0) ).xyz + (float4(*(kernelContext_10->state_0+4U * index_1)) ).xyz);
            value_1 = dot(_S248 + _S249, _S245.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S250 = 4U * index_1;
                float3 _S251 = rotate_0(&rg_1->rot_0, (float4((kernelContext_10->chunks_0+index_1)->center_0) ).xyz + (float4(*(kernelContext_10->state_0+_S250)) ).xyz - isl_1->com_0.xyz);
                float3 _S252 = rg_1->vel_0 + rg_1->vel_err_0 + cross(rg_1->w_1, _S251);
                float3 _S253 = rotate_0(&rg_1->rot_0, (float4(*(kernelContext_10->state_0+(_S250 + 2U))) ).xyz);
                value_1 = dot(_S252 + _S253, _S245.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S254 = 3U * index_1;
                    float3 f_4 = (float4(*(kernelContext_10->bond_loads_0+_S254)) ).xyz;
                    bool _S255 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S255)
                    {
                        mc_0 = (float4(*(kernelContext_10->bond_loads_0+(_S254 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_10->bond_loads_0+(_S254 + 2U))) ).xyz;
                    }
                    float3 fc_2;
                    if(_S255)
                    {
                        fc_2 = f_4;
                    }
                    else
                    {
                        fc_2 = - f_4;
                    }
                    value_1 = dot(fc_2, _S245.xyz) + dot(mc_0, _S246.xyz);
                }
                else
                {
                    uint _S256 = 4U * index_1;
                    float3 _S257 = rotate_0(&rg_1->rot_0, float3((float4(*(kernelContext_10->state_0+(_S256 + 1U))) ).w, (float4(*(kernelContext_10->state_0+(_S256 + 2U))) ).w, (float4(*(kernelContext_10->state_0+(_S256 + 3U))) ).w));
                    value_1 = dot(_S257, _S245.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_7, value_1, kernelContext_10);
        at_0 = at_0 + 4U;
    }
    return;
}

float4 quat_vec_0(const Quat_0 thread* q_9)
{
    return float4(q_9->x_0, q_9->y_0, q_9->z_0, q_9->w_0);
}

[[kernel]] void island_frame(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Island_natural_0 device* islands_1 [[buffer(8)]], Params_0 constant* params_1 [[buffer(0)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* loads_1 [[buffer(9)]], packed_float4 device* state_3 [[buffer(5)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(6)]], MaterialTable_0 constant* materials_1 [[buffer(1)]], packed_float4 device* bond_loads_1 [[buffer(7)]], uint device* csr_1 [[buffer(4)]])
{
    thread KernelContext_0 kernelContext_11;
    (&kernelContext_11)->islands_0 = islands_1;
    (&kernelContext_11)->params_0 = params_1;
    (&kernelContext_11)->chunks_0 = chunks_1;
    (&kernelContext_11)->loads_0 = loads_1;
    (&kernelContext_11)->state_0 = state_3;
    (&kernelContext_11)->bonds_0 = bonds_1;
    (&kernelContext_11)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_11)->materials_0 = materials_1;
    (&kernelContext_11)->bond_loads_0 = bond_loads_1;
    (&kernelContext_11)->csr_0 = csr_1;
    threadgroup uint g_halt_1;
    (&kernelContext_11)->g_halt_0 = &g_halt_1;
    threadgroup array<float4, int(256)> g_red_a_1;
    (&kernelContext_11)->g_red_a_0 = &g_red_a_1;
    threadgroup array<float4, int(256)> g_red_b_1;
    (&kernelContext_11)->g_red_b_0 = &g_red_b_1;
    uint tid_1 = thread_0.x;
    uint _S258 = group_0.x;
    Island_natural_0 device* _S259 = islands_1+_S258;
    uint4 _S260 = uint4((*_S259).info_0) ;
    float4 _S261 = float4((*_S259).com_0) ;
    float4 _S262 = float4((*_S259).inertia0_0) ;
    float4 _S263 = float4((*_S259).inertia1_0) ;
    float4 _S264 = float4((*_S259).inertia2_0) ;
    float4 _S265 = float4((*_S259).inv0_0) ;
    float4 _S266 = float4((*_S259).inv1_0) ;
    float4 _S267 = float4((*_S259).inv2_0) ;
    float4 _S268 = float4((*_S259).wcom_0) ;
    float4 _S269 = float4((*_S259).winv0_0) ;
    float4 _S270 = float4((*_S259).winv1_0) ;
    float4 _S271 = float4((*_S259).winv2_0) ;
    float4 _S272 = float4((*_S259).rotation_0) ;
    float4 _S273 = float4((*_S259).position_0) ;
    float4 _S274 = float4((*_S259).position_err_0) ;
    float4 _S275 = float4((*_S259).velocity_0) ;
    float4 _S276 = float4((*_S259).velocity_err_0) ;
    float4 _S277 = float4((*_S259).angular_velocity_0) ;
    uint4 _S278 = uint4((*_S259).done_0) ;
    uint4 _S279 = uint4((*_S259).probes_0) ;
    float4 _S280 = float4((*_S259).energy_0) ;
    thread Island_0 isl_2;
    (&isl_2)->range_0 = uint4((*_S259).range_0) ;
    (&isl_2)->info_0 = _S260;
    (&isl_2)->com_0 = _S261;
    (&isl_2)->inertia0_0 = _S262;
    (&isl_2)->inertia1_0 = _S263;
    (&isl_2)->inertia2_0 = _S264;
    (&isl_2)->inv0_0 = _S265;
    (&isl_2)->inv1_0 = _S266;
    (&isl_2)->inv2_0 = _S267;
    (&isl_2)->wcom_0 = _S268;
    (&isl_2)->winv0_0 = _S269;
    (&isl_2)->winv1_0 = _S270;
    (&isl_2)->winv2_0 = _S271;
    (&isl_2)->rotation_0 = _S272;
    (&isl_2)->position_0 = _S273;
    (&isl_2)->position_err_0 = _S274;
    (&isl_2)->velocity_0 = _S275;
    (&isl_2)->velocity_err_0 = _S276;
    (&isl_2)->angular_velocity_0 = _S277;
    (&isl_2)->done_0 = _S278;
    (&isl_2)->probes_0 = _S279;
    (&isl_2)->energy_0 = _S280;
    bool driven_0 = (((&isl_2)->info_0.x) & 2U) != 0U;
    bool _S281 = !((((&isl_2)->info_0.x) & 1U) != 0U);
    bool _S282;
    if(_S281)
    {
        _S282 = !driven_0;
    }
    else
    {
        _S282 = false;
    }
    uint _S283;
    if((((&isl_2)->info_0.z) & 1U) != 0U)
    {
        _S283 = 0U;
    }
    else
    {
        _S283 = (&isl_2)->info_0.y;
    }
    float _S284 = (&kernelContext_11)->params_0->dt_0;
    bool _S285 = ((&kernelContext_11)->params_0->fracture_0) != 0U;
    bool _S286 = ((&kernelContext_11)->params_0->rigid_motion_loads_0) != 0U;
    float3 _S287 = (&kernelContext_11)->params_0->gravity_0.xyz;
    float _S288 = (&isl_2)->com_0.w;
    thread Rigid_0 rg_2;
    (&rg_2)->rot_0 = quat_of_0((&isl_2)->rotation_0);
    (&rg_2)->pos_0 = (&isl_2)->position_0.xyz;
    (&rg_2)->pos_err_0 = (&isl_2)->position_err_0.xyz;
    (&rg_2)->vel_0 = (&isl_2)->velocity_0.xyz;
    (&rg_2)->vel_err_0 = (&isl_2)->velocity_err_0.xyz;
    (&rg_2)->w_1 = (&isl_2)->angular_velocity_0.xyz;
    float3 _S289 = float3(0.0f) ;
    (&rg_2)->a_4 = _S289;
    (&rg_2)->alpha_0 = _S289;
    bool _S290 = tid_1 == 0U;
    if(_S290)
    {
        *(&kernelContext_11)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    thread float work_2 = 0.0f;
    thread float work_err_1 = 0.0f;
    uint done_1 = 0U;
    for(;;)
    {
        if(done_1 < _S283)
        {
        }
        else
        {
            break;
        }
        uint abs_step_1 = (&isl_2)->info_0.w + done_1 + 1U;
        uint k_8 = abs_step_1 - 1U - (&kernelContext_11)->params_0->step_start_0;
        uint i_4;
        uint c_4;
        if(_S281)
        {
            thread float3 f_5 = _S289;
            thread float3 t_5 = _S289;
            i_4 = (&isl_2)->range_0.x + tid_1;
            for(;;)
            {
                if(i_4 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S291 = (&kernelContext_11)->chunks_0+i_4;
                thread Quat_0 _S292 = (&rg_2)->rot_0;
                thread float3 fl_0;
                thread float3 tl_0;
                chunk_external_0(i_4, i_4, &_S292, k_8, _S284, &fl_0, &tl_0, &kernelContext_11);
                float4 _S293 = float4(_S291->center_0) ;
                float3 fc_3 = fl_0 + _S287 * float3(_S293.w) ;
                float3 _S294 = _S293.xyz;
                float3 _S295 = _S294 + (float4(*((&kernelContext_11)->state_0+4U * i_4)) ).xyz - (&isl_2)->com_0.xyz;
                thread Quat_0 _S296 = (&rg_2)->rot_0;
                float3 _S297 = rotate_0(&_S296, _S295);
                f_5 = f_5 + fc_3;
                t_5 = t_5 + (cross(_S297, fc_3) + tl_0);
                uint4 _S298 = uint4(_S291->load_range_0) ;
                c_4 = _S298.x;
                for(;;)
                {
                    if(c_4 < (_S298.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    uint _S299 = 5U * c_4;
                    if(((as_type<uint4>((float4(*((&kernelContext_11)->loads_0+_S299)) ))).y) != 2U)
                    {
                        c_4 = c_4 + 1U;
                        continue;
                    }
                    float _S300 = eval_function_0(c_4, k_8, _S284, 0.0f, &kernelContext_11);
                    float3 _S301 = float3(_S300) ;
                    float3 _S302 = (float4(*((&kernelContext_11)->loads_0+(_S299 + 1U))) ).xyz * _S301;
                    thread Quat_0 _S303 = (&rg_2)->rot_0;
                    float3 _S304 = rotate_0(&_S303, _S302);
                    f_5 = f_5 + _S304;
                    float3 _S305 = _S294 - (&isl_2)->com_0.xyz;
                    thread Quat_0 _S306 = (&rg_2)->rot_0;
                    float3 _S307 = rotate_0(&_S306, _S305);
                    float3 _S308 = cross(_S307, _S304);
                    float3 _S309 = (float4(*((&kernelContext_11)->loads_0+(_S299 + 2U))) ).xyz * _S301;
                    thread Quat_0 _S310 = (&rg_2)->rot_0;
                    float3 _S311 = rotate_0(&_S310, _S309);
                    t_5 = t_5 + (_S308 + _S311);
                    c_4 = c_4 + 1U;
                }
                i_4 = i_4 + 256U;
            }
            group_sum2_0(tid_1, &f_5, &t_5, &kernelContext_11);
            thread Quat_0 _S312 = (&rg_2)->rot_0;
            float3 _S313 = world_mul_0(&_S312, (&isl_2)->inertia0_0, (&isl_2)->inertia1_0, (&isl_2)->inertia2_0, (&rg_2)->w_1);
            (&rg_2)->a_4 = f_5 / float3(_S288) ;
            float3 _S314 = t_5 - cross((&rg_2)->w_1, _S313);
            thread Quat_0 _S315 = (&rg_2)->rot_0;
            float3 _S316 = world_mul_0(&_S315, (&isl_2)->inv0_0, (&isl_2)->inv1_0, (&isl_2)->inv2_0, _S314);
            (&rg_2)->alpha_0 = _S316;
        }
        i_4 = (&isl_2)->range_0.z + tid_1;
        for(;;)
        {
            if(i_4 < ((&isl_2)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bond_update_0(i_4, _S284, _S285, abs_step_1, &kernelContext_11);
            i_4 = i_4 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        c_4 = (&isl_2)->range_0.x + tid_1;
        for(;;)
        {
            if(c_4 < ((&isl_2)->range_0.y))
            {
            }
            else
            {
                break;
            }
            thread Island_0 _S317 = isl_2;
            thread Rigid_0 _S318 = rg_2;
            chunk_update_0(c_4, &_S317, &_S318, _S284, _S286, k_8, &work_2, &work_err_1, &kernelContext_11);
            c_4 = c_4 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S282)
        {
            thread Quat_0 _S319 = (&rg_2)->rot_0;
            float3 _S320 = world_mul_0(&_S319, (&isl_2)->inertia0_0, (&isl_2)->inertia1_0, (&isl_2)->inertia2_0, (&rg_2)->w_1);
            thread Quat_0 _S321 = (&rg_2)->rot_0;
            float3 _S322 = world_mul_0(&_S321, (&isl_2)->inertia0_0, (&isl_2)->inertia1_0, (&isl_2)->inertia2_0, (&rg_2)->alpha_0);
            float3 _S323 = float3(_S284) ;
            float3 l_0 = _S320 + (_S322 + cross((&rg_2)->w_1, _S320)) * _S323;
            comp_add_0(&(&rg_2)->vel_0, &(&rg_2)->vel_err_0, (&rg_2)->a_4 * _S323);
            float3 vel_1 = (&rg_2)->vel_0 + (&rg_2)->vel_err_0;
            thread Quat_0 _S324 = (&rg_2)->rot_0;
            float3 _S325 = world_mul_0(&_S324, (&isl_2)->inv0_0, (&isl_2)->inv1_0, (&isl_2)->inv2_0, l_0);
            thread Quat_0 _S326 = (&rg_2)->rot_0;
            Quat_0 _S327 = integrate_rotation_0(&_S326, _S325, _S284);
            float3 _S328 = vel_1 * _S323;
            float3 _S329 = (&isl_2)->com_0.xyz;
            thread Quat_0 _S330 = (&rg_2)->rot_0;
            float3 _S331 = rotate_0(&_S330, _S329);
            float3 _S332 = (&isl_2)->com_0.xyz;
            thread Quat_0 _S333 = _S327;
            float3 _S334 = rotate_0(&_S333, _S332);
            comp_add_0(&(&rg_2)->pos_0, &(&rg_2)->pos_err_0, _S328 + (_S331 - _S334));
            (&rg_2)->rot_0 = _S327;
            thread Quat_0 _S335 = _S327;
            float3 _S336 = world_mul_0(&_S335, (&isl_2)->inv0_0, (&isl_2)->inv1_0, (&isl_2)->inv2_0, l_0);
            (&rg_2)->w_1 = _S336;
        }
        if(_S281)
        {
            float3 wcom_1 = (&isl_2)->wcom_0.xyz;
            float wmass_0 = (&isl_2)->wcom_0.w;
            thread float3 tu_0 = _S289;
            thread float3 pv_0 = _S289;
            uint c_5 = (&isl_2)->range_0.x + tid_1;
            for(;;)
            {
                if(c_5 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S337 = (&kernelContext_11)->chunks_0+c_5;
                uint _S338 = 4U * c_5;
                float3 _S339 = float3(((float4(_S337->center_0) ).w * (float4(_S337->scale_0) ).x)) ;
                tu_0 = tu_0 + (float4(*((&kernelContext_11)->state_0+_S338)) ).xyz * _S339;
                pv_0 = pv_0 + (float4(*((&kernelContext_11)->state_0+(_S338 + 2U))) ).xyz * _S339;
                c_5 = c_5 + 256U;
            }
            group_sum2_0(tid_1, &tu_0, &pv_0, &kernelContext_11);
            float3 _S340 = float3(wmass_0) ;
            float3 tr_0 = tu_0 / _S340;
            float3 dv_0 = pv_0 / _S340;
            thread float3 lu_0 = _S289;
            thread float3 lv_0 = _S289;
            uint c_6 = (&isl_2)->range_0.x + tid_1;
            for(;;)
            {
                if(c_6 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                ChunkStatic_natural_0 device* _S341 = (&kernelContext_11)->chunks_0+c_6;
                float4 _S342 = float4(_S341->center_0) ;
                float3 r_7 = _S342.xyz - wcom_1;
                uint _S343 = 4U * c_6;
                float3 _S344 = float3(_S342.w) ;
                float4 _S345 = float4(_S341->inertia0_1) ;
                float4 _S346 = float4(_S341->inertia1_1) ;
                float4 _S347 = float4(_S341->inertia2_1) ;
                float3 _S348 = float3((float4(_S341->scale_0) ).x) ;
                lu_0 = lu_0 + (cross(r_7, (float4(*((&kernelContext_11)->state_0+_S343)) ).xyz - tr_0) * _S344 + rows_mul_0(_S345, _S346, _S347, (float4(*((&kernelContext_11)->state_0+(_S343 + 1U))) ).xyz)) * _S348;
                lv_0 = lv_0 + (cross(r_7, (float4(*((&kernelContext_11)->state_0+(_S343 + 2U))) ).xyz - dv_0) * _S344 + rows_mul_0(_S345, _S346, _S347, (float4(*((&kernelContext_11)->state_0+(_S343 + 3U))) ).xyz)) * _S348;
                c_6 = c_6 + 256U;
            }
            group_sum2_0(tid_1, &lu_0, &lv_0, &kernelContext_11);
            float3 phi_0 = rows_mul_0((&isl_2)->winv0_0, (&isl_2)->winv1_0, (&isl_2)->winv2_0, lu_0);
            float3 dw_0 = rows_mul_0((&isl_2)->winv0_0, (&isl_2)->winv1_0, (&isl_2)->winv2_0, lv_0);
            uint c_7 = (&isl_2)->range_0.x + tid_1;
            for(;;)
            {
                if(c_7 < ((&isl_2)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                float3 r_8 = (float4(((&kernelContext_11)->chunks_0+c_7)->center_0) ).xyz - wcom_1;
                uint _S349 = 4U * c_7;
                *((&kernelContext_11)->state_0+_S349) = packed_float4(float4((float4(*((&kernelContext_11)->state_0+_S349)) ).xyz - (tr_0 + cross(phi_0, r_8)), (float4(*((&kernelContext_11)->state_0+_S349)) ).w)) ;
                uint _S350 = _S349 + 1U;
                *((&kernelContext_11)->state_0+_S350) = packed_float4(float4((float4(*((&kernelContext_11)->state_0+_S350)) ).xyz - phi_0, (float4(*((&kernelContext_11)->state_0+_S350)) ).w)) ;
                uint _S351 = _S349 + 2U;
                *((&kernelContext_11)->state_0+_S351) = packed_float4(float4((float4(*((&kernelContext_11)->state_0+_S351)) ).xyz - (dv_0 + cross(dw_0, r_8)), (float4(*((&kernelContext_11)->state_0+_S351)) ).w)) ;
                uint _S352 = _S349 + 3U;
                *((&kernelContext_11)->state_0+_S352) = packed_float4(float4((float4(*((&kernelContext_11)->state_0+_S352)) ).xyz - dw_0, (float4(*((&kernelContext_11)->state_0+_S352)) ).w)) ;
                c_7 = c_7 + 256U;
            }
            if(!driven_0)
            {
                Quat_0 rot_1 = (&rg_2)->rot_0;
                float3 _S353 = tr_0 - cross(phi_0, wcom_1);
                thread Quat_0 _S354 = (&rg_2)->rot_0;
                float3 _S355 = rotate_0(&_S354, _S353);
                comp_add_0(&(&rg_2)->pos_0, &(&rg_2)->pos_err_0, _S355);
                Quat_0 _S356 = from_axis_angle_0(phi_0, length(phi_0));
                thread Quat_0 _S357 = (&rg_2)->rot_0;
                thread Quat_0 _S358 = _S356;
                Quat_0 _S359 = quat_mul_0(&_S357, &_S358);
                thread Quat_0 _S360 = _S359;
                Quat_0 _S361 = normalized_0(&_S360);
                (&rg_2)->rot_0 = _S361;
                float3 _S362 = dv_0 + cross(dw_0, (&isl_2)->com_0.xyz - wcom_1);
                thread Quat_0 _S363 = rot_1;
                float3 _S364 = rotate_0(&_S363, _S362);
                comp_add_0(&(&rg_2)->vel_0, &(&rg_2)->vel_err_0, _S364);
                thread Quat_0 _S365 = rot_1;
                float3 _S366 = rotate_0(&_S365, dw_0);
                (&rg_2)->w_1 = (&rg_2)->w_1 + _S366;
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        bool _S367;
        if(_S290)
        {
            _S367 = ((&isl_2)->probes_0.y) > ((&isl_2)->probes_0.x);
        }
        else
        {
            _S367 = false;
        }
        if(_S367)
        {
            thread Island_0 _S368 = isl_2;
            thread Rigid_0 _S369 = rg_2;
            record_probes_0(&_S368, &_S369, k_8, &kernelContext_11);
        }
        uint _S370 = done_1 + 1U;
        if((*(&kernelContext_11)->g_halt_0) != 0U)
        {
            done_1 = _S370;
            break;
        }
        done_1 = _S370;
    }
    thread float3 wsum_0 = float3(work_2, work_err_1, 0.0f);
    thread float3 unused_0 = _S289;
    group_sum2_0(tid_1, &wsum_0, &unused_0, &kernelContext_11);
    if(_S290)
    {
        thread Quat_0 _S371 = (&rg_2)->rot_0;
        float4 _S372 = quat_vec_0(&_S371);
        (&isl_2)->rotation_0 = _S372;
        (&isl_2)->position_0 = float4((&rg_2)->pos_0, 0.0f);
        (&isl_2)->position_err_0 = float4((&rg_2)->pos_err_0, 0.0f);
        (&isl_2)->velocity_0 = float4((&rg_2)->vel_0, 0.0f);
        (&isl_2)->velocity_err_0 = float4((&rg_2)->vel_err_0, 0.0f);
        (&isl_2)->angular_velocity_0 = float4((&rg_2)->w_1, 0.0f);
        (&isl_2)->done_0.x = done_1;
        float _S373 = wsum_0.x;
        thread float _S374 = (&isl_2)->energy_0.x;
        thread float _S375 = (&isl_2)->energy_0.y;
        comp_add1_0(&_S374, &_S375, _S373);
        (&isl_2)->energy_0.x = _S374;
        (&isl_2)->energy_0.y = _S375 + wsum_0.y;
        (&isl_2)->info_0.w = (&isl_2)->info_0.w + done_1;
        if((*(&kernelContext_11)->g_halt_0) != 0U)
        {
            (&isl_2)->info_0.z = ((&isl_2)->info_0.z) | 1U;
        }
        Island_natural_0 device* _S376 = (&kernelContext_11)->islands_0+_S258;
        _S376->range_0 = packed_uint4(isl_2.range_0) ;
        _S376->info_0 = packed_uint4(isl_2.info_0) ;
        _S376->com_0 = packed_float4(isl_2.com_0) ;
        _S376->inertia0_0 = packed_float4(isl_2.inertia0_0) ;
        _S376->inertia1_0 = packed_float4(isl_2.inertia1_0) ;
        _S376->inertia2_0 = packed_float4(isl_2.inertia2_0) ;
        _S376->inv0_0 = packed_float4(isl_2.inv0_0) ;
        _S376->inv1_0 = packed_float4(isl_2.inv1_0) ;
        _S376->inv2_0 = packed_float4(isl_2.inv2_0) ;
        _S376->wcom_0 = packed_float4(isl_2.wcom_0) ;
        _S376->winv0_0 = packed_float4(isl_2.winv0_0) ;
        _S376->winv1_0 = packed_float4(isl_2.winv1_0) ;
        _S376->winv2_0 = packed_float4(isl_2.winv2_0) ;
        _S376->rotation_0 = packed_float4(isl_2.rotation_0) ;
        _S376->position_0 = packed_float4(isl_2.position_0) ;
        _S376->position_err_0 = packed_float4(isl_2.position_err_0) ;
        _S376->velocity_0 = packed_float4(isl_2.velocity_0) ;
        _S376->velocity_err_0 = packed_float4(isl_2.velocity_err_0) ;
        _S376->angular_velocity_0 = packed_float4(isl_2.angular_velocity_0) ;
        _S376->done_0 = packed_uint4(isl_2.done_0) ;
        _S376->probes_0 = packed_uint4(isl_2.probes_0) ;
        _S376->energy_0 = packed_float4(isl_2.energy_0) ;
    }
    return;
}

