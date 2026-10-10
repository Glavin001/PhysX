#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;
struct Params_0
{
    float4 gravity_0;
    float dt_0;
    uint fracture_0;
    uint rigid_motion_loads_0;
    uint step_start_0;
    float t_hi_0;
    float t_lo_0;
    uint max_steps_0;
    uint contact_mode_0;
    uint halt_index_0;
    uint chunk_count_0;
    uint pair_count_0;
    uint impactor_count_0;
    uint cand_count_0;
    uint probe_base_0;
    uint probe_stride_0;
    uint slot_base_0;
    uint ledger_base_0;
    uint record_base_0;
    uint record_stride_0;
    uint cand_base_0;
    uint pair_index_0;
    uint cand_index_0;
    float zeta_0;
    float pair_friction_0;
    float ground_hi_0;
    float ground_lo_0;
    float ground_friction_0;
    float ground_modulus_0;
    uint has_ground_0;
    uint wide_bond_groups_0;
    uint wide_bond_table_0;
    uint wide_chunk_table_0;
    uint wide_base_0;
    uint seg_index_0;
    uint seg_count_0;
    uint seg_base_0;
    uint pad0_0;
    uint pad1_0;
    uint pad2_0;
};

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
    packed_float4 half_0;
    packed_float4 crot0_0;
    packed_float4 crot1_0;
    packed_float4 crot2_0;
    packed_float4 cmat_0;
    packed_float4 start_hi_0;
    packed_float4 start_lo_0;
    packed_uint4 cinfo_0;
};

struct Impactor_natural_0
{
    packed_float4 position_1;
    packed_float4 position_err_1;
    packed_float4 velocity_1;
    packed_float4 velocity_err_1;
    packed_float4 angular_velocity_1;
    packed_float4 rotation_1;
    packed_float4 inertia0_2;
    packed_float4 inertia1_2;
    packed_float4 inertia2_2;
    packed_float4 inv0_2;
    packed_float4 inv1_2;
    packed_float4 inv2_2;
    packed_float4 shape_0;
    packed_float4 half_1;
    packed_float4 mat_0;
    packed_float4 crush_0;
    packed_float4 geom_0;
    packed_float4 unused_0;
    packed_float4 ledger_0;
    packed_uint4 cand_0;
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
    float crush_1;
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
    Params_0 constant* params_0;
    Island_natural_0 device* islands_0;
    uint device* index_0;
    ChunkStatic_natural_0 device* chunks_0;
    packed_float4 device* state_0;
    packed_float4 device* scratch_0;
    packed_float4 device* contact_state_0;
    packed_float4 device* loads_0;
    Impactor_natural_0 device* impactors_0;
    BondStatic_natural_0 device* bonds_0;
    BondDyn_natural_0 device* bond_dyn_0;
    MaterialTable_0 constant* materials_0;
    array<float4, int(256)> threadgroup* g_red_a_0;
    array<float4, int(256)> threadgroup* g_red_b_0;
    uint threadgroup* g_run_0;
    uint threadgroup* g_halt_0;
    uint threadgroup* g_wide_run_0;
};

bool stopped_0(KernelContext_0 thread* kernelContext_0)
{
    uint4 _S1 = uint4((kernelContext_0->islands_0+kernelContext_0->params_0->halt_index_0)->info_0) ;
    bool _S2;
    if(((_S1.z) & 1U) != 0U)
    {
        _S2 = true;
    }
    else
    {
        _S2 = (_S1.y) != 0U;
    }
    return _S2;
}

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

struct WorldPoint_0
{
    float3 hi_0;
    float3 lo_0;
    float3 rel_0;
};

WorldPoint_0 chunk_world_0(uint c_0, KernelContext_0 thread* kernelContext_1)
{
    ChunkStatic_natural_0 device* _S3 = kernelContext_1->chunks_0+c_0;
    Island_natural_0 device* _S4 = kernelContext_1->islands_0+(uint4(_S3->info_1) ).y;
    Quat_0 q_3 = quat_of_0(float4(_S4->rotation_0) );
    thread WorldPoint_0 w_1;
    (&w_1)->hi_0 = (float4(_S4->position_0) ).xyz;
    (&w_1)->lo_0 = (float4(_S4->position_err_0) ).xyz;
    float3 _S5 = (float4(_S3->center_0) ).xyz + (float4(*(kernelContext_1->state_0+4U * c_0)) ).xyz;
    thread Quat_0 _S6 = q_3;
    float3 _S7 = rotate_0(&_S6, _S5);
    (&w_1)->rel_0 = _S7;
    return w_1;
}

float3 world_diff_0(const WorldPoint_0 thread* a_0, const WorldPoint_0 thread* b_0)
{
    return a_0->hi_0 - b_0->hi_0 + (a_0->lo_0 - b_0->lo_0) + (a_0->rel_0 - b_0->rel_0);
}

float3 safe_normalize_0(float3 v_2)
{
    float n_0 = length(v_2);
    float3 _S8;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S8 = v_2 / float3(n_0) ;
    }
    else
    {
        _S8 = float3(0.0f) ;
    }
    return _S8;
}

Quat_0 from_axis_angle_0(float3 axis_0, float angle_0)
{
    float3 a_1 = safe_normalize_0(axis_0);
    float _S9 = 0.5f * angle_0;
    float s_0 = sin(_S9);
    thread Quat_0 q_4;
    (&q_4)->w_0 = cos(_S9);
    (&q_4)->x_0 = a_1.x * s_0;
    (&q_4)->y_0 = a_1.y * s_0;
    (&q_4)->z_0 = a_1.z * s_0;
    return q_4;
}

struct Box_0
{
    float3 center_1;
    float3 axis0_0;
    float3 axis1_0;
    float3 axis2_0;
    float3 half_2;
    uint hull_at_0;
    uint hull_v_0;
    uint hull_f_0;
};

Box_0 chunk_box_0(uint c_1, float3 center_2, KernelContext_0 thread* kernelContext_2)
{
    ChunkStatic_natural_0 device* _S10 = kernelContext_2->chunks_0+c_1;
    Quat_0 q_5 = quat_of_0(float4((kernelContext_2->islands_0+(uint4(_S10->info_1) ).y)->rotation_0) );
    float3 th_0 = (float4(*(kernelContext_2->state_0+(4U * c_1 + 1U))) ).xyz;
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length(th_0));
    thread Box_0 b_1;
    (&b_1)->center_1 = center_2;
    float4 _S11 = float4(_S10->crot0_0) ;
    float4 _S12 = float4(_S10->crot1_0) ;
    float4 _S13 = float4(_S10->crot2_0) ;
    float3 _S14 = float3(_S11.x, _S12.x, _S13.x);
    thread Quat_0 _S15 = hidden_0;
    float3 _S16 = rotate_0(&_S15, _S14);
    thread Quat_0 _S17 = q_5;
    float3 _S18 = rotate_0(&_S17, _S16);
    (&b_1)->axis0_0 = _S18;
    float3 _S19 = float3(_S11.y, _S12.y, _S13.y);
    thread Quat_0 _S20 = hidden_0;
    float3 _S21 = rotate_0(&_S20, _S19);
    thread Quat_0 _S22 = q_5;
    float3 _S23 = rotate_0(&_S22, _S21);
    (&b_1)->axis1_0 = _S23;
    float3 _S24 = float3(_S11.z, _S12.z, _S13.z);
    thread Quat_0 _S25 = hidden_0;
    float3 _S26 = rotate_0(&_S25, _S24);
    thread Quat_0 _S27 = q_5;
    float3 _S28 = rotate_0(&_S27, _S26);
    (&b_1)->axis2_0 = _S28;
    (&b_1)->half_2 = (float4(_S10->half_0) ).xyz;
    float4 _S29 = float4(_S10->cmat_0) ;
    (&b_1)->hull_at_0 = (as_type<uint>((_S29.z)));
    uint _S30 = (as_type<uint>((_S29.w)));
    (&b_1)->hull_v_0 = _S30 & 255U;
    (&b_1)->hull_f_0 = _S30 >> 8U;
    return b_1;
}

uint sample_count_0(const Box_0 thread* b_2)
{
    uint _S31 = b_2->hull_v_0;
    uint _S32;
    if((b_2->hull_v_0) == 0U)
    {
        _S32 = 14U;
    }
    else
    {
        _S32 = _S31 + b_2->hull_f_0;
    }
    return _S32;
}

bool may_overlap_0(const Box_0 thread* a_2, const Box_0 thread* b_3)
{
    float3 _S33 = b_3->center_1 - a_2->center_1;
    float3 _S34 = a_2->half_2;
    float3 _S35 = b_3->half_2;
    float _S36 = 0.00000999999974738f * (length(a_2->half_2) + length(b_3->half_2));
    float3 _S37 = a_2->axis0_0;
    float3 _S38 = a_2->axis1_0;
    float3 _S39 = a_2->axis2_0;
    float3 _S40 = b_3->axis0_0;
    float3 _S41 = b_3->axis1_0;
    float3 _S42 = b_3->axis2_0;
    array<float3, int(6)> _S43 = { { a_2->axis0_0, a_2->axis1_0, a_2->axis2_0, b_3->axis0_0, b_3->axis1_0, b_3->axis2_0 } };
    uint i_0 = 0U;
    for(;;)
    {
        if(i_0 < 15U)
        {
        }
        else
        {
            break;
        }
        float3 l_0;
        if(i_0 < 6U)
        {
            l_0 = _S43[i_0];
        }
        else
        {
            uint _S44 = i_0 - 6U;
            l_0 = cross(_S43[_S44 / 3U], _S43[3U + _S44 % 3U]);
        }
        float len_0 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + 1U;
            continue;
        }
        if((abs(dot(_S33, l_0))) > (_S34.x * abs(dot(_S37, l_0)) + _S34.y * abs(dot(_S38, l_0)) + _S34.z * abs(dot(_S39, l_0)) + (_S35.x * abs(dot(_S40, l_0)) + _S35.y * abs(dot(_S41, l_0)) + _S35.z * abs(dot(_S42, l_0))) + _S36 * len_0))
        {
            return false;
        }
        i_0 = i_0 + 1U;
    }
    return true;
}

void chunk_velocity_0(uint c_2, float3 thread* v_3, float3 thread* w_2, KernelContext_0 thread* kernelContext_3)
{
    ChunkStatic_natural_0 device* _S45 = kernelContext_3->chunks_0+c_2;
    Island_natural_0 device* _S46 = kernelContext_3->islands_0+(uint4(_S45->info_1) ).y;
    Quat_0 q_6 = quat_of_0(float4(_S46->rotation_0) );
    uint _S47 = 4U * c_2;
    float3 _S48 = (float4(_S45->center_0) ).xyz + (float4(*(kernelContext_3->state_0+_S47)) ).xyz - (float4(_S46->com_0) ).xyz;
    thread Quat_0 _S49 = q_6;
    float3 _S50 = rotate_0(&_S49, _S48);
    float3 _S51 = (float4(_S46->angular_velocity_0) ).xyz;
    float3 _S52 = (float4(_S46->velocity_0) ).xyz + (float4(_S46->velocity_err_0) ).xyz + cross(_S51, _S50);
    float3 _S53 = (float4(*(kernelContext_3->state_0+(_S47 + 2U))) ).xyz;
    thread Quat_0 _S54 = q_6;
    float3 _S55 = rotate_0(&_S54, _S53);
    *v_3 = _S52 + _S55;
    float3 _S56 = (float4(*(kernelContext_3->state_0+(_S47 + 3U))) ).xyz;
    thread Quat_0 _S57 = q_6;
    float3 _S58 = rotate_0(&_S57, _S56);
    *w_2 = _S51 + _S58;
    return;
}

float3 box_to_world_0(const Box_0 thread* b_4, float3 local_0)
{
    return b_4->axis0_0 * float3(local_0.x)  + b_4->axis1_0 * float3(local_0.y)  + b_4->axis2_0 * float3(local_0.z) ;
}

float3 box_axis_0(const Box_0 thread* b_5, uint k_0)
{
    float3 _S59;
    if(k_0 == 0U)
    {
        _S59 = b_5->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S59 = b_5->axis1_0;
        }
        else
        {
            _S59 = b_5->axis2_0;
        }
    }
    return _S59;
}

float comp3_0(float3 v_4, uint k_1)
{
    float _S60;
    if(k_1 == 0U)
    {
        _S60 = v_4.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S60 = v_4.y;
        }
        else
        {
            _S60 = v_4.z;
        }
    }
    return _S60;
}

float3 sample_point_0(const Box_0 thread* b_6, uint i_1, KernelContext_0 thread* kernelContext_4)
{
    uint _S61 = b_6->hull_v_0;
    if((b_6->hull_v_0) != 0U)
    {
        float3 local_1;
        if(i_1 < _S61)
        {
            local_1 = (float4(*(kernelContext_4->loads_0+(b_6->hull_at_0 + i_1))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_1 = (float4(*(kernelContext_4->loads_0+(b_6->hull_at_0 + _S61 + b_6->hull_f_0 + (i_1 - _S61)))) ).xyz;
        }
        float3 _S62 = b_6->center_1;
        float3 _S63 = box_to_world_0(b_6, local_1);
        return _S62 + _S63;
    }
    float sign_0;
    if(i_1 < 8U)
    {
        float3 h_0 = b_6->half_2 * float3(0.89999997615814209f) ;
        if((i_1 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S64;
        if((i_1 & 2U) == 0U)
        {
            _S64 = - h_0.y;
        }
        else
        {
            _S64 = h_0.y;
        }
        float _S65;
        if((i_1 & 4U) == 0U)
        {
            _S65 = - h_0.z;
        }
        else
        {
            _S65 = h_0.z;
        }
        return b_6->center_1 + b_6->axis0_0 * float3(sign_0)  + b_6->axis1_0 * float3(_S64)  + b_6->axis2_0 * float3(_S65) ;
    }
    uint _S66 = i_1 - 8U;
    uint axis_1 = _S66 / 2U;
    if((_S66 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3 _S67 = b_6->center_1;
    float3 _S68 = box_axis_0(b_6, axis_1);
    return _S67 + _S68 * float3((sign_0 * comp3_0(b_6->half_2, axis_1))) ;
}

float3 sample_point_1(const Box_0 thread* b_7, uint i_2, KernelContext_0 thread* kernelContext_5)
{
    uint _S69 = b_7->hull_v_0;
    if((b_7->hull_v_0) != 0U)
    {
        float3 local_2;
        if(i_2 < _S69)
        {
            local_2 = (float4(*(kernelContext_5->loads_0+(b_7->hull_at_0 + i_2))) ).xyz * float3(0.89999997615814209f) ;
        }
        else
        {
            local_2 = (float4(*(kernelContext_5->loads_0+(b_7->hull_at_0 + _S69 + b_7->hull_f_0 + (i_2 - _S69)))) ).xyz;
        }
        float3 _S70 = b_7->center_1;
        float3 _S71 = box_to_world_0(b_7, local_2);
        return _S70 + _S71;
    }
    float sign_1;
    if(i_2 < 8U)
    {
        float3 h_1 = b_7->half_2 * float3(0.89999997615814209f) ;
        if((i_2 & 1U) == 0U)
        {
            sign_1 = - h_1.x;
        }
        else
        {
            sign_1 = h_1.x;
        }
        float _S72;
        if((i_2 & 2U) == 0U)
        {
            _S72 = - h_1.y;
        }
        else
        {
            _S72 = h_1.y;
        }
        float _S73;
        if((i_2 & 4U) == 0U)
        {
            _S73 = - h_1.z;
        }
        else
        {
            _S73 = h_1.z;
        }
        return b_7->center_1 + b_7->axis0_0 * float3(sign_1)  + b_7->axis1_0 * float3(_S72)  + b_7->axis2_0 * float3(_S73) ;
    }
    uint _S74 = i_2 - 8U;
    uint axis_2 = _S74 / 2U;
    if((_S74 % 2U) == 0U)
    {
        sign_1 = -1.0f;
    }
    else
    {
        sign_1 = 1.0f;
    }
    float3 _S75 = b_7->center_1;
    float3 _S76 = box_axis_0(b_7, axis_2);
    return _S75 + _S76 * float3((sign_1 * comp3_0(b_7->half_2, axis_2))) ;
}

float3 box_to_local_0(const Box_0 thread* b_8, float3 r_1)
{
    return float3(dot(r_1, b_8->axis0_0), dot(r_1, b_8->axis1_0), dot(r_1, b_8->axis2_0));
}

float hull_signed_distance_0(const Box_0 thread* b_9, float3 local_3, uint thread* face_0, KernelContext_0 thread* kernelContext_6)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_0 = 0U;
    for(;;)
    {
        if(f_0 < (b_9->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4 _S77 = float4(*(kernelContext_6->loads_0+(b_9->hull_at_0 + b_9->hull_v_0 + f_0))) ;
        float d_0 = dot(_S77.xyz, local_3) - _S77.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

bool penetration_0(const Box_0 thread* b_10, float3 p_0, float thread* depth_0, float3 thread* normal_1, KernelContext_0 thread* kernelContext_7)
{
    *depth_0 = 0.0f;
    *normal_1 = float3(0.0f) ;
    float3 r_2 = p_0 - b_10->center_1;
    float3 _S78 = b_10->half_2;
    if((dot(r_2, r_2)) > (dot(b_10->half_2, b_10->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S79 = b_10->hull_v_0;
    if((b_10->hull_v_0) != 0U)
    {
        float3 _S80 = box_to_local_0(b_10, r_2);
        thread uint face_1;
        float _S81 = hull_signed_distance_0(b_10, _S80, &face_1, kernelContext_7);
        if(!(_S81 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S81;
        float3 _S82 = box_to_world_0(b_10, (float4(*(kernelContext_7->loads_0+(b_10->hull_at_0 + _S79 + face_1))) ).xyz);
        *normal_1 = _S82;
        return true;
    }
    float best_1 = 1.00000001504746622e+30f;
    uint axis_3 = 0U;
    float side_0 = 1.0f;
    uint k_2 = 0U;
    for(;;)
    {
        if(k_2 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S83 = box_axis_0(b_10, k_2);
        float local_4 = dot(r_2, _S83);
        float d_1 = comp3_0(_S78, k_2) - abs(local_4);
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S84;
            if(local_4 >= 0.0f)
            {
                _S84 = 1.0f;
            }
            else
            {
                _S84 = -1.0f;
            }
            best_1 = d_1;
            axis_3 = k_2;
            side_0 = _S84;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3 _S85 = box_axis_0(b_10, axis_3);
    *normal_1 = _S85 * float3(side_0) ;
    return true;
}

bool penetration_1(const Box_0 thread* b_11, float3 p_1, float thread* depth_1, float3 thread* normal_2, KernelContext_0 thread* kernelContext_8)
{
    *depth_1 = 0.0f;
    *normal_2 = float3(0.0f) ;
    float3 r_3 = p_1 - b_11->center_1;
    float3 _S86 = b_11->half_2;
    if((dot(r_3, r_3)) > (dot(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S87 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3 _S88 = box_to_local_0(b_11, r_3);
        thread uint face_2;
        float _S89 = hull_signed_distance_0(b_11, _S88, &face_2, kernelContext_8);
        if(!(_S89 < 0.0f))
        {
            return false;
        }
        *depth_1 = - _S89;
        float3 _S90 = box_to_world_0(b_11, (float4(*(kernelContext_8->loads_0+(b_11->hull_at_0 + _S87 + face_2))) ).xyz);
        *normal_2 = _S90;
        return true;
    }
    float best_2 = 1.00000001504746622e+30f;
    uint axis_4 = 0U;
    float side_1 = 1.0f;
    uint k_3 = 0U;
    for(;;)
    {
        if(k_3 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S91 = box_axis_0(b_11, k_3);
        float local_5 = dot(r_3, _S91);
        float d_2 = comp3_0(_S86, k_3) - abs(local_5);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_2)
        {
            float _S92;
            if(local_5 >= 0.0f)
            {
                _S92 = 1.0f;
            }
            else
            {
                _S92 = -1.0f;
            }
            best_2 = d_2;
            axis_4 = k_3;
            side_1 = _S92;
        }
        k_3 = k_3 + 1U;
    }
    *depth_1 = best_2;
    float3 _S93 = box_axis_0(b_11, axis_4);
    *normal_2 = _S93 * float3(side_1) ;
    return true;
}

bool pair_point_0(const Box_0 thread* ba_0, const Box_0 thread* bb_0, uint na_0, uint e_0, float3 thread* p_2, float3 thread* n_1, float thread* d_3, KernelContext_0 thread* kernelContext_9)
{
    if(e_0 < na_0)
    {
        float3 _S94 = sample_point_1(ba_0, e_0, kernelContext_9);
        *p_2 = _S94;
        bool _S95 = penetration_1(bb_0, _S94, d_3, n_1, kernelContext_9);
        return _S95;
    }
    float3 _S96 = sample_point_1(bb_0, e_0 - na_0, kernelContext_9);
    *p_2 = _S96;
    bool _S97 = penetration_1(ba_0, _S96, d_3, n_1, kernelContext_9);
    if(!_S97)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

bool is_nan_0(float x_1)
{
    return ((as_type<uint>((x_1))) & 2147483647U) > 2139095040U;
}

float2 half_thickness_and_area_0(const Box_0 thread* b_12, float3 d_4)
{
    uint k_4 = 0U;
    float h_2 = 0.0f;
    float area_0 = 0.0f;
    for(;;)
    {
        if(k_4 < 3U)
        {
        }
        else
        {
            break;
        }
        float3 _S98 = box_axis_0(b_12, k_4);
        float c_3 = abs(dot(d_4, _S98));
        float h_3 = h_2 + c_3 * comp3_0(b_12->half_2, k_4);
        uint _S99 = k_4 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S99 % 3U) * comp3_0(b_12->half_2, (k_4 + 2U) % 3U);
        k_4 = _S99;
        h_2 = h_3;
        area_0 = area_1;
    }
    return float2(h_2, area_0);
}

float contact_stiffness_0(float ea_0, const Box_0 thread* a_3, float eb_0, const Box_0 thread* b_13, float3 dir_0)
{
    float3 d_5 = safe_normalize_0(dir_0);
    float2 _S100 = half_thickness_and_area_0(a_3, d_5);
    float2 _S101 = half_thickness_and_area_0(b_13, d_5);
    return min(_S100.y, _S101.y) / (_S100.x / ea_0 + _S101.x / eb_0);
}

float3 penalty_force_0(float k_5, float m_red_0, float friction_0, float depth_2, float3 normal_3, float3 rel_velocity_0, float dt_1, uint points_0, float thread* stored_0, float thread* dissipated_1, KernelContext_0 thread* kernelContext_10)
{
    float c_max_0 = 1.0f / max(float(points_0), 10.0f) * m_red_0 / dt_1;
    float vn_0 = dot(rel_velocity_0, normal_3);
    float _S102 = k_5 * depth_2;
    float _S103 = min(2.0f * kernelContext_10->params_0->zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    float _S104 = _S102 - _S103;
    float _S105 = max(_S104, 0.0f);
    float3 vt_0 = rel_velocity_0 - normal_3 * float3(vn_0) ;
    float vt_mag_0 = length(vt_0);
    float _S106 = friction_0 * _S105;
    float _S107 = min(_S106, min(c_max_0, _S106 / 0.00100000004749745f) * vt_mag_0);
    float3 ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * float3((_S107 / vt_mag_0)) ;
    }
    else
    {
        ft_0 = float3(0.0f) ;
    }
    *stored_0 = 0.5f * k_5 * depth_2 * depth_2;
    float damping_power_0;
    if(_S104 > 0.0f)
    {
        damping_power_0 = _S103 * vn_0;
    }
    else
    {
        damping_power_0 = _S102 * max(vn_0, 0.0f);
    }
    *dissipated_1 = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * float3(_S105)  + ft_0;
}

void comp_add1_0(float thread* sum_0, float thread* err_0, float x_2)
{
    float t_2 = *sum_0 + x_2;
    if((abs(*sum_0)) >= (abs(x_2)))
    {
        *err_0 = *err_0 + (*sum_0 - t_2 + x_2);
    }
    else
    {
        *err_0 = *err_0 + (x_2 - t_2 + *sum_0);
    }
    *sum_0 = t_2;
    return;
}

void pair_contact_0(uint i_3, KernelContext_0 thread* kernelContext_11)
{
    uint at_0 = kernelContext_11->params_0->pair_index_0 + 6U * i_3;
    uint ca_0 = kernelContext_11->index_0[at_0];
    uint cb_0 = kernelContext_11->index_0[at_0 + 1U];
    uint _S108 = kernelContext_11->index_0[at_0 + 3U];
    float _S109 = (as_type<float>((kernelContext_11->index_0[at_0 + 4U])));
    float _S110 = (as_type<float>((kernelContext_11->index_0[at_0 + 5U])));
    float _S111 = kernelContext_11->params_0->dt_0;
    uint out_0 = kernelContext_11->params_0->slot_base_0 + 2U * kernelContext_11->index_0[at_0 + 2U];
    WorldPoint_0 _S112 = chunk_world_0(ca_0, kernelContext_11);
    WorldPoint_0 _S113 = chunk_world_0(cb_0, kernelContext_11);
    thread WorldPoint_0 _S114 = _S113;
    thread WorldPoint_0 _S115 = _S112;
    float3 _S116 = world_diff_0(&_S114, &_S115);
    bool touching_0 = !((length(_S116)) > ((float4((kernelContext_11->chunks_0+ca_0)->half_0) ).w + (float4((kernelContext_11->chunks_0+cb_0)->half_0) ).w));
    float4 _S117 = float4(*(kernelContext_11->scratch_0+(kernelContext_11->params_0->ledger_base_0 + i_3))) ;
    thread float4 ledger_1 = _S117;
    uint flags_0 = (as_type<uint>((_S117.w)));
    float3 _S118 = float3(0.0f) ;
    Box_0 _S119 = chunk_box_0(ca_0, _S118, kernelContext_11);
    Box_0 _S120 = chunk_box_0(cb_0, _S116, kernelContext_11);
    thread Box_0 _S121 = _S119;
    uint _S122 = sample_count_0(&_S121);
    thread Box_0 _S123 = _S120;
    uint _S124 = sample_count_0(&_S123);
    uint _S125 = _S122 + _S124;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S125)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_11->contact_state_0+(_S108 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                e_1 = e_1 + 1U;
            }
        }
        if((flags_0 & 2U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < 4U)
                {
                }
                else
                {
                    break;
                }
                *(kernelContext_11->scratch_0+(out_0 + e_1)) = packed_float4(float4(0.0f) ) ;
                e_1 = e_1 + 1U;
            }
        }
        if(flags_0 != 0U)
        {
            has_state_0 = true;
        }
        else
        {
            has_state_0 = (ledger_1.x) != 0.0f;
        }
        if(has_state_0)
        {
            ledger_1.x = 0.0f;
            ledger_1.w = (as_type<float>((0U)));
            *(kernelContext_11->scratch_0+(kernelContext_11->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
        }
        return;
    }
    thread Box_0 _S126 = _S119;
    thread Box_0 _S127 = _S120;
    bool _S128 = may_overlap_0(&_S126, &_S127);
    uint count_0;
    float3 fa_0;
    float3 ta_0;
    float3 fb_0;
    float3 tb_0;
    float stored_sum_0;
    if(_S128)
    {
        thread float3 va0_0;
        thread float3 wa0_0;
        chunk_velocity_0(ca_0, &va0_0, &wa0_0, kernelContext_11);
        thread float3 vb0_0;
        thread float3 wb0_0;
        chunk_velocity_0(cb_0, &vb0_0, &wb0_0, kernelContext_11);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S125)
            {
            }
            else
            {
                break;
            }
            thread Box_0 _S129 = _S119;
            thread Box_0 _S130 = _S120;
            thread float3 p_3;
            thread float3 n_2;
            thread float d_6;
            bool _S131 = pair_point_0(&_S129, &_S130, _S122, e_1, &p_3, &n_2, &d_6, kernelContext_11);
            if(!_S131)
            {
                uint _S132 = _S108 + e_1;
                if(!is_nan_0((float4(*(kernelContext_11->contact_state_0+_S132)) ).x))
                {
                    *(kernelContext_11->contact_state_0+_S132) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S133 = count_0 + 1U;
            uint _S134 = _S108 + e_1;
            float4 _S135 = float4(*(kernelContext_11->contact_state_0+_S134)) ;
            thread float4 entry_0 = _S135;
            if(is_nan_0(_S135.x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_6 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - _S120.center_1)), n_2)) * _S111 + 9.99999971718068537e-10f))
                {
                    stored_sum_0 = d_6;
                }
                else
                {
                    stored_sum_0 = 0.0f;
                }
                entry_0 = float4(stored_sum_0, n_2);
            }
            entry_0.x = min(entry_0.x, d_6);
            *(kernelContext_11->contact_state_0+_S134) = packed_float4(entry_0) ;
            uint engaged_1;
            if((d_6 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S133;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float _S136 = (float4((kernelContext_11->chunks_0+ca_0)->cmat_0) ).x;
            float _S137 = (float4((kernelContext_11->chunks_0+cb_0)->cmat_0) ).x;
            float3 _S138 = _S120.center_1 - _S119.center_1;
            thread Box_0 _S139 = _S119;
            thread Box_0 _S140 = _S120;
            float _S141 = contact_stiffness_0(_S136, &_S139, _S137, &_S140, _S138);
            float _S142 = _S141 / max(float(engaged_0), 10.0f);
            e_1 = 0U;
            fa_0 = _S118;
            ta_0 = _S118;
            fb_0 = _S118;
            tb_0 = _S118;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S125)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S143 = _S119;
                thread Box_0 _S144 = _S120;
                thread float3 p_4;
                thread float3 n_3;
                thread float d_7;
                bool _S145 = pair_point_0(&_S143, &_S144, _S122, e_1, &p_4, &n_3, &d_7, kernelContext_11);
                if(!_S145)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_7 - (float4(*(kernelContext_11->contact_state_0+(_S108 + e_1))) ).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                thread float stored_1;
                thread float diss_0;
                float3 _S146 = penalty_force_0(_S142, _S109, _S110, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - _S120.center_1)), _S111, engaged_0, &stored_1, &diss_0, kernelContext_11);
                float3 fa_1 = fa_0 + _S146;
                float3 ta_1 = ta_0 + cross(p_4, _S146);
                float3 _S147 = - _S146;
                float3 fb_1 = fb_0 + _S147;
                float3 tb_1 = tb_0 + cross(p_4 - _S120.center_1, _S147);
                float stored_sum_1 = stored_sum_0 + stored_1;
                thread float _S148 = ledger_1.y;
                thread float _S149 = ledger_1.z;
                comp_add1_0(&_S148, &_S149, diss_0);
                ledger_1.z = _S149;
                ledger_1.y = _S148;
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                e_1 = e_1 + 1U;
            }
            has_state_0 = true;
        }
        else
        {
            has_state_0 = false;
            fa_0 = _S118;
            ta_0 = _S118;
            fb_0 = _S118;
            tb_0 = _S118;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S118;
        ta_0 = _S118;
        fb_0 = _S118;
        tb_0 = _S118;
        stored_sum_0 = 0.0f;
    }
    bool loaded_0;
    if(!has_state_0)
    {
        loaded_0 = (flags_0 & 1U) != 0U;
    }
    else
    {
        loaded_0 = false;
    }
    if(loaded_0)
    {
        e_1 = 0U;
        for(;;)
        {
            if(e_1 < _S125)
            {
            }
            else
            {
                break;
            }
            *(kernelContext_11->contact_state_0+(_S108 + e_1)) = packed_float4(float4((as_type<float>((2143289344U))), 0.0f, 0.0f, 0.0f)) ;
            e_1 = e_1 + 1U;
        }
    }
    float3 _S150 = float3(0.0f) ;
    if(any(fa_0 != _S150))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(ta_0 != _S150);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(fb_0 != _S150);
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any(tb_0 != _S150);
    }
    bool _S151;
    if(loaded_0)
    {
        _S151 = true;
    }
    else
    {
        _S151 = (flags_0 & 2U) != 0U;
    }
    if(_S151)
    {
        *(kernelContext_11->scratch_0+out_0) = packed_float4(float4(fa_0, 0.0f)) ;
        *(kernelContext_11->scratch_0+(out_0 + 1U)) = packed_float4(float4(ta_0, 0.0f)) ;
        *(kernelContext_11->scratch_0+(out_0 + 2U)) = packed_float4(float4(fb_0, 0.0f)) ;
        *(kernelContext_11->scratch_0+(out_0 + 3U)) = packed_float4(float4(tb_0, 0.0f)) ;
    }
    ledger_1.x = stored_sum_0;
    if(has_state_0)
    {
        e_1 = 1U;
    }
    else
    {
        e_1 = 0U;
    }
    if(loaded_0)
    {
        count_0 = 2U;
    }
    else
    {
        count_0 = 0U;
    }
    ledger_1.w = (as_type<float>((e_1 | count_0)));
    *(kernelContext_11->scratch_0+(kernelContext_11->params_0->ledger_base_0 + i_3)) = packed_float4(ledger_1) ;
    return;
}

struct Impactor_0
{
    float4 position_1;
    float4 position_err_1;
    float4 velocity_1;
    float4 velocity_err_1;
    float4 angular_velocity_1;
    float4 rotation_1;
    float4 inertia0_2;
    float4 inertia1_2;
    float4 inertia2_2;
    float4 inv0_2;
    float4 inv1_2;
    float4 inv2_2;
    float4 shape_0;
    float4 half_1;
    float4 mat_0;
    float4 crush_0;
    float4 geom_0;
    float4 unused_0;
    float4 ledger_0;
    uint4 cand_0;
};

Box_0 impactor_box_0(const Impactor_0 thread* imp_0, float3 center_3, float3 half_3)
{
    Quat_0 q_7 = quat_of_0(imp_0->rotation_1);
    thread Box_0 b_14;
    (&b_14)->center_1 = center_3;
    float3 _S152 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S153 = q_7;
    float3 _S154 = rotate_0(&_S153, _S152);
    (&b_14)->axis0_0 = _S154;
    float3 _S155 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S156 = q_7;
    float3 _S157 = rotate_0(&_S156, _S155);
    (&b_14)->axis1_0 = _S157;
    float3 _S158 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S159 = q_7;
    float3 _S160 = rotate_0(&_S159, _S158);
    (&b_14)->axis2_0 = _S160;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

uint impactor_slots_0(const Impactor_natural_0 thread* imp_1, const Box_0 thread* b_15)
{
    uint _S161;
    if(((float4(imp_1->shape_0) ).x) == 0.0f)
    {
        _S161 = 1U;
    }
    else
    {
        uint _S162 = sample_count_0(b_15);
        _S161 = _S162 + 14U;
    }
    return _S161;
}

uint impactor_slots_1(const Impactor_natural_0 thread* imp_2, const Box_0 thread* b_16)
{
    uint _S163;
    if(((float4(imp_2->shape_0) ).x) == 0.0f)
    {
        _S163 = 1U;
    }
    else
    {
        uint _S164 = sample_count_0(b_16);
        _S163 = _S164 + 14U;
    }
    return _S163;
}

bool sphere_contact_0(const Box_0 thread* b_17, float3 center_4, float radius_0, float3 thread* point_0, float3 thread* normal_4, float thread* depth_3, KernelContext_0 thread* kernelContext_12)
{
    float3 _S165 = float3(0.0f) ;
    *point_0 = _S165;
    *normal_4 = _S165;
    *depth_3 = 0.0f;
    float3 _S166 = b_17->center_1;
    float3 r_4 = center_4 - b_17->center_1;
    float3 _S167 = b_17->axis0_0;
    float3 _S168 = b_17->axis1_0;
    float3 _S169 = b_17->axis2_0;
    float3 local_6 = float3(dot(r_4, b_17->axis0_0), dot(r_4, b_17->axis1_0), dot(r_4, b_17->axis2_0));
    uint _S170 = b_17->hull_v_0;
    if((b_17->hull_v_0) != 0U)
    {
        thread uint face_3;
        float _S171 = hull_signed_distance_0(b_17, local_6, &face_3, kernelContext_12);
        if(_S171 >= radius_0)
        {
            return false;
        }
        float3 _S172 = box_to_world_0(b_17, (float4(*(kernelContext_12->loads_0+(b_17->hull_at_0 + _S170 + face_3))) ).xyz);
        *normal_4 = _S172;
        *point_0 = center_4 - _S172 * float3(max(_S171, 0.0f)) ;
        *depth_3 = radius_0 - _S171;
        return true;
    }
    float3 q_8 = clamp(local_6, - b_17->half_2, b_17->half_2);
    float3 d_8 = local_6 - q_8;
    float dist_0 = length(d_8);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3 dn_0 = d_8 / float3(dist_0) ;
        *normal_4 = _S167 * float3(dn_0.x)  + _S168 * float3(dn_0.y)  + _S169 * float3(dn_0.z) ;
        *point_0 = _S166 + _S167 * float3(q_8.x)  + _S168 * float3(q_8.y)  + _S169 * float3(q_8.z) ;
        *depth_3 = radius_0 - dist_0;
        return true;
    }
    thread float inside_0;
    thread float3 n_4;
    bool _S173 = penetration_0(b_17, center_4, &inside_0, &n_4, kernelContext_12);
    if(!_S173)
    {
        return false;
    }
    *normal_4 = n_4;
    *point_0 = center_4 - n_4 * float3(min(radius_0, inside_0)) ;
    *depth_3 = radius_0 + inside_0;
    return true;
}

bool impactor_contact_0(const Impactor_natural_0 thread* imp_3, float crush_depth_0, const Box_0 thread* shrunk_0, const Box_0 thread* b_18, uint j_0, float3 thread* p_5, float3 thread* n_5, float thread* d_9, KernelContext_0 thread* kernelContext_13)
{
    float3 _S174 = float3(0.0f) ;
    *p_5 = _S174;
    *n_5 = _S174;
    *d_9 = 0.0f;
    float4 _S175 = float4(imp_3->shape_0) ;
    if((_S175.x) == 0.0f)
    {
        bool _S176 = sphere_contact_0(b_18, _S174, _S175.y - crush_depth_0, p_5, n_5, d_9, kernelContext_13);
        if(!_S176)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S177 = sample_count_0(b_18);
    if(j_0 < _S177)
    {
        float3 _S178 = sample_point_0(b_18, j_0, kernelContext_13);
        *p_5 = _S178;
        bool _S179 = penetration_0(shrunk_0, _S178, d_9, n_5, kernelContext_13);
        return _S179;
    }
    float3 _S180 = sample_point_0(shrunk_0, j_0 - _S177, kernelContext_13);
    *p_5 = _S180;
    bool _S181 = penetration_0(b_18, _S180, d_9, n_5, kernelContext_13);
    if(!_S181)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

bool impactor_contact_1(const Impactor_natural_0 thread* imp_4, float crush_depth_1, const Box_0 thread* shrunk_1, const Box_0 thread* b_19, uint j_1, float3 thread* p_6, float3 thread* n_6, float thread* d_10, KernelContext_0 thread* kernelContext_14)
{
    float3 _S182 = float3(0.0f) ;
    *p_6 = _S182;
    *n_6 = _S182;
    *d_10 = 0.0f;
    float4 _S183 = float4(imp_4->shape_0) ;
    if((_S183.x) == 0.0f)
    {
        bool _S184 = sphere_contact_0(b_19, _S182, _S183.y - crush_depth_1, p_6, n_6, d_10, kernelContext_14);
        if(!_S184)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S185 = sample_count_0(b_19);
    if(j_1 < _S185)
    {
        float3 _S186 = sample_point_0(b_19, j_1, kernelContext_14);
        *p_6 = _S186;
        bool _S187 = penetration_0(shrunk_1, _S186, d_10, n_6, kernelContext_14);
        return _S187;
    }
    float3 _S188 = sample_point_0(shrunk_1, j_1 - _S185, kernelContext_14);
    *p_6 = _S188;
    bool _S189 = penetration_0(b_19, _S188, d_10, n_6, kernelContext_14);
    if(!_S189)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

WorldPoint_0 impactor_point_0(uint _S190, KernelContext_0 thread* kernelContext_15)
{
    Impactor_natural_0 device* _S191 = kernelContext_15->impactors_0+_S190;
    thread WorldPoint_0 wi_0;
    (&wi_0)->hi_0 = (float4(_S191->position_1) ).xyz;
    (&wi_0)->lo_0 = (float4(_S191->position_err_1) ).xyz;
    (&wi_0)->rel_0 = float3(0.0f) ;
    return wi_0;
}

Box_0 impactor_box_1(uint _S192, float3 _S193, float3 _S194, KernelContext_0 thread* kernelContext_16)
{
    Quat_0 q_9 = quat_of_0(float4((kernelContext_16->impactors_0+_S192)->rotation_1) );
    thread Box_0 b_20;
    (&b_20)->center_1 = _S193;
    float3 _S195 = float3(1.0f, 0.0f, 0.0f);
    thread Quat_0 _S196 = q_9;
    float3 _S197 = rotate_0(&_S196, _S195);
    (&b_20)->axis0_0 = _S197;
    float3 _S198 = float3(0.0f, 1.0f, 0.0f);
    thread Quat_0 _S199 = q_9;
    float3 _S200 = rotate_0(&_S199, _S198);
    (&b_20)->axis1_0 = _S200;
    float3 _S201 = float3(0.0f, 0.0f, 1.0f);
    thread Quat_0 _S202 = q_9;
    float3 _S203 = rotate_0(&_S202, _S201);
    (&b_20)->axis2_0 = _S203;
    (&b_20)->half_2 = _S194;
    (&b_20)->hull_at_0 = 0U;
    (&b_20)->hull_v_0 = 0U;
    (&b_20)->hull_f_0 = 0U;
    return b_20;
}

Box_0 impactor_shrunk_0(uint _S204, float _S205, const Box_0 thread* _S206)
{
    thread Box_0 shrunk_2 = *_S206;
    (&shrunk_2)->half_2 = _S206->half_2 - min(float3(_S205) , _S206->half_2 * float3(0.5f) );
    return shrunk_2;
}

bool impactor_contact_2(uint _S207, float _S208, const Box_0 thread* _S209, const Box_0 thread* _S210, uint _S211, float3 thread* _S212, float3 thread* _S213, float thread* _S214, KernelContext_0 thread* kernelContext_17)
{
    Impactor_natural_0 _S215 = *(kernelContext_17->impactors_0+_S207);
    float3 _S216 = float3(0.0f) ;
    *_S212 = _S216;
    *_S213 = _S216;
    *_S214 = 0.0f;
    float4 _S217 = float4(_S215.shape_0) ;
    if((_S217.x) == 0.0f)
    {
        bool _S218 = sphere_contact_0(_S210, _S216, _S217.y - _S208, _S212, _S213, _S214, kernelContext_17);
        if(!_S218)
        {
            return false;
        }
        *_S213 = - *_S213;
        return true;
    }
    uint _S219 = sample_count_0(_S210);
    if(_S211 < _S219)
    {
        float3 _S220 = sample_point_0(_S210, _S211, kernelContext_17);
        *_S212 = _S220;
        bool _S221 = penetration_0(_S209, _S220, _S214, _S213, kernelContext_17);
        return _S221;
    }
    float3 _S222 = sample_point_0(_S209, _S211 - _S219, kernelContext_17);
    *_S212 = _S222;
    bool _S223 = penetration_0(_S210, _S222, _S214, _S213, kernelContext_17);
    if(!_S223)
    {
        return false;
    }
    *_S213 = - *_S213;
    return true;
}

uint impactor_contact_count_0(uint _S224, float _S225, const Box_0 thread* _S226, const Box_0 thread* _S227, KernelContext_0 thread* kernelContext_18)
{
    thread Impactor_natural_0 _S228 = *(kernelContext_18->impactors_0+_S224);
    uint j_2 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        uint _S229 = impactor_slots_1(&_S228, _S227);
        if(j_2 < _S229)
        {
        }
        else
        {
            break;
        }
        thread float3 p_7;
        thread float3 n_7;
        thread float d_11;
        bool _S230 = impactor_contact_2(_S224, _S225, _S226, _S227, j_2, &p_7, &n_7, &d_11, kernelContext_18);
        if(_S230)
        {
            count_1 = count_1 + 1U;
        }
        j_2 = j_2 + 1U;
    }
    return count_1;
}

void impactor_candidate_forces_0(uint k_6, KernelContext_0 thread* kernelContext_19)
{
    uint _S231 = 3U * k_6;
    uint at_1 = kernelContext_19->params_0->cand_index_0 + _S231;
    uint c_4 = kernelContext_19->index_0[at_1];
    uint slot_0 = kernelContext_19->index_0[at_1 + 1U];
    uint _S232 = kernelContext_19->index_0[at_1 + 2U];
    thread Impactor_natural_0 _S233 = *(kernelContext_19->impactors_0+_S232);
    float _S234 = kernelContext_19->params_0->dt_0;
    float3 _S235 = float3(0.0f) ;
    thread float4 data_0 = float4(*(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231))) ;
    float3 f_sum_0;
    float3 t_sum_0;
    float3 imp_f_0;
    float3 imp_t_0;
    if(((uint4((&_S233)->cand_0) ).z) == 0U)
    {
        WorldPoint_0 _S236 = chunk_world_0(c_4, kernelContext_19);
        WorldPoint_0 _S237 = impactor_point_0(_S232, kernelContext_19);
        thread WorldPoint_0 _S238 = _S236;
        thread WorldPoint_0 _S239 = _S237;
        float3 _S240 = world_diff_0(&_S238, &_S239);
        float4 _S241 = float4((&_S233)->half_1) ;
        if(!((length(_S240)) > (_S241.w + (float4((kernelContext_19->chunks_0+c_4)->half_0) ).w)))
        {
            Box_0 _S242 = impactor_box_1(_S232, _S235, _S241.xyz, kernelContext_19);
            Box_0 _S243 = chunk_box_0(c_4, _S240, kernelContext_19);
            float4 _S244 = float4((&_S233)->mat_0) ;
            float _S245 = _S244.x;
            float _S246 = (float4((kernelContext_19->chunks_0+c_4)->cmat_0) ).x;
            float3 _S247 = _S243.center_1 - _S242.center_1;
            thread Box_0 _S248 = _S242;
            thread Box_0 _S249 = _S243;
            float _S250 = contact_stiffness_0(_S245, &_S248, _S246, &_S249, _S247);
            float4 _S251 = float4((&_S233)->geom_0) ;
            float _S252 = _S251.y;
            thread Box_0 _S253 = _S242;
            Box_0 _S254 = impactor_shrunk_0(_S232, _S252, &_S253);
            thread Box_0 _S255 = _S254;
            thread Box_0 _S256 = _S243;
            uint _S257 = impactor_contact_count_0(_S232, _S252, &_S255, &_S256, kernelContext_19);
            bool _S258 = ((float4((&_S233)->shape_0) ).x) == 0.0f;
            float _S259;
            if(_S258)
            {
                _S259 = _S250;
            }
            else
            {
                _S259 = _S250 / max(float(_S257), 10.0f);
            }
            uint _S260;
            if(_S258)
            {
                _S260 = 1U;
            }
            else
            {
                _S260 = _S257;
            }
            float m_1 = (float4((kernelContext_19->chunks_0+c_4)->center_0) ).w;
            float _S261 = _S244.z;
            float _S262 = m_1 * _S261 / (m_1 + _S261);
            float _S263;
            if((kernelContext_19->params_0->pair_friction_0) >= 0.0f)
            {
                _S263 = kernelContext_19->params_0->pair_friction_0;
            }
            else
            {
                _S263 = min(_S244.y, (float4((kernelContext_19->chunks_0+c_4)->cmat_0) ).y);
            }
            float3 _S264 = (float4((&_S233)->velocity_1) ).xyz + (float4((&_S233)->velocity_err_1) ).xyz;
            thread float3 vc_0;
            thread float3 wc_0;
            chunk_velocity_0(c_4, &vc_0, &wc_0, kernelContext_19);
            uint j_3 = 0U;
            f_sum_0 = _S235;
            t_sum_0 = _S235;
            imp_f_0 = _S235;
            imp_t_0 = _S235;
            for(;;)
            {
                bool _S265;
                if(_S257 > 0U)
                {
                    thread Box_0 _S266 = _S243;
                    uint _S267 = impactor_slots_0(&_S233, &_S266);
                    _S265 = j_3 < _S267;
                }
                else
                {
                    _S265 = false;
                }
                if(_S265)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S268 = _S254;
                thread Box_0 _S269 = _S243;
                thread float3 p_8;
                thread float3 nrm_0;
                thread float dep_0;
                bool _S270 = impactor_contact_0(&_S233, _S252, &_S268, &_S269, j_3, &p_8, &nrm_0, &dep_0, kernelContext_19);
                if(!_S270)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                thread float stored_2;
                thread float diss_1;
                float3 _S271 = penalty_force_0(_S259, _S262, _S263, dep_0 * _S251.x, nrm_0, vc_0 + cross(wc_0, p_8 - _S243.center_1) - (_S264 + cross((float4((&_S233)->angular_velocity_1) ).xyz, p_8)), _S234, _S260, &stored_2, &diss_1, kernelContext_19);
                float3 f_sum_1 = f_sum_0 + _S271;
                float3 t_sum_1 = t_sum_0 + cross(p_8 - _S243.center_1, _S271);
                float3 imp_f_1 = imp_f_0 - _S271;
                float3 imp_t_1 = imp_t_0 - cross(p_8, _S271);
                thread float _S272 = data_0.z;
                thread float _S273 = data_0.w;
                comp_add1_0(&_S272, &_S273, diss_1);
                data_0.w = _S273;
                data_0.z = _S272;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + 1U;
            }
        }
        else
        {
            f_sum_0 = _S235;
            t_sum_0 = _S235;
            imp_f_0 = _S235;
            imp_t_0 = _S235;
        }
    }
    else
    {
        f_sum_0 = _S235;
        t_sum_0 = _S235;
        imp_f_0 = _S235;
        imp_t_0 = _S235;
    }
    uint _S274 = 2U * slot_0;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->slot_base_0 + _S274)) = packed_float4(float4(f_sum_0, 0.0f)) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->slot_base_0 + _S274 + 1U)) = packed_float4(float4(t_sum_0, 0.0f)) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231)) = packed_float4(data_0) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231 + 1U)) = packed_float4(float4(imp_f_0, 0.0f)) ;
    *(kernelContext_19->scratch_0+(kernelContext_19->params_0->cand_base_0 + _S231 + 2U)) = packed_float4(float4(imp_t_0, 0.0f)) ;
    return;
}

void travel_check_0(uint c_5, KernelContext_0 thread* kernelContext_20)
{
    ChunkStatic_natural_0 device* _S275 = kernelContext_20->chunks_0+c_5;
    if(((uint4(_S275->cinfo_0) ).z) == 0U)
    {
        return;
    }
    WorldPoint_0 _S276 = chunk_world_0(c_5, kernelContext_20);
    float4 _S277 = float4(_S275->start_hi_0) ;
    if((length(_S276.hi_0 - _S277.xyz + (_S276.lo_0 - (float4(_S275->start_lo_0) ).xyz) + _S276.rel_0)) > (_S277.w))
    {
        (kernelContext_20->islands_0+kernelContext_20->params_0->halt_index_0)->info_0[int(2)] = ((uint4((kernelContext_20->islands_0+kernelContext_20->params_0->halt_index_0)->info_0) ).z) | 1U;
    }
    return;
}

[[kernel]] void contact_forces(uint3 id_0 [[thread_position_in_grid]], Params_0 constant* params_1 [[buffer(0)]], Island_natural_0 device* islands_1 [[buffer(9)]], uint device* index_1 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_1 [[buffer(3)]], packed_float4 device* state_1 [[buffer(6)]], packed_float4 device* scratch_1 [[buffer(8)]], packed_float4 device* contact_state_1 [[buffer(11)]], packed_float4 device* loads_1 [[buffer(5)]], Impactor_natural_0 device* impactors_1 [[buffer(10)]], BondStatic_natural_0 device* bonds_1 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_1 [[buffer(7)]], MaterialTable_0 constant* materials_1 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_21;
    (&kernelContext_21)->params_0 = params_1;
    (&kernelContext_21)->islands_0 = islands_1;
    (&kernelContext_21)->index_0 = index_1;
    (&kernelContext_21)->chunks_0 = chunks_1;
    (&kernelContext_21)->state_0 = state_1;
    (&kernelContext_21)->scratch_0 = scratch_1;
    (&kernelContext_21)->contact_state_0 = contact_state_1;
    (&kernelContext_21)->loads_0 = loads_1;
    (&kernelContext_21)->impactors_0 = impactors_1;
    (&kernelContext_21)->bonds_0 = bonds_1;
    (&kernelContext_21)->bond_dyn_0 = bond_dyn_1;
    (&kernelContext_21)->materials_0 = materials_1;
    threadgroup array<float4, int(256)> g_red_a_1;
    (&kernelContext_21)->g_red_a_0 = &g_red_a_1;
    threadgroup array<float4, int(256)> g_red_b_1;
    (&kernelContext_21)->g_red_b_0 = &g_red_b_1;
    threadgroup uint g_run_1;
    (&kernelContext_21)->g_run_0 = &g_run_1;
    threadgroup uint g_halt_1;
    (&kernelContext_21)->g_halt_0 = &g_halt_1;
    threadgroup uint g_wide_run_1;
    (&kernelContext_21)->g_wide_run_0 = &g_wide_run_1;
    uint i_4 = id_0.x;
    bool _S278 = stopped_0(&kernelContext_21);
    if(_S278)
    {
        return;
    }
    if(i_4 < ((&kernelContext_21)->params_0->pair_count_0))
    {
        pair_contact_0(i_4, &kernelContext_21);
    }
    else
    {
        if(i_4 < ((&kernelContext_21)->params_0->pair_count_0 + (&kernelContext_21)->params_0->cand_count_0))
        {
            impactor_candidate_forces_0(i_4 - (&kernelContext_21)->params_0->pair_count_0, &kernelContext_21);
        }
        else
        {
            if(i_4 < ((&kernelContext_21)->params_0->pair_count_0 + (&kernelContext_21)->params_0->cand_count_0 + (&kernelContext_21)->params_0->chunk_count_0))
            {
                travel_check_0(i_4 - (&kernelContext_21)->params_0->pair_count_0 - (&kernelContext_21)->params_0->cand_count_0, &kernelContext_21);
            }
        }
    }
    return;
}

[[kernel]] void impactor_shares(uint3 id_1 [[thread_position_in_grid]], Params_0 constant* params_2 [[buffer(0)]], Island_natural_0 device* islands_2 [[buffer(9)]], uint device* index_2 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_2 [[buffer(3)]], packed_float4 device* state_2 [[buffer(6)]], packed_float4 device* scratch_2 [[buffer(8)]], packed_float4 device* contact_state_2 [[buffer(11)]], packed_float4 device* loads_2 [[buffer(5)]], Impactor_natural_0 device* impactors_2 [[buffer(10)]], BondStatic_natural_0 device* bonds_2 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_2 [[buffer(7)]], MaterialTable_0 constant* materials_2 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_22;
    (&kernelContext_22)->params_0 = params_2;
    (&kernelContext_22)->islands_0 = islands_2;
    (&kernelContext_22)->index_0 = index_2;
    (&kernelContext_22)->chunks_0 = chunks_2;
    (&kernelContext_22)->state_0 = state_2;
    (&kernelContext_22)->scratch_0 = scratch_2;
    (&kernelContext_22)->contact_state_0 = contact_state_2;
    (&kernelContext_22)->loads_0 = loads_2;
    (&kernelContext_22)->impactors_0 = impactors_2;
    (&kernelContext_22)->bonds_0 = bonds_2;
    (&kernelContext_22)->bond_dyn_0 = bond_dyn_2;
    (&kernelContext_22)->materials_0 = materials_2;
    threadgroup array<float4, int(256)> g_red_a_2;
    (&kernelContext_22)->g_red_a_0 = &g_red_a_2;
    threadgroup array<float4, int(256)> g_red_b_2;
    (&kernelContext_22)->g_red_b_0 = &g_red_b_2;
    threadgroup uint g_run_2;
    (&kernelContext_22)->g_run_0 = &g_run_2;
    threadgroup uint g_halt_2;
    (&kernelContext_22)->g_halt_0 = &g_halt_2;
    threadgroup uint g_wide_run_2;
    (&kernelContext_22)->g_wide_run_0 = &g_wide_run_2;
    uint k_7 = id_1.x;
    bool _S279;
    if(k_7 >= (params_2->cand_count_0))
    {
        _S279 = true;
    }
    else
    {
        bool _S280 = stopped_0(&kernelContext_22);
        _S279 = _S280;
    }
    if(_S279)
    {
        return;
    }
    uint _S281 = 3U * k_7;
    uint at_2 = (&kernelContext_22)->params_0->cand_index_0 + _S281;
    uint c_6 = (&kernelContext_22)->index_0[at_2];
    uint _S282 = (&kernelContext_22)->index_0[at_2 + 2U];
    thread Impactor_natural_0 _S283 = *((&kernelContext_22)->impactors_0+_S282);
    if(((uint4((&_S283)->cand_0) ).z) == 0U)
    {
        _S279 = ((float4((&_S283)->crush_0) ).x) > 0.0f;
    }
    else
    {
        _S279 = false;
    }
    float total_0;
    float ksum_0;
    if(_S279)
    {
        WorldPoint_0 _S284 = chunk_world_0(c_6, &kernelContext_22);
        WorldPoint_0 _S285 = impactor_point_0(_S282, &kernelContext_22);
        thread WorldPoint_0 _S286 = _S284;
        thread WorldPoint_0 _S287 = _S285;
        float3 _S288 = world_diff_0(&_S286, &_S287);
        float4 _S289 = float4((&_S283)->half_1) ;
        if(!((length(_S288)) > (_S289.w + (float4(((&kernelContext_22)->chunks_0+c_6)->half_0) ).w)))
        {
            Box_0 _S290 = impactor_box_1(_S282, float3(0.0f) , _S289.xyz, &kernelContext_22);
            Box_0 _S291 = chunk_box_0(c_6, _S288, &kernelContext_22);
            float _S292 = (float4((&_S283)->mat_0) ).x;
            float _S293 = (float4(((&kernelContext_22)->chunks_0+c_6)->cmat_0) ).x;
            float3 _S294 = _S291.center_1 - _S290.center_1;
            thread Box_0 _S295 = _S290;
            thread Box_0 _S296 = _S291;
            float _S297 = contact_stiffness_0(_S292, &_S295, _S293, &_S296, _S294);
            float _S298 = (float4((&_S283)->crush_0) ).w;
            thread Box_0 _S299 = _S290;
            Box_0 _S300 = impactor_shrunk_0(_S282, _S298, &_S299);
            thread Box_0 _S301 = _S300;
            thread Box_0 _S302 = _S291;
            uint _S303 = impactor_contact_count_0(_S282, _S298, &_S301, &_S302, &kernelContext_22);
            float _S304;
            if(((float4((&_S283)->shape_0) ).x) == 0.0f)
            {
                _S304 = _S297;
            }
            else
            {
                _S304 = _S297 / max(float(_S303), 10.0f);
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S303 > 0U)
                {
                    thread Box_0 _S305 = _S291;
                    uint _S306 = impactor_slots_0(&_S283, &_S305);
                    _S279 = j_4 < _S306;
                }
                else
                {
                    _S279 = false;
                }
                if(_S279)
                {
                }
                else
                {
                    break;
                }
                thread Box_0 _S307 = _S300;
                thread Box_0 _S308 = _S291;
                thread float3 p_9;
                thread float3 nrm_1;
                thread float dep_1;
                bool _S309 = impactor_contact_1(&_S283, _S298, &_S307, &_S308, j_4, &p_9, &nrm_1, &dep_1, &kernelContext_22);
                if(!_S309)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S304;
                total_0 = total_0 + _S304 * dep_1;
                ksum_0 = ksum_1;
                j_4 = j_4 + 1U;
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
    float4 _S310 = float4(*((&kernelContext_22)->scratch_0+((&kernelContext_22)->params_0->cand_base_0 + _S281))) ;
    *((&kernelContext_22)->scratch_0+((&kernelContext_22)->params_0->cand_base_0 + _S281)) = packed_float4(float4(total_0, ksum_0, _S310.z, _S310.w)) ;
    return;
}

void group_sum2_0(uint tid_0, float4 thread* a_4, float4 thread* b_21, KernelContext_0 thread* kernelContext_23)
{
    (*kernelContext_23->g_red_a_0)[tid_0] = *a_4;
    (*kernelContext_23->g_red_b_0)[tid_0] = *b_21;
    threadgroup_barrier(mem_flags::mem_threadgroup);
    uint s_1 = 128U;
    for(;;)
    {
        if(s_1 > 0U)
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_1)
        {
            uint _S311 = tid_0 + s_1;
            (*kernelContext_23->g_red_a_0)[tid_0] = (*kernelContext_23->g_red_a_0)[tid_0] + (*kernelContext_23->g_red_a_0)[_S311];
            (*kernelContext_23->g_red_b_0)[tid_0] = (*kernelContext_23->g_red_b_0)[tid_0] + (*kernelContext_23->g_red_b_0)[_S311];
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
        s_1 = s_1 >> 1U;
    }
    *a_4 = (*kernelContext_23->g_red_a_0)[int(0)];
    *b_21 = (*kernelContext_23->g_red_b_0)[int(0)];
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return;
}

[[kernel]] void impactor_crush(uint3 group_0 [[threadgroup_position_in_grid]], uint3 thread_0 [[thread_position_in_threadgroup]], Params_0 constant* params_3 [[buffer(0)]], Island_natural_0 device* islands_3 [[buffer(9)]], uint device* index_3 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_3 [[buffer(3)]], packed_float4 device* state_3 [[buffer(6)]], packed_float4 device* scratch_3 [[buffer(8)]], packed_float4 device* contact_state_3 [[buffer(11)]], packed_float4 device* loads_3 [[buffer(5)]], Impactor_natural_0 device* impactors_3 [[buffer(10)]], BondStatic_natural_0 device* bonds_3 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_3 [[buffer(7)]], MaterialTable_0 constant* materials_3 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_24;
    (&kernelContext_24)->params_0 = params_3;
    (&kernelContext_24)->islands_0 = islands_3;
    (&kernelContext_24)->index_0 = index_3;
    (&kernelContext_24)->chunks_0 = chunks_3;
    (&kernelContext_24)->state_0 = state_3;
    (&kernelContext_24)->scratch_0 = scratch_3;
    (&kernelContext_24)->contact_state_0 = contact_state_3;
    (&kernelContext_24)->loads_0 = loads_3;
    (&kernelContext_24)->impactors_0 = impactors_3;
    (&kernelContext_24)->bonds_0 = bonds_3;
    (&kernelContext_24)->bond_dyn_0 = bond_dyn_3;
    (&kernelContext_24)->materials_0 = materials_3;
    threadgroup array<float4, int(256)> g_red_a_3;
    (&kernelContext_24)->g_red_a_0 = &g_red_a_3;
    threadgroup array<float4, int(256)> g_red_b_3;
    (&kernelContext_24)->g_red_b_0 = &g_red_b_3;
    threadgroup uint g_run_3;
    (&kernelContext_24)->g_run_0 = &g_run_3;
    threadgroup uint g_halt_3;
    (&kernelContext_24)->g_halt_0 = &g_halt_3;
    threadgroup uint g_wide_run_3;
    (&kernelContext_24)->g_wide_run_0 = &g_wide_run_3;
    uint ii_0 = group_0.x;
    uint tid_1 = thread_0.x;
    bool _S312;
    if(ii_0 >= (params_3->impactor_count_0))
    {
        _S312 = true;
    }
    else
    {
        bool _S313 = stopped_0(&kernelContext_24);
        _S312 = _S313;
    }
    if(_S312)
    {
        return;
    }
    Impactor_natural_0 device* _S314 = (&kernelContext_24)->impactors_0+ii_0;
    float4 _S315 = float4((*_S314).position_err_1) ;
    float4 _S316 = float4((*_S314).velocity_1) ;
    float4 _S317 = float4((*_S314).velocity_err_1) ;
    float4 _S318 = float4((*_S314).angular_velocity_1) ;
    float4 _S319 = float4((*_S314).rotation_1) ;
    float4 _S320 = float4((*_S314).inertia0_2) ;
    float4 _S321 = float4((*_S314).inertia1_2) ;
    float4 _S322 = float4((*_S314).inertia2_2) ;
    float4 _S323 = float4((*_S314).inv0_2) ;
    float4 _S324 = float4((*_S314).inv1_2) ;
    float4 _S325 = float4((*_S314).inv2_2) ;
    float4 _S326 = float4((*_S314).shape_0) ;
    float4 _S327 = float4((*_S314).half_1) ;
    float4 _S328 = float4((*_S314).mat_0) ;
    float4 _S329 = float4((*_S314).crush_0) ;
    float4 _S330 = float4((*_S314).geom_0) ;
    float4 _S331 = float4((*_S314).unused_0) ;
    float4 _S332 = float4((*_S314).ledger_0) ;
    uint4 _S333 = uint4((*_S314).cand_0) ;
    thread Impactor_0 imp_5;
    (&imp_5)->position_1 = float4((*_S314).position_1) ;
    (&imp_5)->position_err_1 = _S315;
    (&imp_5)->velocity_1 = _S316;
    (&imp_5)->velocity_err_1 = _S317;
    (&imp_5)->angular_velocity_1 = _S318;
    (&imp_5)->rotation_1 = _S319;
    (&imp_5)->inertia0_2 = _S320;
    (&imp_5)->inertia1_2 = _S321;
    (&imp_5)->inertia2_2 = _S322;
    (&imp_5)->inv0_2 = _S323;
    (&imp_5)->inv1_2 = _S324;
    (&imp_5)->inv2_2 = _S325;
    (&imp_5)->shape_0 = _S326;
    (&imp_5)->half_1 = _S327;
    (&imp_5)->mat_0 = _S328;
    (&imp_5)->crush_0 = _S329;
    (&imp_5)->geom_0 = _S330;
    (&imp_5)->unused_0 = _S331;
    (&imp_5)->ledger_0 = _S332;
    (&imp_5)->cand_0 = _S333;
    float4 _S334 = float4(0.0f) ;
    thread float4 shares_0 = _S334;
    thread float4 unused_1 = _S334;
    uint k_8 = (&imp_5)->cand_0.x + tid_1;
    for(;;)
    {
        if(k_8 < ((&imp_5)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + float4(*((&kernelContext_24)->scratch_0+((&kernelContext_24)->params_0->cand_base_0 + 3U * k_8))) ;
        k_8 = k_8 + 256U;
    }
    group_sum2_0(tid_1, &shares_0, &unused_1, &kernelContext_24);
    if(tid_1 != 0U)
    {
        _S312 = true;
    }
    else
    {
        _S312 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S312)
    {
        return;
    }
    (&imp_5)->geom_0 = float4(1.0f, (&imp_5)->crush_0.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_0.x) > 0.0f)
    {
        _S312 = ((&imp_5)->crush_0.z) < ((&imp_5)->crush_0.y);
    }
    else
    {
        _S312 = false;
    }
    if(_S312)
    {
        _S312 = total_1 > ((&imp_5)->crush_0.x);
    }
    else
    {
        _S312 = false;
    }
    if(_S312)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_0.x) / shares_0.y;
        (&imp_5)->crush_0.w = (&imp_5)->crush_0.w + extra_0;
        (&imp_5)->crush_0.z = (&imp_5)->crush_0.z + (&imp_5)->crush_0.x * extra_0;
        float _S335 = (&imp_5)->crush_0.x * extra_0;
        thread float _S336 = (&imp_5)->ledger_0.z;
        thread float _S337 = (&imp_5)->ledger_0.w;
        comp_add1_0(&_S336, &_S337, _S335);
        (&imp_5)->ledger_0.w = _S337;
        (&imp_5)->ledger_0.z = _S336;
        float _S338 = (&imp_5)->crush_0.x * extra_0;
        thread float _S339 = (&imp_5)->ledger_0.x;
        thread float _S340 = (&imp_5)->ledger_0.y;
        comp_add1_0(&_S339, &_S340, _S338);
        (&imp_5)->ledger_0.y = _S340;
        (&imp_5)->ledger_0.x = _S339;
        (&imp_5)->geom_0.x = (&imp_5)->crush_0.x / total_1;
    }
    Impactor_natural_0 device* _S341 = (&kernelContext_24)->impactors_0+ii_0;
    _S341->position_1 = packed_float4(imp_5.position_1) ;
    _S341->position_err_1 = packed_float4(imp_5.position_err_1) ;
    _S341->velocity_1 = packed_float4(imp_5.velocity_1) ;
    _S341->velocity_err_1 = packed_float4(imp_5.velocity_err_1) ;
    _S341->angular_velocity_1 = packed_float4(imp_5.angular_velocity_1) ;
    _S341->rotation_1 = packed_float4(imp_5.rotation_1) ;
    _S341->inertia0_2 = packed_float4(imp_5.inertia0_2) ;
    _S341->inertia1_2 = packed_float4(imp_5.inertia1_2) ;
    _S341->inertia2_2 = packed_float4(imp_5.inertia2_2) ;
    _S341->inv0_2 = packed_float4(imp_5.inv0_2) ;
    _S341->inv1_2 = packed_float4(imp_5.inv1_2) ;
    _S341->inv2_2 = packed_float4(imp_5.inv2_2) ;
    _S341->shape_0 = packed_float4(imp_5.shape_0) ;
    _S341->half_1 = packed_float4(imp_5.half_1) ;
    _S341->mat_0 = packed_float4(imp_5.mat_0) ;
    _S341->crush_0 = packed_float4(imp_5.crush_0) ;
    _S341->geom_0 = packed_float4(imp_5.geom_0) ;
    _S341->unused_0 = packed_float4(imp_5.unused_0) ;
    _S341->ledger_0 = packed_float4(imp_5.ledger_0) ;
    _S341->cand_0 = packed_uint4(imp_5.cand_0) ;
    return;
}

void comp_add_0(float3 thread* sum_1, float3 thread* err_1, float3 x_3)
{
    float3 t_3 = *sum_1 + x_3;
    float3 _S342 = abs(x_3);
    *err_1 = *err_1 + (select(x_3, *sum_1, (abs(*sum_1)) >= _S342) - t_3 + select(*sum_1, x_3, (abs(*sum_1)) >= _S342));
    *sum_1 = t_3;
    return;
}

float3 inverse_rotate_0(const Quat_0 thread* q_10, float3 v_5)
{
    thread Quat_0 c_7;
    (&c_7)->w_0 = q_10->w_0;
    (&c_7)->x_0 = - q_10->x_0;
    (&c_7)->y_0 = - q_10->y_0;
    (&c_7)->z_0 = - q_10->z_0;
    thread Quat_0 _S343 = c_7;
    float3 _S344 = rotate_0(&_S343, v_5);
    return _S344;
}

float3 inverse_rotate_1(const Quat_0 thread* q_11, float3 v_6)
{
    thread Quat_0 c_8;
    (&c_8)->w_0 = q_11->w_0;
    (&c_8)->x_0 = - q_11->x_0;
    (&c_8)->y_0 = - q_11->y_0;
    (&c_8)->z_0 = - q_11->z_0;
    thread Quat_0 _S345 = c_8;
    float3 _S346 = rotate_0(&_S345, v_6);
    return _S346;
}

float3 rows_mul_0(float4 r0_0, float4 r1_0, float4 r2_0, float3 v_7)
{
    return float3(dot(r0_0.xyz, v_7), dot(r1_0.xyz, v_7), dot(r2_0.xyz, v_7));
}

float3 world_mul_0(const Quat_0 thread* q_12, float4 r0_1, float4 r1_1, float4 r2_1, float3 v_8)
{
    float3 _S347 = inverse_rotate_1(q_12, v_8);
    float3 _S348 = rotate_1(q_12, rows_mul_0(r0_1, r1_1, r2_1, _S347));
    return _S348;
}

Quat_0 quat_mul_0(const Quat_0 thread* a_5, const Quat_0 thread* o_0)
{
    thread Quat_0 r_5;
    (&r_5)->w_0 = a_5->w_0 * o_0->w_0 - a_5->x_0 * o_0->x_0 - a_5->y_0 * o_0->y_0 - a_5->z_0 * o_0->z_0;
    (&r_5)->x_0 = a_5->w_0 * o_0->x_0 + a_5->x_0 * o_0->w_0 + a_5->y_0 * o_0->z_0 - a_5->z_0 * o_0->y_0;
    (&r_5)->y_0 = a_5->w_0 * o_0->y_0 - a_5->x_0 * o_0->z_0 + a_5->y_0 * o_0->w_0 + a_5->z_0 * o_0->x_0;
    (&r_5)->z_0 = a_5->w_0 * o_0->z_0 + a_5->x_0 * o_0->y_0 - a_5->y_0 * o_0->x_0 + a_5->z_0 * o_0->w_0;
    return r_5;
}

Quat_0 normalized_0(const Quat_0 thread* q_13)
{
    float n_8 = sqrt(q_13->w_0 * q_13->w_0 + q_13->x_0 * q_13->x_0 + q_13->y_0 * q_13->y_0 + q_13->z_0 * q_13->z_0);
    thread Quat_0 r_6;
    (&r_6)->w_0 = q_13->w_0 / n_8;
    (&r_6)->x_0 = q_13->x_0 / n_8;
    (&r_6)->y_0 = q_13->y_0 / n_8;
    (&r_6)->z_0 = q_13->z_0 / n_8;
    return r_6;
}

Quat_0 integrate_rotation_0(const Quat_0 thread* q_14, float3 omega_0, float dt_2)
{
    float angle_1 = length(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_14;
    }
    thread Quat_0 _S349 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S350 = quat_mul_0(&_S349, q_14);
    thread Quat_0 _S351 = _S350;
    Quat_0 _S352 = normalized_0(&_S351);
    return _S352;
}

float4 quat_vec_0(const Quat_0 thread* q_15)
{
    return float4(q_15->x_0, q_15->y_0, q_15->z_0, q_15->w_0);
}

[[kernel]] void impactor_integrate(uint3 group_1 [[threadgroup_position_in_grid]], uint3 thread_1 [[thread_position_in_threadgroup]], Params_0 constant* params_4 [[buffer(0)]], Island_natural_0 device* islands_4 [[buffer(9)]], uint device* index_4 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_4 [[buffer(3)]], packed_float4 device* state_4 [[buffer(6)]], packed_float4 device* scratch_4 [[buffer(8)]], packed_float4 device* contact_state_4 [[buffer(11)]], packed_float4 device* loads_4 [[buffer(5)]], Impactor_natural_0 device* impactors_4 [[buffer(10)]], BondStatic_natural_0 device* bonds_4 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_4 [[buffer(7)]], MaterialTable_0 constant* materials_4 [[buffer(1)]])
{
    float3 p_10;
    thread KernelContext_0 kernelContext_25;
    (&kernelContext_25)->params_0 = params_4;
    (&kernelContext_25)->islands_0 = islands_4;
    (&kernelContext_25)->index_0 = index_4;
    (&kernelContext_25)->chunks_0 = chunks_4;
    (&kernelContext_25)->state_0 = state_4;
    (&kernelContext_25)->scratch_0 = scratch_4;
    (&kernelContext_25)->contact_state_0 = contact_state_4;
    (&kernelContext_25)->loads_0 = loads_4;
    (&kernelContext_25)->impactors_0 = impactors_4;
    (&kernelContext_25)->bonds_0 = bonds_4;
    (&kernelContext_25)->bond_dyn_0 = bond_dyn_4;
    (&kernelContext_25)->materials_0 = materials_4;
    threadgroup array<float4, int(256)> g_red_a_4;
    (&kernelContext_25)->g_red_a_0 = &g_red_a_4;
    threadgroup array<float4, int(256)> g_red_b_4;
    (&kernelContext_25)->g_red_b_0 = &g_red_b_4;
    threadgroup uint g_run_4;
    (&kernelContext_25)->g_run_0 = &g_run_4;
    threadgroup uint g_halt_4;
    (&kernelContext_25)->g_halt_0 = &g_halt_4;
    threadgroup uint g_wide_run_4;
    (&kernelContext_25)->g_wide_run_0 = &g_wide_run_4;
    uint ii_1 = group_1.x;
    uint tid_2 = thread_1.x;
    if(ii_1 >= (params_4->impactor_count_0))
    {
        return;
    }
    Island_natural_0 device* _S353 = (&kernelContext_25)->islands_0+(&kernelContext_25)->params_0->halt_index_0;
    Impactor_natural_0 device* _S354 = (&kernelContext_25)->impactors_0+ii_1;
    float4 _S355 = float4((*_S354).position_err_1) ;
    float4 _S356 = float4((*_S354).velocity_1) ;
    float4 _S357 = float4((*_S354).velocity_err_1) ;
    float4 _S358 = float4((*_S354).angular_velocity_1) ;
    float4 _S359 = float4((*_S354).rotation_1) ;
    float4 _S360 = float4((*_S354).inertia0_2) ;
    float4 _S361 = float4((*_S354).inertia1_2) ;
    float4 _S362 = float4((*_S354).inertia2_2) ;
    float4 _S363 = float4((*_S354).inv0_2) ;
    float4 _S364 = float4((*_S354).inv1_2) ;
    float4 _S365 = float4((*_S354).inv2_2) ;
    float4 _S366 = float4((*_S354).shape_0) ;
    float4 _S367 = float4((*_S354).half_1) ;
    float4 _S368 = float4((*_S354).mat_0) ;
    float4 _S369 = float4((*_S354).crush_0) ;
    float4 _S370 = float4((*_S354).geom_0) ;
    float4 _S371 = float4((*_S354).unused_0) ;
    float4 _S372 = float4((*_S354).ledger_0) ;
    uint4 _S373 = uint4((*_S354).cand_0) ;
    thread Impactor_0 imp_6;
    (&imp_6)->position_1 = float4((*_S354).position_1) ;
    (&imp_6)->position_err_1 = _S355;
    (&imp_6)->velocity_1 = _S356;
    (&imp_6)->velocity_err_1 = _S357;
    (&imp_6)->angular_velocity_1 = _S358;
    (&imp_6)->rotation_1 = _S359;
    (&imp_6)->inertia0_2 = _S360;
    (&imp_6)->inertia1_2 = _S361;
    (&imp_6)->inertia2_2 = _S362;
    (&imp_6)->inv0_2 = _S363;
    (&imp_6)->inv1_2 = _S364;
    (&imp_6)->inv2_2 = _S365;
    (&imp_6)->shape_0 = _S366;
    (&imp_6)->half_1 = _S367;
    (&imp_6)->mat_0 = _S368;
    (&imp_6)->crush_0 = _S369;
    (&imp_6)->geom_0 = _S370;
    (&imp_6)->unused_0 = _S371;
    (&imp_6)->ledger_0 = _S372;
    (&imp_6)->cand_0 = _S373;
    bool _S374;
    if(((&imp_6)->cand_0.z) != 0U)
    {
        _S374 = true;
    }
    else
    {
        _S374 = (((uint4(_S353->info_0) ).z) & 1U) != 0U;
    }
    if(_S374)
    {
        _S374 = true;
    }
    else
    {
        uint _S375 = (uint4(_S353->info_0) ).y;
        if(_S375 != 0U)
        {
            _S374 = ((&imp_6)->cand_0.w) >= _S375;
        }
        else
        {
            _S374 = false;
        }
    }
    if(_S374)
    {
        return;
    }
    float4 _S376 = float4(0.0f) ;
    thread float4 rf_0 = _S376;
    thread float4 rt_0 = _S376;
    uint k_9 = (&imp_6)->cand_0.x + tid_2;
    for(;;)
    {
        if(k_9 < ((&imp_6)->cand_0.y))
        {
        }
        else
        {
            break;
        }
        uint _S377 = 3U * k_9;
        rf_0 = rf_0 + float4(*((&kernelContext_25)->scratch_0+((&kernelContext_25)->params_0->cand_base_0 + _S377 + 1U))) ;
        rt_0 = rt_0 + float4(*((&kernelContext_25)->scratch_0+((&kernelContext_25)->params_0->cand_base_0 + _S377 + 2U))) ;
        k_9 = k_9 + 256U;
    }
    group_sum2_0(tid_2, &rf_0, &rt_0, &kernelContext_25);
    if(tid_2 != 0U)
    {
        return;
    }
    float dt_3 = (&kernelContext_25)->params_0->dt_0;
    float3 _S378 = float3(0.0f) ;
    float3 load_f_0;
    float3 load_t_0;
    if(((&kernelContext_25)->params_0->has_ground_0) != 0U)
    {
        float3 _S379 = (&imp_6)->half_1.xyz;
        thread Impactor_0 _S380 = imp_6;
        Box_0 _S381 = impactor_box_0(&_S380, _S378, _S379);
        float3 _S382 = (&imp_6)->velocity_1.xyz + (&imp_6)->velocity_err_1.xyz;
        float _S383 = (&kernelContext_25)->params_0->ground_modulus_0;
        float _S384 = (&imp_6)->mat_0.x;
        float3 _S385 = float3(0.0f, 0.0f, 1.0f);
        thread Box_0 _S386 = _S381;
        thread Box_0 _S387 = _S381;
        float _S388 = contact_stiffness_0(_S383, &_S386, _S384, &_S387, _S385);
        float _S389 = (&imp_6)->position_1.z - (&kernelContext_25)->params_0->ground_hi_0 + ((&imp_6)->position_err_1.z - (&kernelContext_25)->params_0->ground_lo_0);
        uint total_points_0;
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S390 = _S388 / float(min(total_points_0, 5U));
        uint s_2 = 0U;
        uint below_0 = 0U;
        for(;;)
        {
            if(s_2 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_10 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S391 = _S381;
                float3 _S392 = sample_point_0(&_S391, s_2, &kernelContext_25);
                p_10 = _S392;
            }
            if((_S389 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        s_2 = 0U;
        load_f_0 = _S378;
        load_t_0 = _S378;
        for(;;)
        {
            if(s_2 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_10 = float3(0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                thread Box_0 _S393 = _S381;
                float3 _S394 = sample_point_0(&_S393, s_2, &kernelContext_25);
                p_10 = _S394;
            }
            float depth_4 = - (_S389 + p_10.z);
            if(depth_4 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            thread float stored_3;
            thread float diss_2;
            float3 _S395 = penalty_force_0(_S390, (&imp_6)->mat_0.z, (&kernelContext_25)->params_0->ground_friction_0, depth_4, _S385, _S382 + cross((&imp_6)->angular_velocity_1.xyz, p_10), dt_3, below_0, &stored_3, &diss_2, &kernelContext_25);
            float3 load_f_1 = load_f_0 + _S395;
            float3 load_t_1 = load_t_0 + cross(p_10, _S395);
            thread float _S396 = (&imp_6)->ledger_0.x;
            thread float _S397 = (&imp_6)->ledger_0.y;
            comp_add1_0(&_S396, &_S397, diss_2);
            (&imp_6)->ledger_0.y = _S397;
            (&imp_6)->ledger_0.x = _S396;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S378;
        load_t_0 = _S378;
    }
    float3 load_f_2 = rf_0.xyz + load_f_0;
    float3 load_t_2 = rt_0.xyz + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    thread float3 vel_0 = (&imp_6)->velocity_1.xyz;
    thread float3 vel_err_0 = (&imp_6)->velocity_err_1.xyz;
    float3 _S398 = float3(dt_3) ;
    comp_add_0(&vel_0, &vel_err_0, (load_f_2 / float3(m_2)  + (&kernelContext_25)->params_0->gravity_0.xyz) * _S398);
    Quat_0 q_16 = quat_of_0((&imp_6)->rotation_1);
    float3 _S399 = (&imp_6)->angular_velocity_1.xyz;
    thread Quat_0 _S400 = q_16;
    float3 _S401 = world_mul_0(&_S400, (&imp_6)->inertia0_2, (&imp_6)->inertia1_2, (&imp_6)->inertia2_2, _S399);
    float3 l_1 = _S401 + load_t_2 * _S398;
    thread Quat_0 _S402 = q_16;
    float3 _S403 = world_mul_0(&_S402, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    thread float3 pos_0 = (&imp_6)->position_1.xyz;
    thread float3 pos_err_0 = (&imp_6)->position_err_1.xyz;
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * _S398);
    thread Quat_0 _S404 = q_16;
    Quat_0 _S405 = integrate_rotation_0(&_S404, _S403, dt_3);
    thread Quat_0 _S406 = _S405;
    float3 _S407 = world_mul_0(&_S406, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = float4(_S407, 0.0f);
    thread Quat_0 _S408 = _S405;
    float4 _S409 = quat_vec_0(&_S408);
    (&imp_6)->rotation_1 = _S409;
    (&imp_6)->position_1 = float4(pos_0, 0.0f);
    (&imp_6)->position_err_1 = float4(pos_err_0, 0.0f);
    (&imp_6)->velocity_1 = float4(vel_0, 0.0f);
    (&imp_6)->velocity_err_1 = float4(vel_err_0, 0.0f);
    (&imp_6)->cand_0.w = (&imp_6)->cand_0.w + 1U;
    (&imp_6)->geom_0 = float4(1.0f, (&imp_6)->crush_0.w, 0.0f, 0.0f);
    Impactor_natural_0 device* _S410 = (&kernelContext_25)->impactors_0+ii_1;
    _S410->position_1 = packed_float4(imp_6.position_1) ;
    _S410->position_err_1 = packed_float4(imp_6.position_err_1) ;
    _S410->velocity_1 = packed_float4(imp_6.velocity_1) ;
    _S410->velocity_err_1 = packed_float4(imp_6.velocity_err_1) ;
    _S410->angular_velocity_1 = packed_float4(imp_6.angular_velocity_1) ;
    _S410->rotation_1 = packed_float4(imp_6.rotation_1) ;
    _S410->inertia0_2 = packed_float4(imp_6.inertia0_2) ;
    _S410->inertia1_2 = packed_float4(imp_6.inertia1_2) ;
    _S410->inertia2_2 = packed_float4(imp_6.inertia2_2) ;
    _S410->inv0_2 = packed_float4(imp_6.inv0_2) ;
    _S410->inv1_2 = packed_float4(imp_6.inv1_2) ;
    _S410->inv2_2 = packed_float4(imp_6.inv2_2) ;
    _S410->shape_0 = packed_float4(imp_6.shape_0) ;
    _S410->half_1 = packed_float4(imp_6.half_1) ;
    _S410->mat_0 = packed_float4(imp_6.mat_0) ;
    _S410->crush_0 = packed_float4(imp_6.crush_0) ;
    _S410->geom_0 = packed_float4(imp_6.geom_0) ;
    _S410->unused_0 = packed_float4(imp_6.unused_0) ;
    _S410->ledger_0 = packed_float4(imp_6.ledger_0) ;
    _S410->cand_0 = packed_uint4(imp_6.cand_0) ;
    uint k_10 = (&imp_6)->cand_0.w - 1U - (&kernelContext_25)->params_0->step_start_0;
    if(k_10 < ((&kernelContext_25)->params_0->record_stride_0))
    {
        uint at_3 = (&kernelContext_25)->params_0->record_base_0 + 2U * (ii_1 * (&kernelContext_25)->params_0->record_stride_0 + k_10);
        *((&kernelContext_25)->scratch_0+at_3) = packed_float4(float4(vel_0 + vel_err_0, 0.0f)) ;
        *((&kernelContext_25)->scratch_0+(at_3 + 1U)) = packed_float4(float4(pos_0 + pos_err_0, 0.0f)) ;
    }
    return;
}

void ground_contact_0(uint c_9, bool account_0, float3 thread* f_1, float3 thread* t_4, KernelContext_0 thread* kernelContext_26)
{
    ChunkStatic_natural_0 device* _S411 = kernelContext_26->chunks_0+c_9;
    WorldPoint_0 _S412 = chunk_world_0(c_9, kernelContext_26);
    float above_0 = _S412.hi_0.z - kernelContext_26->params_0->ground_hi_0 + (_S412.lo_0.z - kernelContext_26->params_0->ground_lo_0) + _S412.rel_0.z;
    if((above_0 - (float4(_S411->half_0) ).w) > 0.0f)
    {
        return;
    }
    Box_0 _S413 = chunk_box_0(c_9, float3(0.0f) , kernelContext_26);
    float _S414 = kernelContext_26->params_0->ground_modulus_0;
    float _S415 = (float4(_S411->cmat_0) ).x;
    float3 _S416 = float3(0.0f, 0.0f, 1.0f);
    thread Box_0 _S417 = _S413;
    thread Box_0 _S418 = _S413;
    float _S419 = contact_stiffness_0(_S414, &_S417, _S415, &_S418, _S416);
    thread Box_0 _S420 = _S413;
    uint _S421 = sample_count_0(&_S420);
    uint s_3 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_3 < _S421)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S422 = _S413;
        float3 _S423 = sample_point_0(&_S422, s_3, kernelContext_26);
        if((above_0 + _S423.z) < 0.0f)
        {
            n_9 = n_9 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_9 == 0U)
    {
        return;
    }
    thread float3 vc_1;
    thread float3 wc_1;
    chunk_velocity_0(c_9, &vc_1, &wc_1, kernelContext_26);
    thread float4 ledger_2 = float4(*(kernelContext_26->scratch_0+(kernelContext_26->params_0->ledger_base_0 + kernelContext_26->params_0->pair_count_0 + c_9))) ;
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S421)
        {
        }
        else
        {
            break;
        }
        thread Box_0 _S424 = _S413;
        float3 _S425 = sample_point_0(&_S424, s_3, kernelContext_26);
        float _S426 = above_0 + _S425.z;
        if(!(_S426 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        thread float stored_4;
        thread float diss_3;
        float3 _S427 = penalty_force_0(_S419 / float(max(n_9, 5U)), (float4(_S411->center_0) ).w, kernelContext_26->params_0->ground_friction_0, - _S426, _S416, vc_1 + cross(wc_1, _S425), kernelContext_26->params_0->dt_0, n_9, &stored_4, &diss_3, kernelContext_26);
        *f_1 = *f_1 + _S427;
        *t_4 = *t_4 + cross(_S425, _S427);
        thread float _S428 = ledger_2.y;
        thread float _S429 = ledger_2.z;
        comp_add1_0(&_S428, &_S429, diss_3);
        ledger_2.z = _S429;
        ledger_2.y = _S428;
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        *(kernelContext_26->scratch_0+(kernelContext_26->params_0->ledger_base_0 + kernelContext_26->params_0->pair_count_0 + c_9)) = packed_float4(ledger_2) ;
    }
    return;
}

[[kernel]] void contact_sums(uint3 id_2 [[thread_position_in_grid]], Params_0 constant* params_5 [[buffer(0)]], Island_natural_0 device* islands_5 [[buffer(9)]], uint device* index_5 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_5 [[buffer(3)]], packed_float4 device* state_5 [[buffer(6)]], packed_float4 device* scratch_5 [[buffer(8)]], packed_float4 device* contact_state_5 [[buffer(11)]], packed_float4 device* loads_5 [[buffer(5)]], Impactor_natural_0 device* impactors_5 [[buffer(10)]], BondStatic_natural_0 device* bonds_5 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_5 [[buffer(7)]], MaterialTable_0 constant* materials_5 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_27;
    (&kernelContext_27)->params_0 = params_5;
    (&kernelContext_27)->islands_0 = islands_5;
    (&kernelContext_27)->index_0 = index_5;
    (&kernelContext_27)->chunks_0 = chunks_5;
    (&kernelContext_27)->state_0 = state_5;
    (&kernelContext_27)->scratch_0 = scratch_5;
    (&kernelContext_27)->contact_state_0 = contact_state_5;
    (&kernelContext_27)->loads_0 = loads_5;
    (&kernelContext_27)->impactors_0 = impactors_5;
    (&kernelContext_27)->bonds_0 = bonds_5;
    (&kernelContext_27)->bond_dyn_0 = bond_dyn_5;
    (&kernelContext_27)->materials_0 = materials_5;
    threadgroup array<float4, int(256)> g_red_a_5;
    (&kernelContext_27)->g_red_a_0 = &g_red_a_5;
    threadgroup array<float4, int(256)> g_red_b_5;
    (&kernelContext_27)->g_red_b_0 = &g_red_b_5;
    threadgroup uint g_run_5;
    (&kernelContext_27)->g_run_0 = &g_run_5;
    threadgroup uint g_halt_5;
    (&kernelContext_27)->g_halt_0 = &g_halt_5;
    threadgroup uint g_wide_run_5;
    (&kernelContext_27)->g_wide_run_0 = &g_wide_run_5;
    uint g_0 = id_2.x;
    bool _S430;
    if(g_0 >= (params_5->seg_count_0))
    {
        _S430 = true;
    }
    else
    {
        bool _S431 = stopped_0(&kernelContext_27);
        _S430 = _S431;
    }
    if(_S430)
    {
        return;
    }
    uint _S432 = 3U * g_0;
    uint _S433 = (&kernelContext_27)->index_0[(&kernelContext_27)->params_0->seg_index_0 + _S432];
    uint begin_0 = (&kernelContext_27)->index_0[(&kernelContext_27)->params_0->seg_index_0 + _S432 + 1U];
    uint _S434 = (&kernelContext_27)->index_0[(&kernelContext_27)->params_0->seg_index_0 + _S432 + 2U];
    float3 _S435 = float3(0.0f) ;
    thread float3 f_2 = _S435;
    thread float3 t_5 = _S435;
    uint e_2 = begin_0;
    for(;;)
    {
        if(e_2 < _S434)
        {
        }
        else
        {
            break;
        }
        uint entry_1 = (&kernelContext_27)->index_0[e_2];
        if(entry_1 == 2147483648U)
        {
            ground_contact_0(_S433, true, &f_2, &t_5, &kernelContext_27);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S436 = 2U * entry_1;
        f_2 = f_2 + (float4(*((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->slot_base_0 + _S436))) ).xyz;
        t_5 = t_5 + (float4(*((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->slot_base_0 + _S436 + 1U))) ).xyz;
        e_2 = e_2 + 1U;
    }
    uint _S437 = 2U * g_0;
    *((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->seg_base_0 + _S437)) = packed_float4(float4(f_2, 0.0f)) ;
    *((&kernelContext_27)->scratch_0+((&kernelContext_27)->params_0->seg_base_0 + _S437 + 1U)) = packed_float4(float4(t_5, 0.0f)) ;
    return;
}

bool contact_stopped_0(const Island_natural_0 thread* isl_0, KernelContext_0 thread* kernelContext_28)
{
    uint4 _S438 = uint4((kernelContext_28->islands_0+kernelContext_28->params_0->halt_index_0)->info_0) ;
    bool _S439;
    if(((_S438.z) & 1U) != 0U)
    {
        _S439 = true;
    }
    else
    {
        uint _S440 = _S438.y;
        if(_S440 != 0U)
        {
            _S439 = _S440 <= ((uint4(isl_0->info_0) ).w);
        }
        else
        {
            _S439 = false;
        }
    }
    return _S439;
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

bool contact_stopped_1(const Island_0 thread* isl_1, KernelContext_0 thread* kernelContext_29)
{
    uint4 _S441 = uint4((kernelContext_29->islands_0+kernelContext_29->params_0->halt_index_0)->info_0) ;
    bool _S442;
    if(((_S441.z) & 1U) != 0U)
    {
        _S442 = true;
    }
    else
    {
        uint _S443 = _S441.y;
        if(_S443 != 0U)
        {
            _S442 = _S443 <= (isl_1->info_0.w);
        }
        else
        {
            _S442 = false;
        }
    }
    return _S442;
}

struct Rigid_0
{
    Quat_0 rot_0;
    float3 pos_1;
    float3 pos_err_1;
    float3 vel_1;
    float3 vel_err_1;
    float3 w_3;
    float3 a_6;
    float3 alpha_0;
};

Rigid_0 rigid_of_0(const Island_natural_0 thread* isl_2)
{
    thread Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(float4(isl_2->rotation_0) );
    (&rg_0)->pos_1 = (float4(isl_2->position_0) ).xyz;
    (&rg_0)->pos_err_1 = (float4(isl_2->position_err_0) ).xyz;
    (&rg_0)->vel_1 = (float4(isl_2->velocity_0) ).xyz;
    (&rg_0)->vel_err_1 = (float4(isl_2->velocity_err_0) ).xyz;
    (&rg_0)->w_3 = (float4(isl_2->angular_velocity_0) ).xyz;
    float3 _S444 = float3(0.0f) ;
    (&rg_0)->a_6 = _S444;
    (&rg_0)->alpha_0 = _S444;
    return rg_0;
}

Rigid_0 rigid_of_1(const Island_0 thread* isl_3)
{
    thread Rigid_0 rg_1;
    (&rg_1)->rot_0 = quat_of_0(isl_3->rotation_0);
    (&rg_1)->pos_1 = isl_3->position_0.xyz;
    (&rg_1)->pos_err_1 = isl_3->position_err_0.xyz;
    (&rg_1)->vel_1 = isl_3->velocity_0.xyz;
    (&rg_1)->vel_err_1 = isl_3->velocity_err_0.xyz;
    (&rg_1)->w_3 = isl_3->angular_velocity_0.xyz;
    float3 _S445 = float3(0.0f) ;
    (&rg_1)->a_6 = _S445;
    (&rg_1)->alpha_0 = _S445;
    return rg_1;
}

float time_since_0(float4 origin_0, uint k_11, float dt_4, KernelContext_0 thread* kernelContext_30)
{
    return kernelContext_30->params_0->t_hi_0 - origin_0.x + (kernelContext_30->params_0->t_lo_0 - origin_0.y) + float(k_11) * dt_4;
}

float table_eval_0(uint offset_0, uint count_2, float tau_0, KernelContext_0 thread* kernelContext_31)
{
    float4 _S446 = float4(*(kernelContext_31->loads_0+offset_0)) ;
    if(tau_0 <= (_S446.x))
    {
        return _S446.y;
    }
    uint i_5 = 1U;
    for(;;)
    {
        if(i_5 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S447 = offset_0 + i_5;
        float4 _S448 = float4(*(kernelContext_31->loads_0+_S447)) ;
        float _S449 = _S448.x;
        if(tau_0 <= _S449)
        {
            float4 _S450 = float4(*(kernelContext_31->loads_0+(_S447 - 1U))) ;
            float _S451 = _S450.x;
            float _S452 = _S450.y;
            return _S452 + (tau_0 - _S451) / max(_S449 - _S451, 1.00000000317107685e-30f) * (_S448.y - _S452);
        }
        i_5 = i_5 + 1U;
    }
    return (float4(*(kernelContext_31->loads_0+(offset_0 + count_2 - 1U))) ).y;
}

float eval_function_0(uint term_0, uint k_12, float dt_5, float shift_0, KernelContext_0 thread* kernelContext_32)
{
    uint _S453 = 5U * term_0;
    uint4 info_2 = (as_type<uint4>((float4(*(kernelContext_32->loads_0+_S453)) )));
    float4 _S454 = float4(*(kernelContext_32->loads_0+(_S453 + 3U))) ;
    float4 _S455 = float4(*(kernelContext_32->loads_0+(_S453 + 4U))) ;
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S454.z;
    }
    float _S456 = time_since_0(_S454, k_12, dt_5, kernelContext_32);
    float tau_1 = _S456 + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S457 = _S455.x;
            if(tau_1 >= _S457)
            {
                shape_1 = _S455.y;
            }
            else
            {
                shape_1 = _S455.y * tau_1 / _S457;
            }
        }
        return shape_1;
    }
    bool _S458;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S458 = true;
        }
        else
        {
            _S458 = tau_1 > (_S455.x);
        }
        if(_S458)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S455.y * sin(3.14159274101257324f * tau_1 / _S455.x);
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S455.y;
        if(sn_0 < 0.0f)
        {
            _S458 = true;
        }
        else
        {
            _S458 = sn_0 > 1.0f;
        }
        if(_S458)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S455.x * (1.0f - sn_0) * exp(- _S455.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        float _S459 = table_eval_0(info_2.w, (as_type<uint>((_S455.x))), tau_1, kernelContext_32);
        return _S459;
    }
    if(kind_0 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S455.x;
        if(sn_1 < 0.0f)
        {
            _S458 = true;
        }
        else
        {
            _S458 = sn_1 > 1.0f;
        }
        if(_S458)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- _S455.y * sn_1);
        }
        float clearing_0 = _S454.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S460 = _S455.w;
        return (_S460 + (_S455.z - _S460) * relax_0) * shape_1;
    }
    float _S461 = _S455.x;
    if(_S461 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S461, 0.0f, 1.0f);
}

void chunk_external_0(uint _S462, uint _S463, const Quat_0 thread* _S464, uint _S465, float _S466, bool _S467, float3 thread* _S468, float3 thread* _S469, KernelContext_0 thread* kernelContext_33)
{
    ChunkStatic_natural_0 device* _S470 = kernelContext_33->chunks_0+_S463;
    float3 _S471 = float3(0.0f) ;
    *_S468 = _S471;
    *_S469 = _S471;
    uint4 _S472 = uint4(_S470->load_range_0) ;
    uint term_1 = _S472.x;
    for(;;)
    {
        if(term_1 < (_S472.y))
        {
        }
        else
        {
            break;
        }
        uint _S473 = 5U * term_1;
        uint _S474 = (as_type<uint4>((float4(*(kernelContext_33->loads_0+_S473)) ))).y;
        if(_S474 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4 _S475 = float4(*(kernelContext_33->loads_0+(_S473 + 1U))) ;
        float4 _S476 = float4(*(kernelContext_33->loads_0+(_S473 + 2U))) ;
        float _S477 = eval_function_0(term_1, _S465, _S466, 0.0f, kernelContext_33);
        float3 fw_0;
        if(_S474 == 0U)
        {
            fw_0 = _S475.xyz * float3(_S477) ;
        }
        else
        {
            float3 _S478 = rotate_0(_S464, _S475.xyz);
            fw_0 = _S478 * float3((- _S477 * _S475.w)) ;
        }
        *_S468 = *_S468 + fw_0;
        float3 _S479 = rotate_0(_S464, _S476.xyz);
        *_S469 = *_S469 + cross(_S479, fw_0);
        term_1 = term_1 + 1U;
    }
    bool _S480;
    if(_S467)
    {
        _S480 = ((uint4(_S470->cinfo_0) ).z) != 0U;
    }
    else
    {
        _S480 = false;
    }
    if(_S480)
    {
        uint4 _S481 = uint4(_S470->cinfo_0) ;
        uint g_1 = _S481.x;
        for(;;)
        {
            if(g_1 < (_S481.y))
            {
            }
            else
            {
                break;
            }
            uint _S482 = 2U * g_1;
            *_S468 = *_S468 + (float4(*(kernelContext_33->scratch_0+(kernelContext_33->params_0->seg_base_0 + _S482))) ).xyz;
            *_S469 = *_S469 + (float4(*(kernelContext_33->scratch_0+(kernelContext_33->params_0->seg_base_0 + _S482 + 1U))) ).xyz;
            g_1 = g_1 + 1U;
        }
    }
    return;
}

void net_load_0(uint c_10, const Island_natural_0 thread* isl_4, const Rigid_0 thread* rg_2, uint k_13, float dt_6, bool contact_0, float3 thread* f_3, float3 thread* t_6, KernelContext_0 thread* kernelContext_34)
{
    ChunkStatic_natural_0 device* _S483 = kernelContext_34->chunks_0+c_10;
    thread float3 fl_0;
    thread float3 tl_0;
    chunk_external_0(c_10, c_10, &rg_2->rot_0, k_13, dt_6, contact_0, &fl_0, &tl_0, kernelContext_34);
    float4 _S484 = float4(_S483->center_0) ;
    float3 fc_0 = fl_0 + kernelContext_34->params_0->gravity_0.xyz * float3(_S484.w) ;
    float3 _S485 = _S484.xyz;
    float3 _S486 = (float4(isl_4->com_0) ).xyz;
    float3 _S487 = rotate_0(&rg_2->rot_0, _S485 + (float4(*(kernelContext_34->state_0+4U * c_10)) ).xyz - _S486);
    *f_3 = *f_3 + fc_0;
    *t_6 = *t_6 + (cross(_S487, fc_0) + tl_0);
    uint4 _S488 = uint4(_S483->load_range_0) ;
    uint term_2 = _S488.x;
    for(;;)
    {
        if(term_2 < (_S488.y))
        {
        }
        else
        {
            break;
        }
        uint _S489 = 5U * term_2;
        if(((as_type<uint4>((float4(*(kernelContext_34->loads_0+_S489)) ))).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float _S490 = eval_function_0(term_2, k_13, dt_6, 0.0f, kernelContext_34);
        float3 _S491 = float3(_S490) ;
        float3 _S492 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_34->loads_0+(_S489 + 1U))) ).xyz * _S491);
        *f_3 = *f_3 + _S492;
        float3 _S493 = rotate_0(&rg_2->rot_0, _S485 - _S486);
        float3 _S494 = cross(_S493, _S492);
        float3 _S495 = rotate_0(&rg_2->rot_0, (float4(*(kernelContext_34->loads_0+(_S489 + 2U))) ).xyz * _S491);
        *t_6 = *t_6 + (_S494 + _S495);
        term_2 = term_2 + 1U;
    }
    return;
}

void net_load_1(uint c_11, const Island_0 thread* isl_5, const Rigid_0 thread* rg_3, uint k_14, float dt_7, bool contact_1, float3 thread* f_4, float3 thread* t_7, KernelContext_0 thread* kernelContext_35)
{
    ChunkStatic_natural_0 device* _S496 = kernelContext_35->chunks_0+c_11;
    thread float3 fl_1;
    thread float3 tl_1;
    chunk_external_0(c_11, c_11, &rg_3->rot_0, k_14, dt_7, contact_1, &fl_1, &tl_1, kernelContext_35);
    float4 _S497 = float4(_S496->center_0) ;
    float3 fc_1 = fl_1 + kernelContext_35->params_0->gravity_0.xyz * float3(_S497.w) ;
    float3 _S498 = _S497.xyz;
    float3 _S499 = isl_5->com_0.xyz;
    float3 _S500 = rotate_0(&rg_3->rot_0, _S498 + (float4(*(kernelContext_35->state_0+4U * c_11)) ).xyz - _S499);
    *f_4 = *f_4 + fc_1;
    *t_7 = *t_7 + (cross(_S500, fc_1) + tl_1);
    uint4 _S501 = uint4(_S496->load_range_0) ;
    uint term_3 = _S501.x;
    for(;;)
    {
        if(term_3 < (_S501.y))
        {
        }
        else
        {
            break;
        }
        uint _S502 = 5U * term_3;
        if(((as_type<uint4>((float4(*(kernelContext_35->loads_0+_S502)) ))).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float _S503 = eval_function_0(term_3, k_14, dt_7, 0.0f, kernelContext_35);
        float3 _S504 = float3(_S503) ;
        float3 _S505 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_35->loads_0+(_S502 + 1U))) ).xyz * _S504);
        *f_4 = *f_4 + _S505;
        float3 _S506 = rotate_0(&rg_3->rot_0, _S498 - _S499);
        float3 _S507 = cross(_S506, _S505);
        float3 _S508 = rotate_0(&rg_3->rot_0, (float4(*(kernelContext_35->loads_0+(_S502 + 2U))) ).xyz * _S504);
        *t_7 = *t_7 + (_S507 + _S508);
        term_3 = term_3 + 1U;
    }
    return;
}

void group_sum3_0(uint tid_3, float3 thread* a_7, float3 thread* b_22, KernelContext_0 thread* kernelContext_36)
{
    thread float4 x_4 = float4(*a_7, 0.0f);
    thread float4 y_1 = float4(*b_22, 0.0f);
    group_sum2_0(tid_3, &x_4, &y_1, kernelContext_36);
    *a_7 = x_4.xyz;
    *b_22 = y_1.xyz;
    return;
}

void rigid_acceleration_0(const Island_natural_0 thread* isl_6, Rigid_0 thread* rg_4, float3 f_5, float3 t_8)
{
    float4 _S509 = float4(isl_6->inertia0_0) ;
    float4 _S510 = float4(isl_6->inertia1_0) ;
    float4 _S511 = float4(isl_6->inertia2_0) ;
    thread Quat_0 _S512 = rg_4->rot_0;
    float3 _S513 = world_mul_0(&_S512, _S509, _S510, _S511, rg_4->w_3);
    rg_4->a_6 = f_5 / float3((float4(isl_6->com_0) ).w) ;
    float4 _S514 = float4(isl_6->inv0_0) ;
    float4 _S515 = float4(isl_6->inv1_0) ;
    float4 _S516 = float4(isl_6->inv2_0) ;
    float3 _S517 = t_8 - cross(rg_4->w_3, _S513);
    thread Quat_0 _S518 = rg_4->rot_0;
    float3 _S519 = world_mul_0(&_S518, _S514, _S515, _S516, _S517);
    rg_4->alpha_0 = _S519;
    return;
}

void rigid_acceleration_1(const Island_0 thread* isl_7, Rigid_0 thread* rg_5, float3 f_6, float3 t_9)
{
    thread Quat_0 _S520 = rg_5->rot_0;
    float3 _S521 = world_mul_0(&_S520, isl_7->inertia0_0, isl_7->inertia1_0, isl_7->inertia2_0, rg_5->w_3);
    rg_5->a_6 = f_6 / float3(isl_7->com_0.w) ;
    float3 _S522 = t_9 - cross(rg_5->w_3, _S521);
    thread Quat_0 _S523 = rg_5->rot_0;
    float3 _S524 = world_mul_0(&_S523, isl_7->inv0_0, isl_7->inv1_0, isl_7->inv2_0, _S522);
    rg_5->alpha_0 = _S524;
    return;
}

bool connected_0(const JointState_0 thread* st_0, bool has_rebar_0)
{
    bool _S525;
    if((st_0->damage_0) < 1.0f)
    {
        _S525 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S525 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S525 = false;
        }
    }
    return _S525;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

Measures_0 stress_measures_0(const JointBond_natural_0 thread* b_23, float3 q_lin_0, float3 q_ang_0)
{
    float4 _S526 = float4(b_23->geom0_0) ;
    float area_2 = _S526.x;
    float _S527 = q_lin_0.z;
    float axial_0 = (metal::fast::divide((_S527), (area_2)));
    float4 _S528 = float4(b_23->geom1_0) ;
    float _S529 = (metal::fast::divide((abs(q_ang_0.x)), (_S528.x)));
    float _S530 = (metal::fast::divide((abs(q_ang_0.y)), (_S528.y)));
    float bending_0 = _S529 + _S530;
    float _S531 = q_lin_0.x;
    float _S532 = q_lin_0.y;
    float _S533 = (metal::fast::sqrt((_S531 * _S531 + _S532 * _S532)));
    float _S534 = (metal::fast::divide((_S533), (area_2)));
    float _S535 = (metal::fast::divide((abs(q_ang_0.z)), (_S526.w)));
    float shear_1 = _S534 + _S535;
    thread Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S536 = - axial_0;
    (&m_3)->normal_compression_0 = max(_S536, 0.0f);
    (&m_3)->compression_0 = _S536 + bending_0;
    (&m_3)->compressive_force_0 = max(- _S527, 0.0f);
    return m_3;
}

float expm1_accurate_0(float x_5)
{
    if((abs(x_5)) < 0.00100000004749745f)
    {
        return x_5 * (1.0f + x_5 * (0.5f + x_5 * 0.1666666716337204f));
    }
    return exp(x_5) - 1.0f;
}

float dif_factor_0(const JointMaterial_0 constant* mat_1, float strain_rate_1)
{
    float r_7 = abs(strain_rate_1);
    float4 _S537 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_7 <= ref_0)
    {
        return 1.0f;
    }
    float _S538 = _S537.z;
    float f_7;
    if(r_7 <= _S538)
    {
        float _S539 = (metal::fast::divide((r_7), (ref_0)));
        float _S540 = (metal::fast::pow((_S539), (_S537.y)));
        f_7 = _S540;
    }
    else
    {
        float _S541 = (metal::fast::divide((_S538), (ref_0)));
        float _S542 = (metal::fast::pow((_S541), (_S537.y)));
        float _S543 = (metal::fast::divide((r_7), (_S538)));
        float _S544 = (metal::fast::pow((_S543), (_S537.w)));
        f_7 = _S542 * _S544;
    }
    return clamp(f_7, 1.0f, mat_1->misc_0.x);
}

float fatigue_factor_0(const JointMaterial_0 constant* mat_2, float fatigue_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    float _S545 = 1.0f - clamp(fatigue_1, 0.0f, 1.0f);
    float _S546 = (metal::fast::divide((1.0f), (mat_2->misc_0.y - 2.0f)));
    float _S547 = (metal::fast::pow((_S545), (_S546)));
    return _S547;
}

float infinity_0()
{
    return (as_type<float>((2139095040U)));
}

float4 failure_indices_0(const JointMaterial_0 constant* mat_3, const JointBond_natural_0 thread* b_24, const Measures_0 thread* m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S548 = min(mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0, mat_3->energy_1.x * multiplier_0);
    thread float4 idx_0;
    float _S549 = (metal::fast::divide((m_4->tension_0), (mat_3->strength_0.x * multiplier_0)));
    idx_0.x = max(_S549, 0.0f);
    float _S550;
    if(_S548 > 0.0f)
    {
        float _S551 = (metal::fast::divide((m_4->shear_0), (_S548)));
        _S550 = _S551;
    }
    else
    {
        _S550 = infinity_0();
    }
    idx_0.y = _S550;
    float _S552 = (metal::fast::divide((m_4->compression_0), (fc_2)));
    idx_0.z = max(_S552, 0.0f);
    float _S553 = (float4(b_24->stiff1_0) ).y;
    if(_S553 > 0.0f)
    {
        float _S554 = (metal::fast::divide((m_4->compressive_force_0), (_S553)));
        _S550 = _S554;
    }
    else
    {
        _S550 = 0.0f;
    }
    idx_0.w = _S550;
    return idx_0;
}

float sq_0(float x_6)
{
    return x_6 * x_6;
}

float damage_law_0(uint kind_1, float kappa_1, float r_8)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == 0U)
    {
        if(r_8 <= 1.0f)
        {
            return 1.0f;
        }
        float _S555 = (metal::fast::divide((r_8 * (kappa_1 - 1.0f)), (kappa_1 * (r_8 - 1.0f))));
        return min(_S555, 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_8 + 1.0f)))
    {
        return 1.0f;
    }
    float _S556 = (metal::fast::divide((1.0f), (kappa_1)));
    return 1.0f - _S556;
}

float2 damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_9, float d_old_0, float psi_0)
{
    float _S557 = damage_law_0(kind_2, lambda_0, r_9);
    float _S558 = max(_S557, d_old_0);
    bool _S559;
    if(_S558 <= d_old_0)
    {
        _S559 = true;
    }
    else
    {
        _S559 = d_old_0 >= 1.0f;
    }
    if(_S559)
    {
        return float2(d_old_0, 0.0f);
    }
    float u0_0 = (metal::fast::divide((psi_0), (lambda_0 * lambda_0)));
    float _S560 = max(kappa_old_0, 1.0f);
    if(kind_2 == 0U)
    {
        if(r_9 > 1.0f)
        {
            float _S561 = (metal::fast::divide((u0_0 * r_9), (r_9 - 1.0f)));
            return float2(_S558, _S561 * max(min(lambda_0, r_9) - min(_S560, r_9), 0.0f));
        }
        return float2(_S558, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_9 + 1.0f);
    float plateau_0 = u0_0 * max(min(lambda_0, ku_0) - min(_S560, ku_0), 0.0f);
    float snap_0;
    if(_S558 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return float2(_S558, plateau_0 + snap_0);
}

void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, array<float, int(6)> thread* region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S562 = - h0_0;
    float _S563 = - h1_0;
    array<float2, int(4)> _S564 = { { float2(_S562, _S563), float2(h0_0, _S563), float2(h0_0, h1_0), float2(_S562, h1_0) } };
    thread array<float2, int(8)> poly_0;
    uint i_6 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S565 = i_6;
        uint _S566 = i_6 + 1U;
        uint _S567 = _S566 % 4U;
        float _S568 = _S564[i_6].y;
        float _S569 = _S564[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S568 - ay_0 * _S569;
        float _S570 = _S564[_S567].y;
        float _S571 = _S564[_S567].x;
        float fq_0 = dz_0 + ax_0 * _S570 - ay_0 * _S571;
        bool _S572 = fp_0 < 0.0f;
        if(_S572)
        {
            uint _S573 = count_4 + 1U;
            poly_0[count_4] = _S564[_S565];
            count_3 = _S573;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S572 != (fq_0 < 0.0f))
        {
            float t_10 = fp_0 / (fp_0 - fq_0);
            uint _S574 = count_3 + 1U;
            poly_0[count_3] = float2(_S569 + t_10 * (_S571 - _S569), _S568 + t_10 * (_S570 - _S568));
            count_4 = _S574;
        }
        else
        {
            count_4 = count_3;
        }
        i_6 = _S566;
    }
    count_3 = 0U;
    for(;;)
    {
        if(count_3 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_3] = 0.0f;
        count_3 = count_3 + 1U;
    }
    if(count_4 < 3U)
    {
        return;
    }
    float2 o_1 = poly_0[int(0)];
    i_6 = 0U;
    float a_8 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_6 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S575 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S575;
        float _S576 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S576;
        uint _S577 = i_6 + 1U;
        uint _S578 = _S577 % count_4;
        float x1_0 = poly_0[_S578].x - _S575;
        float y1_0 = poly_0[_S578].y - _S576;
        float _S579 = x0_0 * y1_0;
        float _S580 = x1_0 * y0_0;
        float cr_0 = _S579 - _S580;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S579 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S580) * cr_0 / 24.0f;
        i_6 = _S577;
        a_8 = a_9;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_8 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_8;
    float cy_0 = sy_0 / a_8;
    (*region_0)[int(0)] = a_8;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S581 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S581 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S581 * cy_0;
    return;
}

float4 no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    thread array<float, int(6)> r_10;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_10);
    float a_10 = r_10[int(0)];
    if((r_10[int(0)]) == 0.0f)
    {
        return float4(0.0f) ;
    }
    float k_15 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_10[int(2)] - ay_1 * r_10[int(1)];
    float _S582 = a_10 * fc_3;
    float _S583 = - ay_1;
    return float4(k_15 * a_10 * fc_3, k_15 * (_S582 * r_10[int(2)] + (_S583 * r_10[int(5)] + ax_1 * r_10[int(4)])), - k_15 * (_S582 * r_10[int(1)] + (_S583 * r_10[int(3)] + ax_1 * r_10[int(5)])), 0.5f * k_15 * (_S582 * fc_3 + ay_1 * ay_1 * r_10[int(3)] + ax_1 * ax_1 * r_10[int(4)] - 2.0f * ax_1 * ay_1 * r_10[int(5)]));
}

float signum_0(float x_7)
{
    float _S584;
    if(((as_type<uint>((x_7))) & 2147483648U) != 0U)
    {
        _S584 = -1.0f;
    }
    else
    {
        _S584 = 1.0f;
    }
    return _S584;
}

float2 return_map_0(float k_16, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_16 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return float2(trial_0, 0.0f);
    }
    float f_8 = cap_0 * signum_0(trial_0);
    float _S585 = (metal::fast::divide((trial_0 - f_8), (k_16)));
    return float2(f_8, _S585);
}

struct Contact_0
{
    float3 q_lin_1;
    float3 q_ang_1;
    float energy_2;
    float diss_4;
    float3 plastic_1;
};

Contact_0 contact_part_0(const JointMaterial_0 constant* mat_4, const JointBond_natural_0 thread* b_25, float crush_2, float3 plastic_2, float3 d_lin_0, float3 d_ang_0)
{
    thread Contact_0 c_12;
    float3 _S586 = float3(0.0f) ;
    (&c_12)->q_lin_1 = _S586;
    (&c_12)->q_ang_1 = _S586;
    (&c_12)->energy_2 = 0.0f;
    (&c_12)->diss_4 = 0.0f;
    (&c_12)->plastic_1 = plastic_2;
    uint _S587 = mat_4->kind_flags_0.y;
    if((_S587 & 2U) == 0U)
    {
        return c_12;
    }
    float4 _S588 = float4(b_25->stiff0_0) ;
    float kn_1 = _S588.x;
    float ks_0 = _S588.y;
    float kt_0 = (float4(b_25->stiff1_0) ).x;
    float4 _S589 = float4(b_25->geom0_0) ;
    float w0_2 = _S589.y;
    float w1_2 = _S589.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S587 & 4U) != 0U)
    {
        float4 p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S590 = p_11.y;
        float _S591 = p_11.z;
        float _S592 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S590;
        m2_0 = _S591;
        energy_3 = _S592;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S593 = d_ang_0.x;
        float _S594 = d_ang_0.y;
        float spread_0 = abs(_S593) * 0.4166666567325592f * w1_2 + abs(_S594) * 0.4166666567325592f * w0_2;
        float _S595 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * (abs(_S595) + spread_0);
        if((_S595 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S595 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S596 = ki_0 * _S593 * i2_0;
                float _S597 = ki_0 * _S594 * i1_0;
                float _S598 = 0.5f * ki_0 * (36.0f * _S595 * _S595 + _S593 * _S593 * i2_0 + _S594 * _S594 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S595;
                m1_0 = _S596;
                m2_0 = _S597;
                energy_3 = _S598;
            }
            else
            {
                uint i_7 = 0U;
                diss_5 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_7 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S599 = ((float(i_7) + 0.5f) / 6.0f - 0.5f) * w0_2;
                    uint j_5 = 0U;
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_5 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = ((float(j_5) + 0.5f) / 6.0f - 0.5f) * w1_2;
                        float di_0 = _S595 + _S593 * s2_0 - _S594 * _S599;
                        if(di_0 < 0.0f)
                        {
                            float f_9 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_9 * s2_0;
                            float m2_2 = m2_0 - f_9 * _S599;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_9;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_7 = i_7 + 1U;
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
    float nc_0 = - nc_sum_0;
    thread float3 p_12 = plastic_2;
    (&c_12)->q_lin_1 = float3(0.0f, 0.0f, nc_sum_0);
    (&c_12)->q_ang_1 = float3(m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S600 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S601 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = (metal::fast::sqrt((_S600 * _S600 + _S601 * _S601)));
    bool _S602;
    if(tn_0 > slide_cap_0)
    {
        _S602 = tn_0 > 0.0f;
    }
    else
    {
        _S602 = false;
    }
    if(_S602)
    {
        float _S603 = (metal::fast::divide((_S600), (tn_0)));
        float _S604 = (metal::fast::divide((_S601), (tn_0)));
        float dslip_0 = (metal::fast::divide((tn_0 - slide_cap_0), (ks_0)));
        p_12.x = p_12.x + _S603 * dslip_0;
        p_12.y = p_12.y + _S604 * dslip_0;
        (&c_12)->q_lin_1.x = _S603 * slide_cap_0;
        (&c_12)->q_lin_1.y = _S604 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        (&c_12)->q_lin_1.x = _S600;
        (&c_12)->q_lin_1.y = _S601;
        diss_5 = 0.0f;
    }
    float2 tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * (float4(b_25->geom1_0) ).z);
    float _S605 = tq_0.x;
    float _S606 = tq_0.y;
    float diss_6 = diss_5 + abs(_S605) * abs(_S606);
    p_12.z = p_12.z + _S606;
    (&c_12)->q_ang_1.z = _S605;
    float _S607 = (metal::fast::divide((sq_0((&c_12)->q_lin_1.x)), (ks_0)));
    float _S608 = (metal::fast::divide((sq_0((&c_12)->q_lin_1.y)), (ks_0)));
    float _S609 = _S607 + _S608;
    float _S610 = (metal::fast::divide((sq_0(_S605)), (kt_0)));
    (&c_12)->energy_2 = energy_3 + 0.5f * (_S609 + _S610);
    (&c_12)->diss_4 = diss_6;
    (&c_12)->plastic_1 = p_12;
    return c_12;
}

float life_rate_0(const JointMaterial_0 constant* mat_5, float s_4)
{
    if(s_4 <= 0.0f)
    {
        return 0.0f;
    }
    float _S611 = mat_5->misc_0.y;
    float _S612 = _S611 + 1.0f;
    float _S613 = (metal::fast::pow((s_4), (_S611)));
    float _S614 = (metal::fast::divide((_S612 * _S613), (mat_5->misc_0.z)));
    return _S614;
}

struct JointResponse_0
{
    float3 force_lin_1;
    float3 force_ang_1;
    JointState_0 state_6;
    float dissipated_2;
    float overshoot_0;
    float stored_5;
    bool disconnected_0;
    Measures_0 measures_0;
};

JointResponse_0 joint_evaluate_0(const JointMaterial_0 constant* mat_6, const JointBond_natural_0 thread* b_26, const JointState_0 thread* state_7, float3 d_lin_1, float3 d_ang_1, float dt_8, bool fracture_1)
{
    float4 _S615 = float4(b_26->stiff0_0) ;
    float kn_2 = _S615.x;
    float ks_1 = _S615.y;
    float kb1_0 = _S615.z;
    float kb2_0 = _S615.w;
    float4 _S616 = float4(b_26->stiff1_0) ;
    float kt_1 = _S616.x;
    bool has_rebar_1 = (_S616.w) != 0.0f;
    uint kind_3 = mat_6->kind_flags_0.x;
    uint flags_1 = mat_6->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    thread JointState_0 st_1 = *state_7;
    bool _S617 = connected_0(state_7, has_rebar_1);
    float3 qe_lin_0 = d_lin_1 * float3(ks_1, ks_1, kn_2);
    float3 qe_ang_0 = d_ang_1 * float3(kb1_0, kb2_0, kt_1);
    Measures_0 _S618 = stress_measures_0(b_26, qe_lin_0, qe_ang_0);
    float _S619 = max(max(_S618.tension_0, _S618.shear_0), _S618.compression_0);
    bool _S620 = dt_8 > 0.0f;
    float dif_1;
    if(_S620)
    {
        float _S621 = (metal::fast::divide((_S619 - (&st_1)->governing_stress_0), (dt_8)));
        float raw_0 = (metal::fast::divide((max(_S621, 0.0f)), (mat_6->misc_0.w)));
        float tau_2 = _S616.z;
        if((flags_1 & 16U) != 0U)
        {
            float _S622 = (metal::fast::divide((dt_8), (tau_2)));
            dif_1 = - expm1_accurate_0(- _S622);
        }
        else
        {
            float _S623 = (metal::fast::divide((dt_8), (tau_2)));
            dif_1 = min(_S623, 1.0f);
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S619;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S624 = dif_factor_0(mat_6, (&st_1)->strain_rate_0);
        dif_1 = _S624;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = (float4(b_26->geom1_0) ).w;
    float _S625 = weibull_0 * dif_1;
    float _S626 = fatigue_factor_0(mat_6, (&st_1)->fatigue_0);
    float multiplier_1 = _S625 * _S626;
    thread Measures_0 _S627 = _S618;
    float4 _S628 = failure_indices_0(mat_6, b_26, &_S627, multiplier_1);
    float _S629 = _S628.x;
    float _S630 = _S628.y;
    (&st_1)->utilization_0 = max(max(_S629, _S630), max(_S628.z, _S628.w));
    float _S631 = d_lin_1.x;
    float _S632 = d_lin_1.y;
    float _S633 = ks_1 * (sq_0(_S631) + sq_0(_S632)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    float _S634 = d_lin_1.z;
    bool _S635 = _S634 > 0.0f;
    if(_S635)
    {
        dif_1 = kn_2 * sq_0(_S634);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S633 + dif_1);
    float psi_c_0;
    if(_S634 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S634);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3 plastic_3 = float3((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S636;
    float3 qc_lin_0;
    if(fracture_1)
    {
        bool _S637 = _S629 >= _S630;
        if(_S637)
        {
            diss_contact_0 = _S629;
        }
        else
        {
            diss_contact_0 = _S630;
        }
        uint mode_ts_0;
        if(_S637)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S636 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S636 = false;
        }
        if(_S636)
        {
            _S636 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S636 = false;
        }
        uint mode_c_0;
        if(_S636)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_6->energy_1.y;
            }
            else
            {
                psi_contact_0 = mat_6->energy_1.z;
            }
            if(softening_0)
            {
                float _S638 = (metal::fast::divide((psi_contact_0 * (float4(b_26->geom0_0) ).x * diss_contact_0 * diss_contact_0), (psi_ts_0)));
                intact_normal_0 = _S638;
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
            float _S639 = inc_0.x;
            if(_S639 > ((&st_1)->damage_0))
            {
                Contact_0 _S640 = contact_part_0(mat_6, b_26, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
                float _S641 = max(_S640.energy_2 - (1.0f - (&st_1)->crush_1) * psi_c_0, 0.0f);
                float _S642 = max(inc_0.y - _S641 * (_S639 - (&st_1)->damage_0), 0.0f);
                float _S643 = max((psi_ts_0 - _S641) * (_S639 - (&st_1)->damage_0) - _S642, 0.0f);
                (&st_1)->damage_0 = _S639;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S642;
                overshoot_1 = _S643;
            }
            else
            {
                dissipated_3 = 0.0f;
                overshoot_1 = 0.0f;
            }
        }
        else
        {
            dissipated_3 = 0.0f;
            overshoot_1 = 0.0f;
        }
        (&st_1)->kappa_0 = max((&st_1)->kappa_0, diss_contact_0);
        float _S644 = state_7->damage_0;
        if((state_7->damage_0) > 0.0f)
        {
            Contact_0 _S645 = contact_part_0(mat_6, b_26, state_7->crush_1, float3(state_7->plastic_x_0, state_7->plastic_y_0, state_7->plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * float3((1.0f - _S644))  + _S645.q_ang_1 * float3(_S644) ;
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S646 = stress_measures_0(b_26, float3(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        thread Measures_0 _S647 = _S646;
        float4 _S648 = failure_indices_0(mat_6, b_26, &_S647, multiplier_1);
        float _S649 = _S648.z;
        float _S650 = _S648.w;
        bool _S651 = _S649 >= _S650;
        if(_S651)
        {
            psi_contact_0 = _S649;
        }
        else
        {
            psi_contact_0 = _S650;
        }
        if(_S651)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S636 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S636 = false;
        }
        if(_S636)
        {
            _S636 = psi_c_0 > 0.0f;
        }
        else
        {
            _S636 = false;
        }
        if(_S636)
        {
            if(softening_0)
            {
                float _S652 = (metal::fast::divide((mat_6->energy_1.w * (float4(b_26->geom0_0) ).x * psi_contact_0 * psi_contact_0), (psi_c_0)));
                intact_normal_0 = _S652;
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
            float2 inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_1, psi_c_0);
            float _S653 = inc_1.x;
            if(_S653 > ((&st_1)->crush_1))
            {
                float _S654 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S654;
                float overshoot_2 = overshoot_1 + max(psi_c_0 * (_S653 - (&st_1)->crush_1) - _S654, 0.0f);
                (&st_1)->crush_1 = _S653;
                (&st_1)->mode_0 = mode_c_0;
                if(_S653 >= 1.0f)
                {
                    _S636 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S636 = false;
                }
                if(_S636)
                {
                    float dissipated_5 = dissipated_4 + psi_ts_0 * (1.0f - (&st_1)->damage_0);
                    (&st_1)->damage_0 = 1.0f;
                    dissipated_3 = dissipated_5;
                }
                else
                {
                    dissipated_3 = dissipated_4;
                }
                overshoot_1 = overshoot_2;
            }
        }
        (&st_1)->kappa_c_0 = max((&st_1)->kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_1)->damage_0;
    float3 _S655 = float3(0.0f) ;
    if(((&st_1)->damage_0) == 0.0f)
    {
        _S636 = (flags_1 & 8U) != 0U;
    }
    else
    {
        _S636 = false;
    }
    float3 qc_ang_0;
    if(!_S636)
    {
        Contact_0 _S656 = contact_part_0(mat_6, b_26, (&st_1)->crush_1, plastic_3, d_lin_1, d_ang_1);
        (&st_1)->plastic_x_0 = _S656.plastic_1.x;
        (&st_1)->plastic_y_0 = _S656.plastic_1.y;
        (&st_1)->plastic_t_0 = _S656.plastic_1.z;
        diss_contact_0 = _S656.diss_4;
        qc_lin_0 = _S656.q_lin_1;
        qc_ang_0 = _S656.q_ang_1;
        psi_contact_0 = _S656.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S655;
        qc_ang_0 = _S655;
        psi_contact_0 = 0.0f;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S635)
    {
        intact_normal_0 = kn_2 * _S634;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_1) * kn_2 * _S634;
    }
    float _S657 = 1.0f - dmg_0;
    float3 force_lin_2 = float3(_S657 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S657 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S657 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3 force_ang_2 = qe_ang_0 * float3(_S657)  + qc_ang_0 * float3(dmg_0) ;
    float stored_6 = _S657 * (psi_ts_0 + (1.0f - (&st_1)->crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S636 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S636 = false;
    }
    float stored_7;
    float3 force_lin_3;
    if(_S636)
    {
        float4 _S658 = float4(b_26->rebar0_0) ;
        float k_axial_0 = _S658.x;
        float k_dowel_0 = _S658.y;
        float yield_force_0 = _S658.z;
        float dowel_capacity_0 = _S658.w;
        float2 nr_0 = return_map_0(k_axial_0, _S634, (&st_1)->rebar_plastic_0, yield_force_0);
        float2 v1_0 = return_map_0(k_dowel_0, _S631, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2 v2_0 = return_map_0(k_dowel_0, _S632, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S659 = nr_0.y;
        float _S660 = v1_0.y;
        float _S661 = v2_0.y;
        float work_0 = yield_force_0 * abs(_S659) + dowel_capacity_0 * (abs(_S660) + abs(_S661));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S659;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S660;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S661;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S662 = nr_0.x;
        float _S663 = (metal::fast::divide((sq_0(_S662)), (k_axial_0)));
        float _S664 = v1_0.x;
        float _S665 = v2_0.x;
        float _S666 = (metal::fast::divide((sq_0(_S664) + sq_0(_S665)), (k_dowel_0)));
        float elastic_0 = 0.5f * (_S663 + _S666);
        if(fracture_1)
        {
            _S636 = ((&st_1)->rebar_work_0) >= ((float4(b_26->rebar1_0) ).x);
        }
        else
        {
            _S636 = false;
        }
        if(_S636)
        {
            (&st_1)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_7 = stored_6;
        }
        else
        {
            float stored_8 = stored_6 + elastic_0;
            force_lin_3 = force_lin_2 + float3(_S664, _S665, _S662);
            dissipated_3 = dissipated_7;
            stored_7 = stored_8;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_3 = dissipated_6;
        stored_7 = stored_6;
    }
    if(fracture_1)
    {
        _S636 = _S620;
    }
    else
    {
        _S636 = false;
    }
    if(_S636)
    {
        _S636 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S636 = false;
    }
    if(_S636)
    {
        Measures_0 _S667 = stress_measures_0(b_26, force_lin_3, force_ang_2);
        thread Measures_0 _S668 = _S667;
        float4 _S669 = failure_indices_0(mat_6, b_26, &_S668, weibull_0);
        float _S670 = life_rate_0(mat_6, max(max(_S669.x, _S669.y), _S669.z));
        (&st_1)->fatigue_0 = min((&st_1)->fatigue_0 + _S670 * dt_8, 1.0f);
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    thread JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_6 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S617)
    {
        thread JointState_0 _S671 = st_1;
        bool _S672 = connected_0(&_S671, has_rebar_1);
        _S636 = !_S672;
    }
    else
    {
        _S636 = false;
    }
    (&resp_0)->disconnected_0 = _S636;
    (&resp_0)->measures_0 = _S618;
    return resp_0;
}

void secant_factors_0(const JointBond_natural_0 thread* b_27, const JointState_0 thread* st_2, float3 d_lin_2, float3 thread* f_lin_0, float3 thread* f_ang_0)
{
    float _S673 = st_2->damage_0;
    bool compressed_0 = (d_lin_2.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S673;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S674 = 1.0f - _S673;
    float _S675 = max(_S674 + contact_2, 9.99999997475242708e-07f);
    float normal_5;
    if(compressed_0)
    {
        normal_5 = max(1.0f - st_2->crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_5 = max(_S674, 9.99999997475242708e-07f);
    }
    *f_lin_0 = float3(_S675, _S675, normal_5);
    *f_ang_0 = float3(_S675) ;
    bool _S676;
    if(((float4(b_27->stiff1_0) ).w) != 0.0f)
    {
        _S676 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S676 = false;
    }
    if(_S676)
    {
        float4 _S677 = float4(b_27->rebar0_0) ;
        float4 _S678 = float4(b_27->stiff0_0) ;
        float _S679 = (metal::fast::divide((_S677.x), (_S678.x)));
        (*f_lin_0).z = (*f_lin_0).z + _S679;
        float _S680 = _S677.y;
        float _S681 = _S678.y;
        float _S682 = (metal::fast::divide((_S680), (_S681)));
        (*f_lin_0).x = (*f_lin_0).x + _S682;
        float _S683 = (metal::fast::divide((_S680), (_S681)));
        (*f_lin_0).y = (*f_lin_0).y + _S683;
    }
    return;
}

bool is_damaged_0(const JointState_0 thread* st_3)
{
    bool _S684;
    if((st_3->damage_0) > 0.0f)
    {
        _S684 = true;
    }
    else
    {
        _S684 = (st_3->crush_1) > 0.0f;
    }
    return _S684;
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

float3 to_local_0(uint _S685, float3 _S686, KernelContext_0 thread* kernelContext_37)
{
    BondStatic_natural_0 device* _S687 = kernelContext_37->bonds_0+_S685;
    return float3(dot(_S686, (float4(_S687->t1_0) ).xyz), dot(_S686, (float4(_S687->t2_0) ).xyz), dot(_S686, (float4(_S687->normal_0) ).xyz));
}

float3 to_body_0(uint _S688, float3 _S689, KernelContext_0 thread* kernelContext_38)
{
    BondStatic_natural_0 device* _S690 = kernelContext_38->bonds_0+_S688;
    return (float4(_S690->t1_0) ).xyz * float3(_S689.x)  + (float4(_S690->t2_0) ).xyz * float3(_S689.y)  + (float4(_S690->normal_0) ).xyz * float3(_S689.z) ;
}

bool bond_update_0(uint i_8, float dt_9, bool fracture_2, uint abs_step_0, KernelContext_0 thread* kernelContext_39)
{
    BondStatic_natural_0 device* _S691 = kernelContext_39->bonds_0+i_8;
    BondDyn_natural_0 device* _S692 = kernelContext_39->bond_dyn_0+i_8;
    float4 _S693 = float4((*_S692).force_lin_0) ;
    float4 _S694 = float4((*_S692).force_ang_0) ;
    float4 _S695 = float4((*_S692).sums_0) ;
    float4 _S696 = float4((*_S692).comps_0) ;
    uint4 _S697 = uint4((*_S692).events_0) ;
    thread BondDyn_0 bd_0;
    (&bd_0)->js_0 = (*_S692).js_0;
    (&bd_0)->force_lin_0 = _S693;
    (&bd_0)->force_ang_0 = _S694;
    (&bd_0)->sums_0 = _S695;
    (&bd_0)->comps_0 = _S696;
    (&bd_0)->events_0 = _S697;
    JointBond_natural_0 _S698 = _S691->law_0;
    thread JointBond_natural_0 _S699 = _S691->law_0;
    uint4 _S700 = uint4((&_S699)->ids_0) ;
    float3 ra_1 = (float4(_S691->ra_0) ).xyz;
    float3 rb_1 = (float4(_S691->rb_0) ).xyz;
    uint _S701 = 4U * _S700.y;
    float3 ta_2 = (float4(*(kernelContext_39->state_0+(_S701 + 1U))) ).xyz;
    float3 va_0 = (float4(*(kernelContext_39->state_0+(_S701 + 2U))) ).xyz;
    float3 wa_0 = (float4(*(kernelContext_39->state_0+(_S701 + 3U))) ).xyz;
    uint _S702 = 4U * _S700.z;
    float3 tb_2 = (float4(*(kernelContext_39->state_0+(_S702 + 1U))) ).xyz;
    float3 vb_0 = (float4(*(kernelContext_39->state_0+(_S702 + 2U))) ).xyz;
    float3 wb_0 = (float4(*(kernelContext_39->state_0+(_S702 + 3U))) ).xyz;
    float3 _S703 = to_local_0(i_8, (float4(*(kernelContext_39->state_0+_S702)) ).xyz + cross(tb_2, rb_1) - ((float4(*(kernelContext_39->state_0+_S701)) ).xyz + cross(ta_2, ra_1)), kernelContext_39);
    float3 _S704 = to_local_0(i_8, tb_2 - ta_2, kernelContext_39);
    float3 _S705 = to_local_0(i_8, vb_0 + cross(wb_0, rb_1) - (va_0 + cross(wa_0, ra_1)), kernelContext_39);
    float3 _S706 = to_local_0(i_8, wb_0 - wa_0, kernelContext_39);
    JointState_0 previous_0 = (&bd_0)->js_0;
    _S699 = _S698;
    thread JointState_0 _S707 = (&bd_0)->js_0;
    JointResponse_0 _S708 = joint_evaluate_0(&kernelContext_39->materials_0->m_0[_S700.x], &_S699, &_S707, _S703, _S704, dt_9, fracture_2);
    thread JointState_0 _S709 = _S708.state_6;
    thread float3 f_lin_1;
    thread float3 f_ang_1;
    secant_factors_0(&_S699, &_S709, _S703, &f_lin_1, &f_ang_1);
    float3 qd_lin_0 = _S705 * (float4(_S691->c_lin_0) ).xyz * f_lin_1;
    float3 qd_ang_0 = _S706 * (float4(_S691->c_ang_0) ).xyz * f_ang_1;
    float3 q_lin_2 = _S708.force_lin_1 + qd_lin_0;
    float3 q_ang_2 = _S708.force_ang_1 + qd_ang_0;
    float damped_0 = (dot(qd_lin_0, _S705) + dot(qd_ang_0, _S706)) * dt_9;
    float3 _S710 = to_body_0(i_8, q_lin_2, kernelContext_39);
    float3 _S711 = to_body_0(i_8, q_ang_2, kernelContext_39);
    uint _S712 = 3U * i_8;
    *(kernelContext_39->scratch_0+_S712) = packed_float4(float4(_S710, max(_S708.measures_0.tension_0, _S708.measures_0.compression_0))) ;
    *(kernelContext_39->scratch_0+(_S712 + 1U)) = packed_float4(float4(_S711 + cross(ra_1, _S710), 0.0f)) ;
    *(kernelContext_39->scratch_0+(_S712 + 2U)) = packed_float4(float4(- _S711 + cross(rb_1, - _S710), 0.0f)) ;
    thread float _S713 = (&bd_0)->sums_0.x;
    thread float _S714 = (&bd_0)->comps_0.x;
    comp_add1_0(&_S713, &_S714, _S708.dissipated_2);
    (&bd_0)->comps_0.x = _S714;
    (&bd_0)->sums_0.x = _S713;
    thread float _S715 = (&bd_0)->sums_0.y;
    thread float _S716 = (&bd_0)->comps_0.y;
    comp_add1_0(&_S715, &_S716, _S708.overshoot_0);
    (&bd_0)->comps_0.y = _S716;
    (&bd_0)->sums_0.y = _S715;
    thread float _S717 = (&bd_0)->sums_0.z;
    thread float _S718 = (&bd_0)->comps_0.z;
    comp_add1_0(&_S717, &_S718, damped_0);
    (&bd_0)->comps_0.z = _S718;
    (&bd_0)->sums_0.z = _S717;
    (&bd_0)->force_lin_0 = float4(q_lin_2, _S708.stored_5);
    (&bd_0)->force_ang_0 = float4(q_ang_2, max((&bd_0)->force_ang_0.w, _S708.state_6.utilization_0));
    thread JointState_0 _S719 = previous_0;
    bool _S720 = is_damaged_0(&_S719);
    bool _S721;
    if(!_S720)
    {
        thread JointState_0 _S722 = _S708.state_6;
        bool _S723 = is_damaged_0(&_S722);
        _S721 = _S723;
    }
    else
    {
        _S721 = false;
    }
    if(_S721)
    {
        _S721 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S721 = false;
    }
    if(_S721)
    {
        (&bd_0)->events_0.x = abs_step_0;
        (&bd_0)->events_0.w = _S708.state_6.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S724 = fatigue_factor_0(&kernelContext_39->materials_0->m_0[_S700.x], previous_0.fatigue_0);
        _S721 = _S724 > 0.99000000953674316f;
    }
    else
    {
        _S721 = false;
    }
    if(_S721)
    {
        float _S725 = fatigue_factor_0(&kernelContext_39->materials_0->m_0[_S700.x], _S708.state_6.fatigue_0);
        _S721 = _S725 <= 0.99000000953674316f;
    }
    else
    {
        _S721 = false;
    }
    if(_S721)
    {
        (&bd_0)->events_0.y = abs_step_0;
    }
    if(_S708.disconnected_0)
    {
        (&bd_0)->events_0.z = abs_step_0;
    }
    (&bd_0)->js_0 = _S708.state_6;
    BondDyn_natural_0 device* _S726 = kernelContext_39->bond_dyn_0+i_8;
    _S726->js_0 = bd_0.js_0;
    _S726->force_lin_0 = packed_float4(bd_0.force_lin_0) ;
    _S726->force_ang_0 = packed_float4(bd_0.force_ang_0) ;
    _S726->sums_0 = packed_float4(bd_0.sums_0) ;
    _S726->comps_0 = packed_float4(bd_0.comps_0) ;
    _S726->events_0 = packed_uint4(bd_0.events_0) ;
    return _S708.disconnected_0;
}

void chunk_update_0(uint c_13, const Island_natural_0 thread* isl_8, const Rigid_0 thread* rg_6, float dt_10, bool rml_0, uint step_0, bool contact_3, float thread* work_1, float thread* work_err_0, KernelContext_0 thread* kernelContext_40)
{
    ChunkStatic_natural_0 device* _S727 = kernelContext_40->chunks_0+c_13;
    float3 _S728 = float3(0.0f) ;
    uint _S729 = kernelContext_40->index_0[c_13];
    float peak_0 = 0.0f;
    uint e_3 = _S729;
    float3 fi_0 = _S728;
    float3 mi_0 = _S728;
    for(;;)
    {
        if(e_3 < (kernelContext_40->index_0)[c_13 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_2 = kernelContext_40->index_0[e_3];
        uint _S730 = 3U * (entry_2 >> 1U);
        float4 _S731 = float4(*(kernelContext_40->scratch_0+_S730)) ;
        if((entry_2 & 1U) == 0U)
        {
            float3 mi_1 = mi_0 + (float4(*(kernelContext_40->scratch_0+(_S730 + 1U))) ).xyz;
            fi_0 = fi_0 + _S731.xyz;
            mi_0 = mi_1;
        }
        else
        {
            float3 mi_2 = mi_0 + (float4(*(kernelContext_40->scratch_0+(_S730 + 2U))) ).xyz;
            fi_0 = fi_0 + - _S731.xyz;
            mi_0 = mi_2;
        }
        float _S732 = max(peak_0, _S731.w);
        uint _S733 = e_3 + 1U;
        peak_0 = _S732;
        e_3 = _S733;
    }
    uint _S734 = 4U * c_13;
    float3 u_0 = (float4(*(kernelContext_40->state_0+_S734)) ).xyz;
    uint _S735 = _S734 + 1U;
    float3 th_1 = (float4(*(kernelContext_40->state_0+_S735)) ).xyz;
    uint _S736 = _S734 + 2U;
    float3 v_9 = (float4(*(kernelContext_40->state_0+_S736)) ).xyz;
    uint _S737 = _S734 + 3U;
    float3 w_4 = (float4(*(kernelContext_40->state_0+_S737)) ).xyz;
    float4 _S738 = float4(_S727->center_0) ;
    float mass_0 = _S738.w;
    float3 _S739 = _S738.xyz;
    float3 _S740 = (float4(isl_8->com_0) ).xyz;
    float3 _S741 = rotate_0(&rg_6->rot_0, _S739 + u_0 - _S740);
    thread float3 f_load_0;
    thread float3 t_load_0;
    chunk_external_0(c_13, c_13, &rg_6->rot_0, step_0, dt_10, contact_3, &f_load_0, &t_load_0, kernelContext_40);
    float3 _S742 = float3(mass_0) ;
    float3 f_world_0 = f_load_0 + kernelContext_40->params_0->gravity_0.xyz * _S742;
    float3 t_world_0 = t_load_0;
    float3 f_world_1;
    float3 t_world_1;
    if(rml_0)
    {
        float3 f_world_2 = f_world_0 - (rg_6->a_6 + cross(rg_6->alpha_0, _S741) + cross(rg_6->w_3, cross(rg_6->w_3, _S741))) * _S742;
        float4 _S743 = float4(_S727->inertia0_1) ;
        float4 _S744 = float4(_S727->inertia1_1) ;
        float4 _S745 = float4(_S727->inertia2_1) ;
        float3 _S746 = world_mul_0(&rg_6->rot_0, _S743, _S744, _S745, rg_6->alpha_0);
        float3 _S747 = world_mul_0(&rg_6->rot_0, _S743, _S744, _S745, rg_6->w_3);
        float3 t_world_2 = t_world_0 - (_S746 + cross(rg_6->w_3, _S747));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3 _S748 = inverse_rotate_0(&rg_6->rot_0, f_world_1);
    float3 _S749 = inverse_rotate_0(&rg_6->rot_0, t_world_1);
    float3 f_ext_0;
    float3 m_ext_0;
    if(rml_0)
    {
        float3 _S750 = inverse_rotate_0(&rg_6->rot_0, rg_6->w_3);
        float4 _S751 = float4(_S727->inertia0_1) ;
        float4 _S752 = float4(_S727->inertia1_1) ;
        float4 _S753 = float4(_S727->inertia2_1) ;
        float3 i_w_0 = rows_mul_0(_S751, _S752, _S753, w_4);
        float3 m_ext_1 = _S749 - (cross(_S750, i_w_0) + cross(w_4, rows_mul_0(_S751, _S752, _S753, _S750)) + cross(w_4, i_w_0));
        f_ext_0 = _S748 - cross(_S750, v_9) * float3((2.0f * mass_0)) ;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S748;
        m_ext_0 = _S749;
    }
    uint4 _S754 = uint4(_S727->load_range_0) ;
    uint term_4 = _S754.x;
    for(;;)
    {
        if(term_4 < (_S754.y))
        {
        }
        else
        {
            break;
        }
        uint _S755 = 5U * term_4;
        if(((as_type<uint4>((float4(*(kernelContext_40->loads_0+_S755)) ))).y) != 2U)
        {
            term_4 = term_4 + 1U;
            continue;
        }
        float _S756 = eval_function_0(term_4, step_0, dt_10, dt_10, kernelContext_40);
        float3 _S757 = float3(_S756) ;
        float3 m_ext_2 = m_ext_0 + (float4(*(kernelContext_40->loads_0+(_S755 + 2U))) ).xyz * _S757;
        f_ext_0 = f_ext_0 + (float4(*(kernelContext_40->loads_0+(_S755 + 1U))) ).xyz * _S757;
        m_ext_0 = m_ext_2;
        term_4 = term_4 + 1U;
    }
    float3 f_10 = f_ext_0 + fi_0;
    float3 m_5 = m_ext_0 + mi_0;
    uint support_0 = (uint4(_S727->info_1) ).x;
    float3 _S758 = float3((float4(*(kernelContext_40->state_0+_S735)) ).w, (float4(*(kernelContext_40->state_0+_S736)) ).w, (float4(*(kernelContext_40->state_0+_S737)) ).w);
    float3 reaction_0;
    float3 u_1;
    float3 th_2;
    float3 v_10;
    float3 w_5;
    if(support_0 == 1U)
    {
        reaction_0 = - f_10;
        u_1 = u_0;
        th_2 = th_1;
        v_10 = _S728;
        w_5 = _S728;
    }
    else
    {
        float4 _S759 = float4(_S727->scale_0) ;
        float3 w_6 = w_4 + rows_mul_0(float4(_S727->inv0_1) , float4(_S727->inv1_1) , float4(_S727->inv2_1) , m_5) * float3((dt_10 * _S759.z)) ;
        float3 _S760 = float3(dt_10) ;
        float3 th_3 = th_1 + w_6 * _S760;
        if(support_0 == 2U)
        {
            reaction_0 = - f_10;
            u_1 = u_0;
            th_2 = _S728;
        }
        else
        {
            float3 v_11 = v_9 + f_10 * float3((dt_10 * _S759.y)) ;
            float3 u_2 = u_0 + v_11 * _S760;
            reaction_0 = _S758;
            u_1 = u_2;
            th_2 = v_11;
        }
        float3 _S761 = th_2;
        th_2 = th_3;
        v_10 = _S761;
        w_5 = w_6;
    }
    *(kernelContext_40->state_0+_S734) = packed_float4(float4(u_1, peak_0)) ;
    *(kernelContext_40->state_0+_S735) = packed_float4(float4(th_2, reaction_0.x)) ;
    *(kernelContext_40->state_0+_S736) = packed_float4(float4(v_10, reaction_0.y)) ;
    *(kernelContext_40->state_0+_S737) = packed_float4(float4(w_5, reaction_0.z)) ;
    float3 _S762 = rotate_0(&rg_6->rot_0, _S739 + u_1 - _S740);
    float3 _S763 = rg_6->vel_1 + rg_6->vel_err_1 + cross(rg_6->w_3, _S762);
    float3 _S764 = rotate_0(&rg_6->rot_0, v_10);
    float3 v_world_0 = _S763 + _S764;
    float3 _S765 = rotate_0(&rg_6->rot_0, w_5);
    comp_add1_0(work_1, work_err_0, (dot(f_load_0, v_world_0) + dot(t_load_0, rg_6->w_3 + _S765)) * dt_10);
    return;
}

void chunk_update_1(uint c_14, const Island_0 thread* isl_9, const Rigid_0 thread* rg_7, float dt_11, bool rml_1, uint step_1, bool contact_4, float thread* work_2, float thread* work_err_1, KernelContext_0 thread* kernelContext_41)
{
    ChunkStatic_natural_0 device* _S766 = kernelContext_41->chunks_0+c_14;
    float3 _S767 = float3(0.0f) ;
    uint _S768 = kernelContext_41->index_0[c_14];
    float peak_1 = 0.0f;
    uint e_4 = _S768;
    float3 fi_1 = _S767;
    float3 mi_3 = _S767;
    for(;;)
    {
        if(e_4 < (kernelContext_41->index_0)[c_14 + 1U])
        {
        }
        else
        {
            break;
        }
        uint entry_3 = kernelContext_41->index_0[e_4];
        uint _S769 = 3U * (entry_3 >> 1U);
        float4 _S770 = float4(*(kernelContext_41->scratch_0+_S769)) ;
        if((entry_3 & 1U) == 0U)
        {
            float3 mi_4 = mi_3 + (float4(*(kernelContext_41->scratch_0+(_S769 + 1U))) ).xyz;
            fi_1 = fi_1 + _S770.xyz;
            mi_3 = mi_4;
        }
        else
        {
            float3 mi_5 = mi_3 + (float4(*(kernelContext_41->scratch_0+(_S769 + 2U))) ).xyz;
            fi_1 = fi_1 + - _S770.xyz;
            mi_3 = mi_5;
        }
        float _S771 = max(peak_1, _S770.w);
        uint _S772 = e_4 + 1U;
        peak_1 = _S771;
        e_4 = _S772;
    }
    uint _S773 = 4U * c_14;
    float3 u_3 = (float4(*(kernelContext_41->state_0+_S773)) ).xyz;
    uint _S774 = _S773 + 1U;
    float3 th_4 = (float4(*(kernelContext_41->state_0+_S774)) ).xyz;
    uint _S775 = _S773 + 2U;
    float3 v_12 = (float4(*(kernelContext_41->state_0+_S775)) ).xyz;
    uint _S776 = _S773 + 3U;
    float3 w_7 = (float4(*(kernelContext_41->state_0+_S776)) ).xyz;
    float4 _S777 = float4(_S766->center_0) ;
    float mass_1 = _S777.w;
    float3 _S778 = _S777.xyz;
    float3 _S779 = isl_9->com_0.xyz;
    float3 _S780 = rotate_0(&rg_7->rot_0, _S778 + u_3 - _S779);
    thread float3 f_load_1;
    thread float3 t_load_1;
    chunk_external_0(c_14, c_14, &rg_7->rot_0, step_1, dt_11, contact_4, &f_load_1, &t_load_1, kernelContext_41);
    float3 _S781 = float3(mass_1) ;
    float3 f_world_3 = f_load_1 + kernelContext_41->params_0->gravity_0.xyz * _S781;
    float3 t_world_3 = t_load_1;
    float3 f_world_4;
    float3 t_world_4;
    if(rml_1)
    {
        float3 f_world_5 = f_world_3 - (rg_7->a_6 + cross(rg_7->alpha_0, _S780) + cross(rg_7->w_3, cross(rg_7->w_3, _S780))) * _S781;
        float4 _S782 = float4(_S766->inertia0_1) ;
        float4 _S783 = float4(_S766->inertia1_1) ;
        float4 _S784 = float4(_S766->inertia2_1) ;
        float3 _S785 = world_mul_0(&rg_7->rot_0, _S782, _S783, _S784, rg_7->alpha_0);
        float3 _S786 = world_mul_0(&rg_7->rot_0, _S782, _S783, _S784, rg_7->w_3);
        float3 t_world_5 = t_world_3 - (_S785 + cross(rg_7->w_3, _S786));
        f_world_4 = f_world_5;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_4 = f_world_3;
        t_world_4 = t_world_3;
    }
    float3 _S787 = inverse_rotate_0(&rg_7->rot_0, f_world_4);
    float3 _S788 = inverse_rotate_0(&rg_7->rot_0, t_world_4);
    float3 f_ext_1;
    float3 m_ext_3;
    if(rml_1)
    {
        float3 _S789 = inverse_rotate_0(&rg_7->rot_0, rg_7->w_3);
        float4 _S790 = float4(_S766->inertia0_1) ;
        float4 _S791 = float4(_S766->inertia1_1) ;
        float4 _S792 = float4(_S766->inertia2_1) ;
        float3 i_w_1 = rows_mul_0(_S790, _S791, _S792, w_7);
        float3 m_ext_4 = _S788 - (cross(_S789, i_w_1) + cross(w_7, rows_mul_0(_S790, _S791, _S792, _S789)) + cross(w_7, i_w_1));
        f_ext_1 = _S787 - cross(_S789, v_12) * float3((2.0f * mass_1)) ;
        m_ext_3 = m_ext_4;
    }
    else
    {
        f_ext_1 = _S787;
        m_ext_3 = _S788;
    }
    uint4 _S793 = uint4(_S766->load_range_0) ;
    uint term_5 = _S793.x;
    for(;;)
    {
        if(term_5 < (_S793.y))
        {
        }
        else
        {
            break;
        }
        uint _S794 = 5U * term_5;
        if(((as_type<uint4>((float4(*(kernelContext_41->loads_0+_S794)) ))).y) != 2U)
        {
            term_5 = term_5 + 1U;
            continue;
        }
        float _S795 = eval_function_0(term_5, step_1, dt_11, dt_11, kernelContext_41);
        float3 _S796 = float3(_S795) ;
        float3 m_ext_5 = m_ext_3 + (float4(*(kernelContext_41->loads_0+(_S794 + 2U))) ).xyz * _S796;
        f_ext_1 = f_ext_1 + (float4(*(kernelContext_41->loads_0+(_S794 + 1U))) ).xyz * _S796;
        m_ext_3 = m_ext_5;
        term_5 = term_5 + 1U;
    }
    float3 f_11 = f_ext_1 + fi_1;
    float3 m_6 = m_ext_3 + mi_3;
    uint support_1 = (uint4(_S766->info_1) ).x;
    float3 _S797 = float3((float4(*(kernelContext_41->state_0+_S774)) ).w, (float4(*(kernelContext_41->state_0+_S775)) ).w, (float4(*(kernelContext_41->state_0+_S776)) ).w);
    float3 reaction_1;
    float3 u_4;
    float3 th_5;
    float3 v_13;
    float3 w_8;
    if(support_1 == 1U)
    {
        reaction_1 = - f_11;
        u_4 = u_3;
        th_5 = th_4;
        v_13 = _S767;
        w_8 = _S767;
    }
    else
    {
        float4 _S798 = float4(_S766->scale_0) ;
        float3 w_9 = w_7 + rows_mul_0(float4(_S766->inv0_1) , float4(_S766->inv1_1) , float4(_S766->inv2_1) , m_6) * float3((dt_11 * _S798.z)) ;
        float3 _S799 = float3(dt_11) ;
        float3 th_6 = th_4 + w_9 * _S799;
        if(support_1 == 2U)
        {
            reaction_1 = - f_11;
            u_4 = u_3;
            th_5 = _S767;
        }
        else
        {
            float3 v_14 = v_12 + f_11 * float3((dt_11 * _S798.y)) ;
            float3 u_5 = u_3 + v_14 * _S799;
            reaction_1 = _S797;
            u_4 = u_5;
            th_5 = v_14;
        }
        float3 _S800 = th_5;
        th_5 = th_6;
        v_13 = _S800;
        w_8 = w_9;
    }
    *(kernelContext_41->state_0+_S773) = packed_float4(float4(u_4, peak_1)) ;
    *(kernelContext_41->state_0+_S774) = packed_float4(float4(th_5, reaction_1.x)) ;
    *(kernelContext_41->state_0+_S775) = packed_float4(float4(v_13, reaction_1.y)) ;
    *(kernelContext_41->state_0+_S776) = packed_float4(float4(w_8, reaction_1.z)) ;
    float3 _S801 = rotate_0(&rg_7->rot_0, _S778 + u_4 - _S779);
    float3 _S802 = rg_7->vel_1 + rg_7->vel_err_1 + cross(rg_7->w_3, _S801);
    float3 _S803 = rotate_0(&rg_7->rot_0, v_13);
    float3 v_world_1 = _S802 + _S803;
    float3 _S804 = rotate_0(&rg_7->rot_0, w_8);
    comp_add1_0(work_2, work_err_1, (dot(f_load_1, v_world_1) + dot(t_load_1, rg_7->w_3 + _S804)) * dt_11);
    return;
}

void integrate_rigid_0(const Island_natural_0 thread* isl_10, Rigid_0 thread* rg_8, float dt_12)
{
    float4 _S805 = float4(isl_10->inertia0_0) ;
    float4 _S806 = float4(isl_10->inertia1_0) ;
    float4 _S807 = float4(isl_10->inertia2_0) ;
    thread Quat_0 _S808 = rg_8->rot_0;
    float3 _S809 = world_mul_0(&_S808, _S805, _S806, _S807, rg_8->w_3);
    thread Quat_0 _S810 = rg_8->rot_0;
    float3 _S811 = world_mul_0(&_S810, _S805, _S806, _S807, rg_8->alpha_0);
    float3 _S812 = float3(dt_12) ;
    float3 l_2 = _S809 + (_S811 + cross(rg_8->w_3, _S809)) * _S812;
    comp_add_0(&rg_8->vel_1, &rg_8->vel_err_1, rg_8->a_6 * _S812);
    float3 vel_2 = rg_8->vel_1 + rg_8->vel_err_1;
    float4 _S813 = float4(isl_10->inv0_0) ;
    float4 _S814 = float4(isl_10->inv1_0) ;
    float4 _S815 = float4(isl_10->inv2_0) ;
    thread Quat_0 _S816 = rg_8->rot_0;
    float3 _S817 = world_mul_0(&_S816, _S813, _S814, _S815, l_2);
    thread Quat_0 _S818 = rg_8->rot_0;
    Quat_0 _S819 = integrate_rotation_0(&_S818, _S817, dt_12);
    float3 _S820 = vel_2 * _S812;
    float3 _S821 = (float4(isl_10->com_0) ).xyz;
    thread Quat_0 _S822 = rg_8->rot_0;
    float3 _S823 = rotate_0(&_S822, _S821);
    thread Quat_0 _S824 = _S819;
    float3 _S825 = rotate_0(&_S824, _S821);
    comp_add_0(&rg_8->pos_1, &rg_8->pos_err_1, _S820 + (_S823 - _S825));
    rg_8->rot_0 = _S819;
    thread Quat_0 _S826 = _S819;
    float3 _S827 = world_mul_0(&_S826, _S813, _S814, _S815, l_2);
    rg_8->w_3 = _S827;
    return;
}

void integrate_rigid_1(const Island_0 thread* isl_11, Rigid_0 thread* rg_9, float dt_13)
{
    thread Quat_0 _S828 = rg_9->rot_0;
    float3 _S829 = world_mul_0(&_S828, isl_11->inertia0_0, isl_11->inertia1_0, isl_11->inertia2_0, rg_9->w_3);
    thread Quat_0 _S830 = rg_9->rot_0;
    float3 _S831 = world_mul_0(&_S830, isl_11->inertia0_0, isl_11->inertia1_0, isl_11->inertia2_0, rg_9->alpha_0);
    float3 _S832 = float3(dt_13) ;
    float3 l_3 = _S829 + (_S831 + cross(rg_9->w_3, _S829)) * _S832;
    comp_add_0(&rg_9->vel_1, &rg_9->vel_err_1, rg_9->a_6 * _S832);
    float3 vel_3 = rg_9->vel_1 + rg_9->vel_err_1;
    float4 _S833 = isl_11->inv0_0;
    float4 _S834 = isl_11->inv1_0;
    float4 _S835 = isl_11->inv2_0;
    thread Quat_0 _S836 = rg_9->rot_0;
    float3 _S837 = world_mul_0(&_S836, isl_11->inv0_0, isl_11->inv1_0, isl_11->inv2_0, l_3);
    thread Quat_0 _S838 = rg_9->rot_0;
    Quat_0 _S839 = integrate_rotation_0(&_S838, _S837, dt_13);
    float3 _S840 = vel_3 * _S832;
    float3 _S841 = isl_11->com_0.xyz;
    thread Quat_0 _S842 = rg_9->rot_0;
    float3 _S843 = rotate_0(&_S842, _S841);
    thread Quat_0 _S844 = _S839;
    float3 _S845 = rotate_0(&_S844, _S841);
    comp_add_0(&rg_9->pos_1, &rg_9->pos_err_1, _S840 + (_S843 - _S845));
    rg_9->rot_0 = _S839;
    thread Quat_0 _S846 = _S839;
    float3 _S847 = world_mul_0(&_S846, _S833, _S834, _S835, l_3);
    rg_9->w_3 = _S847;
    return;
}

void drift_moments_0(uint c_15, float3 thread* tu_0, float3 thread* pv_0, KernelContext_0 thread* kernelContext_42)
{
    ChunkStatic_natural_0 device* _S848 = kernelContext_42->chunks_0+c_15;
    uint _S849 = 4U * c_15;
    float3 _S850 = float3(((float4(_S848->center_0) ).w * (float4(_S848->scale_0) ).x)) ;
    *tu_0 = *tu_0 + (float4(*(kernelContext_42->state_0+_S849)) ).xyz * _S850;
    *pv_0 = *pv_0 + (float4(*(kernelContext_42->state_0+(_S849 + 2U))) ).xyz * _S850;
    return;
}

void drift_angular_0(uint c_16, float3 wcom_1, float3 tr_0, float3 dv_0, float3 thread* lu_0, float3 thread* lv_0, KernelContext_0 thread* kernelContext_43)
{
    ChunkStatic_natural_0 device* _S851 = kernelContext_43->chunks_0+c_16;
    float4 _S852 = float4(_S851->center_0) ;
    float3 r_11 = _S852.xyz - wcom_1;
    uint _S853 = 4U * c_16;
    float3 _S854 = float3(_S852.w) ;
    float4 _S855 = float4(_S851->inertia0_1) ;
    float4 _S856 = float4(_S851->inertia1_1) ;
    float4 _S857 = float4(_S851->inertia2_1) ;
    float3 _S858 = float3((float4(_S851->scale_0) ).x) ;
    *lu_0 = *lu_0 + (cross(r_11, (float4(*(kernelContext_43->state_0+_S853)) ).xyz - tr_0) * _S854 + rows_mul_0(_S855, _S856, _S857, (float4(*(kernelContext_43->state_0+(_S853 + 1U))) ).xyz)) * _S858;
    *lv_0 = *lv_0 + (cross(r_11, (float4(*(kernelContext_43->state_0+(_S853 + 2U))) ).xyz - dv_0) * _S854 + rows_mul_0(_S855, _S856, _S857, (float4(*(kernelContext_43->state_0+(_S853 + 3U))) ).xyz)) * _S858;
    return;
}

void drift_apply_0(uint c_17, float3 wcom_2, float3 tr_1, float3 phi_0, float3 dv_1, float3 dw_0, KernelContext_0 thread* kernelContext_44)
{
    float3 r_12 = (float4((kernelContext_44->chunks_0+c_17)->center_0) ).xyz - wcom_2;
    uint _S859 = 4U * c_17;
    *(kernelContext_44->state_0+_S859) = packed_float4(float4((float4(*(kernelContext_44->state_0+_S859)) ).xyz - (tr_1 + cross(phi_0, r_12)), (float4(*(kernelContext_44->state_0+_S859)) ).w)) ;
    uint _S860 = _S859 + 1U;
    *(kernelContext_44->state_0+_S860) = packed_float4(float4((float4(*(kernelContext_44->state_0+_S860)) ).xyz - phi_0, (float4(*(kernelContext_44->state_0+_S860)) ).w)) ;
    uint _S861 = _S859 + 2U;
    *(kernelContext_44->state_0+_S861) = packed_float4(float4((float4(*(kernelContext_44->state_0+_S861)) ).xyz - (dv_1 + cross(dw_0, r_12)), (float4(*(kernelContext_44->state_0+_S861)) ).w)) ;
    uint _S862 = _S859 + 3U;
    *(kernelContext_44->state_0+_S862) = packed_float4(float4((float4(*(kernelContext_44->state_0+_S862)) ).xyz - dw_0, (float4(*(kernelContext_44->state_0+_S862)) ).w)) ;
    return;
}

void drift_rigid_0(const Island_natural_0 thread* isl_12, Rigid_0 thread* rg_10, float3 tr_2, float3 phi_1, float3 dv_2, float3 dw_1)
{
    float3 wcom_3 = (float4(isl_12->wcom_0) ).xyz;
    Quat_0 rot_1 = rg_10->rot_0;
    float3 _S863 = tr_2 - cross(phi_1, wcom_3);
    thread Quat_0 _S864 = rg_10->rot_0;
    float3 _S865 = rotate_0(&_S864, _S863);
    comp_add_0(&rg_10->pos_1, &rg_10->pos_err_1, _S865);
    Quat_0 _S866 = from_axis_angle_0(phi_1, length(phi_1));
    thread Quat_0 _S867 = rg_10->rot_0;
    thread Quat_0 _S868 = _S866;
    Quat_0 _S869 = quat_mul_0(&_S867, &_S868);
    thread Quat_0 _S870 = _S869;
    Quat_0 _S871 = normalized_0(&_S870);
    rg_10->rot_0 = _S871;
    float3 _S872 = dv_2 + cross(dw_1, (float4(isl_12->com_0) ).xyz - wcom_3);
    thread Quat_0 _S873 = rot_1;
    float3 _S874 = rotate_0(&_S873, _S872);
    comp_add_0(&rg_10->vel_1, &rg_10->vel_err_1, _S874);
    thread Quat_0 _S875 = rot_1;
    float3 _S876 = rotate_0(&_S875, dw_1);
    rg_10->w_3 = rg_10->w_3 + _S876;
    return;
}

void drift_rigid_1(const Island_0 thread* isl_13, Rigid_0 thread* rg_11, float3 tr_3, float3 phi_2, float3 dv_3, float3 dw_2)
{
    float3 wcom_4 = isl_13->wcom_0.xyz;
    Quat_0 rot_2 = rg_11->rot_0;
    float3 _S877 = tr_3 - cross(phi_2, wcom_4);
    thread Quat_0 _S878 = rg_11->rot_0;
    float3 _S879 = rotate_0(&_S878, _S877);
    comp_add_0(&rg_11->pos_1, &rg_11->pos_err_1, _S879);
    Quat_0 _S880 = from_axis_angle_0(phi_2, length(phi_2));
    thread Quat_0 _S881 = rg_11->rot_0;
    thread Quat_0 _S882 = _S880;
    Quat_0 _S883 = quat_mul_0(&_S881, &_S882);
    thread Quat_0 _S884 = _S883;
    Quat_0 _S885 = normalized_0(&_S884);
    rg_11->rot_0 = _S885;
    float3 _S886 = dv_3 + cross(dw_2, isl_13->com_0.xyz - wcom_4);
    thread Quat_0 _S887 = rot_2;
    float3 _S888 = rotate_0(&_S887, _S886);
    comp_add_0(&rg_11->vel_1, &rg_11->vel_err_1, _S888);
    thread Quat_0 _S889 = rot_2;
    float3 _S890 = rotate_0(&_S889, dw_2);
    rg_11->w_3 = rg_11->w_3 + _S890;
    return;
}

void write_probe_0(uint slot_1, uint k_17, float value_0, KernelContext_0 thread* kernelContext_45)
{
    uint at_4 = kernelContext_45->params_0->probe_base_0 * 4U + slot_1 * kernelContext_45->params_0->probe_stride_0 + k_17;
    thread float4 v_15 = float4(*(kernelContext_45->scratch_0+at_4 / 4U)) ;
    v_15[at_4 % 4U] = value_0;
    *(kernelContext_45->scratch_0+at_4 / 4U) = packed_float4(v_15) ;
    return;
}

void record_probes_0(const Island_0 thread* isl_14, const Rigid_0 thread* rg_12, uint k_18, KernelContext_0 thread* kernelContext_46)
{
    uint4 _S891 = isl_14->probes_0;
    uint at_5 = isl_14->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S891.y))
        {
        }
        else
        {
            break;
        }
        uint4 info_3 = (as_type<uint4>((float4(*(kernelContext_46->loads_0+at_5)) )));
        float4 _S892 = float4(*(kernelContext_46->loads_0+(at_5 + 1U))) ;
        float4 _S893 = float4(*(kernelContext_46->loads_0+(at_5 + 2U))) ;
        float4 _S894 = float4(*(kernelContext_46->loads_0+(at_5 + 3U))) ;
        uint kind_4 = info_3.x;
        uint i_9 = info_3.y;
        float value_1;
        if(kind_4 == 0U)
        {
            float3 _S895 = rg_12->pos_1 - _S893.xyz + (rg_12->pos_err_1 - _S894.xyz);
            float3 _S896 = rotate_0(&rg_12->rot_0, (float4((kernelContext_46->chunks_0+i_9)->center_0) ).xyz + (float4(*(kernelContext_46->state_0+4U * i_9)) ).xyz);
            value_1 = dot(_S895 + _S896, _S892.xyz);
        }
        else
        {
            if(kind_4 == 1U)
            {
                uint _S897 = 4U * i_9;
                float3 _S898 = rotate_0(&rg_12->rot_0, (float4((kernelContext_46->chunks_0+i_9)->center_0) ).xyz + (float4(*(kernelContext_46->state_0+_S897)) ).xyz - isl_14->com_0.xyz);
                float3 _S899 = rg_12->vel_1 + rg_12->vel_err_1 + cross(rg_12->w_3, _S898);
                float3 _S900 = rotate_0(&rg_12->rot_0, (float4(*(kernelContext_46->state_0+(_S897 + 2U))) ).xyz);
                value_1 = dot(_S899 + _S900, _S892.xyz);
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S901 = 3U * i_9;
                    float3 f_12 = (float4(*(kernelContext_46->scratch_0+_S901)) ).xyz;
                    bool _S902 = (info_3.z) == 0U;
                    float3 mc_0;
                    if(_S902)
                    {
                        mc_0 = (float4(*(kernelContext_46->scratch_0+(_S901 + 1U))) ).xyz;
                    }
                    else
                    {
                        mc_0 = (float4(*(kernelContext_46->scratch_0+(_S901 + 2U))) ).xyz;
                    }
                    float3 fc_4;
                    if(_S902)
                    {
                        fc_4 = f_12;
                    }
                    else
                    {
                        fc_4 = - f_12;
                    }
                    value_1 = dot(fc_4, _S892.xyz) + dot(mc_0, _S893.xyz);
                }
                else
                {
                    uint _S903 = 4U * i_9;
                    float3 _S904 = rotate_0(&rg_12->rot_0, float3((float4(*(kernelContext_46->state_0+(_S903 + 1U))) ).w, (float4(*(kernelContext_46->state_0+(_S903 + 2U))) ).w, (float4(*(kernelContext_46->state_0+(_S903 + 3U))) ).w));
                    value_1 = dot(_S904, _S892.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_18, value_1, kernelContext_46);
        at_5 = at_5 + 4U;
    }
    return;
}

void contact_split_at_0(uint at_6, KernelContext_0 thread* kernelContext_47)
{
    uint previous_1 = (uint4((kernelContext_47->islands_0+kernelContext_47->params_0->halt_index_0)->info_0) ).y;
    uint _S905;
    if(previous_1 == 0U)
    {
        _S905 = at_6;
    }
    else
    {
        _S905 = min(previous_1, at_6);
    }
    (kernelContext_47->islands_0+kernelContext_47->params_0->halt_index_0)->info_0[int(1)] = _S905;
    return;
}

[[kernel]] void island_frame(uint3 group_2 [[threadgroup_position_in_grid]], uint3 thread_2 [[thread_position_in_threadgroup]], Params_0 constant* params_6 [[buffer(0)]], Island_natural_0 device* islands_6 [[buffer(9)]], uint device* index_6 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_6 [[buffer(3)]], packed_float4 device* state_8 [[buffer(6)]], packed_float4 device* scratch_6 [[buffer(8)]], packed_float4 device* contact_state_6 [[buffer(11)]], packed_float4 device* loads_6 [[buffer(5)]], Impactor_natural_0 device* impactors_6 [[buffer(10)]], BondStatic_natural_0 device* bonds_6 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_6 [[buffer(7)]], MaterialTable_0 constant* materials_6 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_48;
    (&kernelContext_48)->params_0 = params_6;
    (&kernelContext_48)->islands_0 = islands_6;
    (&kernelContext_48)->index_0 = index_6;
    (&kernelContext_48)->chunks_0 = chunks_6;
    (&kernelContext_48)->state_0 = state_8;
    (&kernelContext_48)->scratch_0 = scratch_6;
    (&kernelContext_48)->contact_state_0 = contact_state_6;
    (&kernelContext_48)->loads_0 = loads_6;
    (&kernelContext_48)->impactors_0 = impactors_6;
    (&kernelContext_48)->bonds_0 = bonds_6;
    (&kernelContext_48)->bond_dyn_0 = bond_dyn_6;
    (&kernelContext_48)->materials_0 = materials_6;
    threadgroup array<float4, int(256)> g_red_a_6;
    (&kernelContext_48)->g_red_a_0 = &g_red_a_6;
    threadgroup array<float4, int(256)> g_red_b_6;
    (&kernelContext_48)->g_red_b_0 = &g_red_b_6;
    threadgroup uint g_run_6;
    (&kernelContext_48)->g_run_0 = &g_run_6;
    threadgroup uint g_halt_6;
    (&kernelContext_48)->g_halt_0 = &g_halt_6;
    threadgroup uint g_wide_run_6;
    (&kernelContext_48)->g_wide_run_0 = &g_wide_run_6;
    uint tid_4 = thread_2.x;
    uint _S906 = group_2.x;
    Island_natural_0 device* _S907 = islands_6+_S906;
    uint4 _S908 = uint4((*_S907).info_0) ;
    float4 _S909 = float4((*_S907).com_0) ;
    float4 _S910 = float4((*_S907).inertia0_0) ;
    float4 _S911 = float4((*_S907).inertia1_0) ;
    float4 _S912 = float4((*_S907).inertia2_0) ;
    float4 _S913 = float4((*_S907).inv0_0) ;
    float4 _S914 = float4((*_S907).inv1_0) ;
    float4 _S915 = float4((*_S907).inv2_0) ;
    float4 _S916 = float4((*_S907).wcom_0) ;
    float4 _S917 = float4((*_S907).winv0_0) ;
    float4 _S918 = float4((*_S907).winv1_0) ;
    float4 _S919 = float4((*_S907).winv2_0) ;
    float4 _S920 = float4((*_S907).rotation_0) ;
    float4 _S921 = float4((*_S907).position_0) ;
    float4 _S922 = float4((*_S907).position_err_0) ;
    float4 _S923 = float4((*_S907).velocity_0) ;
    float4 _S924 = float4((*_S907).velocity_err_0) ;
    float4 _S925 = float4((*_S907).angular_velocity_0) ;
    uint4 _S926 = uint4((*_S907).done_0) ;
    uint4 _S927 = uint4((*_S907).probes_0) ;
    float4 _S928 = float4((*_S907).energy_0) ;
    thread Island_0 isl_15;
    (&isl_15)->range_0 = uint4((*_S907).range_0) ;
    (&isl_15)->info_0 = _S908;
    (&isl_15)->com_0 = _S909;
    (&isl_15)->inertia0_0 = _S910;
    (&isl_15)->inertia1_0 = _S911;
    (&isl_15)->inertia2_0 = _S912;
    (&isl_15)->inv0_0 = _S913;
    (&isl_15)->inv1_0 = _S914;
    (&isl_15)->inv2_0 = _S915;
    (&isl_15)->wcom_0 = _S916;
    (&isl_15)->winv0_0 = _S917;
    (&isl_15)->winv1_0 = _S918;
    (&isl_15)->winv2_0 = _S919;
    (&isl_15)->rotation_0 = _S920;
    (&isl_15)->position_0 = _S921;
    (&isl_15)->position_err_0 = _S922;
    (&isl_15)->velocity_0 = _S923;
    (&isl_15)->velocity_err_0 = _S924;
    (&isl_15)->angular_velocity_0 = _S925;
    (&isl_15)->done_0 = _S926;
    (&isl_15)->probes_0 = _S927;
    (&isl_15)->energy_0 = _S928;
    bool driven_0 = (((&isl_15)->info_0.x) & 2U) != 0U;
    bool _S929 = !((((&isl_15)->info_0.x) & 1U) != 0U);
    bool _S930;
    if(_S929)
    {
        _S930 = !driven_0;
    }
    else
    {
        _S930 = false;
    }
    bool contact_island_0 = (((&isl_15)->info_0.x) & 4U) != 0U;
    bool _S931 = tid_4 == 0U;
    bool _S932;
    uint run_0;
    if(_S931)
    {
        if(contact_island_0 != (((&kernelContext_48)->params_0->contact_mode_0) == 1U))
        {
            _S932 = true;
        }
        else
        {
            _S932 = (((&isl_15)->info_0.x) & 8U) != 0U;
        }
        if(_S932)
        {
            run_0 = 0U;
        }
        else
        {
            run_0 = 1U;
        }
        if(contact_island_0)
        {
            thread Island_0 _S933 = isl_15;
            bool _S934 = contact_stopped_1(&_S933, &kernelContext_48);
            _S932 = _S934;
        }
        else
        {
            _S932 = false;
        }
        if(_S932)
        {
            run_0 = 0U;
        }
        *(&kernelContext_48)->g_run_0 = run_0;
        *(&kernelContext_48)->g_halt_0 = 0U;
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    if((((&isl_15)->info_0.z) & 1U) != 0U)
    {
        _S932 = true;
    }
    else
    {
        _S932 = (*(&kernelContext_48)->g_run_0) == 0U;
    }
    if(_S932)
    {
        run_0 = 0U;
    }
    else
    {
        run_0 = min((&isl_15)->info_0.y, (&kernelContext_48)->params_0->max_steps_0);
    }
    float _S935 = (&kernelContext_48)->params_0->dt_0;
    bool _S936 = ((&kernelContext_48)->params_0->fracture_0) != 0U;
    bool _S937 = ((&kernelContext_48)->params_0->rigid_motion_loads_0) != 0U;
    thread Island_0 _S938 = isl_15;
    Rigid_0 _S939 = rigid_of_1(&_S938);
    thread Rigid_0 rg_13 = _S939;
    thread float work_3 = 0.0f;
    thread float work_err_2 = 0.0f;
    uint done_1 = 0U;
    for(;;)
    {
        if(done_1 < run_0)
        {
        }
        else
        {
            break;
        }
        uint abs_step_1 = (&isl_15)->info_0.w + done_1 + 1U;
        uint k_19 = abs_step_1 - 1U - (&kernelContext_48)->params_0->step_start_0;
        uint i_10;
        if(_S929)
        {
            float3 _S940 = float3(0.0f) ;
            thread float3 f_13 = _S940;
            thread float3 t_11 = _S940;
            i_10 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(i_10 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                thread Island_0 _S941 = isl_15;
                thread Rigid_0 _S942 = rg_13;
                net_load_1(i_10, &_S941, &_S942, k_19, _S935, contact_island_0, &f_13, &t_11, &kernelContext_48);
                i_10 = i_10 + 256U;
            }
            group_sum3_0(tid_4, &f_13, &t_11, &kernelContext_48);
            thread Island_0 _S943 = isl_15;
            rigid_acceleration_1(&_S943, &rg_13, f_13, t_11);
        }
        i_10 = (&isl_15)->range_0.z + tid_4;
        for(;;)
        {
            if(i_10 < ((&isl_15)->range_0.w))
            {
            }
            else
            {
                break;
            }
            bool _S944 = bond_update_0(i_10, _S935, _S936, abs_step_1, &kernelContext_48);
            if(_S944)
            {
                *(&kernelContext_48)->g_halt_0 = 1U;
            }
            i_10 = i_10 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        uint c_18 = (&isl_15)->range_0.x + tid_4;
        for(;;)
        {
            if(c_18 < ((&isl_15)->range_0.y))
            {
            }
            else
            {
                break;
            }
            thread Island_0 _S945 = isl_15;
            thread Rigid_0 _S946 = rg_13;
            chunk_update_1(c_18, &_S945, &_S946, _S935, _S937, k_19, contact_island_0, &work_3, &work_err_2, &kernelContext_48);
            c_18 = c_18 + 256U;
        }
        threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        if(_S930)
        {
            thread Island_0 _S947 = isl_15;
            integrate_rigid_1(&_S947, &rg_13, _S935);
        }
        if(_S929)
        {
            float3 _S948 = (&isl_15)->wcom_0.xyz;
            float3 _S949 = float3(0.0f) ;
            thread float3 tu_1 = _S949;
            thread float3 pv_1 = _S949;
            uint c_19 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_19 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_19, &tu_1, &pv_1, &kernelContext_48);
                c_19 = c_19 + 256U;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1, &kernelContext_48);
            float3 tr_4 = tu_1 / float3((&isl_15)->wcom_0.w) ;
            float3 dv_4 = pv_1 / float3((&isl_15)->wcom_0.w) ;
            thread float3 lu_1 = _S949;
            thread float3 lv_1 = _S949;
            uint c_20 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_20 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_20, _S948, tr_4, dv_4, &lu_1, &lv_1, &kernelContext_48);
                c_20 = c_20 + 256U;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, &kernelContext_48);
            float3 phi_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lu_1);
            float3 dw_3 = rows_mul_0((&isl_15)->winv0_0, (&isl_15)->winv1_0, (&isl_15)->winv2_0, lv_1);
            uint c_21 = (&isl_15)->range_0.x + tid_4;
            for(;;)
            {
                if(c_21 < ((&isl_15)->range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_21, _S948, tr_4, phi_3, dv_4, dw_3, &kernelContext_48);
                c_21 = c_21 + 256U;
            }
            if(!driven_0)
            {
                thread Island_0 _S950 = isl_15;
                drift_rigid_1(&_S950, &rg_13, tr_4, phi_3, dv_4, dw_3);
            }
            threadgroup_barrier(mem_flags::mem_device | mem_flags::mem_threadgroup | mem_flags::mem_texture | mem_flags::mem_threadgroup_imageblock);
        }
        if(_S931)
        {
            _S932 = ((&isl_15)->probes_0.y) > ((&isl_15)->probes_0.x);
        }
        else
        {
            _S932 = false;
        }
        if(_S932)
        {
            thread Island_0 _S951 = isl_15;
            thread Rigid_0 _S952 = rg_13;
            record_probes_0(&_S951, &_S952, k_19, &kernelContext_48);
        }
        uint _S953 = done_1 + 1U;
        if((*(&kernelContext_48)->g_halt_0) != 0U)
        {
            done_1 = _S953;
            break;
        }
        done_1 = _S953;
    }
    thread float3 wsum_0 = float3(work_3, work_err_2, 0.0f);
    thread float3 unused_2 = float3(0.0f) ;
    group_sum3_0(tid_4, &wsum_0, &unused_2, &kernelContext_48);
    if(_S931)
    {
        thread Quat_0 _S954 = (&rg_13)->rot_0;
        float4 _S955 = quat_vec_0(&_S954);
        (&isl_15)->rotation_0 = _S955;
        (&isl_15)->position_0 = float4((&rg_13)->pos_1, 0.0f);
        (&isl_15)->position_err_0 = float4((&rg_13)->pos_err_1, 0.0f);
        (&isl_15)->velocity_0 = float4((&rg_13)->vel_1, 0.0f);
        (&isl_15)->velocity_err_0 = float4((&rg_13)->vel_err_1, 0.0f);
        (&isl_15)->angular_velocity_0 = float4((&rg_13)->w_3, 0.0f);
        (&isl_15)->done_0.x = done_1;
        (&isl_15)->info_0.y = (&isl_15)->info_0.y - done_1;
        if((*(&kernelContext_48)->g_halt_0) != 0U)
        {
            _S930 = contact_island_0;
        }
        else
        {
            _S930 = false;
        }
        if(_S930)
        {
            contact_split_at_0((&isl_15)->info_0.w + done_1, &kernelContext_48);
        }
        float _S956 = wsum_0.x;
        thread float _S957 = (&isl_15)->energy_0.x;
        thread float _S958 = (&isl_15)->energy_0.y;
        comp_add1_0(&_S957, &_S958, _S956);
        (&isl_15)->energy_0.x = _S957;
        (&isl_15)->energy_0.y = _S958 + wsum_0.y;
        (&isl_15)->info_0.w = (&isl_15)->info_0.w + done_1;
        if((*(&kernelContext_48)->g_halt_0) != 0U)
        {
            (&isl_15)->info_0.z = ((&isl_15)->info_0.z) | 1U;
        }
        Island_natural_0 device* _S959 = (&kernelContext_48)->islands_0+_S906;
        _S959->range_0 = packed_uint4(isl_15.range_0) ;
        _S959->info_0 = packed_uint4(isl_15.info_0) ;
        _S959->com_0 = packed_float4(isl_15.com_0) ;
        _S959->inertia0_0 = packed_float4(isl_15.inertia0_0) ;
        _S959->inertia1_0 = packed_float4(isl_15.inertia1_0) ;
        _S959->inertia2_0 = packed_float4(isl_15.inertia2_0) ;
        _S959->inv0_0 = packed_float4(isl_15.inv0_0) ;
        _S959->inv1_0 = packed_float4(isl_15.inv1_0) ;
        _S959->inv2_0 = packed_float4(isl_15.inv2_0) ;
        _S959->wcom_0 = packed_float4(isl_15.wcom_0) ;
        _S959->winv0_0 = packed_float4(isl_15.winv0_0) ;
        _S959->winv1_0 = packed_float4(isl_15.winv1_0) ;
        _S959->winv2_0 = packed_float4(isl_15.winv2_0) ;
        _S959->rotation_0 = packed_float4(isl_15.rotation_0) ;
        _S959->position_0 = packed_float4(isl_15.position_0) ;
        _S959->position_err_0 = packed_float4(isl_15.position_err_0) ;
        _S959->velocity_0 = packed_float4(isl_15.velocity_0) ;
        _S959->velocity_err_0 = packed_float4(isl_15.velocity_err_0) ;
        _S959->angular_velocity_0 = packed_float4(isl_15.angular_velocity_0) ;
        _S959->done_0 = packed_uint4(isl_15.done_0) ;
        _S959->probes_0 = packed_uint4(isl_15.probes_0) ;
        _S959->energy_0 = packed_float4(isl_15.energy_0) ;
    }
    return;
}

struct WideGroup_0
{
    uint island_0;
    uint begin_1;
    uint end_0;
    uint first_0;
};

WideGroup_0 wide_group_0(uint table_0, uint g_2, KernelContext_0 thread* kernelContext_49)
{
    thread WideGroup_0 w_10;
    uint _S960 = table_0 + 4U * g_2;
    (&w_10)->island_0 = kernelContext_49->index_0[_S960];
    (&w_10)->begin_1 = kernelContext_49->index_0[_S960 + 1U];
    (&w_10)->end_0 = kernelContext_49->index_0[_S960 + 2U];
    (&w_10)->first_0 = kernelContext_49->index_0[_S960 + 3U];
    return w_10;
}

bool wide_runs_0(const Island_natural_0 thread* isl_16, KernelContext_0 thread* kernelContext_50)
{
    uint4 _S961 = uint4(isl_16->info_0) ;
    bool _S962;
    if(((_S961.z) & 1U) != 0U)
    {
        _S962 = true;
    }
    else
    {
        _S962 = (_S961.y) == 0U;
    }
    if(_S962)
    {
        return false;
    }
    if(((_S961.x) & 4U) == 0U)
    {
        _S962 = true;
    }
    else
    {
        bool _S963 = contact_stopped_0(isl_16, kernelContext_50);
        _S962 = !_S963;
    }
    return _S962;
}

bool wide_enter_0(uint tid_5, const Island_natural_0 thread* isl_17, KernelContext_0 thread* kernelContext_51)
{
    if(tid_5 == 0U)
    {
        bool _S964 = wide_runs_0(isl_17, kernelContext_51);
        int _S965;
        if(_S964)
        {
            _S965 = int(1);
        }
        else
        {
            _S965 = int(0);
        }
        *kernelContext_51->g_wide_run_0 = uint(_S965);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_51->g_wide_run_0) != 0U;
}

uint wide_step_0(const Island_natural_0 thread* isl_18, KernelContext_0 thread* kernelContext_52)
{
    return (uint4(isl_18->info_0) ).w - kernelContext_52->params_0->step_start_0;
}

uint wide_step_1(const Island_0 thread* isl_19, KernelContext_0 thread* kernelContext_53)
{
    return isl_19->info_0.w - kernelContext_53->params_0->step_start_0;
}

void wide_store_0(uint slot_2, uint p_13, float3 a_11, float3 b_28, KernelContext_0 thread* kernelContext_54)
{
    uint _S966 = 8U * slot_2;
    *(kernelContext_54->scratch_0+(kernelContext_54->params_0->wide_base_0 + _S966 + p_13)) = packed_float4(float4(a_11, 0.0f)) ;
    *(kernelContext_54->scratch_0+(kernelContext_54->params_0->wide_base_0 + _S966 + p_13 + 1U)) = packed_float4(float4(b_28, 0.0f)) ;
    return;
}

bool contact_stopped_2(uint _S967, KernelContext_0 thread* kernelContext_55)
{
    Island_natural_0 device* _S968 = kernelContext_55->islands_0+_S967;
    uint4 _S969 = uint4((kernelContext_55->islands_0+kernelContext_55->params_0->halt_index_0)->info_0) ;
    bool _S970;
    if(((_S969.z) & 1U) != 0U)
    {
        _S970 = true;
    }
    else
    {
        uint _S971 = _S969.y;
        if(_S971 != 0U)
        {
            _S970 = _S971 <= ((uint4(_S968->info_0) ).w);
        }
        else
        {
            _S970 = false;
        }
    }
    return _S970;
}

bool wide_runs_1(uint _S972, KernelContext_0 thread* kernelContext_56)
{
    uint4 _S973 = uint4((kernelContext_56->islands_0+_S972)->info_0) ;
    bool _S974;
    if(((_S973.z) & 1U) != 0U)
    {
        _S974 = true;
    }
    else
    {
        _S974 = (_S973.y) == 0U;
    }
    if(_S974)
    {
        return false;
    }
    if(((_S973.x) & 4U) == 0U)
    {
        _S974 = true;
    }
    else
    {
        bool _S975 = contact_stopped_2(_S972, kernelContext_56);
        _S974 = !_S975;
    }
    return _S974;
}

bool wide_enter_1(uint _S976, uint _S977, KernelContext_0 thread* kernelContext_57)
{
    if(_S976 == 0U)
    {
        bool _S978 = wide_runs_1(_S977, kernelContext_57);
        int _S979;
        if(_S978)
        {
            _S979 = int(1);
        }
        else
        {
            _S979 = int(0);
        }
        *kernelContext_57->g_wide_run_0 = uint(_S979);
    }
    threadgroup_barrier(mem_flags::mem_threadgroup);
    return (*kernelContext_57->g_wide_run_0) != 0U;
}

[[kernel]] void wide_bonds(uint3 group_3 [[threadgroup_position_in_grid]], uint3 thread_3 [[thread_position_in_threadgroup]], Params_0 constant* params_7 [[buffer(0)]], Island_natural_0 device* islands_7 [[buffer(9)]], uint device* index_7 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_7 [[buffer(3)]], packed_float4 device* state_9 [[buffer(6)]], packed_float4 device* scratch_7 [[buffer(8)]], packed_float4 device* contact_state_7 [[buffer(11)]], packed_float4 device* loads_7 [[buffer(5)]], Impactor_natural_0 device* impactors_7 [[buffer(10)]], BondStatic_natural_0 device* bonds_7 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_7 [[buffer(7)]], MaterialTable_0 constant* materials_7 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_58;
    (&kernelContext_58)->params_0 = params_7;
    (&kernelContext_58)->islands_0 = islands_7;
    (&kernelContext_58)->index_0 = index_7;
    (&kernelContext_58)->chunks_0 = chunks_7;
    (&kernelContext_58)->state_0 = state_9;
    (&kernelContext_58)->scratch_0 = scratch_7;
    (&kernelContext_58)->contact_state_0 = contact_state_7;
    (&kernelContext_58)->loads_0 = loads_7;
    (&kernelContext_58)->impactors_0 = impactors_7;
    (&kernelContext_58)->bonds_0 = bonds_7;
    (&kernelContext_58)->bond_dyn_0 = bond_dyn_7;
    (&kernelContext_58)->materials_0 = materials_7;
    threadgroup array<float4, int(256)> g_red_a_7;
    (&kernelContext_58)->g_red_a_0 = &g_red_a_7;
    threadgroup array<float4, int(256)> g_red_b_7;
    (&kernelContext_58)->g_red_b_0 = &g_red_b_7;
    threadgroup uint g_run_7;
    (&kernelContext_58)->g_run_0 = &g_run_7;
    threadgroup uint g_halt_7;
    (&kernelContext_58)->g_halt_0 = &g_halt_7;
    threadgroup uint g_wide_run_7;
    (&kernelContext_58)->g_wide_run_0 = &g_wide_run_7;
    uint tid_6 = thread_3.x;
    uint _S980 = group_3.x;
    bool bond_group_0 = _S980 < (params_7->wide_bond_groups_0);
    WideGroup_0 wg_0;
    if(bond_group_0)
    {
        WideGroup_0 _S981 = wide_group_0((&kernelContext_58)->params_0->wide_bond_table_0, _S980, &kernelContext_58);
        wg_0 = _S981;
    }
    else
    {
        WideGroup_0 _S982 = wide_group_0((&kernelContext_58)->params_0->wide_chunk_table_0, _S980 - params_7->wide_bond_groups_0, &kernelContext_58);
        wg_0 = _S982;
    }
    WideGroup_0 _S983 = wg_0;
    thread Island_natural_0 _S984 = *((&kernelContext_58)->islands_0+wg_0.island_0);
    bool _S985 = wide_enter_1(tid_6, wg_0.island_0, &kernelContext_58);
    if(!_S985)
    {
        return;
    }
    uint _S986 = wide_step_0(&_S984, &kernelContext_58);
    if(bond_group_0)
    {
        uint i_11 = wg_0.begin_1 + tid_6;
        bool _S987;
        if(i_11 < (wg_0.end_0))
        {
            bool _S988 = bond_update_0(i_11, (&kernelContext_58)->params_0->dt_0, ((&kernelContext_58)->params_0->fracture_0) != 0U, (uint4((&_S984)->info_0) ).w + 1U, &kernelContext_58);
            _S987 = _S988;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            ((&kernelContext_58)->islands_0+_S983.island_0)->info_0[int(2)] = ((uint4((&_S984)->info_0) ).z) | 2U;
        }
        return;
    }
    uint _S989 = (uint4((&_S984)->info_0) ).x;
    if((_S989 & 1U) != 0U)
    {
        return;
    }
    float3 _S990 = float3(0.0f) ;
    thread float3 f_14 = _S990;
    thread float3 t_12 = _S990;
    uint c_22 = wg_0.begin_1 + tid_6;
    if(c_22 < (wg_0.end_0))
    {
        Rigid_0 _S991 = rigid_of_0(&_S984);
        float _S992 = (&kernelContext_58)->params_0->dt_0;
        bool _S993 = (_S989 & 4U) != 0U;
        thread Rigid_0 _S994 = _S991;
        net_load_0(c_22, &_S984, &_S994, _S986, _S992, _S993, &f_14, &t_12, &kernelContext_58);
    }
    group_sum3_0(tid_6, &f_14, &t_12, &kernelContext_58);
    if(tid_6 == 0U)
    {
        wide_store_0(_S980 - params_7->wide_bond_groups_0, 0U, f_14, t_12, &kernelContext_58);
    }
    return;
}

void wide_partials_0(uint tid_7, uint first_1, uint count_5, uint p_14, float3 thread* a_12, float3 thread* b_29, KernelContext_0 thread* kernelContext_59)
{
    float4 _S995 = float4(0.0f) ;
    thread float4 x_8 = _S995;
    thread float4 y_2 = _S995;
    uint s_5 = tid_7;
    for(;;)
    {
        if(s_5 < count_5)
        {
        }
        else
        {
            break;
        }
        uint _S996 = 8U * (first_1 + s_5);
        x_8 = x_8 + float4(*(kernelContext_59->scratch_0+(kernelContext_59->params_0->wide_base_0 + _S996 + p_14))) ;
        y_2 = y_2 + float4(*(kernelContext_59->scratch_0+(kernelContext_59->params_0->wide_base_0 + _S996 + p_14 + 1U))) ;
        s_5 = s_5 + 256U;
    }
    group_sum2_0(tid_7, &x_8, &y_2, kernelContext_59);
    *a_12 = x_8.xyz;
    *b_29 = y_2.xyz;
    return;
}

Rigid_0 wide_rigid_frame_0(uint tid_8, const Island_natural_0 thread* isl_20, const WideGroup_0 thread* wg_1, KernelContext_0 thread* kernelContext_60)
{
    Rigid_0 _S997 = rigid_of_0(isl_20);
    thread Rigid_0 rg_14 = _S997;
    if((((uint4(isl_20->info_0) ).x) & 1U) == 0U)
    {
        thread float3 f_15;
        thread float3 t_13;
        wide_partials_0(tid_8, wg_1->first_0, (uint4(isl_20->done_0) ).z, 0U, &f_15, &t_13, kernelContext_60);
        rigid_acceleration_0(isl_20, &rg_14, f_15, t_13);
    }
    return rg_14;
}

[[kernel]] void wide_chunks(uint3 group_4 [[threadgroup_position_in_grid]], uint3 thread_4 [[thread_position_in_threadgroup]], Params_0 constant* params_8 [[buffer(0)]], Island_natural_0 device* islands_8 [[buffer(9)]], uint device* index_8 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_8 [[buffer(3)]], packed_float4 device* state_10 [[buffer(6)]], packed_float4 device* scratch_8 [[buffer(8)]], packed_float4 device* contact_state_8 [[buffer(11)]], packed_float4 device* loads_8 [[buffer(5)]], Impactor_natural_0 device* impactors_8 [[buffer(10)]], BondStatic_natural_0 device* bonds_8 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_8 [[buffer(7)]], MaterialTable_0 constant* materials_8 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_61;
    (&kernelContext_61)->params_0 = params_8;
    (&kernelContext_61)->islands_0 = islands_8;
    (&kernelContext_61)->index_0 = index_8;
    (&kernelContext_61)->chunks_0 = chunks_8;
    (&kernelContext_61)->state_0 = state_10;
    (&kernelContext_61)->scratch_0 = scratch_8;
    (&kernelContext_61)->contact_state_0 = contact_state_8;
    (&kernelContext_61)->loads_0 = loads_8;
    (&kernelContext_61)->impactors_0 = impactors_8;
    (&kernelContext_61)->bonds_0 = bonds_8;
    (&kernelContext_61)->bond_dyn_0 = bond_dyn_8;
    (&kernelContext_61)->materials_0 = materials_8;
    threadgroup array<float4, int(256)> g_red_a_8;
    (&kernelContext_61)->g_red_a_0 = &g_red_a_8;
    threadgroup array<float4, int(256)> g_red_b_8;
    (&kernelContext_61)->g_red_b_0 = &g_red_b_8;
    threadgroup uint g_run_8;
    (&kernelContext_61)->g_run_0 = &g_run_8;
    threadgroup uint g_halt_8;
    (&kernelContext_61)->g_halt_0 = &g_halt_8;
    threadgroup uint g_wide_run_8;
    (&kernelContext_61)->g_wide_run_0 = &g_wide_run_8;
    uint tid_9 = thread_4.x;
    uint _S998 = group_4.x;
    WideGroup_0 _S999 = wide_group_0(params_8->wide_chunk_table_0, _S998, &kernelContext_61);
    thread Island_natural_0 _S1000 = *((&kernelContext_61)->islands_0+_S999.island_0);
    bool _S1001 = wide_enter_1(tid_9, _S999.island_0, &kernelContext_61);
    if(!_S1001)
    {
        return;
    }
    uint _S1002 = (uint4((&_S1000)->info_0) ).x;
    bool anchored_0 = (_S1002 & 1U) != 0U;
    thread WideGroup_0 _S1003 = _S999;
    Rigid_0 _S1004 = wide_rigid_frame_0(tid_9, &_S1000, &_S1003, &kernelContext_61);
    thread float work_4 = 0.0f;
    thread float work_err_3 = 0.0f;
    float3 _S1005 = float3(0.0f) ;
    thread float3 tu_2 = _S1005;
    thread float3 pv_2 = _S1005;
    uint c_23 = _S999.begin_1 + tid_9;
    if(c_23 < (_S999.end_0))
    {
        float _S1006 = (&kernelContext_61)->params_0->dt_0;
        bool _S1007 = ((&kernelContext_61)->params_0->rigid_motion_loads_0) != 0U;
        uint _S1008 = wide_step_0(&_S1000, &kernelContext_61);
        bool _S1009 = (_S1002 & 4U) != 0U;
        thread Rigid_0 _S1010 = _S1004;
        chunk_update_0(c_23, &_S1000, &_S1010, _S1006, _S1007, _S1008, _S1009, &work_4, &work_err_3, &kernelContext_61);
        if(!anchored_0)
        {
            drift_moments_0(c_23, &tu_2, &pv_2, &kernelContext_61);
        }
    }
    thread float3 wsum_1 = float3(work_4, work_err_3, 0.0f);
    thread float3 unused_3 = _S1005;
    group_sum3_0(tid_9, &wsum_1, &unused_3, &kernelContext_61);
    bool _S1011 = !anchored_0;
    if(_S1011)
    {
        group_sum3_0(tid_9, &tu_2, &pv_2, &kernelContext_61);
    }
    if(tid_9 == 0U)
    {
        *((&kernelContext_61)->scratch_0+((&kernelContext_61)->params_0->wide_base_0 + 8U * _S998 + 6U)) = packed_float4(float4(wsum_1, 0.0f)) ;
        if(_S1011)
        {
            wide_store_0(_S998, 2U, tu_2, pv_2, &kernelContext_61);
        }
    }
    return;
}

[[kernel]] void wide_drift(uint3 group_5 [[threadgroup_position_in_grid]], uint3 thread_5 [[thread_position_in_threadgroup]], Params_0 constant* params_9 [[buffer(0)]], Island_natural_0 device* islands_9 [[buffer(9)]], uint device* index_9 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_9 [[buffer(3)]], packed_float4 device* state_11 [[buffer(6)]], packed_float4 device* scratch_9 [[buffer(8)]], packed_float4 device* contact_state_9 [[buffer(11)]], packed_float4 device* loads_9 [[buffer(5)]], Impactor_natural_0 device* impactors_9 [[buffer(10)]], BondStatic_natural_0 device* bonds_9 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_9 [[buffer(7)]], MaterialTable_0 constant* materials_9 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_62;
    (&kernelContext_62)->params_0 = params_9;
    (&kernelContext_62)->islands_0 = islands_9;
    (&kernelContext_62)->index_0 = index_9;
    (&kernelContext_62)->chunks_0 = chunks_9;
    (&kernelContext_62)->state_0 = state_11;
    (&kernelContext_62)->scratch_0 = scratch_9;
    (&kernelContext_62)->contact_state_0 = contact_state_9;
    (&kernelContext_62)->loads_0 = loads_9;
    (&kernelContext_62)->impactors_0 = impactors_9;
    (&kernelContext_62)->bonds_0 = bonds_9;
    (&kernelContext_62)->bond_dyn_0 = bond_dyn_9;
    (&kernelContext_62)->materials_0 = materials_9;
    threadgroup array<float4, int(256)> g_red_a_9;
    (&kernelContext_62)->g_red_a_0 = &g_red_a_9;
    threadgroup array<float4, int(256)> g_red_b_9;
    (&kernelContext_62)->g_red_b_0 = &g_red_b_9;
    threadgroup uint g_run_9;
    (&kernelContext_62)->g_run_0 = &g_run_9;
    threadgroup uint g_halt_9;
    (&kernelContext_62)->g_halt_0 = &g_halt_9;
    threadgroup uint g_wide_run_9;
    (&kernelContext_62)->g_wide_run_0 = &g_wide_run_9;
    uint tid_10 = thread_5.x;
    uint _S1012 = group_5.x;
    WideGroup_0 _S1013 = wide_group_0(params_9->wide_chunk_table_0, _S1012, &kernelContext_62);
    Island_natural_0 device* _S1014 = (&kernelContext_62)->islands_0+_S1013.island_0;
    Island_natural_0 isl_21 = *_S1014;
    bool _S1015;
    if((((uint4((*_S1014).info_0) ).x) & 1U) != 0U)
    {
        _S1015 = true;
    }
    else
    {
        bool _S1016 = wide_enter_1(tid_10, _S1013.island_0, &kernelContext_62);
        _S1015 = !_S1016;
    }
    if(_S1015)
    {
        return;
    }
    thread float3 tu_3;
    thread float3 pv_3;
    wide_partials_0(tid_10, _S1013.first_0, (uint4(isl_21.done_0) ).z, 2U, &tu_3, &pv_3, &kernelContext_62);
    float4 _S1017 = float4(isl_21.wcom_0) ;
    float3 _S1018 = float3(_S1017.w) ;
    float3 tr_5 = tu_3 / _S1018;
    float3 dv_5 = pv_3 / _S1018;
    float3 _S1019 = float3(0.0f) ;
    thread float3 lu_2 = _S1019;
    thread float3 lv_2 = _S1019;
    uint c_24 = _S1013.begin_1 + tid_10;
    if(c_24 < (_S1013.end_0))
    {
        drift_angular_0(c_24, _S1017.xyz, tr_5, dv_5, &lu_2, &lv_2, &kernelContext_62);
    }
    group_sum3_0(tid_10, &lu_2, &lv_2, &kernelContext_62);
    if(tid_10 == 0U)
    {
        wide_store_0(_S1012, 4U, lu_2, lv_2, &kernelContext_62);
    }
    return;
}

[[kernel]] void wide_rigid(uint3 group_6 [[threadgroup_position_in_grid]], uint3 thread_6 [[thread_position_in_threadgroup]], Params_0 constant* params_10 [[buffer(0)]], Island_natural_0 device* islands_10 [[buffer(9)]], uint device* index_10 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_10 [[buffer(3)]], packed_float4 device* state_12 [[buffer(6)]], packed_float4 device* scratch_10 [[buffer(8)]], packed_float4 device* contact_state_10 [[buffer(11)]], packed_float4 device* loads_10 [[buffer(5)]], Impactor_natural_0 device* impactors_10 [[buffer(10)]], BondStatic_natural_0 device* bonds_10 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_10 [[buffer(7)]], MaterialTable_0 constant* materials_10 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_63;
    (&kernelContext_63)->params_0 = params_10;
    (&kernelContext_63)->islands_0 = islands_10;
    (&kernelContext_63)->index_0 = index_10;
    (&kernelContext_63)->chunks_0 = chunks_10;
    (&kernelContext_63)->state_0 = state_12;
    (&kernelContext_63)->scratch_0 = scratch_10;
    (&kernelContext_63)->contact_state_0 = contact_state_10;
    (&kernelContext_63)->loads_0 = loads_10;
    (&kernelContext_63)->impactors_0 = impactors_10;
    (&kernelContext_63)->bonds_0 = bonds_10;
    (&kernelContext_63)->bond_dyn_0 = bond_dyn_10;
    (&kernelContext_63)->materials_0 = materials_10;
    threadgroup array<float4, int(256)> g_red_a_10;
    (&kernelContext_63)->g_red_a_0 = &g_red_a_10;
    threadgroup array<float4, int(256)> g_red_b_10;
    (&kernelContext_63)->g_red_b_0 = &g_red_b_10;
    threadgroup uint g_run_10;
    (&kernelContext_63)->g_run_0 = &g_run_10;
    threadgroup uint g_halt_10;
    (&kernelContext_63)->g_halt_0 = &g_halt_10;
    threadgroup uint g_wide_run_10;
    (&kernelContext_63)->g_wide_run_0 = &g_wide_run_10;
    uint tid_11 = thread_6.x;
    uint _S1020 = group_6.x;
    WideGroup_0 _S1021 = wide_group_0(params_10->wide_chunk_table_0, _S1020, &kernelContext_63);
    thread Island_natural_0 _S1022 = *((&kernelContext_63)->islands_0+_S1021.island_0);
    uint _S1023 = (uint4((&_S1022)->info_0) ).x;
    bool _S1024;
    if((_S1023 & 1U) != 0U)
    {
        _S1024 = true;
    }
    else
    {
        bool _S1025 = wide_enter_1(tid_11, _S1021.island_0, &kernelContext_63);
        _S1024 = !_S1025;
    }
    if(_S1024)
    {
        return;
    }
    uint _S1026 = (uint4((&_S1022)->done_0) ).z;
    thread float3 tu_4;
    thread float3 pv_4;
    wide_partials_0(tid_11, _S1021.first_0, _S1026, 2U, &tu_4, &pv_4, &kernelContext_63);
    thread float3 lu_3;
    thread float3 lv_3;
    wide_partials_0(tid_11, _S1021.first_0, _S1026, 4U, &lu_3, &lv_3, &kernelContext_63);
    float4 _S1027 = float4((&_S1022)->wcom_0) ;
    float3 _S1028 = float3(_S1027.w) ;
    float3 tr_6 = tu_4 / _S1028;
    float3 dv_6 = pv_4 / _S1028;
    float4 _S1029 = float4((&_S1022)->winv0_0) ;
    float4 _S1030 = float4((&_S1022)->winv1_0) ;
    float4 _S1031 = float4((&_S1022)->winv2_0) ;
    float3 phi_4 = rows_mul_0(_S1029, _S1030, _S1031, lu_3);
    float3 dw_4 = rows_mul_0(_S1029, _S1030, _S1031, lv_3);
    uint c_25 = _S1021.begin_1 + tid_11;
    if(c_25 < (_S1021.end_0))
    {
        drift_apply_0(c_25, _S1027.xyz, tr_6, phi_4, dv_6, dw_4, &kernelContext_63);
    }
    if(_S1020 != (_S1021.first_0))
    {
        return;
    }
    thread WideGroup_0 _S1032 = _S1021;
    Rigid_0 _S1033 = wide_rigid_frame_0(tid_11, &_S1022, &_S1032, &kernelContext_63);
    thread Rigid_0 rg_15 = _S1033;
    if(tid_11 != 0U)
    {
        return;
    }
    if(!((_S1023 & 2U) != 0U))
    {
        integrate_rigid_0(&_S1022, &rg_15, (&kernelContext_63)->params_0->dt_0);
        drift_rigid_0(&_S1022, &rg_15, tr_6, phi_4, dv_6, dw_4);
    }
    thread Quat_0 _S1034 = (&rg_15)->rot_0;
    float4 _S1035 = quat_vec_0(&_S1034);
    ((&kernelContext_63)->islands_0+_S1021.island_0)->rotation_0 = packed_float4(_S1035) ;
    ((&kernelContext_63)->islands_0+_S1021.island_0)->position_0 = packed_float4(float4((&rg_15)->pos_1, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S1021.island_0)->position_err_0 = packed_float4(float4((&rg_15)->pos_err_1, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S1021.island_0)->velocity_0 = packed_float4(float4((&rg_15)->vel_1, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S1021.island_0)->velocity_err_0 = packed_float4(float4((&rg_15)->vel_err_1, 0.0f)) ;
    ((&kernelContext_63)->islands_0+_S1021.island_0)->angular_velocity_0 = packed_float4(float4((&rg_15)->w_3, 0.0f)) ;
    return;
}

[[kernel]] void wide_end(uint3 group_7 [[threadgroup_position_in_grid]], uint3 thread_7 [[thread_position_in_threadgroup]], Params_0 constant* params_11 [[buffer(0)]], Island_natural_0 device* islands_11 [[buffer(9)]], uint device* index_11 [[buffer(4)]], ChunkStatic_natural_0 device* chunks_11 [[buffer(3)]], packed_float4 device* state_13 [[buffer(6)]], packed_float4 device* scratch_11 [[buffer(8)]], packed_float4 device* contact_state_11 [[buffer(11)]], packed_float4 device* loads_11 [[buffer(5)]], Impactor_natural_0 device* impactors_11 [[buffer(10)]], BondStatic_natural_0 device* bonds_11 [[buffer(2)]], BondDyn_natural_0 device* bond_dyn_11 [[buffer(7)]], MaterialTable_0 constant* materials_11 [[buffer(1)]])
{
    thread KernelContext_0 kernelContext_64;
    (&kernelContext_64)->params_0 = params_11;
    (&kernelContext_64)->islands_0 = islands_11;
    (&kernelContext_64)->index_0 = index_11;
    (&kernelContext_64)->chunks_0 = chunks_11;
    (&kernelContext_64)->state_0 = state_13;
    (&kernelContext_64)->scratch_0 = scratch_11;
    (&kernelContext_64)->contact_state_0 = contact_state_11;
    (&kernelContext_64)->loads_0 = loads_11;
    (&kernelContext_64)->impactors_0 = impactors_11;
    (&kernelContext_64)->bonds_0 = bonds_11;
    (&kernelContext_64)->bond_dyn_0 = bond_dyn_11;
    (&kernelContext_64)->materials_0 = materials_11;
    threadgroup array<float4, int(256)> g_red_a_11;
    (&kernelContext_64)->g_red_a_0 = &g_red_a_11;
    threadgroup array<float4, int(256)> g_red_b_11;
    (&kernelContext_64)->g_red_b_0 = &g_red_b_11;
    threadgroup uint g_run_11;
    (&kernelContext_64)->g_run_0 = &g_run_11;
    threadgroup uint g_halt_11;
    (&kernelContext_64)->g_halt_0 = &g_halt_11;
    threadgroup uint g_wide_run_11;
    (&kernelContext_64)->g_wide_run_0 = &g_wide_run_11;
    uint tid_12 = thread_7.x;
    uint _S1036 = group_7.x;
    WideGroup_0 _S1037 = wide_group_0(params_11->wide_chunk_table_0, _S1036, &kernelContext_64);
    if(_S1036 != (_S1037.first_0))
    {
        return;
    }
    Island_natural_0 device* _S1038 = (&kernelContext_64)->islands_0+_S1037.island_0;
    thread Island_natural_0 _S1039 = *_S1038;
    uint4 _S1040 = uint4((&_S1039)->info_0) ;
    float4 _S1041 = float4((&_S1039)->com_0) ;
    float4 _S1042 = float4((&_S1039)->inertia0_0) ;
    float4 _S1043 = float4((&_S1039)->inertia1_0) ;
    float4 _S1044 = float4((&_S1039)->inertia2_0) ;
    float4 _S1045 = float4((&_S1039)->inv0_0) ;
    float4 _S1046 = float4((&_S1039)->inv1_0) ;
    float4 _S1047 = float4((&_S1039)->inv2_0) ;
    float4 _S1048 = float4((&_S1039)->wcom_0) ;
    float4 _S1049 = float4((&_S1039)->winv0_0) ;
    float4 _S1050 = float4((&_S1039)->winv1_0) ;
    float4 _S1051 = float4((&_S1039)->winv2_0) ;
    float4 _S1052 = float4((&_S1039)->rotation_0) ;
    float4 _S1053 = float4((&_S1039)->position_0) ;
    float4 _S1054 = float4((&_S1039)->position_err_0) ;
    float4 _S1055 = float4((&_S1039)->velocity_0) ;
    float4 _S1056 = float4((&_S1039)->velocity_err_0) ;
    float4 _S1057 = float4((&_S1039)->angular_velocity_0) ;
    uint4 _S1058 = uint4((&_S1039)->done_0) ;
    uint4 _S1059 = uint4((&_S1039)->probes_0) ;
    float4 _S1060 = float4((&_S1039)->energy_0) ;
    thread Island_0 isl_22;
    (&isl_22)->range_0 = uint4((&_S1039)->range_0) ;
    (&isl_22)->info_0 = _S1040;
    (&isl_22)->com_0 = _S1041;
    (&isl_22)->inertia0_0 = _S1042;
    (&isl_22)->inertia1_0 = _S1043;
    (&isl_22)->inertia2_0 = _S1044;
    (&isl_22)->inv0_0 = _S1045;
    (&isl_22)->inv1_0 = _S1046;
    (&isl_22)->inv2_0 = _S1047;
    (&isl_22)->wcom_0 = _S1048;
    (&isl_22)->winv0_0 = _S1049;
    (&isl_22)->winv1_0 = _S1050;
    (&isl_22)->winv2_0 = _S1051;
    (&isl_22)->rotation_0 = _S1052;
    (&isl_22)->position_0 = _S1053;
    (&isl_22)->position_err_0 = _S1054;
    (&isl_22)->velocity_0 = _S1055;
    (&isl_22)->velocity_err_0 = _S1056;
    (&isl_22)->angular_velocity_0 = _S1057;
    (&isl_22)->done_0 = _S1058;
    (&isl_22)->probes_0 = _S1059;
    (&isl_22)->energy_0 = _S1060;
    _S1039 = *_S1038;
    bool _S1061 = wide_enter_0(tid_12, &_S1039, &kernelContext_64);
    if(!_S1061)
    {
        return;
    }
    thread float3 work_5;
    thread float3 unused_4;
    wide_partials_0(tid_12, _S1037.first_0, (&isl_22)->done_0.z, 6U, &work_5, &unused_4, &kernelContext_64);
    if(tid_12 != 0U)
    {
        return;
    }
    thread Island_0 _S1062 = isl_22;
    uint _S1063 = wide_step_1(&_S1062, &kernelContext_64);
    if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
    {
        thread Island_0 _S1064 = isl_22;
        Rigid_0 _S1065 = rigid_of_1(&_S1064);
        thread Island_0 _S1066 = isl_22;
        thread Rigid_0 _S1067 = _S1065;
        record_probes_0(&_S1066, &_S1067, _S1063, &kernelContext_64);
    }
    bool halt_0 = (((&isl_22)->info_0.z) & 2U) != 0U;
    bool _S1068;
    if(halt_0)
    {
        _S1068 = (((&isl_22)->info_0.x) & 4U) != 0U;
    }
    else
    {
        _S1068 = false;
    }
    if(_S1068)
    {
        contact_split_at_0((&isl_22)->info_0.w + 1U, &kernelContext_64);
    }
    float _S1069 = work_5.x;
    thread float _S1070 = (&isl_22)->energy_0.x;
    thread float _S1071 = (&isl_22)->energy_0.y;
    comp_add1_0(&_S1070, &_S1071, _S1069);
    (&isl_22)->energy_0.x = _S1070;
    (&isl_22)->energy_0.y = _S1071 + work_5.y;
    (&isl_22)->done_0.x = (&isl_22)->done_0.x + 1U;
    (&isl_22)->info_0.y = (&isl_22)->info_0.y - 1U;
    (&isl_22)->info_0.w = (&isl_22)->info_0.w + 1U;
    if(halt_0)
    {
        (&isl_22)->info_0.z = (((&isl_22)->info_0.z) & 4294967293U) | 1U;
    }
    Island_natural_0 device* _S1072 = (&kernelContext_64)->islands_0+_S1037.island_0;
    _S1072->range_0 = packed_uint4(isl_22.range_0) ;
    _S1072->info_0 = packed_uint4(isl_22.info_0) ;
    _S1072->com_0 = packed_float4(isl_22.com_0) ;
    _S1072->inertia0_0 = packed_float4(isl_22.inertia0_0) ;
    _S1072->inertia1_0 = packed_float4(isl_22.inertia1_0) ;
    _S1072->inertia2_0 = packed_float4(isl_22.inertia2_0) ;
    _S1072->inv0_0 = packed_float4(isl_22.inv0_0) ;
    _S1072->inv1_0 = packed_float4(isl_22.inv1_0) ;
    _S1072->inv2_0 = packed_float4(isl_22.inv2_0) ;
    _S1072->wcom_0 = packed_float4(isl_22.wcom_0) ;
    _S1072->winv0_0 = packed_float4(isl_22.winv0_0) ;
    _S1072->winv1_0 = packed_float4(isl_22.winv1_0) ;
    _S1072->winv2_0 = packed_float4(isl_22.winv2_0) ;
    _S1072->rotation_0 = packed_float4(isl_22.rotation_0) ;
    _S1072->position_0 = packed_float4(isl_22.position_0) ;
    _S1072->position_err_0 = packed_float4(isl_22.position_err_0) ;
    _S1072->velocity_0 = packed_float4(isl_22.velocity_0) ;
    _S1072->velocity_err_0 = packed_float4(isl_22.velocity_err_0) ;
    _S1072->angular_velocity_0 = packed_float4(isl_22.angular_velocity_0) ;
    _S1072->done_0 = packed_uint4(isl_22.done_0) ;
    _S1072->probes_0 = packed_uint4(isl_22.probes_0) ;
    _S1072->energy_0 = packed_float4(isl_22.energy_0) ;
    return;
}

