#include "slang-cuda-prelude.h"

struct Params_0
{
    float4  gravity_0;
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
    uint solve_mode_0;
    uint cload_base_0;
    uint cframe_base_0;
    uint statics_base_0;
    uint statics_bonds_0;
    uint statics_newton_0;
    uint statics_cg_0;
    float statics_tol_0;
};

struct JointMaterial_0
{
    float4  strength_0;
    float4  energy_0;
    float4  dif_0;
    float4  misc_0;
    uint4  kind_flags_0;
};

struct MaterialTable_0
{
    FixedArray<JointMaterial_0, 64>  m_0;
};

struct JointBond_0
{
    float4  geom0_0;
    float4  geom1_0;
    float4  stiff0_0;
    float4  stiff1_0;
    float4  rebar0_0;
    float4  rebar1_0;
    uint4  ids_0;
};

struct BondStatic_0
{
    float4  t1_0;
    float4  t2_0;
    float4  normal_0;
    float4  ra_0;
    float4  rb_0;
    float4  centroid_0;
    float4  c_lin_0;
    float4  c_ang_0;
    JointBond_0 law_0;
};

struct ChunkStatic_0
{
    float4  center_0;
    float4  inertia0_0;
    float4  inertia1_0;
    float4  inertia2_0;
    float4  inv0_0;
    float4  inv1_0;
    float4  inv2_0;
    float4  scale_0;
    uint4  info_0;
    uint4  load_range_0;
    float4  half_0;
    float4  crot0_0;
    float4  crot1_0;
    float4  crot2_0;
    float4  cmat_0;
    float4  start_hi_0;
    float4  start_lo_0;
    uint4  cinfo_0;
};

struct JointState_0
{
    float damage_0;
    float crush_0;
    float kappa_0;
    float kappa_c_0;
    float ductility_0;
    float ductility_c_0;
    float life_0;
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

struct BondDyn_0
{
    JointState_0 js_0;
    float4  force_lin_0;
    float4  force_ang_0;
    float4  sums_0;
    float4  comps_0;
    uint4  events_0;
};

struct Island_0
{
    uint4  range_0;
    uint4  info_1;
    float4  com_0;
    float4  inertia0_1;
    float4  inertia1_1;
    float4  inertia2_1;
    float4  inv0_1;
    float4  inv1_1;
    float4  inv2_1;
    float4  wcom_0;
    float4  winv0_0;
    float4  winv1_0;
    float4  winv2_0;
    float4  rotation_0;
    float4  position_0;
    float4  position_err_0;
    float4  velocity_0;
    float4  velocity_err_0;
    float4  angular_velocity_0;
    uint done_0;
    uint coverage_0;
    uint wide_groups_0;
    uint done_pad_0;
    uint4  probes_0;
    float4  energy_1;
    float4  rotation_err_0;
    float4  momentum_0;
    float4  momentum_err_0;
};

struct Impactor_0
{
    float4  position_1;
    float4  position_err_1;
    float4  velocity_1;
    float4  velocity_err_1;
    float4  angular_velocity_1;
    float4  rotation_1;
    float4  inertia0_2;
    float4  inertia1_2;
    float4  inertia2_2;
    float4  inv0_2;
    float4  inv1_2;
    float4  inv2_2;
    float4  shape_0;
    float4  half_1;
    float4  mat_0;
    float4  crush_1;
    float4  geom_0;
    float4  rotation_err_1;
    float4  ledger_0;
    uint4  cand_0;
    float4  momentum_1;
    float4  momentum_err_1;
};

struct GlobalParams_0
{
    Params_0* params_0;
    MaterialTable_0* materials_0;
    StructuredBuffer<BondStatic_0> bonds_0;
    StructuredBuffer<ChunkStatic_0> chunks_0;
    StructuredBuffer<uint> index_0;
    StructuredBuffer<float4 > loads_0;
    RWStructuredBuffer<float4 > state_0;
    RWStructuredBuffer<BondDyn_0> bond_dyn_0;
    RWStructuredBuffer<float4 > scratch_0;
    RWStructuredBuffer<Island_0> islands_0;
    RWStructuredBuffer<Impactor_0> impactors_0;
    RWStructuredBuffer<float4 > contact_state_0;
};

extern "C" __constant__ GlobalParams_0 SLANG_globalParams;
#define globalParams_0 (&SLANG_globalParams)
static __device__ float3  max_0(float3  x_0, float3  y_0)
{
    float3  result_0;
    int i_0 = int(0);
    for(;;)
    {
        if(i_0 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_0, i_0) = (F32_max((_slang_vector_get_element(x_0, i_0)), (_slang_vector_get_element(y_0, i_0))));
        i_0 = i_0 + int(1);
    }
    return result_0;
}

__device__ static const FixedArray<float, 6>  SPRING_AT_0 = { {
    -0.4166666567325592f, -0.25f, -0.0833333358168602f, 0.0833333358168602f, 0.25f, 0.4166666567325592f
} };
static __device__ float clamp_0(float x_1, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_1), (minBound_0)))), (maxBound_0)));
}

static __device__ uint WaveGetActiveMask_0(uint _S1)
{
    return _S1;
}

static __device__ float4  WaveActiveSum_0(float4  expr_0, uint _S2)
{
    float4  _S3 = (_waveSumMultiple((make_uint4 (WaveGetActiveMask_0(_S2), 0U, 0U, 0U)).x, (expr_0)));
    return _S3;
}

__device__ __shared__ FixedArray<float4 , 32>  g_part_a_0;

__device__ __shared__ FixedArray<float4 , 32>  g_part_b_0;

static __device__ void group_sum2_0(uint tid_0, float4  * a_0, float4  * b_0, uint _S4)
{
    float4  _S5 = WaveActiveSum_0(*a_0, _S4);
    float4  _S6 = WaveActiveSum_0(*b_0, _S4);
    bool _S7 = (tid_0 % 32U) == 0U;
    uint _S8 = __ballot_sync(_S4, _S7);
    if(_S7)
    {
        (*&g_part_a_0)[tid_0 / 32U] = _S5;
        (*&g_part_b_0)[tid_0 / 32U] = _S6;
    }
    __syncthreads();
    uint w_0 = 1U;
    float4  sa_0 = (*&g_part_a_0)[int(0)];
    float4  sb_0 = (*&g_part_b_0)[int(0)];
    for(;;)
    {
        if(w_0 < 8U)
        {
        }
        else
        {
            break;
        }
        float4  sa_1 = sa_0 + (*&g_part_a_0)[w_0];
        float4  sb_1 = sb_0 + (*&g_part_b_0)[w_0];
        w_0 = w_0 + 1U;
        sa_0 = sa_1;
        sb_0 = sb_1;
    }
    __syncthreads();
    *a_0 = sa_0;
    *b_0 = sb_0;
    return;
}

static __device__ void group_sum3_0(uint tid_1, float3  * a_1, float3  * b_1, uint _S9)
{
    float4  x_2 = make_float4 ((*a_1).x, (*a_1).y, (*a_1).z, 0.0f);
    float4  y_1 = make_float4 ((*b_1).x, (*b_1).y, (*b_1).z, 0.0f);
    group_sum2_0(tid_1, &x_2, &y_1, _S9);
    float4  _S10 = x_2;
    *a_1 = float3 {_S10.x, _S10.y, _S10.z};
    float4  _S11 = y_1;
    *b_1 = float3 {_S11.x, _S11.y, _S11.z};
    return;
}

static __device__ uint4  asuint_0(float4  x_3)
{
    uint4  result_1;
    int i_1 = int(0);
    for(;;)
    {
        if(i_1 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_asuint((_slang_vector_get_element(x_3, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float4  abs_0(float4  x_4)
{
    float4  result_2;
    int i_2 = int(0);
    for(;;)
    {
        if(i_2 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_abs((_slang_vector_get_element(x_4, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float dot_0(float3  x_5, float3  y_2)
{
    return x_5.x * y_2.x + x_5.y * y_2.y + x_5.z * y_2.z;
}

static __device__ float3  abs_1(float3  x_6)
{
    float3  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_abs((_slang_vector_get_element(x_6, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float3  min_0(float3  x_7, float3  y_3)
{
    float3  result_4;
    int i_4 = int(0);
    for(;;)
    {
        if(i_4 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_4) = (F32_min((_slang_vector_get_element(x_7, i_4)), (_slang_vector_get_element(y_3, i_4))));
        i_4 = i_4 + int(1);
    }
    return result_4;
}

static __device__ float3  clamp_1(float3  x_8, float3  minBound_1, float3  maxBound_1)
{
    return min_0(max_0(x_8, minBound_1), maxBound_1);
}

static __device__ bool any_0(bool3  x_9)
{
    bool result_5 = false;
    int i_5 = int(0);
    for(;;)
    {
        if(i_5 < int(3))
        {
        }
        else
        {
            break;
        }
        if(result_5)
        {
            result_5 = true;
        }
        else
        {
            result_5 = (bool((_slang_vector_get_element(x_9, i_5))));
        }
        i_5 = i_5 + int(1);
    }
    return result_5;
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S12 = left_0.y;
    float _S13 = right_0.z;
    float _S14 = left_0.z;
    float _S15 = right_0.y;
    float _S16 = right_0.x;
    float _S17 = left_0.x;
    return make_float3 (_S12 * _S13 - _S14 * _S15, _S14 * _S16 - _S17 * _S13, _S17 * _S15 - _S12 * _S16);
}

static __device__ float length_0(float3  x_10)
{
    return (F32_sqrt((dot_0(x_10, x_10))));
}

static __device__ bool stopped_0()
{
    uint _S18 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S19 = (&(globalParams_0->islands_0)[_S18])->info_1;
    bool _S20;
    if((((&(globalParams_0->islands_0)[_S18])->info_1.z) & 1U) != 0U)
    {
        _S20 = true;
    }
    else
    {
        _S20 = (_S19.y) != 0U;
    }
    return _S20;
}

struct Quat_0
{
    float w_1;
    float x_11;
    float y_4;
    float z_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_11 = q_0.x;
    (&r_0)->y_4 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_11, q_1->y_4, q_1->z_0);
    float3  t_0 = cross_0(qv_0, v_0) * make_float3 (2.0f);
    return v_0 + t_0 * make_float3 (q_1->w_1) + cross_0(qv_0, t_0);
}

struct WorldPoint_0
{
    float3  hi_0;
    float3  lo_0;
    float3  rel_0;
};

static __device__ WorldPoint_0 chunk_world_0(uint c_0)
{
    ChunkStatic_0 * _S21 = (&(globalParams_0->chunks_0)[c_0]);
    uint4  _S22 = __ldg(&_S21->info_0);
    Island_0 * _S23 = (&(globalParams_0->islands_0)[_S22.y]);
    Quat_0 q_2 = quat_of_0(_S23->rotation_0);
    WorldPoint_0 w_2;
    float4  _S24 = _S23->position_0;
    (&w_2)->hi_0 = float3 {_S24.x, _S24.y, _S24.z};
    float4  _S25 = _S23->position_err_0;
    (&w_2)->lo_0 = float3 {_S25.x, _S25.y, _S25.z};
    float4  _S26 = __ldg(&_S21->center_0);
    float4  _S27 = *(&(globalParams_0->state_0)[4U * c_0]);
    float3  _S28 = float3 {_S26.x, _S26.y, _S26.z} + float3 {_S27.x, _S27.y, _S27.z};
    Quat_0 _S29 = q_2;
    float3  _S30 = rotate_0(&_S29, _S28);
    (&w_2)->rel_0 = _S30;
    return w_2;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_2, WorldPoint_0 * b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_1)
{
    float n_0 = length_0(v_1);
    float3  _S31;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S31 = v_1 / make_float3 (n_0);
    }
    else
    {
        _S31 = make_float3 (0.0f);
    }
    return _S31;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_0, float angle_0)
{
    float3  a_3 = safe_normalize_0(axis_0);
    float _S32 = 0.5f * angle_0;
    float s_0 = (F32_sin((_S32)));
    Quat_0 q_3;
    (&q_3)->w_1 = (F32_cos((_S32)));
    (&q_3)->x_11 = a_3.x * s_0;
    (&q_3)->y_4 = a_3.y * s_0;
    (&q_3)->z_0 = a_3.z * s_0;
    return q_3;
}

struct Box_0
{
    float3  center_1;
    float3  axis0_0;
    float3  axis1_0;
    float3  axis2_0;
    float3  half_2;
    uint hull_at_0;
    uint hull_v_0;
    uint hull_f_0;
};

static __device__ Box_0 chunk_box_0(uint c_1, float3  center_2)
{
    ChunkStatic_0 * _S33 = (&(globalParams_0->chunks_0)[c_1]);
    uint4  _S34 = __ldg(&_S33->info_0);
    Quat_0 q_4 = quat_of_0((&(globalParams_0->islands_0)[_S34.y])->rotation_0);
    float4  _S35 = *(&(globalParams_0->state_0)[4U * c_1 + 1U]);
    float3  th_0 = float3 {_S35.x, _S35.y, _S35.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length_0(th_0));
    Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4  _S36 = __ldg(&_S33->crot0_0);
    float _S37 = _S36.x;
    float4  _S38 = __ldg(&_S33->crot1_0);
    float _S39 = _S38.x;
    float4  _S40 = __ldg(&_S33->crot2_0);
    float3  _S41 = make_float3 (_S37, _S39, _S40.x);
    Quat_0 _S42 = hidden_0;
    float3  _S43 = rotate_0(&_S42, _S41);
    Quat_0 _S44 = q_4;
    float3  _S45 = rotate_0(&_S44, _S43);
    (&b_3)->axis0_0 = _S45;
    float3  _S46 = make_float3 (_S36.y, _S38.y, _S40.y);
    Quat_0 _S47 = hidden_0;
    float3  _S48 = rotate_0(&_S47, _S46);
    Quat_0 _S49 = q_4;
    float3  _S50 = rotate_0(&_S49, _S48);
    (&b_3)->axis1_0 = _S50;
    float3  _S51 = make_float3 (_S36.z, _S38.z, _S40.z);
    Quat_0 _S52 = hidden_0;
    float3  _S53 = rotate_0(&_S52, _S51);
    Quat_0 _S54 = q_4;
    float3  _S55 = rotate_0(&_S54, _S53);
    (&b_3)->axis2_0 = _S55;
    float4  _S56 = __ldg(&_S33->half_0);
    (&b_3)->half_2 = float3 {_S56.x, _S56.y, _S56.z};
    float4  _S57 = __ldg(&_S33->cmat_0);
    (&b_3)->hull_at_0 = (F32_asuint((_S57.z)));
    uint _S58 = (F32_asuint((_S57.w)));
    (&b_3)->hull_v_0 = _S58 & 255U;
    (&b_3)->hull_f_0 = _S58 >> int(8);
    return b_3;
}

static __device__ uint sample_count_0(Box_0 * b_4)
{
    uint _S59 = b_4->hull_v_0;
    uint _S60;
    if((b_4->hull_v_0) == 0U)
    {
        _S60 = 14U;
    }
    else
    {
        _S60 = _S59 + b_4->hull_f_0;
    }
    return _S60;
}

static __device__ bool may_overlap_0(Box_0 * a_4, Box_0 * b_5)
{
    float3  _S61 = b_5->center_1 - a_4->center_1;
    float3  _S62 = a_4->half_2;
    float3  _S63 = b_5->half_2;
    float _S64 = 0.00000999999974738f * (length_0(a_4->half_2) + length_0(b_5->half_2));
    float3  _S65 = a_4->axis0_0;
    float3  _S66 = a_4->axis1_0;
    float3  _S67 = a_4->axis2_0;
    float3  _S68 = b_5->axis0_0;
    float3  _S69 = b_5->axis1_0;
    float3  _S70 = b_5->axis2_0;
    FixedArray<float3 , 6>  _S71 = { {
        a_4->axis0_0, a_4->axis1_0, a_4->axis2_0, b_5->axis0_0, b_5->axis1_0, b_5->axis2_0
    } };
    uint i_6 = 0U;
    for(;;)
    {
        if(i_6 < 15U)
        {
        }
        else
        {
            break;
        }
        float3  l_0;
        if(i_6 < 6U)
        {
            l_0 = _S71[i_6];
        }
        else
        {
            uint _S72 = i_6 - 6U;
            l_0 = cross_0(_S71[_S72 / 3U], _S71[3U + _S72 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_6 = i_6 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S61, l_0)))) > (_S62.x * (F32_abs((dot_0(_S65, l_0)))) + _S62.y * (F32_abs((dot_0(_S66, l_0)))) + _S62.z * (F32_abs((dot_0(_S67, l_0)))) + (_S63.x * (F32_abs((dot_0(_S68, l_0)))) + _S63.y * (F32_abs((dot_0(_S69, l_0)))) + _S63.z * (F32_abs((dot_0(_S70, l_0))))) + _S64 * len_0))
        {
            return false;
        }
        i_6 = i_6 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_2, float3  * v_2, float3  * w_3)
{
    ChunkStatic_0 * _S73 = (&(globalParams_0->chunks_0)[c_2]);
    uint4  _S74 = __ldg(&_S73->info_0);
    Island_0 * _S75 = (&(globalParams_0->islands_0)[_S74.y]);
    Quat_0 q_5 = quat_of_0(_S75->rotation_0);
    float4  _S76 = __ldg(&_S73->center_0);
    uint _S77 = 4U * c_2;
    float4  _S78 = *(&(globalParams_0->state_0)[_S77]);
    float4  _S79 = _S75->com_0;
    float3  _S80 = float3 {_S76.x, _S76.y, _S76.z} + float3 {_S78.x, _S78.y, _S78.z} - float3 {_S79.x, _S79.y, _S79.z};
    Quat_0 _S81 = q_5;
    float3  _S82 = rotate_0(&_S81, _S80);
    float4  _S83 = _S75->velocity_0;
    float4  _S84 = _S75->velocity_err_0;
    float4  _S85 = _S75->angular_velocity_0;
    float3  _S86 = float3 {_S85.x, _S85.y, _S85.z};
    float3  _S87 = float3 {_S83.x, _S83.y, _S83.z} + float3 {_S84.x, _S84.y, _S84.z} + cross_0(_S86, _S82);
    float4  _S88 = *(&(globalParams_0->state_0)[_S77 + 2U]);
    float3  _S89 = float3 {_S88.x, _S88.y, _S88.z};
    Quat_0 _S90 = q_5;
    float3  _S91 = rotate_0(&_S90, _S89);
    *v_2 = _S87 + _S91;
    float4  _S92 = *(&(globalParams_0->state_0)[_S77 + 3U]);
    float3  _S93 = float3 {_S92.x, _S92.y, _S92.z};
    Quat_0 _S94 = q_5;
    float3  _S95 = rotate_0(&_S94, _S93);
    *w_3 = _S86 + _S95;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_6, float3  local_0)
{
    return b_6->axis0_0 * make_float3 (local_0.x) + b_6->axis1_0 * make_float3 (local_0.y) + b_6->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_7, uint k_0)
{
    float3  _S96;
    if(k_0 == 0U)
    {
        _S96 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S96 = b_7->axis1_0;
        }
        else
        {
            _S96 = b_7->axis2_0;
        }
    }
    return _S96;
}

static __device__ float comp3_0(float3  v_3, uint k_1)
{
    float _S97;
    if(k_1 == 0U)
    {
        _S97 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S97 = v_3.y;
        }
        else
        {
            _S97 = v_3.z;
        }
    }
    return _S97;
}

static __device__ float3  sample_point_0(Box_0 * b_8, uint i_7)
{
    uint _S98 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_7 < _S98)
        {
            float4  _S99 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + i_7]));
            local_1 = float3 {_S99.x, _S99.y, _S99.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S100 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + _S98 + b_8->hull_f_0 + (i_7 - _S98)]));
            local_1 = float3 {_S100.x, _S100.y, _S100.z};
        }
        float3  _S101 = b_8->center_1;
        float3  _S102 = box_to_world_0(b_8, local_1);
        return _S101 + _S102;
    }
    float sign_0;
    if(i_7 < 8U)
    {
        float3  h_0 = b_8->half_2 * make_float3 (0.89999997615814209f);
        if((i_7 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S103;
        if((i_7 & 2U) == 0U)
        {
            _S103 = - h_0.y;
        }
        else
        {
            _S103 = h_0.y;
        }
        float _S104;
        if((i_7 & 4U) == 0U)
        {
            _S104 = - h_0.z;
        }
        else
        {
            _S104 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * make_float3 (sign_0) + b_8->axis1_0 * make_float3 (_S103) + b_8->axis2_0 * make_float3 (_S104);
    }
    uint _S105 = i_7 - 8U;
    uint axis_1 = _S105 / 2U;
    if((_S105 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S106 = b_8->center_1;
    float3  _S107 = box_axis_0(b_8, axis_1);
    return _S106 + _S107 * make_float3 (sign_0 * comp3_0(b_8->half_2, axis_1));
}

static __device__ float3  box_to_local_0(Box_0 * b_9, float3  r_1)
{
    return make_float3 (dot_0(r_1, b_9->axis0_0), dot_0(r_1, b_9->axis1_0), dot_0(r_1, b_9->axis2_0));
}

static __device__ float hull_signed_distance_0(Box_0 * b_10, float3  local_2, uint * face_0)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_0 = 0U;
    for(;;)
    {
        if(f_0 < (b_10->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4  _S108 = __ldg((&(globalParams_0->loads_0)[b_10->hull_at_0 + b_10->hull_v_0 + f_0]));
        float d_0 = dot_0(float3 {_S108.x, _S108.y, _S108.z}, local_2) - _S108.w;
        if(d_0 > best_0)
        {
            *face_0 = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + 1U;
    }
    return best_0;
}

static __device__ bool penetration_0(Box_0 * b_11, float3  p_0, float * depth_0, float3  * normal_1)
{
    *depth_0 = 0.0f;
    *normal_1 = make_float3 (0.0f);
    float3  r_2 = p_0 - b_11->center_1;
    float3  _S109 = b_11->half_2;
    if((dot_0(r_2, r_2)) > (dot_0(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S110 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3  _S111 = box_to_local_0(b_11, r_2);
        uint face_1;
        float _S112 = hull_signed_distance_0(b_11, _S111, &face_1);
        if(!(_S112 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S112;
        float4  _S113 = __ldg((&(globalParams_0->loads_0)[b_11->hull_at_0 + _S110 + face_1]));
        float3  _S114 = box_to_world_0(b_11, float3 {_S113.x, _S113.y, _S113.z});
        *normal_1 = _S114;
        return true;
    }
    float best_1 = 1.00000001504746622e+30f;
    uint axis_2 = 0U;
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
        float3  _S115 = box_axis_0(b_11, k_2);
        float local_3 = dot_0(r_2, _S115);
        float d_1 = comp3_0(_S109, k_2) - (F32_abs((local_3)));
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S116;
            if(local_3 >= 0.0f)
            {
                _S116 = 1.0f;
            }
            else
            {
                _S116 = -1.0f;
            }
            best_1 = d_1;
            axis_2 = k_2;
            side_0 = _S116;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3  _S117 = box_axis_0(b_11, axis_2);
    *normal_1 = _S117 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_0, float3  * p_1, float3  * n_1, float * d_2)
{
    if(e_0 < na_0)
    {
        float3  _S118 = sample_point_0(ba_0, e_0);
        *p_1 = _S118;
        bool _S119 = penetration_0(bb_0, _S118, d_2, n_1);
        return _S119;
    }
    float3  _S120 = sample_point_0(bb_0, e_0 - na_0);
    *p_1 = _S120;
    bool _S121 = penetration_0(ba_0, _S120, d_2, n_1);
    if(!_S121)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

static __device__ bool is_nan_0(float x_12)
{
    return ((F32_asuint((x_12))) & 2147483647U) > 2139095040U;
}

static __device__ float2  half_thickness_and_area_0(Box_0 * b_12, float3  d_3)
{
    uint k_3 = 0U;
    float h_1 = 0.0f;
    float area_0 = 0.0f;
    for(;;)
    {
        if(k_3 < 3U)
        {
        }
        else
        {
            break;
        }
        float3  _S122 = box_axis_0(b_12, k_3);
        float c_3 = (F32_abs((dot_0(d_3, _S122))));
        float h_2 = h_1 + c_3 * comp3_0(b_12->half_2, k_3);
        uint _S123 = k_3 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S123 % 3U) * comp3_0(b_12->half_2, (k_3 + 2U) % 3U);
        k_3 = _S123;
        h_1 = h_2;
        area_0 = area_1;
    }
    return make_float2 (h_1, area_0);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_5, float eb_0, Box_0 * b_13, float3  dir_0)
{
    float3  d_4 = safe_normalize_0(dir_0);
    float2  _S124 = half_thickness_and_area_0(a_5, d_4);
    float2  _S125 = half_thickness_and_area_0(b_13, d_4);
    return (F32_min((_S124.y), (_S125.y))) / (_S124.x / ea_0 + _S125.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3  normal_2, float3  rel_velocity_0, float dt_1, uint points_0, float * stored_0, float * dissipated_1)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_1;
    float _S126 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_2);
    float _S127 = k_4 * depth_1;
    float _S128 = (F32_min((2.0f * _S126 * (F32_sqrt((k_4 * m_red_0)))), (c_max_0))) * vn_0;
    float _S129 = _S127 - _S128;
    float _S130 = (F32_max((_S129), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_2 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S131 = friction_0 * _S130;
    float _S132 = (F32_min((_S131), ((F32_min((c_max_0), (_S131 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S132 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S129 > 0.0f)
    {
        damping_power_0 = _S128 * vn_0;
    }
    else
    {
        damping_power_0 = _S127 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_1 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * make_float3 (_S130) + ft_0;
}

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_13)
{
    float t_1 = *sum_0 + x_13;
    if((F32_abs((*sum_0))) >= (F32_abs((x_13))))
    {
        *err_0 = *err_0 + (*sum_0 - t_1 + x_13);
    }
    else
    {
        *err_0 = *err_0 + (x_13 - t_1 + *sum_0);
    }
    *sum_0 = t_1;
    return;
}

static __device__ void cov_or_0(uint island_0, uint bits_0)
{
    uint _S133 = atomicOr(&(&(globalParams_0->islands_0)[island_0])->coverage_0, bits_0);
    return;
}

static __device__ void cov_mark_0(uint island_1, uint seen_0, uint bits_1)
{
    if((bits_1 & (~seen_0)) != 0U)
    {
        cov_or_0(island_1, bits_1);
    }
    return;
}

static __device__ void sentinel_mark_0(uint bits_2)
{
    uint _S134 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S135 = __ldg(&globalParams_0->params_0->halt_index_0);
    cov_mark_0(_S134, (&(globalParams_0->islands_0)[_S135])->coverage_0, bits_2);
    return;
}

static __device__ void pair_contact_0(uint i_8)
{
    uint _S136 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S136 + 6U * i_8;
    uint _S137 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S138 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S139 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S140 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S141 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S142 = (U32_asfloat((_S141)));
    uint _S143 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S144 = (U32_asfloat((_S143)));
    float _S145 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S146 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S146 + 2U * _S139;
    WorldPoint_0 wa_0 = chunk_world_0(_S137);
    WorldPoint_0 _S147 = chunk_world_0(_S138);
    WorldPoint_0 _S148 = wa_0;
    float3  _S149 = world_diff_0(&_S147, &_S148);
    float _S150 = length_0(_S149);
    float4  _S151 = __ldg(&(&(globalParams_0->chunks_0)[_S137])->half_0);
    float _S152 = _S151.w;
    float4  _S153 = __ldg(&(&(globalParams_0->chunks_0)[_S138])->half_0);
    bool touching_0 = !(_S150 > (_S152 + _S153.w));
    uint _S154 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S155 = (&(globalParams_0->scratch_0)[_S154 + i_8]);
    float4  ledger_1 = *_S155;
    uint flags_0 = (F32_asuint(((*_S155).w)));
    float3  _S156 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S137, _S156);
    Box_0 bb_1 = chunk_box_0(_S138, _S149);
    Box_0 _S157 = ba_1;
    uint _S158 = sample_count_0(&_S157);
    Box_0 _S159 = bb_1;
    uint _S160 = sample_count_0(&_S159);
    uint _S161 = _S158 + _S160;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S161)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S140 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
                *(&(globalParams_0->scratch_0)[out_0 + e_1]) = make_float4 (0.0f);
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
            *&((&ledger_1)->x) = 0.0f;
            *&((&ledger_1)->w) = (U32_asfloat((0U)));
            uint _S162 = __ldg(&globalParams_0->params_0->ledger_base_0);
            *(&(globalParams_0->scratch_0)[_S162 + i_8]) = ledger_1;
        }
        return;
    }
    Box_0 _S163 = ba_1;
    Box_0 _S164 = bb_1;
    bool _S165 = may_overlap_0(&_S163, &_S164);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    if(_S165)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S137, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S138, &vb0_0, &wb0_0);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S161)
            {
            }
            else
            {
                break;
            }
            Box_0 _S166 = ba_1;
            Box_0 _S167 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S168 = pair_point_0(&_S166, &_S167, _S158, e_1, &p_2, &n_2, &d_5);
            if(!_S168)
            {
                uint _S169 = _S140 + e_1;
                if(!is_nan_0((*(&(globalParams_0->contact_state_0)[_S169])).x))
                {
                    *(&(globalParams_0->contact_state_0)[_S169]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S170 = count_0 + 1U;
            uint _S171 = _S140 + e_1;
            float4  * _S172 = (&(globalParams_0->contact_state_0)[_S171]);
            float4  entry_0 = *_S172;
            if(is_nan_0((*_S172).x))
            {
                has_state_0 = true;
            }
            else
            {
                float4  _S173 = entry_0;
                has_state_0 = (dot_0(float3 {_S173.y, _S173.z, _S173.w}, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S145 + 9.99999971718068537e-10f))
                {
                    stored_sum_0 = d_5;
                }
                else
                {
                    stored_sum_0 = 0.0f;
                }
                entry_0 = make_float4 (stored_sum_0, n_2.x, n_2.y, n_2.z);
            }
            *&((&entry_0)->x) = (F32_min((entry_0.x), (d_5)));
            *(&(globalParams_0->contact_state_0)[_S171]) = entry_0;
            uint engaged_1;
            if((d_5 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S170;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float4  _S174 = __ldg(&(&(globalParams_0->chunks_0)[_S137])->cmat_0);
            float _S175 = _S174.x;
            float4  _S176 = __ldg(&(&(globalParams_0->chunks_0)[_S138])->cmat_0);
            float _S177 = _S176.x;
            float3  _S178 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S179 = ba_1;
            Box_0 _S180 = bb_1;
            float _S181 = contact_stiffness_0(_S175, &_S179, _S177, &_S180, _S178);
            float _S182 = _S181 / (F32_max((float(engaged_0)), (10.0f)));
            e_1 = 0U;
            fa_0 = _S156;
            ta_0 = _S156;
            fb_0 = _S156;
            tb_0 = _S156;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S161)
                {
                }
                else
                {
                    break;
                }
                Box_0 _S183 = ba_1;
                Box_0 _S184 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S185 = pair_point_0(&_S183, &_S184, _S158, e_1, &p_3, &n_3, &d_6);
                if(!_S185)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S140 + e_1])).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S182, _S142, _S144, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S145, engaged_0, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S186 = - f_1;
                float3  fb_1 = fb_0 + _S186;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S186);
                float stored_sum_1 = stored_sum_0 + stored_1;
                comp_add1_0(&((&ledger_1)->y), &((&ledger_1)->z), diss_0);
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
            fa_0 = _S156;
            ta_0 = _S156;
            fb_0 = _S156;
            tb_0 = _S156;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S156;
        ta_0 = _S156;
        fb_0 = _S156;
        tb_0 = _S156;
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
            if(e_1 < _S161)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S140 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + 1U;
        }
    }
    if(any_0(fa_0 != make_float3 (0.0f)))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(ta_0 != make_float3 (0.0f));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(fb_0 != make_float3 (0.0f));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(tb_0 != make_float3 (0.0f));
    }
    bool _S187;
    if(loaded_0)
    {
        _S187 = true;
    }
    else
    {
        _S187 = (flags_0 & 2U) != 0U;
    }
    if(_S187)
    {
        *(&(globalParams_0->scratch_0)[out_0]) = make_float4 (fa_0.x, fa_0.y, fa_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 1U]) = make_float4 (ta_0.x, ta_0.y, ta_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 2U]) = make_float4 (fb_0.x, fb_0.y, fb_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 3U]) = make_float4 (tb_0.x, tb_0.y, tb_0.z, 0.0f);
    }
    *&((&ledger_1)->x) = stored_sum_0;
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
    *&((&ledger_1)->w) = (U32_asfloat((e_1 | count_0)));
    uint _S188 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S188 + i_8]) = ledger_1;
    if(loaded_0)
    {
        sentinel_mark_0(1U);
    }
    return;
}

static __device__ Box_0 impactor_box_0(Impactor_0 * imp_0, float3  center_3, float3  half_3)
{
    Quat_0 q_6 = quat_of_0(imp_0->rotation_1);
    Box_0 b_14;
    (&b_14)->center_1 = center_3;
    float3  _S189 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S190 = q_6;
    float3  _S191 = rotate_0(&_S190, _S189);
    (&b_14)->axis0_0 = _S191;
    float3  _S192 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S193 = q_6;
    float3  _S194 = rotate_0(&_S193, _S192);
    (&b_14)->axis1_0 = _S194;
    float3  _S195 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S196 = q_6;
    float3  _S197 = rotate_0(&_S196, _S195);
    (&b_14)->axis2_0 = _S197;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_15)
{
    uint _S198;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S198 = 1U;
    }
    else
    {
        uint _S199 = sample_count_0(b_15);
        _S198 = _S199 + 14U;
    }
    return _S198;
}

static __device__ bool sphere_contact_0(Box_0 * b_16, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S200 = make_float3 (0.0f);
    *point_0 = _S200;
    *normal_3 = _S200;
    *depth_2 = 0.0f;
    float3  _S201 = b_16->center_1;
    float3  r_3 = center_4 - b_16->center_1;
    float3  _S202 = b_16->axis0_0;
    float3  _S203 = b_16->axis1_0;
    float3  _S204 = b_16->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_16->axis0_0), dot_0(r_3, b_16->axis1_0), dot_0(r_3, b_16->axis2_0));
    uint _S205 = b_16->hull_v_0;
    if((b_16->hull_v_0) != 0U)
    {
        uint face_2;
        float _S206 = hull_signed_distance_0(b_16, local_4, &face_2);
        if(_S206 >= radius_0)
        {
            return false;
        }
        float4  _S207 = __ldg((&(globalParams_0->loads_0)[b_16->hull_at_0 + _S205 + face_2]));
        float3  _S208 = box_to_world_0(b_16, float3 {_S207.x, _S207.y, _S207.z});
        *normal_3 = _S208;
        *point_0 = center_4 - _S208 * make_float3 ((F32_max((_S206), (0.0f))));
        *depth_2 = radius_0 - _S206;
        return true;
    }
    float3  q_7 = clamp_1(local_4, - b_16->half_2, b_16->half_2);
    float3  d_7 = local_4 - q_7;
    float dist_0 = length_0(d_7);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3  dn_0 = d_7 / make_float3 (dist_0);
        *normal_3 = _S202 * make_float3 (dn_0.x) + _S203 * make_float3 (dn_0.y) + _S204 * make_float3 (dn_0.z);
        *point_0 = _S201 + _S202 * make_float3 (q_7.x) + _S203 * make_float3 (q_7.y) + _S204 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S209 = penetration_0(b_16, center_4, &inside_0, &n_4);
    if(!_S209)
    {
        return false;
    }
    *normal_3 = n_4;
    *point_0 = center_4 - n_4 * make_float3 ((F32_min((radius_0), (inside_0))));
    *depth_2 = radius_0 + inside_0;
    return true;
}

static __device__ bool impactor_contact_0(Impactor_0 * imp_2, float crush_depth_0, Box_0 * shrunk_0, Box_0 * b_17, uint j_0, float3  * p_4, float3  * n_5, float * d_8)
{
    float3  _S210 = make_float3 (0.0f);
    *p_4 = _S210;
    *n_5 = _S210;
    *d_8 = 0.0f;
    float4  _S211 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S212 = sphere_contact_0(b_17, _S210, _S211.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S212)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S213 = sample_count_0(b_17);
    if(j_0 < _S213)
    {
        float3  _S214 = sample_point_0(b_17, j_0);
        *p_4 = _S214;
        bool _S215 = penetration_0(shrunk_0, _S214, d_8, n_5);
        return _S215;
    }
    float3  _S216 = sample_point_0(shrunk_0, j_0 - _S213);
    *p_4 = _S216;
    bool _S217 = penetration_0(b_17, _S216, d_8, n_5);
    if(!_S217)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S218)
{
    Impactor_0 * _S219 = (&(globalParams_0->impactors_0)[_S218]);
    WorldPoint_0 wi_0;
    float4  _S220 = _S219->position_1;
    (&wi_0)->hi_0 = float3 {_S220.x, _S220.y, _S220.z};
    float4  _S221 = _S219->position_err_1;
    (&wi_0)->lo_0 = float3 {_S221.x, _S221.y, _S221.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S222, float3  _S223, float3  _S224)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S222])->rotation_1);
    Box_0 b_18;
    (&b_18)->center_1 = _S223;
    float3  _S225 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S226 = q_8;
    float3  _S227 = rotate_0(&_S226, _S225);
    (&b_18)->axis0_0 = _S227;
    float3  _S228 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S229 = q_8;
    float3  _S230 = rotate_0(&_S229, _S228);
    (&b_18)->axis1_0 = _S230;
    float3  _S231 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S232 = q_8;
    float3  _S233 = rotate_0(&_S232, _S231);
    (&b_18)->axis2_0 = _S233;
    (&b_18)->half_2 = _S224;
    (&b_18)->hull_at_0 = 0U;
    (&b_18)->hull_v_0 = 0U;
    (&b_18)->hull_f_0 = 0U;
    return b_18;
}

static __device__ Box_0 impactor_shrunk_0(uint _S234, float _S235, Box_0 * _S236)
{
    Box_0 shrunk_1 = *_S236;
    (&shrunk_1)->half_2 = _S236->half_2 - min_0(make_float3 (_S235), _S236->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S237, float _S238, Box_0 * _S239, Box_0 * _S240, uint _S241, float3  * _S242, float3  * _S243, float * _S244)
{
    Impactor_0 _S245 = *(&(globalParams_0->impactors_0)[_S237]);
    float3  _S246 = make_float3 (0.0f);
    *_S242 = _S246;
    *_S243 = _S246;
    *_S244 = 0.0f;
    if((_S245.shape_0.x) == 0.0f)
    {
        bool _S247 = sphere_contact_0(_S240, _S246, _S245.shape_0.y - _S238, _S242, _S243, _S244);
        if(!_S247)
        {
            return false;
        }
        *_S243 = - *_S243;
        return true;
    }
    uint _S248 = sample_count_0(_S240);
    if(_S241 < _S248)
    {
        float3  _S249 = sample_point_0(_S240, _S241);
        *_S242 = _S249;
        bool _S250 = penetration_0(_S239, _S249, _S244, _S243);
        return _S250;
    }
    float3  _S251 = sample_point_0(_S239, _S241 - _S248);
    *_S242 = _S251;
    bool _S252 = penetration_0(_S240, _S251, _S244, _S243);
    if(!_S252)
    {
        return false;
    }
    *_S243 = - *_S243;
    return true;
}

static __device__ uint impactor_contact_count_0(uint _S253, float _S254, Box_0 * _S255, Box_0 * _S256)
{
    Impactor_0 _S257 = *(&(globalParams_0->impactors_0)[_S253]);
    uint j_1 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S258 = _S257;
        uint _S259 = impactor_slots_0(&_S258, _S256);
        if(j_1 < _S259)
        {
        }
        else
        {
            break;
        }
        float3  p_5;
        float3  n_6;
        float d_9;
        bool _S260 = impactor_contact_1(_S253, _S254, _S255, _S256, j_1, &p_5, &n_6, &d_9);
        if(_S260)
        {
            count_1 = count_1 + 1U;
        }
        j_1 = j_1 + 1U;
    }
    return count_1;
}

static __device__ void impactor_candidate_forces_0(uint k_5)
{
    uint _S261 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S262 = 3U * k_5;
    uint at_1 = _S261 + _S262;
    uint _S263 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S264 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S265 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S265]);
    float _S266 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S267 = make_float3 (0.0f);
    uint _S268 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S268 + _S262]);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if((imp_3.cand_0.z) == 0U)
    {
        WorldPoint_0 _S269 = impactor_point_0(_S265);
        WorldPoint_0 _S270 = chunk_world_0(_S263);
        WorldPoint_0 _S271 = _S269;
        float3  _S272 = world_diff_0(&_S270, &_S271);
        float _S273 = length_0(_S272);
        float _S274 = imp_3.half_1.w;
        float4  _S275 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->half_0);
        if(!(_S273 > (_S274 + _S275.w)))
        {
            float4  _S276 = imp_3.half_1;
            Box_0 _S277 = impactor_box_1(_S265, _S267, float3 {_S276.x, _S276.y, _S276.z});
            Box_0 b_19 = chunk_box_0(_S263, _S272);
            float _S278 = imp_3.mat_0.x;
            float4  _S279 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->cmat_0);
            float _S280 = _S279.x;
            float3  _S281 = b_19.center_1 - _S277.center_1;
            Box_0 _S282 = _S277;
            Box_0 _S283 = b_19;
            float _S284 = contact_stiffness_0(_S278, &_S282, _S280, &_S283, _S281);
            float _S285 = imp_3.geom_0.y;
            Box_0 _S286 = _S277;
            Box_0 _S287 = impactor_shrunk_0(_S265, _S285, &_S286);
            Box_0 _S288 = _S287;
            Box_0 _S289 = b_19;
            uint _S290 = impactor_contact_count_0(_S265, _S285, &_S288, &_S289);
            bool _S291 = (imp_3.shape_0.x) == 0.0f;
            float _S292;
            if(_S291)
            {
                _S292 = _S284;
            }
            else
            {
                _S292 = _S284 / (F32_max((float(_S290)), (10.0f)));
            }
            uint _S293;
            if(_S291)
            {
                _S293 = 1U;
            }
            else
            {
                _S293 = _S290;
            }
            float4  _S294 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->center_0);
            float m_1 = _S294.w;
            float _S295 = imp_3.mat_0.z;
            float _S296 = m_1 * _S295 / (m_1 + _S295);
            float _S297 = __ldg(&globalParams_0->params_0->pair_friction_0);
            float _S298;
            if(_S297 >= 0.0f)
            {
                float _S299 = __ldg(&globalParams_0->params_0->pair_friction_0);
                _S298 = _S299;
            }
            else
            {
                float _S300 = imp_3.mat_0.y;
                float4  _S301 = __ldg(&(&(globalParams_0->chunks_0)[_S263])->cmat_0);
                _S298 = (F32_min((_S300), (_S301.y)));
            }
            float4  _S302 = imp_3.velocity_1;
            float4  _S303 = imp_3.velocity_err_1;
            float3  _S304 = float3 {_S302.x, _S302.y, _S302.z} + float3 {_S303.x, _S303.y, _S303.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S263, &vc_0, &wc_0);
            hit_0 = false;
            uint j_2 = 0U;
            f_sum_0 = _S267;
            t_sum_0 = _S267;
            imp_f_0 = _S267;
            imp_t_0 = _S267;
            for(;;)
            {
                bool _S305;
                if(_S290 > 0U)
                {
                    Impactor_0 _S306 = imp_3;
                    Box_0 _S307 = b_19;
                    uint _S308 = impactor_slots_0(&_S306, &_S307);
                    _S305 = j_2 < _S308;
                }
                else
                {
                    _S305 = false;
                }
                if(_S305)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S309 = imp_3;
                Box_0 _S310 = _S287;
                Box_0 _S311 = b_19;
                float3  p_6;
                float3  nrm_0;
                float dep_0;
                bool _S312 = impactor_contact_0(&_S309, _S285, &_S310, &_S311, j_2, &p_6, &nrm_0, &dep_0);
                if(!_S312)
                {
                    j_2 = j_2 + 1U;
                    continue;
                }
                float4  _S313 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S292, _S296, _S298, dep_0 * imp_3.geom_0.x, nrm_0, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S304 + cross_0(float3 {_S313.x, _S313.y, _S313.z}, p_6)), _S266, _S293, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_19.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), diss_1);
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_2 = j_2 + 1U;
            }
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S267;
            t_sum_0 = _S267;
            imp_f_0 = _S267;
            imp_t_0 = _S267;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S267;
        t_sum_0 = _S267;
        imp_f_0 = _S267;
        imp_t_0 = _S267;
    }
    uint _S314 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S315 = 2U * _S264;
    *(&(globalParams_0->scratch_0)[_S314 + _S315]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S316 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S316 + _S315 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S317 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S317 + _S262]) = data_0;
    uint _S318 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S318 + _S262 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S319 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S319 + _S262 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(2U);
    }
    return;
}

static __device__ void travel_check_0(uint c_4)
{
    ChunkStatic_0 * _S320 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S321 = __ldg(&_S320->cinfo_0);
    if((_S321.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S322 = __ldg(&_S320->start_hi_0);
    float3  _S323 = wp_0.hi_0 - float3 {_S322.x, _S322.y, _S322.z};
    float4  _S324 = __ldg(&_S320->start_lo_0);
    if((length_0(_S323 + (wp_0.lo_0 - float3 {_S324.x, _S324.y, _S324.z}) + wp_0.rel_0)) > (_S322.w))
    {
        uint _S325 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S326 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S325])->info_1)->z) = ((&(globalParams_0->islands_0)[_S326])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint i_9 = (blockIdx * blockDim + threadIdx).x;
    if(stopped_0())
    {
        return;
    }
    uint _S327 = __ldg(&globalParams_0->params_0->pair_count_0);
    if(i_9 < _S327)
    {
        pair_contact_0(i_9);
    }
    else
    {
        uint _S328 = __ldg(&globalParams_0->params_0->pair_count_0);
        uint _S329 = __ldg(&globalParams_0->params_0->cand_count_0);
        if(i_9 < (_S328 + _S329))
        {
            uint _S330 = __ldg(&globalParams_0->params_0->pair_count_0);
            impactor_candidate_forces_0(i_9 - _S330);
        }
        else
        {
            uint _S331 = __ldg(&globalParams_0->params_0->pair_count_0);
            uint _S332 = __ldg(&globalParams_0->params_0->cand_count_0);
            uint _S333 = _S331 + _S332;
            uint _S334 = __ldg(&globalParams_0->params_0->chunk_count_0);
            if(i_9 < (_S333 + _S334))
            {
                uint _S335 = __ldg(&globalParams_0->params_0->pair_count_0);
                uint _S336 = i_9 - _S335;
                uint _S337 = __ldg(&globalParams_0->params_0->cand_count_0);
                travel_check_0(_S336 - _S337);
            }
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S338 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S339;
    if(k_6 >= _S338)
    {
        _S339 = true;
    }
    else
    {
        _S339 = stopped_0();
    }
    if(_S339)
    {
        return;
    }
    uint _S340 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S341 = 3U * k_6;
    uint at_2 = _S340 + _S341;
    uint _S342 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S343 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S344 = (&(globalParams_0->impactors_0)[_S343]);
    Impactor_0 imp_4 = *_S344;
    if(((*_S344).cand_0.z) == 0U)
    {
        _S339 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S339 = false;
    }
    float total_0;
    float ksum_0;
    if(_S339)
    {
        WorldPoint_0 _S345 = impactor_point_0(_S343);
        WorldPoint_0 _S346 = chunk_world_0(_S342);
        WorldPoint_0 _S347 = _S345;
        float3  _S348 = world_diff_0(&_S346, &_S347);
        float _S349 = length_0(_S348);
        float _S350 = imp_4.half_1.w;
        float4  _S351 = __ldg(&(&(globalParams_0->chunks_0)[_S342])->half_0);
        if(!(_S349 > (_S350 + _S351.w)))
        {
            float4  _S352 = imp_4.half_1;
            Box_0 _S353 = impactor_box_1(_S343, make_float3 (0.0f), float3 {_S352.x, _S352.y, _S352.z});
            Box_0 b_20 = chunk_box_0(_S342, _S348);
            float _S354 = imp_4.mat_0.x;
            float4  _S355 = __ldg(&(&(globalParams_0->chunks_0)[_S342])->cmat_0);
            float _S356 = _S355.x;
            float3  _S357 = b_20.center_1 - _S353.center_1;
            Box_0 _S358 = _S353;
            Box_0 _S359 = b_20;
            float _S360 = contact_stiffness_0(_S354, &_S358, _S356, &_S359, _S357);
            float _S361 = imp_4.crush_1.w;
            Box_0 _S362 = _S353;
            Box_0 _S363 = impactor_shrunk_0(_S343, _S361, &_S362);
            Box_0 _S364 = _S363;
            Box_0 _S365 = b_20;
            uint _S366 = impactor_contact_count_0(_S343, _S361, &_S364, &_S365);
            float _S367;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S367 = _S360;
            }
            else
            {
                _S367 = _S360 / (F32_max((float(_S366)), (10.0f)));
            }
            uint j_3 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S366 > 0U)
                {
                    Impactor_0 _S368 = imp_4;
                    Box_0 _S369 = b_20;
                    uint _S370 = impactor_slots_0(&_S368, &_S369);
                    _S339 = j_3 < _S370;
                }
                else
                {
                    _S339 = false;
                }
                if(_S339)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S371 = imp_4;
                Box_0 _S372 = _S363;
                Box_0 _S373 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S374 = impactor_contact_0(&_S371, _S361, &_S372, &_S373, j_3, &p_7, &nrm_1, &dep_1);
                if(!_S374)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S367;
                total_0 = total_0 + _S367 * dep_1;
                ksum_0 = ksum_1;
                j_3 = j_3 + 1U;
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
    uint _S375 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S375 + _S341]);
    uint _S376 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S376 + _S341]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S377;
    uint _S378 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S379 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S380 = ii_0 >= _S379;
    uint _S381 = __ballot_sync(_S378, _S380);
    bool _S382;
    uint k_7;
    if(_S380)
    {
        uint _S383 = __ballot_sync(_S378, true);
        _S382 = true;
        k_7 = _S383;
    }
    else
    {
        bool _S384 = stopped_0();
        uint _S385 = __ballot_sync(_S378, true);
        _S382 = _S384;
        k_7 = _S385;
    }
    uint _S386 = 0U;
    uint _S387 = __ballot_sync(k_7, _S382);
    if(_S382)
    {
        return;
    }
    else
    {
        uint _S388 = __ballot_sync(k_7, true);
        _S386 = _S388;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S389 = make_float4 (0.0f);
    float4  shares_0 = _S389;
    float4  unused_0 = _S389;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S390;
    _S390 = _S386;
    for(;;)
    {
        bool _S391 = k_7 < ((&imp_5)->cand_0.y);
        uint _S392 = __ballot_sync(_S390, _S391);
        if(_S391)
        {
            uint _S393 = __ballot_sync(_S390, true);
        }
        else
        {
            uint _S394 = __ballot_sync(_S390, false);
            uint _S395 = __ballot_sync(_S390, false);
            uint _S396 = __ballot_sync(_S386, true);
            _S377 = _S396;
            break;
        }
        uint _S397 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S397 + 3U * k_7]);
        uint _S398 = __ballot_sync(_S390, true);
        k_7 = k_7 + 256U;
        _S390 = _S398;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S377);
    bool _S399 = tid_2 != 0U;
    uint _S400 = __ballot_sync(_S377, _S399);
    if(_S399)
    {
        _S382 = true;
    }
    else
    {
        _S382 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S382)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S382 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S382 = false;
    }
    if(_S382)
    {
        _S382 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S382 = false;
    }
    if(_S382)
    {
        float extra_0 = (total_1 - (&imp_5)->crush_1.x) / shares_0.y;
        *&((&(&imp_5)->crush_1)->w) = *&((&(&imp_5)->crush_1)->w) + extra_0;
        *&((&(&imp_5)->crush_1)->z) = *&((&(&imp_5)->crush_1)->z) + (&imp_5)->crush_1.x * extra_0;
        comp_add1_0(&((&(&imp_5)->ledger_0)->z), &((&(&imp_5)->ledger_0)->w), (&imp_5)->crush_1.x * extra_0);
        comp_add1_0(&((&(&imp_5)->ledger_0)->x), &((&(&imp_5)->ledger_0)->y), (&imp_5)->crush_1.x * extra_0);
        *&((&(&imp_5)->geom_0)->x) = (&imp_5)->crush_1.x / total_1;
    }
    *(&(globalParams_0->impactors_0)[ii_0]) = imp_5;
    return;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_14)
{
    float3  t_2 = *sum_1 + x_14;
    float3  _S401 = abs_1(x_14);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S401, *sum_1,x_14) - t_2 + _slang_select((abs_1(*sum_1)) >= _S401, x_14,*sum_1));
    *sum_1 = t_2;
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_4)
{
    Quat_0 c_5;
    (&c_5)->w_1 = q_9->w_1;
    (&c_5)->x_11 = - q_9->x_11;
    (&c_5)->y_4 = - q_9->y_4;
    (&c_5)->z_0 = - q_9->z_0;
    Quat_0 _S402 = c_5;
    float3  _S403 = rotate_0(&_S402, v_4);
    return _S403;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S404 = inverse_rotate_0(q_10, v_6);
    float3  _S405 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S404));
    return _S405;
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_1)
{
    float s_1 = (F32_sin((0.25f * angle_1)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).z, -2.0f * s_1 * s_1);
}

static __device__ Quat_0 quat_mul_0(Quat_0 * a_6, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_11 * o_0->x_11 - a_6->y_4 * o_0->y_4 - a_6->z_0 * o_0->z_0;
    (&r_4)->x_11 = a_6->w_1 * o_0->x_11 + a_6->x_11 * o_0->w_1 + a_6->y_4 * o_0->z_0 - a_6->z_0 * o_0->y_4;
    (&r_4)->y_4 = a_6->w_1 * o_0->y_4 - a_6->x_11 * o_0->z_0 + a_6->y_4 * o_0->w_1 + a_6->z_0 * o_0->x_11;
    (&r_4)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_11 * o_0->y_4 - a_6->y_4 * o_0->x_11 + a_6->z_0 * o_0->w_1;
    return r_4;
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_11, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_15)
{
    float4  t_3 = *sum_2 + x_15;
    float4  _S406 = abs_0(x_15);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S406, *sum_2,x_15) - t_3 + _slang_select((abs_0(*sum_2)) >= _S406, x_15,*sum_2));
    *sum_2 = t_3;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_16)
{
    Quat_0 _S407 = *hi_1;
    float4  _S408 = quat_vec_0(&_S407);
    float4  sum_3 = _S408;
    comp_add4_0(&sum_3, lo_1, x_16);
    float4  t_4 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_4 - sum_3);
    *hi_1 = quat_of_0(t_4);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_0, float dt_2)
{
    float _S409 = length_0(omega_0);
    float angle_2 = _S409 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_0 / make_float3 (_S409), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_11 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S410 = dq_0;
    Quat_0 _S411 = *hi_2;
    Quat_0 _S412 = quat_mul_0(&_S410, &_S411);
    Quat_0 _S413 = _S412;
    float4  _S414 = quat_vec_0(&_S413);
    quat_accumulate_0(hi_2, lo_2, _S414);
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S415 = 0U;
    uint _S416;
    float3  p_8;
    uint _S417 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S418 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S419 = ii_1 >= _S418;
    uint _S420 = __ballot_sync(_S417, _S419);
    if(_S419)
    {
        return;
    }
    else
    {
        uint _S421 = __ballot_sync(_S417, true);
        _S415 = _S421;
    }
    uint _S422 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S423 = (&(globalParams_0->islands_0)[_S422]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    uint4  _S424 = _S423->info_1;
    bool _S425 = ((_S423->info_1.z) & 1U) != 0U;
    uint _S426 = __ballot_sync(_S415, _S425);
    bool _S427;
    uint k_8;
    if(_S425)
    {
        uint _S428 = __ballot_sync(_S415, true);
        _S427 = true;
        k_8 = _S428;
    }
    else
    {
        uint _S429 = _S415 & (~_S426);
        uint _S430 = _S424.y;
        bool _S431 = _S430 != 0U;
        uint _S432 = __ballot_sync(_S429, _S431);
        if(_S431)
        {
            bool _S433 = ((&imp_6)->cand_0.w) >= _S430;
            uint _S434 = __ballot_sync(_S429, true);
            _S427 = _S433;
        }
        else
        {
            uint _S435 = __ballot_sync(_S429, true);
            _S427 = false;
        }
        uint _S436 = __ballot_sync(_S415, true);
        k_8 = _S436;
    }
    uint _S437 = 0U;
    uint _S438 = __ballot_sync(k_8, _S427);
    if(_S427)
    {
        return;
    }
    else
    {
        uint _S439 = __ballot_sync(k_8, true);
        _S437 = _S439;
    }
    uint _S440 = 0U;
    bool _S441 = ((&imp_6)->cand_0.z) != 0U;
    uint _S442 = __ballot_sync(_S437, _S441);
    if(_S441)
    {
        if(tid_3 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_1])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S443 = __ballot_sync(_S437, true);
        _S440 = _S443;
    }
    float4  _S444 = make_float4 (0.0f);
    float4  rf_0 = _S444;
    float4  rt_0 = _S444;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S440;
    for(;;)
    {
        bool _S445 = k_8 < ((&imp_6)->cand_0.y);
        uint _S446 = __ballot_sync(total_points_0, _S445);
        if(_S445)
        {
            uint _S447 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S448 = __ballot_sync(total_points_0, false);
            uint _S449 = __ballot_sync(total_points_0, false);
            uint _S450 = __ballot_sync(_S440, true);
            _S416 = _S450;
            break;
        }
        uint _S451 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S452 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S451 + _S452 + 1U]);
        uint _S453 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S453 + _S452 + 2U]);
        uint _S454 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S454;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S416);
    bool _S455 = tid_3 != 0U;
    uint _S456 = __ballot_sync(_S416, _S455);
    if(_S455)
    {
        return;
    }
    float _S457 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S458 = make_float3 (0.0f);
    uint _S459 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S459 != 0U)
    {
        float4  _S460 = (&imp_6)->half_1;
        float3  _S461 = float3 {_S460.x, _S460.y, _S460.z};
        Impactor_0 _S462 = imp_6;
        Box_0 _S463 = impactor_box_0(&_S462, _S458, _S461);
        float4  _S464 = (&imp_6)->velocity_1;
        float4  _S465 = (&imp_6)->velocity_err_1;
        float3  _S466 = float3 {_S464.x, _S464.y, _S464.z} + float3 {_S465.x, _S465.y, _S465.z};
        float _S467 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S468 = (&imp_6)->mat_0.x;
        float3  _S469 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S470 = _S463;
        Box_0 _S471 = _S463;
        float _S472 = contact_stiffness_0(_S467, &_S470, _S468, &_S471, _S469);
        float _S473 = (&imp_6)->position_1.z;
        float _S474 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S475 = _S473 - _S474;
        float _S476 = (&imp_6)->position_err_1.z;
        float _S477 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S478 = _S475 + (_S476 - _S477);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S479 = _S472 / float((U32_min((total_points_0), (5U))));
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
                p_8 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S480 = _S463;
                float3  _S481 = sample_point_0(&_S480, s_2);
                p_8 = _S481;
            }
            if((_S478 + p_8.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U);
        }
        s_2 = 0U;
        load_f_0 = _S458;
        load_t_0 = _S458;
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
                p_8 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S482 = _S463;
                float3  _S483 = sample_point_0(&_S482, s_2);
                p_8 = _S483;
            }
            float depth_3 = - (_S478 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S484 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S466 + cross_0(float3 {_S484.x, _S484.y, _S484.z}, p_8);
            float _S485 = (&imp_6)->mat_0.z;
            float _S486 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S479, _S485, _S486, depth_3, _S469, v_7, _S457, below_0, &stored_3, &diss_2);
            float3  load_f_1 = load_f_0 + f_3;
            float3  load_t_1 = load_t_0 + cross_0(p_8, f_3);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_2);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + 1U;
        }
    }
    else
    {
        load_f_0 = _S458;
        load_t_0 = _S458;
    }
    float4  _S487 = rf_0;
    float3  load_f_2 = float3 {_S487.x, _S487.y, _S487.z} + load_f_0;
    float4  _S488 = rt_0;
    float3  load_t_2 = float3 {_S488.x, _S488.y, _S488.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S489 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S489.x, _S489.y, _S489.z};
    float4  _S490 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S490.x, _S490.y, _S490.z};
    float3  _S491 = load_f_2 / make_float3 (m_2);
    float4  _S492 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S491 + float3 {_S492.x, _S492.y, _S492.z}) * make_float3 (_S457));
    Quat_0 _S493 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_12 = _S493;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S494 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S494.x, _S494.y, _S494.z};
    float4  _S495 = (&imp_6)->momentum_err_1;
    float3  l_err_0 = float3 {_S495.x, _S495.y, _S495.z};
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * make_float3 (_S457));
    float3  l_1 = l_hi_0 + l_err_0;
    Quat_0 _S496 = _S493;
    float3  _S497 = world_mul_0(&_S496, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S498 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S498.x, _S498.y, _S498.z};
    float4  _S499 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S499.x, _S499.y, _S499.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S457));
    turn_left_0(&q_12, &q_err_0, _S497, _S457);
    Quat_0 _S500 = q_12;
    float3  _S501 = world_mul_0(&_S500, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S501.x, _S501.y, _S501.z, 0.0f);
    Quat_0 _S502 = q_12;
    float4  _S503 = quat_vec_0(&_S502);
    (&imp_6)->rotation_1 = _S503;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = make_float4 (l_hi_0.x, l_hi_0.y, l_hi_0.z, 0.0f);
    (&imp_6)->momentum_err_1 = make_float4 (l_err_0.x, l_err_0.y, l_err_0.z, 0.0f);
    (&imp_6)->position_1 = make_float4 (pos_0.x, pos_0.y, pos_0.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_0.x, pos_err_0.y, pos_err_0.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_0.x, vel_0.y, vel_0.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_0.x, vel_err_0.y, vel_err_0.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_1]) = imp_6;
    uint _S504 = (&imp_6)->cand_0.w - 1U;
    uint _S505 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S504 - _S505;
    uint _S506 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S506)
    {
        uint _S507 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S508 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S507 + 2U * (ii_1 * _S508 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_5)
{
    ChunkStatic_0 * _S509 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S510 = wp_1.hi_0.z;
    float _S511 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S512 = _S510 - _S511;
    float _S513 = wp_1.lo_0.z;
    float _S514 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S512 + (_S513 - _S514) + wp_1.rel_0.z;
    float4  _S515 = __ldg(&_S509->half_0);
    if((above_0 - _S515.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S516 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S517 = __ldg(&_S509->cmat_0);
    float _S518 = _S517.x;
    float3  _S519 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S520 = b_21;
    Box_0 _S521 = b_21;
    float _S522 = contact_stiffness_0(_S516, &_S520, _S518, &_S521, _S519);
    Box_0 _S523 = b_21;
    uint _S524 = sample_count_0(&_S523);
    uint s_3 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_3 < _S524)
        {
        }
        else
        {
            break;
        }
        Box_0 _S525 = b_21;
        float3  _S526 = sample_point_0(&_S525, s_3);
        if((above_0 + _S526.z) < 0.0f)
        {
            n_7 = n_7 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_7 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U);
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_6, &vc_1, &wc_1);
    uint _S527 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S528 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S527 + _S528 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S524)
        {
        }
        else
        {
            break;
        }
        Box_0 _S529 = b_21;
        float3  _S530 = sample_point_0(&_S529, s_3);
        float _S531 = above_0 + _S530.z;
        if(!(_S531 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S531;
        float3  v_8 = vc_1 + cross_0(wc_1, _S530);
        float _S532 = _S522 / float((U32_max((n_7), (5U))));
        float4  _S533 = __ldg(&_S509->center_0);
        float _S534 = _S533.w;
        float _S535 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S536 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S532, _S534, _S535, depth_4, _S519, v_8, _S536, n_7, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_5 = *t_5 + cross_0(_S530, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S537 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S538 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S537 + _S538 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S539 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S540;
    if(g_1 >= _S539)
    {
        _S540 = true;
    }
    else
    {
        _S540 = stopped_0();
    }
    if(_S540)
    {
        return;
    }
    uint _S541 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S542 = 3U * g_1;
    uint _S543 = __ldg((&(globalParams_0->index_0)[_S541 + _S542]));
    uint _S544 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S545 = __ldg((&(globalParams_0->index_0)[_S544 + _S542 + 1U]));
    uint _S546 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S547 = __ldg((&(globalParams_0->index_0)[_S546 + _S542 + 2U]));
    float3  _S548 = make_float3 (0.0f);
    float3  f_5 = _S548;
    float3  t_6 = _S548;
    uint e_2 = _S545;
    for(;;)
    {
        if(e_2 < _S547)
        {
        }
        else
        {
            break;
        }
        uint _S549 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S549 == 2147483648U)
        {
            ground_contact_0(_S543, true, &f_5, &t_6);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S550 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S551 = 2U * _S549;
        float4  _S552 = *(&(globalParams_0->scratch_0)[_S550 + _S551]);
        f_5 = f_5 + float3 {_S552.x, _S552.y, _S552.z};
        uint _S553 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S554 = *(&(globalParams_0->scratch_0)[_S553 + _S551 + 1U]);
        t_6 = t_6 + float3 {_S554.x, _S554.y, _S554.z};
        e_2 = e_2 + 1U;
    }
    uint _S555 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S556 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S555 + _S556]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S557 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S557 + _S556 + 1U]) = make_float4 (t_6.x, t_6.y, t_6.z, 0.0f);
    return;
}

__device__ __shared__ FixedArray<uint, 5>  g_seen_0;

static __device__ void seen_clear_0(uint tid_4)
{
    if(tid_4 < 5U)
    {
        (*&g_seen_0)[tid_4] = 0U;
    }
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S558 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S559 = (&(globalParams_0->islands_0)[_S558])->info_1;
    bool _S560;
    if((((&(globalParams_0->islands_0)[_S558])->info_1.z) & 1U) != 0U)
    {
        _S560 = true;
    }
    else
    {
        uint _S561 = _S559.y;
        if(_S561 != 0U)
        {
            _S560 = _S561 <= (isl_0->info_1.w);
        }
        else
        {
            _S560 = false;
        }
    }
    return _S560;
}

__device__ __shared__ uint g_run_0;

__device__ __shared__ uint g_halt_0;

struct Rigid_0
{
    Quat_0 rot_0;
    float4  rot_err_0;
    float3  pos_1;
    float3  pos_err_1;
    float3  vel_1;
    float3  vel_err_1;
    float3  w_4;
    float3  l_2;
    float3  l_err_1;
    float3  torque_0;
    float3  a_7;
    float3  alpha_0;
};

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_1)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(isl_1->rotation_0);
    (&rg_0)->rot_err_0 = isl_1->rotation_err_0;
    float4  _S562 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S562.x, _S562.y, _S562.z};
    float4  _S563 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S563.x, _S563.y, _S563.z};
    float4  _S564 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S564.x, _S564.y, _S564.z};
    float4  _S565 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S565.x, _S565.y, _S565.z};
    float4  _S566 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S566.x, _S566.y, _S566.z};
    float4  _S567 = isl_1->momentum_0;
    (&rg_0)->l_2 = float3 {_S567.x, _S567.y, _S567.z};
    float4  _S568 = isl_1->momentum_err_0;
    (&rg_0)->l_err_1 = float3 {_S568.x, _S568.y, _S568.z};
    float3  _S569 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S569;
    (&rg_0)->a_7 = _S569;
    (&rg_0)->alpha_0 = _S569;
    return rg_0;
}

static __device__ float time_since_0(float4  origin_0, uint k_10, float dt_3)
{
    float _S570 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S571 = _S570 - origin_0.x;
    float _S572 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S571 + (_S572 - origin_0.y) + float(k_10) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S573 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S573.x))
    {
        return _S573.y;
    }
    uint i_10 = 1U;
    for(;;)
    {
        if(i_10 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S574 = offset_0 + i_10;
        float4  _S575 = __ldg((&(globalParams_0->loads_0)[_S574]));
        float _S576 = _S575.x;
        if(tau_0 <= _S576)
        {
            float4  _S577 = __ldg((&(globalParams_0->loads_0)[_S574 - 1U]));
            float _S578 = _S577.x;
            float _S579 = _S577.y;
            return _S579 + (tau_0 - _S578) / (F32_max((_S576 - _S578), (1.00000000317107685e-30f))) * (_S575.y - _S579);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S580 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S580.y;
}

static __device__ float eval_function_0(uint term_0, uint k_11, float dt_4, float shift_0)
{
    uint _S581 = 5U * term_0;
    float4  _S582 = __ldg((&(globalParams_0->loads_0)[_S581]));
    uint4  info_2 = asuint_0(_S582);
    float4  _S583 = __ldg((&(globalParams_0->loads_0)[_S581 + 3U]));
    float4  _S584 = __ldg((&(globalParams_0->loads_0)[_S581 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S583.z;
    }
    float tau_1 = time_since_0(_S583, k_11, dt_4) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S585 = _S584.x;
            if(tau_1 >= _S585)
            {
                shape_1 = _S584.y;
            }
            else
            {
                shape_1 = _S584.y * tau_1 / _S585;
            }
        }
        return shape_1;
    }
    bool _S586;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S586 = true;
        }
        else
        {
            _S586 = tau_1 > (_S584.x);
        }
        if(_S586)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S584.y * (F32_sin((3.14159274101257324f * tau_1 / _S584.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S584.y;
        if(sn_0 < 0.0f)
        {
            _S586 = true;
        }
        else
        {
            _S586 = sn_0 > 1.0f;
        }
        if(_S586)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S584.x * (1.0f - sn_0) * (F32_exp((- _S584.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S584.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S584.x;
        if(sn_1 < 0.0f)
        {
            _S586 = true;
        }
        else
        {
            _S586 = sn_1 > 1.0f;
        }
        if(_S586)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S584.y * sn_1)));
        }
        float clearing_0 = _S583.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S587 = _S584.w;
        return (_S587 + (_S584.z - _S587) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S588 = _S584.y;
        if(tau_1 < _S588)
        {
            return _S584.x;
        }
        float s_4 = tau_1 - _S588;
        float _S589 = _S584.w;
        if(s_4 > _S589)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S584.z * (F32_sin((3.14159274101257324f * s_4 / _S589)));
        }
        return shape_1;
    }
    float _S590 = _S584.x;
    if(_S590 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S590, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_6, float3  t_7)
{
    uint _S591 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S591 == 0U)
    {
        return;
    }
    uint _S592 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S593 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S592 + _S593]) = make_float4 (f_6.x, f_6.y, f_6.z, 0.0f);
    uint _S594 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S594 + _S593 + 1U]) = make_float4 (t_7.x, t_7.y, t_7.z, 0.0f);
    uint _S595 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S596 = (&(globalParams_0->scratch_0)[_S595 + _S593]);
    uint _S597 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S598 = *(&(globalParams_0->scratch_0)[_S597 + _S593]);
    *_S596 = make_float4 ((float3 {_S598.x, _S598.y, _S598.z} + f_6).x, (float3 {_S598.x, _S598.y, _S598.z} + f_6).y, (float3 {_S598.x, _S598.y, _S598.z} + f_6).z, 0.0f);
    uint _S599 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S600 = (&(globalParams_0->scratch_0)[_S599 + _S593 + 1U]);
    uint _S601 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S602 = *(&(globalParams_0->scratch_0)[_S601 + _S593 + 1U]);
    *_S600 = make_float4 ((float3 {_S602.x, _S602.y, _S602.z} + t_7).x, (float3 {_S602.x, _S602.y, _S602.z} + t_7).y, (float3 {_S602.x, _S602.y, _S602.z} + t_7).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S603, uint _S604, Quat_0 * _S605, uint _S606, float _S607, bool _S608, float _S609, float3  * _S610, float3  * _S611, float3  * _S612, float3  * _S613)
{
    bool _S614;
    ChunkStatic_0 * _S615 = (&(globalParams_0->chunks_0)[_S604]);
    float3  _S616 = make_float3 (0.0f);
    *_S610 = _S616;
    *_S611 = _S616;
    *_S612 = _S616;
    *_S613 = _S616;
    uint4  _S617 = __ldg(&_S615->load_range_0);
    uint term_1 = _S617.x;
    for(;;)
    {
        if(term_1 < (_S617.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S618 = 5U * term_1;
        float4  _S619 = __ldg((&(globalParams_0->loads_0)[_S618]));
        uint _S620 = asuint_0(_S619).y;
        bool replacement_0 = _S620 == 2U;
        float4  _S621 = __ldg((&(globalParams_0->loads_0)[_S618 + 1U]));
        float4  _S622 = __ldg((&(globalParams_0->loads_0)[_S618 + 2U]));
        float _S623;
        if(replacement_0)
        {
            _S623 = _S609;
        }
        else
        {
            _S623 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S606, _S607, _S623);
        if(replacement_0)
        {
            *_S612 = *_S612 + float3 {_S621.x, _S621.y, _S621.z} * make_float3 (value_0);
            *_S613 = *_S613 + float3 {_S622.x, _S622.y, _S622.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S620 == 0U)
        {
            _S614 = true;
        }
        else
        {
            _S614 = _S620 == 3U;
        }
        float3  fw_0;
        if(_S614)
        {
            fw_0 = float3 {_S621.x, _S621.y, _S621.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S624 = rotate_0(_S605, float3 {_S621.x, _S621.y, _S621.z});
            fw_0 = _S624 * make_float3 (- value_0 * _S621.w);
        }
        float3  lever_0;
        if(_S620 == 3U)
        {
            float4  _S625 = *(&(globalParams_0->state_0)[4U * _S603]);
            lever_0 = float3 {_S622.x, _S622.y, _S622.z} - float3 {_S625.x, _S625.y, _S625.z};
        }
        else
        {
            lever_0 = float3 {_S622.x, _S622.y, _S622.z};
        }
        *_S610 = *_S610 + fw_0;
        float3  _S626 = rotate_0(_S605, lever_0);
        *_S611 = *_S611 + cross_0(_S626, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S608)
    {
        uint4  _S627 = __ldg(&_S615->cinfo_0);
        _S614 = (_S627.z) != 0U;
    }
    else
    {
        _S614 = false;
    }
    if(_S614)
    {
        uint4  _S628 = __ldg(&_S615->cinfo_0);
        uint g_2 = _S628.x;
        for(;;)
        {
            if(g_2 < (_S628.y))
            {
            }
            else
            {
                break;
            }
            uint _S629 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S630 = 2U * g_2;
            float4  _S631 = *(&(globalParams_0->scratch_0)[_S629 + _S630]);
            *_S610 = *_S610 + float3 {_S631.x, _S631.y, _S631.z};
            uint _S632 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S633 = *(&(globalParams_0->scratch_0)[_S632 + _S630 + 1U]);
            *_S611 = *_S611 + float3 {_S633.x, _S633.y, _S633.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S634, uint _S635, Quat_0 * _S636, uint _S637, float _S638, bool _S639, float3  * _S640, float3  * _S641)
{
    float3  rf_1;
    float3  rm_0;
    chunk_loads_0(_S634, _S635, _S636, _S637, _S638, _S639, 0.0f, _S640, _S641, &rf_1, &rm_0);
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_1, uint k_12, float dt_5, bool contact_0)
{
    float3  f_7;
    float3  t_8;
    chunk_external_0(c_8, c_8, rot_1, k_12, dt_5, contact_0, &f_7, &t_8);
    record_chunk_load_0(c_8, f_7, t_8);
    return length_0(f_7);
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_2, Rigid_0 * rg_1, uint k_13, float dt_6, bool contact_1, float3  * f_8, float3  * t_9)
{
    ChunkStatic_0 * _S642 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_1->rot_0, k_13, dt_6, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S643 = fl_0;
    float4  _S644 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S645 = float3 {_S644.x, _S644.y, _S644.z};
    float4  _S646 = __ldg(&_S642->center_0);
    float3  fc_0 = _S643 + _S645 * make_float3 (_S646.w);
    float3  _S647 = float3 {_S646.x, _S646.y, _S646.z};
    float4  _S648 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S649 = isl_2->com_0;
    float3  _S650 = float3 {_S649.x, _S649.y, _S649.z};
    float3  _S651 = rotate_0(&rg_1->rot_0, _S647 + float3 {_S648.x, _S648.y, _S648.z} - _S650);
    *f_8 = *f_8 + fc_0;
    *t_9 = *t_9 + (cross_0(_S651, fc_0) + tl_0);
    uint4  _S652 = __ldg(&_S642->load_range_0);
    if((_S652.y) > (_S652.x))
    {
        float3  _S653 = rotate_0(&rg_1->rot_0, rep_f_0);
        *f_8 = *f_8 + _S653;
        float3  _S654 = rotate_0(&rg_1->rot_0, _S647 - _S650);
        float3  _S655 = cross_0(_S654, _S653);
        float3  _S656 = rotate_0(&rg_1->rot_0, rep_m_0);
        *t_9 = *t_9 + (_S655 + _S656);
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_3, Rigid_0 * rg_2, float3  f_9, float3  t_10)
{
    Quat_0 _S657 = rg_2->rot_0;
    float3  _S658 = world_mul_0(&_S657, isl_3->inertia0_1, isl_3->inertia1_1, isl_3->inertia2_1, rg_2->w_4);
    rg_2->a_7 = f_9 / make_float3 (isl_3->com_0.w);
    float3  _S659 = t_10 - cross_0(rg_2->w_4, _S658);
    Quat_0 _S660 = rg_2->rot_0;
    float3  _S661 = world_mul_0(&_S660, isl_3->inv0_1, isl_3->inv1_1, isl_3->inv2_1, _S659);
    rg_2->alpha_0 = _S661;
    rg_2->torque_0 = t_10;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S662 = __ldg(&ptr_0->geom0_0);
    float4  _S663 = __ldg(&ptr_0->geom1_0);
    float4  _S664 = __ldg(&ptr_0->stiff0_0);
    float4  _S665 = __ldg(&ptr_0->stiff1_0);
    float4  _S666 = __ldg(&ptr_0->rebar0_0);
    float4  _S667 = __ldg(&ptr_0->rebar1_0);
    uint4  _S668 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S669 = { _S662, _S663, _S664, _S665, _S666, _S667, _S668 };
    return _S669;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S670;
    if((st_0->damage_0) > 0.0f)
    {
        _S670 = true;
    }
    else
    {
        _S670 = (st_0->crush_0) > 0.0f;
    }
    return _S670;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S671;
    if((st_1->damage_0) < 1.0f)
    {
        _S671 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S671 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S671 = false;
        }
    }
    return _S671;
}

static __device__ float fdiv_0(float a_8, float b_22)
{
    return a_8 / b_22;
}

static __device__ float fsqrt_0(float a_9)
{
    return (F32_sqrt((a_9)));
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

static __device__ Measures_0 stress_measures_0(JointBond_0 * b_23, float3  q_lin_0, float3  q_ang_0)
{
    float area_2 = b_23->geom0_0.x;
    float _S672 = q_lin_0.z;
    float axial_0 = fdiv_0(_S672, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S673 = q_lin_0.x;
    float _S674 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S673 * _S673 + _S674 * _S674), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S675 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S675), (0.0f)));
    (&m_3)->compression_0 = _S675 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S672), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_17)
{
    if((F32_abs((x_17))) < 0.00100000004749745f)
    {
        return x_17 * (1.0f + x_17 * (0.5f + x_17 * 0.1666666716337204f));
    }
    return (F32_exp((x_17))) - 1.0f;
}

static __device__ float fpow_0(float a_10, float b_24)
{
    return (F32_pow((a_10), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S676 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S677 = _S676.z;
    float f_10;
    if(r_5 <= _S677)
    {
        f_10 = fpow_0(fdiv_0(r_5, ref_0), _S676.y);
    }
    else
    {
        f_10 = fpow_0(fdiv_0(_S677, ref_0), _S676.y) * fpow_0(fdiv_0(r_5, _S677), _S676.w);
    }
    return clamp_0(f_10, 1.0f, mat_1->misc_0.x);
}

static __device__ float fatigue_factor_0(JointMaterial_0 * mat_2, float life_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return fpow_0(clamp_0(life_1, 0.0f, 1.0f), fdiv_0(1.0f, mat_2->misc_0.y - 2.0f));
}

static __device__ float infinity_0()
{
    return (U32_asfloat((2139095040U)));
}

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_25, Measures_0 * m_4, float multiplier_0)
{
    float fc_1 = mat_3->strength_0.y * multiplier_0;
    float _S678 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S679;
    if(_S678 > 0.0f)
    {
        _S679 = fdiv_0(m_4->shear_0, _S678);
    }
    else
    {
        _S679 = infinity_0();
    }
    *&((&idx_0)->y) = _S679;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_1)), (0.0f)));
    float _S680 = b_25->stiff1_0.y;
    if(_S680 > 0.0f)
    {
        _S679 = fdiv_0(m_4->compressive_force_0, _S680);
    }
    else
    {
        _S679 = 0.0f;
    }
    *&((&idx_0)->w) = _S679;
    return idx_0;
}

static __device__ float sq_0(float x_18)
{
    return x_18 * x_18;
}

static __device__ float damage_law_0(uint kind_1, float kappa_1, float r_6)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == 0U)
    {
        if(r_6 <= 1.0f)
        {
            return 1.0f;
        }
        return (F32_min((fdiv_0(r_6 * (kappa_1 - 1.0f), kappa_1 * (r_6 - 1.0f))), (1.0f)));
    }
    if(kappa_1 >= (0.5f * (r_6 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

static __device__ __noinline__ float2  damage_increment_0(uint kind_2, float kappa_old_0, float lambda_0, float r_7, float d_old_0, float psi_0)
{
    float _S681 = (F32_max((damage_law_0(kind_2, lambda_0, r_7)), (d_old_0)));
    bool _S682;
    if(_S681 <= d_old_0)
    {
        _S682 = true;
    }
    else
    {
        _S682 = d_old_0 >= 1.0f;
    }
    if(_S682)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S683 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S681, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S683), (r_7)))), (0.0f))));
        }
        return make_float2 (_S681, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S683), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S681 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S681, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S684 = - h0_0;
    float _S685 = - h1_0;
    FixedArray<float2 , 4>  _S686 = { {
        float2 {
            _S684, _S685
        }, float2 {
            h0_0, _S685
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S684, h1_0
        }
    } };
    FixedArray<float2 , 8>  poly_0;
    uint i_11 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_11 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S687 = i_11;
        uint _S688 = i_11 + 1U;
        uint _S689 = _S688 % 4U;
        float _S690 = _S686[i_11].y;
        float _S691 = _S686[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S690 - ay_0 * _S691;
        float _S692 = _S686[_S689].y;
        float _S693 = _S686[_S689].x;
        float fq_0 = dz_0 + ax_0 * _S692 - ay_0 * _S693;
        bool _S694 = fp_0 < 0.0f;
        if(_S694)
        {
            uint _S695 = count_4 + 1U;
            poly_0[count_4] = _S686[_S687];
            count_3 = _S695;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S694 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S696 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S691 + t_11 * (_S693 - _S691), _S690 + t_11 * (_S692 - _S690));
            count_4 = _S696;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S688;
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
    float2  o_1 = poly_0[int(0)];
    i_11 = 0U;
    float a_11 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_11 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S697 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S697;
        float _S698 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S698;
        uint _S699 = i_11 + 1U;
        uint _S700 = _S699 % count_4;
        float x1_0 = poly_0[_S700].x - _S697;
        float y1_0 = poly_0[_S700].y - _S698;
        float _S701 = x0_0 * y1_0;
        float _S702 = x1_0 * y0_0;
        float cr_0 = _S701 - _S702;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S701 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S702) * cr_0 / 24.0f;
        i_11 = _S699;
        a_11 = a_12;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_11 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_11;
    float cy_0 = sy_0 / a_11;
    (*region_0)[int(0)] = a_11;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S703 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S703 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S703 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_13 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_14 = kn_0 / (w0_1 * w1_1);
    float fc_2 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S704 = a_13 * fc_2;
    float _S705 = - ay_1;
    return make_float4 (k_14 * a_13 * fc_2, k_14 * (_S704 * r_8[int(2)] + (_S705 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_14 * (_S704 * r_8[int(1)] + (_S705 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_14 * (_S704 * fc_2 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_19)
{
    float _S706;
    if(((F32_asuint((x_19))) & 2147483648U) != 0U)
    {
        _S706 = -1.0f;
    }
    else
    {
        _S706 = 1.0f;
    }
    return _S706;
}

static __device__ float2  return_map_0(float k_15, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_15 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    return make_float2 (f_11, fdiv_0(trial_0 - f_11, k_15));
}

struct Contact_0
{
    float3  q_lin_1;
    float3  q_ang_1;
    float energy_2;
    float diss_4;
    float3  plastic_1;
};

static __device__ __noinline__ Contact_0 contact_part_0(JointMaterial_0 * mat_4, JointBond_0 * b_26, float crush_2, float3  plastic_2, float3  d_lin_0, float3  d_ang_0)
{
    Contact_0 c_10;
    float3  _S707 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S707;
    (&c_10)->q_ang_1 = _S707;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S708 = mat_4->kind_flags_0.y;
    if((_S708 & 2U) == 0U)
    {
        return c_10;
    }
    float kn_1 = b_26->stiff0_0.x;
    float ks_0 = b_26->stiff0_0.y;
    float kt_0 = b_26->stiff1_0.x;
    float w0_2 = b_26->geom0_0.y;
    float w1_2 = b_26->geom0_0.z;
    float diss_5;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S708 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S709 = p_9.y;
        float _S710 = p_9.z;
        float _S711 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S709;
        m2_0 = _S710;
        energy_3 = _S711;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S712 = d_ang_0.x;
        float _S713 = d_ang_0.y;
        float spread_0 = (F32_abs((_S712))) * 0.4166666567325592f * w1_2 + (F32_abs((_S713))) * 0.4166666567325592f * w0_2;
        float _S714 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S714))) + spread_0);
        if((_S714 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S714 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S715 = ki_0 * _S712 * i2_0;
                float _S716 = ki_0 * _S713 * i1_0;
                float _S717 = 0.5f * ki_0 * (36.0f * _S714 * _S714 + _S712 * _S712 * i2_0 + _S713 * _S713 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S714;
                m1_0 = _S715;
                m2_0 = _S716;
                energy_3 = _S717;
            }
            else
            {
                uint i_12 = 0U;
                diss_5 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_12 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S718 = SPRING_AT_0[i_12] * w0_2;
                    uint j_4 = 0U;
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_4 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = SPRING_AT_0[j_4] * w1_2;
                        float di_0 = _S714 + _S712 * s2_0 - _S713 * _S718;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S718;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_4 = j_4 + 1U;
                    }
                    i_12 = i_12 + 1U;
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
    float3  p_10 = plastic_2;
    (&c_10)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_10)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S719 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S720 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S719 * _S719 + _S720 * _S720);
    bool _S721;
    if(tn_0 > slide_cap_0)
    {
        _S721 = tn_0 > 0.0f;
    }
    else
    {
        _S721 = false;
    }
    if(_S721)
    {
        float _S722 = fdiv_0(_S719, tn_0);
        float _S723 = fdiv_0(_S720, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S722 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S723 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S722 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S723 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S719;
        *&((&(&c_10)->q_lin_1)->y) = _S720;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S724 = tq_0.x;
    float _S725 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S724))) * (F32_abs((_S725)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S725;
    *&((&(&c_10)->q_ang_1)->z) = _S724;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S724), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S726 = mat_5->kind_flags_0.y;
    if((_S726 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S726 & 4U) != 0U)
    {
        float4  _S727 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S727.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S728 = d_ang_1.x;
        float _S729 = d_ang_1.y;
        float spread_1 = (F32_abs((_S728))) * 0.4166666567325592f * w1_3 + (F32_abs((_S729))) * 0.4166666567325592f * w0_3;
        float _S730 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S730))) + spread_1);
        if((_S730 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S730 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S730;
            }
            else
            {
                uint i_13 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_13 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S731 = SPRING_AT_0[i_13] * w0_3;
                    uint j_5 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_5 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S730 + _S728 * (SPRING_AT_0[j_5] * w1_3) - _S729 * _S731;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_13 = i_13 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    float3  p_11 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S732 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S733 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S732 * _S732 + _S733 * _S733);
    bool _S734;
    if(tn_1 > slide_cap_1)
    {
        _S734 = tn_1 > 0.0f;
    }
    else
    {
        _S734 = false;
    }
    if(_S734)
    {
        float _S735 = fdiv_0(_S733, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S732, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S735 * dslip_1;
    }
    *&((&p_11)->z) = *&((&p_11)->z) + return_map_0(kt_1, d_ang_1.z, p_11.z, slide_cap_1 * b_27->geom1_0.z).y;
    return p_11;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S736 = mat_6->misc_0.y;
    return fdiv_0((_S736 + 1.0f) * fpow_0(s_5, _S736), mat_6->misc_0.z);
}

struct JointResponse_0
{
    float3  force_lin_1;
    float3  force_ang_1;
    JointState_0 state_1;
    float dissipated_2;
    float overshoot_0;
    float stored_5;
    bool disconnected_0;
    float fatigue_before_0;
    Measures_0 measures_0;
};

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_28, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_7, bool fracture_1)
{
    float kn_3 = b_28->stiff0_0.x;
    float ks_2 = b_28->stiff0_0.y;
    float kb1_0 = b_28->stiff0_0.z;
    float kb2_0 = b_28->stiff0_0.w;
    float4  _S737 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S738 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S739 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S740 = (F32_max(((F32_max((_S739.tension_0), (_S739.shear_0)))), (_S739.compression_0)));
    bool _S741 = dt_7 > 0.0f;
    float dif_1;
    if(_S741)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S740 - (&st_2)->governing_stress_0, dt_7)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S737.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_7, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_7, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S740;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S742 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S742;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S743 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S743;
    Measures_0 _S744 = _S739;
    float4  _S745 = failure_indices_0(mat_7, b_28, &_S744, multiplier_1);
    float _S746 = _S745.x;
    float _S747 = _S745.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S746), (_S747)))), ((F32_max((_S745.z), (_S745.w))))));
    float _S748 = d_lin_2.x;
    float _S749 = d_lin_2.y;
    float _S750 = ks_2 * (sq_0(_S748) + sq_0(_S749)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S751 = d_lin_2.z;
    bool _S752 = _S751 > 0.0f;
    if(_S752)
    {
        dif_1 = kn_3 * sq_0(_S751);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S750 + dif_1);
    float psi_c_0;
    if(_S751 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S751);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3  plastic_4 = make_float3 ((&st_2)->plastic_x_0, (&st_2)->plastic_y_0, (&st_2)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S753;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S754 = _S746 >= _S747;
        if(_S754)
        {
            diss_contact_0 = _S746;
        }
        else
        {
            diss_contact_0 = _S747;
        }
        uint mode_ts_0;
        if(_S754)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S753 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S753 = false;
        }
        if(_S753)
        {
            _S753 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S753 = false;
        }
        uint mode_c_0;
        if(_S753)
        {
            if(mode_ts_0 == 1U)
            {
                psi_contact_0 = mat_7->energy_0.y;
            }
            else
            {
                psi_contact_0 = mat_7->energy_0.z;
            }
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(psi_contact_0 * b_28->geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_2)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2  inc_0 = damage_increment_0(mode_c_0, (&st_2)->kappa_0, diss_contact_0, intact_normal_0, (&st_2)->damage_0, psi_ts_0);
            float _S755 = inc_0.x;
            if(_S755 > ((&st_2)->damage_0))
            {
                Contact_0 _S756 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S757 = (F32_max((_S756.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S758 = (F32_max((inc_0.y - _S757 * (_S755 - (&st_2)->damage_0)), (0.0f)));
                float _S759 = (F32_max(((psi_ts_0 - _S757) * (_S755 - (&st_2)->damage_0) - _S758), (0.0f)));
                (&st_2)->damage_0 = _S755;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S758;
                overshoot_1 = _S759;
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
        (&st_2)->kappa_0 = (F32_max(((&st_2)->kappa_0), (diss_contact_0)));
        float _S760 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S761 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S760) + _S761.q_ang_1 * make_float3 (_S760);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S762 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S763 = _S762;
        float4  _S764 = failure_indices_0(mat_7, b_28, &_S763, multiplier_1);
        float _S765 = _S764.z;
        float _S766 = _S764.w;
        bool _S767 = _S765 >= _S766;
        if(_S767)
        {
            psi_contact_0 = _S765;
        }
        else
        {
            psi_contact_0 = _S766;
        }
        if(_S767)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S753 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S753 = false;
        }
        if(_S753)
        {
            _S753 = psi_c_0 > 0.0f;
        }
        else
        {
            _S753 = false;
        }
        if(_S753)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_7->energy_0.w * b_28->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_2)->ductility_c_0 = intact_normal_0;
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
            float2  inc_1 = damage_increment_0(law_1, (&st_2)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_2)->crush_0, psi_c_0);
            float _S768 = inc_1.x;
            if(_S768 > ((&st_2)->crush_0))
            {
                float _S769 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S769;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S768 - (&st_2)->crush_0) - _S769), (0.0f)));
                (&st_2)->crush_0 = _S768;
                (&st_2)->mode_0 = mode_c_0;
                if(_S768 >= 1.0f)
                {
                    _S753 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S753 = false;
                }
                if(_S753)
                {
                    float dissipated_5 = dissipated_4 + psi_ts_0 * (1.0f - (&st_2)->damage_0);
                    (&st_2)->damage_0 = 1.0f;
                    dissipated_3 = dissipated_5;
                }
                else
                {
                    dissipated_3 = dissipated_4;
                }
                overshoot_1 = overshoot_2;
            }
        }
        (&st_2)->kappa_c_0 = (F32_max(((&st_2)->kappa_c_0), (psi_contact_0)));
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_2)->damage_0;
    float3  _S770 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S771 = contact_offsets_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S771.x;
            (&st_2)->plastic_y_0 = _S771.y;
            (&st_2)->plastic_t_0 = _S771.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S770;
        qc_ang_0 = _S770;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S772 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S772.plastic_1.x;
        (&st_2)->plastic_y_0 = _S772.plastic_1.y;
        (&st_2)->plastic_t_0 = _S772.plastic_1.z;
        diss_contact_0 = _S772.diss_4;
        qc_lin_0 = _S772.q_lin_1;
        qc_ang_0 = _S772.q_ang_1;
        psi_contact_0 = _S772.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S752)
    {
        intact_normal_0 = kn_3 * _S751;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S751;
    }
    float _S773 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S773 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S773 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S773 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S773) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S773 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S753 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S753 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S753)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S751, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S748, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S749, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S774 = nr_0.y;
        float _S775 = v1_0.y;
        float _S776 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S774))) + dowel_capacity_0 * ((F32_abs((_S775))) + (F32_abs((_S776))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S774;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S775;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S776;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S777 = nr_0.x;
        float _S778 = v1_0.x;
        float _S779 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S777), k_axial_0) + fdiv_0(sq_0(_S778) + sq_0(_S779), k_dowel_0));
        if(fracture_1)
        {
            _S753 = ((&st_2)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S753 = false;
        }
        if(_S753)
        {
            (&st_2)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_7 = stored_6;
        }
        else
        {
            float stored_8 = stored_6 + elastic_0;
            force_lin_3 = force_lin_2 + make_float3 (_S778, _S779, _S777);
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
        _S753 = _S741;
    }
    else
    {
        _S753 = false;
    }
    if(_S753)
    {
        _S753 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S753 = false;
    }
    if(_S753)
    {
        Measures_0 _S780 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S781 = _S780;
        float4  _S782 = failure_indices_0(mat_7, b_28, &_S781, weibull_0);
        float _S783 = life_rate_0(mat_7, (F32_max(((F32_max((_S782.x), (_S782.y)))), (_S782.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S783 * dt_7), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S738)
    {
        JointState_0 _S784 = st_2;
        bool _S785 = connected_0(&_S784, has_rebar_1);
        _S753 = !_S785;
    }
    else
    {
        _S753 = false;
    }
    (&resp_0)->disconnected_0 = _S753;
    (&resp_0)->fatigue_before_0 = _S743;
    (&resp_0)->measures_0 = _S739;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S786 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S786;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S787 = 1.0f - _S786;
    float _S788 = (F32_max((_S787 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S787), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S788, _S788, normal_4);
    *f_ang_0 = make_float3 (_S788);
    bool _S789;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S789 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S789 = false;
    }
    if(_S789)
    {
        float4  _S790 = b_29->rebar0_0;
        float4  _S791 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S792 = fdiv_0(_S790.y, _S791.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S792;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S792;
    }
    return;
}

static __device__ float3  to_local_0(uint _S793, float3  _S794)
{
    BondStatic_0 * _S795 = (&(globalParams_0->bonds_0)[_S793]);
    float4  _S796 = __ldg(&_S795->t1_0);
    float _S797 = dot_0(_S794, float3 {_S796.x, _S796.y, _S796.z});
    float4  _S798 = __ldg(&_S795->t2_0);
    float _S799 = dot_0(_S794, float3 {_S798.x, _S798.y, _S798.z});
    float4  _S800 = __ldg(&_S795->normal_0);
    return make_float3 (_S797, _S799, dot_0(_S794, float3 {_S800.x, _S800.y, _S800.z}));
}

static __device__ float3  to_body_0(uint _S801, float3  _S802)
{
    BondStatic_0 * _S803 = (&(globalParams_0->bonds_0)[_S801]);
    float4  _S804 = __ldg(&_S803->t1_0);
    float3  _S805 = float3 {_S804.x, _S804.y, _S804.z} * make_float3 (_S802.x);
    float4  _S806 = __ldg(&_S803->t2_0);
    float3  _S807 = _S805 + float3 {_S806.x, _S806.y, _S806.z} * make_float3 (_S802.y);
    float4  _S808 = __ldg(&_S803->normal_0);
    return _S807 + float3 {_S808.x, _S808.y, _S808.z} * make_float3 (_S802.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_8, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S809 = (&(globalParams_0->bonds_0)[i_14]);
    JointBond_0 _S810 = slang_ldg_0(&_S809->law_0);
    uint ca_0 = _S810.ids_0.y;
    uint cb_0 = _S810.ids_0.z;
    float4  _S811 = __ldg(&_S809->ra_0);
    float3  ra_1 = float3 {_S811.x, _S811.y, _S811.z};
    float4  _S812 = __ldg(&_S809->rb_0);
    float3  rb_1 = float3 {_S812.x, _S812.y, _S812.z};
    uint _S813 = 4U * ca_0;
    float4  _S814 = *(&(globalParams_0->state_0)[_S813]);
    float4  _S815 = *(&(globalParams_0->state_0)[_S813 + 1U]);
    float3  ta_2 = float3 {_S815.x, _S815.y, _S815.z};
    float4  _S816 = *(&(globalParams_0->state_0)[_S813 + 2U]);
    float3  va_0 = float3 {_S816.x, _S816.y, _S816.z};
    float4  _S817 = *(&(globalParams_0->state_0)[_S813 + 3U]);
    float3  wa_1 = float3 {_S817.x, _S817.y, _S817.z};
    uint _S818 = 4U * cb_0;
    float4  _S819 = *(&(globalParams_0->state_0)[_S818]);
    float4  _S820 = *(&(globalParams_0->state_0)[_S818 + 1U]);
    float3  tb_2 = float3 {_S820.x, _S820.y, _S820.z};
    float4  _S821 = *(&(globalParams_0->state_0)[_S818 + 2U]);
    float3  vb_0 = float3 {_S821.x, _S821.y, _S821.z};
    float4  _S822 = *(&(globalParams_0->state_0)[_S818 + 3U]);
    float3  wb_0 = float3 {_S822.x, _S822.y, _S822.z};
    float3  _S823 = to_local_0(i_14, float3 {_S819.x, _S819.y, _S819.z} + cross_0(tb_2, rb_1) - (float3 {_S814.x, _S814.y, _S814.z} + cross_0(ta_2, ra_1)));
    float3  _S824 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S825 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S826 = to_local_0(i_14, wb_0 - wa_1);
    JointBond_0 _S827 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointState_0 _S828 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    bool _S829 = is_damaged_0(&_S828);
    JointBond_0 _S830 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointBond_0 _S831 = _S830;
    JointState_0 _S832 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointResponse_0 _S833 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S827.ids_0.x], &_S831, &_S832, _S823, _S824, dt_8, fracture_2);
    BondStatic_0 * _S834 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    float4  _S835 = __ldg(&_S834->ra_0);
    float3  ra_2 = float3 {_S835.x, _S835.y, _S835.z};
    float4  _S836 = __ldg(&_S834->rb_0);
    float3  rb_2 = float3 {_S836.x, _S836.y, _S836.z};
    JointBond_0 _S837 = slang_ldg_0(&_S834->law_0);
    JointBond_0 _S838 = _S837;
    JointState_0 _S839 = _S833.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S838, &_S839, _S823, &f_lin_1, &f_ang_1);
    float4  _S840 = __ldg(&_S834->c_lin_0);
    float3  qd_lin_0 = _S825 * float3 {_S840.x, _S840.y, _S840.z} * f_lin_1;
    float4  _S841 = __ldg(&_S834->c_ang_0);
    float3  qd_ang_0 = _S826 * float3 {_S841.x, _S841.y, _S841.z} * f_ang_1;
    float3  q_lin_2 = _S833.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S833.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S825) + dot_0(qd_ang_0, _S826)) * dt_8;
    float3  _S842 = to_body_0(i_14, q_lin_2);
    float3  _S843 = to_body_0(i_14, q_ang_2);
    uint _S844 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S844]) = make_float4 (_S842.x, _S842.y, _S842.z, (F32_max((_S833.measures_0.tension_0), (_S833.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S844 + 1U]) = make_float4 ((_S843 + cross_0(ra_2, _S842)).x, (_S843 + cross_0(ra_2, _S842)).y, (_S843 + cross_0(ra_2, _S842)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S844 + 2U]) = make_float4 ((- _S843 + cross_0(rb_2, - _S842)).x, (- _S843 + cross_0(rb_2, - _S842)).y, (- _S843 + cross_0(rb_2, - _S842)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S833.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S833.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S833.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S833.state_1.utilization_0))));
    bool _S845;
    if(!_S829)
    {
        JointState_0 _S846 = _S833.state_1;
        bool _S847 = is_damaged_0(&_S846);
        _S845 = _S847;
    }
    else
    {
        _S845 = false;
    }
    if(_S845)
    {
        _S845 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S845 = false;
    }
    if(_S845)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S833.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S837.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S845 = (_S833.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S845 = false;
    }
    if(_S845)
    {
        _S845 = (_S833.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S845 = false;
    }
    if(_S845)
    {
        float _S848 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S827.ids_0.x], _S833.state_1.life_0);
        _S845 = _S848 <= 0.99000000953674316f;
    }
    else
    {
        _S845 = false;
    }
    if(_S845)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S837.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S833.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S833.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S833.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_4, Rigid_0 * rg_3, float dt_9, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S849 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S850 = make_float3 (0.0f);
    uint _S851 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S851;
    float3  fi_0 = _S850;
    float3  mi_0 = _S850;
    for(;;)
    {
        uint _S852 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S852)
        {
        }
        else
        {
            break;
        }
        uint _S853 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S854 = 3U * (_S853 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S854]);
        if((_S853 & 1U) == 0U)
        {
            float4  _S855 = *(&(globalParams_0->scratch_0)[_S854 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S855.x, _S855.y, _S855.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S856 = *(&(globalParams_0->scratch_0)[_S854 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S856.x, _S856.y, _S856.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S857 = (F32_max((peak_0), (fa_2.w)));
        uint _S858 = e_3 + 1U;
        peak_0 = _S857;
        e_3 = _S858;
    }
    uint _S859 = 4U * c_11;
    float4  _S860 = *(&(globalParams_0->state_0)[_S859]);
    float3  u_0 = float3 {_S860.x, _S860.y, _S860.z};
    uint _S861 = _S859 + 1U;
    float4  _S862 = *(&(globalParams_0->state_0)[_S861]);
    float3  th_1 = float3 {_S862.x, _S862.y, _S862.z};
    uint _S863 = _S859 + 2U;
    float4  _S864 = *(&(globalParams_0->state_0)[_S863]);
    float3  v_9 = float3 {_S864.x, _S864.y, _S864.z};
    uint _S865 = _S859 + 3U;
    float4  _S866 = *(&(globalParams_0->state_0)[_S865]);
    float3  w_5 = float3 {_S866.x, _S866.y, _S866.z};
    float4  _S867 = __ldg(&_S849->center_0);
    float mass_0 = _S867.w;
    float3  _S868 = float3 {_S867.x, _S867.y, _S867.z};
    float4  _S869 = isl_4->com_0;
    float3  _S870 = float3 {_S869.x, _S869.y, _S869.z};
    float3  _S871 = rotate_0(&rg_3->rot_0, _S868 + u_0 - _S870);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_11, c_11, &rg_3->rot_0, step_0, dt_9, contact_3, dt_9, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S872 = f_load_0;
    float4  _S873 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S872 + float3 {_S873.x, _S873.y, _S873.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S874 = rg_3->alpha_0;
        float3  _S875 = rg_3->w_4;
        float3  f_world_2 = f_world_0 - (rg_3->a_7 + cross_0(rg_3->alpha_0, _S871) + cross_0(rg_3->w_4, cross_0(rg_3->w_4, _S871))) * make_float3 (mass_0);
        float4  _S876 = __ldg(&_S849->inertia0_0);
        float4  _S877 = __ldg(&_S849->inertia1_0);
        float4  _S878 = __ldg(&_S849->inertia2_0);
        float3  _S879 = world_mul_0(&rg_3->rot_0, _S876, _S877, _S878, _S874);
        float3  _S880 = world_mul_0(&rg_3->rot_0, _S876, _S877, _S878, _S875);
        float3  t_world_2 = t_world_0 - (_S879 + cross_0(_S875, _S880));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S881 = inverse_rotate_0(&rg_3->rot_0, f_world_1);
    float3  _S882 = inverse_rotate_0(&rg_3->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S883 = inverse_rotate_0(&rg_3->rot_0, rg_3->w_4);
        float3  f_ext_1 = _S881 - cross_0(_S883, v_9) * make_float3 (2.0f * mass_0);
        float4  _S884 = __ldg(&_S849->inertia0_0);
        float4  _S885 = __ldg(&_S849->inertia1_0);
        float4  _S886 = __ldg(&_S849->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S884, _S885, _S886, w_5);
        float3  m_ext_1 = _S882 - (cross_0(_S883, i_w_0) + cross_0(w_5, rows_mul_0(_S884, _S885, _S886, _S883)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S881;
        m_ext_0 = _S882;
    }
    float3  f_13 = f_ext_0 + rep_f_1 + fi_0;
    float3  m_5 = m_ext_0 + rep_m_1 + mi_0;
    uint4  _S887 = __ldg(&_S849->info_0);
    uint support_0 = _S887.x;
    float3  _S888 = make_float3 ((*(&(globalParams_0->state_0)[_S861])).w, (*(&(globalParams_0->state_0)[_S863])).w, (*(&(globalParams_0->state_0)[_S865])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_2;
    float3  v_10;
    float3  w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_13;
        u_1 = u_0;
        th_2 = th_1;
        v_10 = _S850;
        w_6 = _S850;
    }
    else
    {
        float4  _S889 = __ldg(&_S849->inv0_0);
        float4  _S890 = __ldg(&_S849->inv1_0);
        float4  _S891 = __ldg(&_S849->inv2_0);
        float3  _S892 = rows_mul_0(_S889, _S890, _S891, m_5);
        float4  _S893 = __ldg(&_S849->scale_0);
        float3  w_7 = w_5 + _S892 * make_float3 (dt_9 * _S893.z);
        float3  th_3 = th_1 + w_7 * make_float3 (dt_9);
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_2 = _S850;
        }
        else
        {
            float3  v_11 = v_9 + f_13 * make_float3 (dt_9 * _S893.y);
            float3  u_2 = u_0 + v_11 * make_float3 (dt_9);
            reaction_0 = _S888;
            u_1 = u_2;
            th_2 = v_11;
        }
        float3  _S894 = th_2;
        th_2 = th_3;
        v_10 = _S894;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S859]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S861]) = make_float4 (th_2.x, th_2.y, th_2.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S863]) = make_float4 (v_10.x, v_10.y, v_10.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S865]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S895 = rotate_0(&rg_3->rot_0, _S868 + u_1 - _S870);
    float3  _S896 = rg_3->vel_1 + rg_3->vel_err_1 + cross_0(rg_3->w_4, _S895);
    float3  _S897 = rotate_0(&rg_3->rot_0, v_10);
    float3  v_world_0 = _S896 + _S897;
    float3  _S898 = rotate_0(&rg_3->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_3->w_4 + _S898)) * dt_9);
    return;
}

static __device__ float3  turn_difference_0(float3  omega_1, float dt_10, float3  v_12)
{
    float _S899 = length_0(omega_1);
    float angle_3 = _S899 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_14 = omega_1 / make_float3 (_S899);
    float s_6 = (F32_sin((0.5f * angle_3)));
    float3  av_0 = cross_0(a_14, v_12);
    return av_0 * make_float3 ((F32_sin((angle_3)))) + cross_0(a_14, av_0) * make_float3 (2.0f * s_6 * s_6);
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_11)
{
    comp_add_0(&rg_4->l_2, &rg_4->l_err_1, rg_4->torque_0 * make_float3 (dt_11));
    float3  l_3 = rg_4->l_2 + rg_4->l_err_1;
    comp_add_0(&rg_4->vel_1, &rg_4->vel_err_1, rg_4->a_7 * make_float3 (dt_11));
    float3  vel_2 = rg_4->vel_1 + rg_4->vel_err_1;
    float4  _S900 = isl_5->inv0_1;
    float4  _S901 = isl_5->inv1_1;
    float4  _S902 = isl_5->inv2_1;
    Quat_0 _S903 = rg_4->rot_0;
    float3  _S904 = world_mul_0(&_S903, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_3);
    float3  _S905 = vel_2 * make_float3 (dt_11);
    float4  _S906 = isl_5->com_0;
    float3  _S907 = float3 {_S906.x, _S906.y, _S906.z};
    Quat_0 _S908 = rg_4->rot_0;
    float3  _S909 = rotate_0(&_S908, _S907);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S905 - turn_difference_0(_S904, dt_11, _S909));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S904, dt_11);
    Quat_0 _S910 = rg_4->rot_0;
    float3  _S911 = world_mul_0(&_S910, _S900, _S901, _S902, l_3);
    rg_4->w_4 = _S911;
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S912 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S913 = __ldg(&_S912->center_0);
    float _S914 = _S913.w;
    float4  _S915 = __ldg(&_S912->scale_0);
    float m_6 = _S914 * _S915.x;
    uint _S916 = 4U * c_12;
    float4  _S917 = *(&(globalParams_0->state_0)[_S916]);
    *tu_0 = *tu_0 + float3 {_S917.x, _S917.y, _S917.z} * make_float3 (m_6);
    float4  _S918 = *(&(globalParams_0->state_0)[_S916 + 2U]);
    *pv_0 = *pv_0 + float3 {_S918.x, _S918.y, _S918.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S919 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S920 = __ldg(&_S919->center_0);
    float3  r_9 = float3 {_S920.x, _S920.y, _S920.z} - wcom_1;
    float4  _S921 = __ldg(&_S919->scale_0);
    float kw_0 = _S921.x;
    uint _S922 = 4U * c_13;
    float4  _S923 = *(&(globalParams_0->state_0)[_S922]);
    float _S924 = _S920.w;
    float3  _S925 = cross_0(r_9, float3 {_S923.x, _S923.y, _S923.z} - tr_0) * make_float3 (_S924);
    float4  _S926 = __ldg(&_S919->inertia0_0);
    float4  _S927 = __ldg(&_S919->inertia1_0);
    float4  _S928 = __ldg(&_S919->inertia2_0);
    float4  _S929 = *(&(globalParams_0->state_0)[_S922 + 1U]);
    *lu_0 = *lu_0 + (_S925 + rows_mul_0(_S926, _S927, _S928, float3 {_S929.x, _S929.y, _S929.z})) * make_float3 (kw_0);
    float4  _S930 = *(&(globalParams_0->state_0)[_S922 + 2U]);
    float4  _S931 = *(&(globalParams_0->state_0)[_S922 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S930.x, _S930.y, _S930.z} - dv_0) * make_float3 (_S924) + rows_mul_0(_S926, _S927, _S928, float3 {_S931.x, _S931.y, _S931.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S932 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S932.x, _S932.y, _S932.z} - wcom_2;
    uint _S933 = 4U * c_14;
    float4  _S934 = *(&(globalParams_0->state_0)[_S933]);
    *(&(globalParams_0->state_0)[_S933]) = make_float4 ((float3 {_S934.x, _S934.y, _S934.z} - (tr_1 + cross_0(phi_0, r_10))).x, (float3 {_S934.x, _S934.y, _S934.z} - (tr_1 + cross_0(phi_0, r_10))).y, (float3 {_S934.x, _S934.y, _S934.z} - (tr_1 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S933])).w);
    uint _S935 = _S933 + 1U;
    float4  _S936 = *(&(globalParams_0->state_0)[_S935]);
    *(&(globalParams_0->state_0)[_S935]) = make_float4 ((float3 {_S936.x, _S936.y, _S936.z} - phi_0).x, (float3 {_S936.x, _S936.y, _S936.z} - phi_0).y, (float3 {_S936.x, _S936.y, _S936.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S935])).w);
    uint _S937 = _S933 + 2U;
    float4  _S938 = *(&(globalParams_0->state_0)[_S937]);
    *(&(globalParams_0->state_0)[_S937]) = make_float4 ((float3 {_S938.x, _S938.y, _S938.z} - (dv_1 + cross_0(dw_0, r_10))).x, (float3 {_S938.x, _S938.y, _S938.z} - (dv_1 + cross_0(dw_0, r_10))).y, (float3 {_S938.x, _S938.y, _S938.z} - (dv_1 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S937])).w);
    uint _S939 = _S933 + 3U;
    float4  _S940 = *(&(globalParams_0->state_0)[_S939]);
    *(&(globalParams_0->state_0)[_S939]) = make_float4 ((float3 {_S940.x, _S940.y, _S940.z} - dw_0).x, (float3 {_S940.x, _S940.y, _S940.z} - dw_0).y, (float3 {_S940.x, _S940.y, _S940.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S939])).w);
    return;
}

static __device__ void turn_right_0(Quat_0 * hi_3, float4  * lo_3, float3  phi_1)
{
    float angle_4 = length_0(phi_1);
    if(angle_4 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_11 = turn_minus_one_0(phi_1 / make_float3 (angle_4), angle_4);
    Quat_0 dq_1;
    (&dq_1)->x_11 = d_11.x;
    (&dq_1)->y_4 = d_11.y;
    (&dq_1)->z_0 = d_11.z;
    (&dq_1)->w_1 = d_11.w;
    Quat_0 _S941 = *hi_3;
    Quat_0 _S942 = dq_1;
    Quat_0 _S943 = quat_mul_0(&_S941, &_S942);
    Quat_0 _S944 = _S943;
    float4  _S945 = quat_vec_0(&_S944);
    quat_accumulate_0(hi_3, lo_3, _S945);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_6, Rigid_0 * rg_5, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S946 = isl_6->wcom_0;
    float3  wcom_3 = float3 {_S946.x, _S946.y, _S946.z};
    Quat_0 rot_2 = rg_5->rot_0;
    float3  _S947 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S948 = rg_5->rot_0;
    float3  _S949 = rotate_0(&_S948, _S947);
    comp_add_0(&rg_5->pos_1, &rg_5->pos_err_1, _S949);
    Quat_0 _S950 = rg_5->rot_0;
    float3  _S951 = inverse_rotate_0(&_S950, rg_5->w_4);
    float4  _S952 = isl_6->inertia0_1;
    float4  _S953 = isl_6->inertia1_1;
    float4  _S954 = isl_6->inertia2_1;
    float3  _S955 = cross_0(phi_2, rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, _S951)) - rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, cross_0(phi_2, _S951));
    Quat_0 _S956 = rg_5->rot_0;
    float3  _S957 = rotate_0(&_S956, _S955);
    turn_right_0(&rg_5->rot_0, &rg_5->rot_err_0, phi_2);
    float4  _S958 = isl_6->com_0;
    float3  _S959 = dv_2 + cross_0(dw_1, float3 {_S958.x, _S958.y, _S958.z} - wcom_3);
    Quat_0 _S960 = rot_2;
    float3  _S961 = rotate_0(&_S960, _S959);
    comp_add_0(&rg_5->vel_1, &rg_5->vel_err_1, _S961);
    Quat_0 _S962 = rot_2;
    float3  _S963 = rotate_0(&_S962, dw_1);
    rg_5->w_4 = rg_5->w_4 + _S963;
    Quat_0 _S964 = rg_5->rot_0;
    float3  _S965 = world_mul_0(&_S964, _S952, _S953, _S954, _S963);
    comp_add_0(&rg_5->l_2, &rg_5->l_err_1, _S957 + _S965);
    return;
}

static __device__ void write_probe_0(uint slot_0, uint k_16, float value_1)
{
    uint _S966 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S967 = _S966 * 4U;
    uint _S968 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S967 + slot_0 * _S968 + k_16;
    float4  v_13 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_13, at_4 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_13;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_7, Rigid_0 * rg_6, uint k_17)
{
    uint4  _S969 = isl_7->probes_0;
    uint at_5 = isl_7->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S969.y))
        {
        }
        else
        {
            break;
        }
        float4  _S970 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_3 = asuint_0(_S970);
        float4  _S971 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S972 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S973 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_4 = info_3.x;
        uint i_15 = info_3.y;
        float value_2;
        if(kind_4 == 0U)
        {
            float4  _S974 = *(&(globalParams_0->state_0)[4U * i_15]);
            float3  small_0 = float3 {_S974.x, _S974.y, _S974.z} + make_float3 (_S971.w, _S972.w, _S973.w);
            float3  _S975 = rg_6->pos_1 - float3 {_S972.x, _S972.y, _S972.z};
            float4  _S976 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
            float3  _S977 = rotate_0(&rg_6->rot_0, float3 {_S976.x, _S976.y, _S976.z});
            float3  _S978 = _S975 + _S977;
            float3  _S979 = rg_6->pos_err_1 - float3 {_S973.x, _S973.y, _S973.z};
            float3  _S980 = rotate_0(&rg_6->rot_0, small_0);
            value_2 = dot_0(_S978 + (_S979 + _S980), float3 {_S971.x, _S971.y, _S971.z});
        }
        else
        {
            if(kind_4 == 1U)
            {
                float4  _S981 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
                uint _S982 = 4U * i_15;
                float4  _S983 = *(&(globalParams_0->state_0)[_S982]);
                float4  _S984 = isl_7->com_0;
                float3  _S985 = rotate_0(&rg_6->rot_0, float3 {_S981.x, _S981.y, _S981.z} + float3 {_S983.x, _S983.y, _S983.z} - float3 {_S984.x, _S984.y, _S984.z});
                float3  _S986 = rg_6->vel_1 + rg_6->vel_err_1 + cross_0(rg_6->w_4, _S985);
                float4  _S987 = *(&(globalParams_0->state_0)[_S982 + 2U]);
                float3  _S988 = rotate_0(&rg_6->rot_0, float3 {_S987.x, _S987.y, _S987.z});
                value_2 = dot_0(_S986 + _S988, float3 {_S971.x, _S971.y, _S971.z});
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S989 = 3U * i_15;
                    float4  _S990 = *(&(globalParams_0->scratch_0)[_S989]);
                    float3  f_14 = float3 {_S990.x, _S990.y, _S990.z};
                    bool _S991 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S991)
                    {
                        float4  _S992 = *(&(globalParams_0->scratch_0)[_S989 + 1U]);
                        mc_0 = float3 {_S992.x, _S992.y, _S992.z};
                    }
                    else
                    {
                        float4  _S993 = *(&(globalParams_0->scratch_0)[_S989 + 2U]);
                        mc_0 = float3 {_S993.x, _S993.y, _S993.z};
                    }
                    float3  fc_3;
                    if(_S991)
                    {
                        fc_3 = f_14;
                    }
                    else
                    {
                        fc_3 = - f_14;
                    }
                    value_2 = dot_0(fc_3, float3 {_S971.x, _S971.y, _S971.z}) + dot_0(mc_0, float3 {_S972.x, _S972.y, _S972.z});
                }
                else
                {
                    uint _S994 = 4U * i_15;
                    float3  _S995 = rotate_0(&rg_6->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S994 + 1U])).w, (*(&(globalParams_0->state_0)[_S994 + 2U])).w, (*(&(globalParams_0->state_0)[_S994 + 3U])).w));
                    value_2 = dot_0(_S995, float3 {_S971.x, _S971.y, _S971.z});
                }
            }
        }
        write_probe_0(info_3.w, k_17, value_2);
        at_5 = at_5 + 4U;
    }
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S996 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S996])->info_1.y;
    uint _S997 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S998;
    if(previous_1 == 0U)
    {
        _S998 = at_6;
    }
    else
    {
        _S998 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S997])->info_1)->y) = _S998;
    return;
}

static __device__ uint seen_bits_0()
{
    uint _S999;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S999 = 32768U;
    }
    else
    {
        _S999 = 0U;
    }
    uint _S1000;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S1000 = 65536U;
    }
    else
    {
        _S1000 = 0U;
    }
    uint _S1001 = _S999 | _S1000;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S999 = 131072U;
    }
    else
    {
        _S999 = 0U;
    }
    uint _S1002 = _S1001 | _S999;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S999 = 32U;
    }
    else
    {
        _S999 = 0U;
    }
    uint _S1003 = _S1002 | _S999;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S999 = 64U;
    }
    else
    {
        _S999 = 0U;
    }
    return _S1003 | _S999;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S1004;
    uint _S1005;
    uint _S1006;
    uint _S1007;
    uint _S1008;
    uint _S1009;
    uint _S1010 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S1011 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S1011]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S1012 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S1013 = __ballot_sync(_S1010, _S1012);
    bool _S1014;
    uint cov_0;
    if(_S1012)
    {
        bool _S1015 = !driven_0;
        uint _S1016 = __ballot_sync(_S1010, true);
        _S1014 = _S1015;
        cov_0 = _S1016;
    }
    else
    {
        uint _S1017 = __ballot_sync(_S1010, true);
        _S1014 = false;
        cov_0 = _S1017;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S1018 = (((&isl_8)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_5);
    bool _S1019 = tid_5 == 0U;
    uint _S1020 = __ballot_sync(cov_0, _S1019);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1019)
    {
        uint _S1021 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1022 = contact_island_0 != (_S1021 == 1U);
        uint _S1023 = __ballot_sync(_S1020, _S1022);
        if(_S1022)
        {
            uint _S1024 = __ballot_sync(_S1020, true);
            settled_0 = true;
            run_0 = _S1024;
        }
        else
        {
            bool _S1025 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1026 = __ballot_sync(_S1020, true);
            settled_0 = _S1025;
            run_0 = _S1026;
        }
        uint _S1027 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1028 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1028;
        }
        else
        {
            uint _S1029 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1029;
        }
        uint _S1030 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1031 = isl_8;
            bool _S1032 = contact_stopped_0(&_S1031);
            uint _S1033 = __ballot_sync(done_1, true);
            settled_0 = _S1032;
            done_1 = _S1033;
        }
        else
        {
            uint _S1034 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1034;
        }
        uint _S1035 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1036 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1037 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1038 = __ballot_sync(cov_0, true);
        cov_0 = _S1038;
    }
    else
    {
        uint _S1039 = __ballot_sync(cov_0, true);
        cov_0 = _S1039;
    }
    __syncthreads();
    bool _S1040 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1041 = __ballot_sync(cov_0, _S1040);
    if(_S1040)
    {
        uint _S1042 = __ballot_sync(cov_0, true);
        settled_0 = true;
        cov_0 = _S1042;
    }
    else
    {
        bool _S1043 = (*&g_run_0) == 0U;
        uint _S1044 = __ballot_sync(cov_0, true);
        settled_0 = _S1043;
        cov_0 = _S1044;
    }
    uint _S1045 = __ballot_sync(cov_0, settled_0);
    if(settled_0)
    {
        uint _S1046 = __ballot_sync(cov_0, true);
        cov_0 = 0U;
        run_0 = _S1046;
    }
    else
    {
        uint _S1047 = (&isl_8)->info_1.y;
        uint _S1048 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1049 = (U32_min((_S1047), (_S1048)));
        uint _S1050 = __ballot_sync(cov_0, true);
        cov_0 = _S1049;
        run_0 = _S1050;
    }
    float _S1051 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1052 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1053 = _S1052 != 0U;
    uint _S1054 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1055 = _S1054 != 0U;
    Island_0 _S1056 = isl_8;
    Rigid_0 _S1057 = rigid_of_0(&_S1056);
    Rigid_0 rg_7 = _S1057;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1018;
    done_1 = 0U;
    bool woke_1 = false;
    uint _S1058 = run_0;
    for(;;)
    {
        uint _S1059 = 0U;
        bool _S1060 = done_1 < cov_0;
        uint _S1061 = __ballot_sync(_S1058, _S1060);
        if(_S1060)
        {
            uint _S1062 = __ballot_sync(_S1058, true);
            _S1059 = _S1062;
        }
        else
        {
            uint _S1063 = __ballot_sync(_S1058, false);
            uint _S1064 = __ballot_sync(_S1058, false);
            uint _S1065 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_0 = _S1065;
            break;
        }
        uint abs_step_1 = (&isl_8)->info_1.w + done_1 + 1U;
        uint _S1066 = abs_step_1 - 1U;
        uint _S1067 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1066 - _S1067;
        bool quiet_0 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1068 = __ballot_sync(_S1059, settled_0);
        bool _S1069;
        uint _S1070;
        if(settled_0)
        {
            bool _S1071 = !quiet_0;
            uint _S1072 = __ballot_sync(_S1059, true);
            _S1069 = _S1071;
            _S1070 = _S1072;
        }
        else
        {
            uint _S1073 = __ballot_sync(_S1059, true);
            _S1069 = false;
            _S1070 = _S1073;
        }
        uint _S1074 = __ballot_sync(_S1070, _S1069);
        bool _S1075;
        bool explicit_step_0;
        uint c_15;
        uint _S1076;
        uint c_16;
        if(_S1069)
        {
            float3  _S1077 = make_float3 (0.0f);
            float3  norm_0 = _S1077;
            float3  unused0_0 = _S1077;
            c_15 = (&isl_8)->range_0.x + tid_5;
            _S1076 = _S1074;
            for(;;)
            {
                bool _S1078 = c_15 < ((&isl_8)->range_0.y);
                uint _S1079 = __ballot_sync(_S1076, _S1078);
                if(_S1078)
                {
                    uint _S1080 = __ballot_sync(_S1076, true);
                }
                else
                {
                    uint _S1081 = __ballot_sync(_S1076, false);
                    uint _S1082 = __ballot_sync(_S1076, false);
                    uint _S1083 = __ballot_sync(_S1074, true);
                    _S1004 = _S1083;
                    break;
                }
                Quat_0 _S1084 = (&rg_7)->rot_0;
                float _S1085 = settled_chunk_load_0(c_15, &_S1084, k_18, _S1051, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1085;
                uint _S1086 = __ballot_sync(_S1076, true);
                c_15 = c_15 + 256U;
                _S1076 = _S1086;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, _S1004);
            uint _S1087 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1088 = _S1087 == 1U;
            uint _S1089 = __ballot_sync(_S1004, _S1088);
            if(_S1088)
            {
                bool _S1090 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1091 = __ballot_sync(_S1004, true);
                _S1075 = _S1090;
                c_16 = _S1091;
            }
            else
            {
                uint _S1092 = __ballot_sync(_S1004, true);
                _S1075 = false;
                c_16 = _S1092;
            }
            uint _S1093 = __ballot_sync(c_16, _S1075);
            if(_S1075)
            {
                uint _S1094 = __ballot_sync(c_16, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1095 = __ballot_sync(c_16, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1096 = __ballot_sync(_S1070, true);
            settled_0 = explicit_step_0;
            c_15 = _S1096;
        }
        else
        {
            uint _S1097 = __ballot_sync(_S1070, true);
            woke_0 = woke_1;
            c_15 = _S1097;
        }
        uint _S1098 = __ballot_sync(c_15, _S1012);
        if(_S1012)
        {
            bool _S1099 = !quiet_0;
            uint _S1100 = __ballot_sync(c_15, true);
            _S1075 = _S1099;
            _S1076 = _S1100;
        }
        else
        {
            uint _S1101 = __ballot_sync(c_15, true);
            _S1075 = false;
            _S1076 = _S1101;
        }
        uint _S1102 = __ballot_sync(_S1076, _S1075);
        uint _S1103;
        if(_S1075)
        {
            float3  _S1104 = make_float3 (0.0f);
            float3  f_15 = _S1104;
            float3  t_12 = _S1104;
            c_16 = (&isl_8)->range_0.x + tid_5;
            _S1103 = _S1102;
            for(;;)
            {
                bool _S1105 = c_16 < ((&isl_8)->range_0.y);
                uint _S1106 = __ballot_sync(_S1103, _S1105);
                if(_S1105)
                {
                    uint _S1107 = __ballot_sync(_S1103, true);
                }
                else
                {
                    uint _S1108 = __ballot_sync(_S1103, false);
                    uint _S1109 = __ballot_sync(_S1103, false);
                    uint _S1110 = __ballot_sync(_S1102, true);
                    _S1005 = _S1110;
                    break;
                }
                Island_0 _S1111 = isl_8;
                Rigid_0 _S1112 = rg_7;
                net_load_0(c_16, &_S1111, &_S1112, k_18, _S1051, contact_island_0, &f_15, &t_12);
                uint _S1113 = __ballot_sync(_S1103, true);
                c_16 = c_16 + 256U;
                _S1103 = _S1113;
            }
            group_sum3_0(tid_5, &f_15, &t_12, _S1005);
            Island_0 _S1114 = isl_8;
            rigid_acceleration_0(&_S1114, &rg_7, f_15, t_12);
            uint _S1115 = __ballot_sync(_S1076, true);
            c_16 = _S1115;
        }
        else
        {
            uint _S1116 = __ballot_sync(_S1076, true);
            c_16 = _S1116;
        }
        bool _S1117 = !settled_0;
        uint _S1118 = __ballot_sync(c_16, _S1117);
        if(_S1117)
        {
            bool _S1119 = !quiet_0;
            uint _S1120 = __ballot_sync(c_16, true);
            explicit_step_0 = _S1119;
            _S1103 = _S1120;
        }
        else
        {
            uint _S1121 = __ballot_sync(c_16, true);
            explicit_step_0 = false;
            _S1103 = _S1121;
        }
        uint _S1122 = __ballot_sync(_S1103, explicit_step_0);
        uint i_16;
        uint _S1123;
        uint c_17;
        uint _S1124;
        if(explicit_step_0)
        {
            i_16 = (&isl_8)->range_0.z + tid_5;
            _S1123 = _S1122;
            for(;;)
            {
                uint _S1125 = 0U;
                bool _S1126 = i_16 < ((&isl_8)->range_0.w);
                uint _S1127 = __ballot_sync(_S1123, _S1126);
                if(_S1126)
                {
                    uint _S1128 = __ballot_sync(_S1123, true);
                    _S1125 = _S1128;
                }
                else
                {
                    uint _S1129 = __ballot_sync(_S1123, false);
                    uint _S1130 = __ballot_sync(_S1123, false);
                    uint _S1131 = __ballot_sync(_S1122, true);
                    _S1006 = _S1131;
                    break;
                }
                bool _S1132 = bond_update_0(i_16, _S1051, _S1053, abs_step_1, false);
                uint _S1133 = __ballot_sync(_S1125, _S1132);
                if(_S1132)
                {
                    *&g_halt_0 = 1U;
                    uint _S1134 = __ballot_sync(_S1125, true);
                }
                else
                {
                    uint _S1135 = __ballot_sync(_S1125, true);
                }
                uint _S1136 = __ballot_sync(_S1123, true);
                i_16 = i_16 + 256U;
                _S1123 = _S1136;
            }
            __syncthreads();
            c_17 = (&isl_8)->range_0.x + tid_5;
            _S1124 = _S1006;
            for(;;)
            {
                bool _S1137 = c_17 < ((&isl_8)->range_0.y);
                uint _S1138 = __ballot_sync(_S1124, _S1137);
                if(_S1137)
                {
                    uint _S1139 = __ballot_sync(_S1124, true);
                }
                else
                {
                    uint _S1140 = __ballot_sync(_S1124, false);
                    uint _S1141 = __ballot_sync(_S1124, false);
                    uint _S1142 = __ballot_sync(_S1006, true);
                    break;
                }
                Island_0 _S1143 = isl_8;
                Rigid_0 _S1144 = rg_7;
                chunk_update_0(c_17, &_S1143, &_S1144, _S1051, _S1055, k_18, contact_island_0, &work_2, &work_err_1);
                uint _S1145 = __ballot_sync(_S1124, true);
                c_17 = c_17 + 256U;
                _S1124 = _S1145;
            }
            __syncthreads();
            uint _S1146 = __ballot_sync(_S1103, true);
            i_16 = _S1146;
        }
        else
        {
            uint _S1147 = __ballot_sync(_S1103, true);
            i_16 = _S1147;
        }
        uint _S1148 = __ballot_sync(i_16, _S1014);
        bool _S1149;
        if(_S1014)
        {
            bool _S1150 = !quiet_0;
            uint _S1151 = __ballot_sync(i_16, true);
            _S1149 = _S1150;
            _S1123 = _S1151;
        }
        else
        {
            uint _S1152 = __ballot_sync(i_16, true);
            _S1149 = false;
            _S1123 = _S1152;
        }
        uint _S1153 = __ballot_sync(_S1123, _S1149);
        if(_S1149)
        {
            Island_0 _S1154 = isl_8;
            integrate_rigid_0(&_S1154, &rg_7, _S1051);
            uint _S1155 = __ballot_sync(_S1123, true);
            c_17 = _S1155;
        }
        else
        {
            uint _S1156 = __ballot_sync(_S1123, true);
            c_17 = _S1156;
        }
        uint _S1157 = __ballot_sync(c_17, _S1012);
        bool _S1158;
        if(_S1012)
        {
            uint _S1159 = __ballot_sync(c_17, true);
            _S1158 = explicit_step_0;
            _S1124 = _S1159;
        }
        else
        {
            uint _S1160 = __ballot_sync(c_17, true);
            _S1158 = false;
            _S1124 = _S1160;
        }
        uint _S1161 = __ballot_sync(_S1124, _S1158);
        uint c_18;
        uint _S1162;
        uint c_19;
        if(_S1158)
        {
            float4  _S1163 = (&isl_8)->wcom_0;
            float3  _S1164 = float3 {_S1163.x, _S1163.y, _S1163.z};
            float3  _S1165 = make_float3 (0.0f);
            float3  tu_1 = _S1165;
            float3  pv_1 = _S1165;
            c_18 = (&isl_8)->range_0.x + tid_5;
            _S1162 = _S1161;
            for(;;)
            {
                bool _S1166 = c_18 < ((&isl_8)->range_0.y);
                uint _S1167 = __ballot_sync(_S1162, _S1166);
                if(_S1166)
                {
                    uint _S1168 = __ballot_sync(_S1162, true);
                }
                else
                {
                    uint _S1169 = __ballot_sync(_S1162, false);
                    uint _S1170 = __ballot_sync(_S1162, false);
                    uint _S1171 = __ballot_sync(_S1161, true);
                    _S1007 = _S1171;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1172 = __ballot_sync(_S1162, true);
                c_18 = c_18 + 256U;
                _S1162 = _S1172;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, _S1007);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1165;
            float3  lv_1 = _S1165;
            c_19 = (&isl_8)->range_0.x + tid_5;
            uint _S1173 = _S1007;
            for(;;)
            {
                bool _S1174 = c_19 < ((&isl_8)->range_0.y);
                uint _S1175 = __ballot_sync(_S1173, _S1174);
                if(_S1174)
                {
                    uint _S1176 = __ballot_sync(_S1173, true);
                }
                else
                {
                    uint _S1177 = __ballot_sync(_S1173, false);
                    uint _S1178 = __ballot_sync(_S1173, false);
                    uint _S1179 = __ballot_sync(_S1007, true);
                    _S1008 = _S1179;
                    break;
                }
                drift_angular_0(c_19, _S1164, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1180 = __ballot_sync(_S1173, true);
                c_19 = c_19 + 256U;
                _S1173 = _S1180;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, _S1008);
            float3  phi_3 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_5;
            uint _S1181 = _S1008;
            for(;;)
            {
                bool _S1182 = c_20 < ((&isl_8)->range_0.y);
                uint _S1183 = __ballot_sync(_S1181, _S1182);
                if(_S1182)
                {
                    uint _S1184 = __ballot_sync(_S1181, true);
                }
                else
                {
                    uint _S1185 = __ballot_sync(_S1181, false);
                    uint _S1186 = __ballot_sync(_S1181, false);
                    uint _S1187 = __ballot_sync(_S1008, true);
                    _S1009 = _S1187;
                    break;
                }
                drift_apply_0(c_20, _S1164, tr_3, phi_3, dv_3, dw_2);
                uint _S1188 = __ballot_sync(_S1181, true);
                c_20 = c_20 + 256U;
                _S1181 = _S1188;
            }
            bool _S1189 = !driven_0;
            uint _S1190 = __ballot_sync(_S1009, _S1189);
            if(_S1189)
            {
                Island_0 _S1191 = isl_8;
                drift_rigid_0(&_S1191, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S1192 = __ballot_sync(_S1009, true);
            }
            else
            {
                uint _S1193 = __ballot_sync(_S1009, true);
            }
            __syncthreads();
            uint _S1194 = __ballot_sync(_S1124, true);
            c_18 = _S1194;
        }
        else
        {
            uint _S1195 = __ballot_sync(_S1124, true);
            c_18 = _S1195;
        }
        uint _S1196 = __ballot_sync(c_18, _S1019);
        bool _S1197;
        if(_S1019)
        {
            bool _S1198 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1199 = __ballot_sync(c_18, true);
            _S1197 = _S1198;
            _S1162 = _S1199;
        }
        else
        {
            uint _S1200 = __ballot_sync(c_18, true);
            _S1197 = false;
            _S1162 = _S1200;
        }
        uint _S1201 = __ballot_sync(_S1162, _S1197);
        if(_S1197)
        {
            Island_0 _S1202 = isl_8;
            Rigid_0 _S1203 = rg_7;
            record_probes_0(&_S1202, &_S1203, k_18);
            uint _S1204 = __ballot_sync(_S1162, true);
            c_19 = _S1204;
        }
        else
        {
            uint _S1205 = __ballot_sync(_S1162, true);
            c_19 = _S1205;
        }
        uint _S1206 = done_1 + 1U;
        bool _S1207 = (*&g_halt_0) != 0U;
        uint _S1208 = __ballot_sync(c_19, _S1207);
        if(_S1207)
        {
            uint _S1209 = __ballot_sync(c_19, false);
            uint _S1210 = __ballot_sync(_S1058, false);
            uint _S1211 = __ballot_sync(run_0, true);
            done_1 = _S1206;
            cov_0 = _S1211;
            break;
        }
        else
        {
            uint _S1212 = __ballot_sync(c_19, true);
        }
        uint _S1213 = __ballot_sync(_S1058, true);
        done_1 = _S1206;
        woke_1 = woke_0;
        _S1058 = _S1213;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_5, &wsum_0, &unused_1, cov_0);
    uint _S1214 = __ballot_sync(cov_0, _S1019);
    if(_S1019)
    {
        Quat_0 _S1215 = (&rg_7)->rot_0;
        float4  _S1216 = quat_vec_0(&_S1215);
        (&isl_8)->rotation_0 = _S1216;
        (&isl_8)->rotation_err_0 = (&rg_7)->rot_err_0;
        (&isl_8)->position_0 = make_float4 ((&rg_7)->pos_1.x, (&rg_7)->pos_1.y, (&rg_7)->pos_1.z, 0.0f);
        (&isl_8)->position_err_0 = make_float4 ((&rg_7)->pos_err_1.x, (&rg_7)->pos_err_1.y, (&rg_7)->pos_err_1.z, 0.0f);
        (&isl_8)->velocity_0 = make_float4 ((&rg_7)->vel_1.x, (&rg_7)->vel_1.y, (&rg_7)->vel_1.z, 0.0f);
        (&isl_8)->velocity_err_0 = make_float4 ((&rg_7)->vel_err_1.x, (&rg_7)->vel_err_1.y, (&rg_7)->vel_err_1.z, 0.0f);
        (&isl_8)->angular_velocity_0 = make_float4 ((&rg_7)->w_4.x, (&rg_7)->w_4.y, (&rg_7)->w_4.z, 0.0f);
        (&isl_8)->momentum_0 = make_float4 ((&rg_7)->l_2.x, (&rg_7)->l_2.y, (&rg_7)->l_2.z, 0.0f);
        (&isl_8)->momentum_err_0 = make_float4 ((&rg_7)->l_err_1.x, (&rg_7)->l_err_1.y, (&rg_7)->l_err_1.z, 0.0f);
        (&isl_8)->done_0 = done_1;
        *&((&(&isl_8)->info_1)->y) = *&((&(&isl_8)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S1014 = contact_island_0;
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            contact_split_at_0((&isl_8)->info_1.w + done_1);
        }
        comp_add1_0(&((&(&isl_8)->energy_1)->x), &((&(&isl_8)->energy_1)->y), wsum_0.x);
        *&((&(&isl_8)->energy_1)->y) = *&((&(&isl_8)->energy_1)->y) + wsum_0.y;
        *&((&(&isl_8)->info_1)->w) = *&((&(&isl_8)->info_1)->w) + done_1;
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_8)->info_1)->z) = (*&((&(&isl_8)->info_1)->z)) | 1U;
        }
        uint _S1217 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1218 = _S1217 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1218 | cov_0;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_8)->info_1.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_0 = 4096U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_2 = cov_1 | cov_0;
            if((((&isl_8)->info_1.x) & 16U) != 0U)
            {
                _S1014 = !quiet_1;
            }
            else
            {
                _S1014 = false;
            }
            if(_S1014)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            uint _S1219 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S1219 == 1U)
            {
                cov_0 = 524288U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_4 = cov_3 | cov_0;
            if(((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x))
            {
                cov_0 = 262144U;
            }
            else
            {
                cov_0 = 0U;
            }
            cov_0 = cov_4 | cov_0;
        }
        else
        {
            cov_0 = cov_1;
        }
        (&isl_8)->coverage_0 = ((&isl_8)->coverage_0) | cov_0;
        if(woke_0)
        {
            *&((&(&isl_8)->info_1)->x) = (*&((&(&isl_8)->info_1)->x)) & 4294967279U;
            *&((&(&isl_8)->info_1)->z) = (*&((&(&isl_8)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[_S1011]) = isl_8;
    }
    return;
}

struct WideGroup_0
{
    uint island_2;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_3)
{
    WideGroup_0 w_8;
    uint _S1220 = table_0 + 4U * g_3;
    uint _S1221 = __ldg((&(globalParams_0->index_0)[_S1220]));
    (&w_8)->island_2 = _S1221;
    uint _S1222 = __ldg((&(globalParams_0->index_0)[_S1220 + 1U]));
    (&w_8)->begin_0 = _S1222;
    uint _S1223 = __ldg((&(globalParams_0->index_0)[_S1220 + 2U]));
    (&w_8)->end_0 = _S1223;
    uint _S1224 = __ldg((&(globalParams_0->index_0)[_S1220 + 3U]));
    (&w_8)->first_0 = _S1224;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1225 = isl_9->info_1;
    bool _S1226;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1226 = true;
    }
    else
    {
        _S1226 = (_S1225.y) == 0U;
    }
    if(_S1226)
    {
        return false;
    }
    if(((_S1225.x) & 4U) == 0U)
    {
        _S1226 = true;
    }
    else
    {
        bool _S1227 = contact_stopped_0(isl_9);
        _S1226 = !_S1227;
    }
    return _S1226;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_6, Island_0 * isl_10)
{
    seen_clear_0(tid_6);
    if(tid_6 == 0U)
    {
        bool _S1228 = wide_runs_0(isl_10);
        int _S1229;
        if(_S1228)
        {
            _S1229 = int(1);
        }
        else
        {
            _S1229 = int(0);
        }
        *&g_wide_run_0 = uint(_S1229);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1230 = isl_11->info_1.w;
    uint _S1231 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1230 - _S1231;
}

static __device__ bool wide_enter_1(uint _S1232, uint _S1233)
{
    Island_0 _S1234 = *(&(globalParams_0->islands_0)[_S1233]);
    seen_clear_0(_S1232);
    if(_S1232 == 0U)
    {
        Island_0 _S1235 = _S1234;
        bool _S1236 = wide_runs_0(&_S1235);
        int _S1237;
        if(_S1236)
        {
            _S1237 = int(1);
        }
        else
        {
            _S1237 = int(0);
        }
        *&g_wide_run_0 = uint(_S1237);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1238 = 0U;
    uint _S1239;
    uint _S1240 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1241 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1242 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1241, _S1242);
    bool _S1243 = _S1242 != (wg_0.first_0);
    uint _S1244 = __ballot_sync(_S1240, _S1243);
    if(_S1243)
    {
        return;
    }
    else
    {
        uint _S1245 = __ballot_sync(_S1240, true);
        _S1238 = _S1245;
    }
    Island_0 * _S1246 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_12 = *_S1246;
    uint _S1247 = (*_S1246).info_1.x;
    bool _S1248 = (_S1247 & 16U) == 0U;
    uint _S1249 = __ballot_sync(_S1238, _S1248);
    bool _S1250;
    uint c_21;
    if(_S1248)
    {
        uint _S1251 = __ballot_sync(_S1238, true);
        _S1250 = true;
        c_21 = _S1251;
    }
    else
    {
        bool _S1252 = wide_enter_1(tid_7, wg_0.island_2);
        bool _S1253 = !_S1252;
        uint _S1254 = __ballot_sync(_S1238, true);
        _S1250 = _S1253;
        c_21 = _S1254;
    }
    uint _S1255 = 0U;
    uint _S1256 = __ballot_sync(c_21, _S1250);
    if(_S1250)
    {
        return;
    }
    else
    {
        uint _S1257 = __ballot_sync(c_21, true);
        _S1255 = _S1257;
    }
    Quat_0 _S1258 = quat_of_0(isl_12.rotation_0);
    bool _S1259 = (_S1247 & 4U) != 0U;
    float3  _S1260 = make_float3 (0.0f);
    float3  norm_1 = _S1260;
    float3  unused_2 = _S1260;
    c_21 = isl_12.range_0.x + tid_7;
    uint cov_5;
    cov_5 = _S1255;
    for(;;)
    {
        bool _S1261 = c_21 < (isl_12.range_0.y);
        uint _S1262 = __ballot_sync(cov_5, _S1261);
        if(_S1261)
        {
            uint _S1263 = __ballot_sync(cov_5, true);
        }
        else
        {
            uint _S1264 = __ballot_sync(cov_5, false);
            uint _S1265 = __ballot_sync(cov_5, false);
            uint _S1266 = __ballot_sync(_S1255, true);
            _S1239 = _S1266;
            break;
        }
        Island_0 _S1267 = isl_12;
        uint _S1268 = wide_step_0(&_S1267);
        float _S1269 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1270 = _S1258;
        float _S1271 = settled_chunk_load_0(c_21, &_S1270, _S1268, _S1269, _S1259);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1271;
        uint _S1272 = __ballot_sync(cov_5, true);
        c_21 = c_21 + 256U;
        cov_5 = _S1272;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, _S1239);
    bool _S1273 = tid_7 != 0U;
    uint _S1274 = __ballot_sync(_S1239, _S1273);
    if(_S1273)
    {
        return;
    }
    uint cov_6 = 1024U | (seen_bits_0());
    uint _S1275 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S1275 == 1U)
    {
        _S1250 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1250 = false;
    }
    if(_S1250)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S1247 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->z) = (isl_12.info_1.z) | 4U;
        cov_5 = cov_6 | 2048U;
    }
    else
    {
        cov_5 = cov_6;
    }
    cov_mark_0(wg_0.island_2, isl_12.coverage_0, cov_5);
    return;
}

static __device__ void wide_store_0(uint slot_1, uint p_12, float3  a_15, float3  b_30)
{
    uint _S1276 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1277 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1276 + _S1277 + p_12]) = make_float4 (a_15.x, a_15.y, a_15.z, 0.0f);
    uint _S1278 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1278 + _S1277 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1279 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1280 = blockIdx.x;
    uint _S1281 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1280 < _S1281;
    uint _S1282 = __ballot_sync(_S1279, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1283;
    if(bond_group_0)
    {
        uint _S1284 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1285 = wide_group_0(_S1284, _S1280);
        uint _S1286 = __ballot_sync(_S1279, true);
        wg_1 = _S1285;
        _S1283 = _S1286;
    }
    else
    {
        uint _S1287 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1288 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1289 = wide_group_0(_S1287, _S1280 - _S1288);
        uint _S1290 = __ballot_sync(_S1279, true);
        wg_1 = _S1289;
        _S1283 = _S1290;
    }
    uint _S1291 = 0U;
    WideGroup_0 _S1292 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S1293 = wide_enter_1(tid_8, wg_1.island_2);
    bool _S1294 = !_S1293;
    uint _S1295 = __ballot_sync(_S1283, _S1294);
    if(_S1294)
    {
        return;
    }
    else
    {
        uint _S1296 = __ballot_sync(_S1283, true);
        _S1291 = _S1296;
    }
    uint _S1297 = 0U;
    Island_0 _S1298 = isl_13;
    uint _S1299 = wide_step_0(&_S1298);
    uint _S1300 = __ballot_sync(_S1291, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_17 = wg_1.begin_0 + tid_8;
        bool _S1301;
        if(i_17 < (wg_1.end_0))
        {
            float _S1302 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1303 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1304 = bond_update_0(i_17, _S1302, _S1303 != 0U, isl_13.info_1.w + 1U, true);
            _S1301 = _S1304;
        }
        else
        {
            _S1301 = false;
        }
        if(_S1301)
        {
            *&((&(&(globalParams_0->islands_0)[_S1292.island_2])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1305 = __ballot_sync(_S1291, true);
        _S1297 = _S1305;
    }
    uint _S1306 = 0U;
    uint _S1307 = isl_13.info_1.x;
    bool _S1308 = (_S1307 & 1U) != 0U;
    uint _S1309 = __ballot_sync(_S1297, _S1308);
    if(_S1308)
    {
        return;
    }
    else
    {
        uint _S1310 = __ballot_sync(_S1297, true);
        _S1306 = _S1310;
    }
    float3  _S1311 = make_float3 (0.0f);
    float3  f_16 = _S1311;
    float3  t_13 = _S1311;
    uint c_22 = wg_1.begin_0 + tid_8;
    bool _S1312 = c_22 < (wg_1.end_0);
    uint _S1313 = __ballot_sync(_S1306, _S1312);
    if(_S1312)
    {
        Island_0 _S1314 = isl_13;
        Rigid_0 _S1315 = rigid_of_0(&_S1314);
        float _S1316 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1317 = (_S1307 & 4U) != 0U;
        Island_0 _S1318 = isl_13;
        Rigid_0 _S1319 = _S1315;
        net_load_0(c_22, &_S1318, &_S1319, _S1299, _S1316, _S1317, &f_16, &t_13);
        uint _S1320 = __ballot_sync(_S1306, true);
        _S1283 = _S1320;
    }
    else
    {
        uint _S1321 = __ballot_sync(_S1306, true);
        _S1283 = _S1321;
    }
    group_sum3_0(tid_8, &f_16, &t_13, _S1283);
    bool _S1322 = tid_8 == 0U;
    uint _S1323 = __ballot_sync(_S1283, _S1322);
    if(_S1322)
    {
        uint _S1324 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1280 - _S1324, 0U, f_16, t_13);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_13, float3  * a_16, float3  * b_31, uint _S1325)
{
    uint _S1326;
    float4  _S1327 = make_float4 (0.0f);
    float4  x_20 = _S1327;
    float4  y_5 = _S1327;
    uint s_7 = tid_9;
    uint _S1328 = _S1325;
    for(;;)
    {
        bool _S1329 = s_7 < count_5;
        uint _S1330 = __ballot_sync(_S1328, _S1329);
        if(_S1329)
        {
            uint _S1331 = __ballot_sync(_S1328, true);
        }
        else
        {
            uint _S1332 = __ballot_sync(_S1328, false);
            uint _S1333 = __ballot_sync(_S1328, false);
            uint _S1334 = __ballot_sync(_S1325, true);
            _S1326 = _S1334;
            break;
        }
        uint _S1335 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1336 = 8U * (first_1 + s_7);
        x_20 = x_20 + *(&(globalParams_0->scratch_0)[_S1335 + _S1336 + p_13]);
        uint _S1337 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1337 + _S1336 + p_13 + 1U]);
        uint _S1338 = __ballot_sync(_S1328, true);
        s_7 = s_7 + 256U;
        _S1328 = _S1338;
    }
    group_sum2_0(tid_9, &x_20, &y_5, _S1326);
    float4  _S1339 = x_20;
    *a_16 = float3 {_S1339.x, _S1339.y, _S1339.z};
    float4  _S1340 = y_5;
    *b_31 = float3 {_S1340.x, _S1340.y, _S1340.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_10, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1341)
{
    Rigid_0 _S1342 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1342;
    bool _S1343 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1344 = __ballot_sync(_S1341, _S1343);
    if(_S1343)
    {
        float3  f_17;
        float3  t_14;
        wide_partials_0(tid_10, wg_2->first_0, isl_14->wide_groups_0, 0U, &f_17, &t_14, _S1344);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_14);
        uint _S1345 = __ballot_sync(_S1341, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1346 = 0U;
    uint _S1347 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1348 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1349 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1348, _S1349);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_2]);
    bool _S1350 = wide_enter_1(tid_11, wg_3.island_2);
    bool _S1351 = !_S1350;
    uint _S1352 = __ballot_sync(_S1347, _S1351);
    if(_S1351)
    {
        return;
    }
    else
    {
        uint _S1353 = __ballot_sync(_S1347, true);
        _S1346 = _S1353;
    }
    uint _S1354 = 0U;
    uint _S1355 = isl_15.info_1.x;
    bool anchored_0 = (_S1355 & 1U) != 0U;
    bool _S1356 = (_S1355 & 16U) != 0U;
    uint _S1357 = __ballot_sync(_S1346, _S1356);
    if(_S1356)
    {
        if(tid_11 == 0U)
        {
            uint _S1358 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1358 + 8U * _S1349 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1359 = __ballot_sync(_S1346, true);
        _S1354 = _S1359;
    }
    Island_0 _S1360 = isl_15;
    WideGroup_0 _S1361 = wg_3;
    Rigid_0 _S1362 = wide_rigid_frame_0(tid_11, &_S1360, &_S1361, _S1354);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1363 = make_float3 (0.0f);
    float3  tu_2 = _S1363;
    float3  pv_2 = _S1363;
    uint c_23 = wg_3.begin_0 + tid_11;
    bool _S1364 = c_23 < (wg_3.end_0);
    uint _S1365 = __ballot_sync(_S1354, _S1364);
    uint _S1366;
    if(_S1364)
    {
        float _S1367 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1368 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1369 = _S1368 != 0U;
        Island_0 _S1370 = isl_15;
        uint _S1371 = wide_step_0(&_S1370);
        bool _S1372 = (_S1355 & 4U) != 0U;
        Island_0 _S1373 = isl_15;
        Rigid_0 _S1374 = _S1362;
        chunk_update_0(c_23, &_S1373, &_S1374, _S1367, _S1369, _S1371, _S1372, &work_3, &work_err_2);
        bool _S1375 = !anchored_0;
        uint _S1376 = __ballot_sync(_S1365, _S1375);
        if(_S1375)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1377 = __ballot_sync(_S1365, true);
        }
        else
        {
            uint _S1378 = __ballot_sync(_S1365, true);
        }
        uint _S1379 = __ballot_sync(_S1354, true);
        _S1366 = _S1379;
    }
    else
    {
        uint _S1380 = __ballot_sync(_S1354, true);
        _S1366 = _S1380;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_3 = _S1363;
    group_sum3_0(tid_11, &wsum_1, &unused_3, _S1366);
    bool _S1381 = !anchored_0;
    uint _S1382 = __ballot_sync(_S1366, _S1381);
    if(_S1381)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, _S1382);
        uint _S1383 = __ballot_sync(_S1366, true);
    }
    if(tid_11 == 0U)
    {
        uint _S1384 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1385 = 8U * _S1349;
        *(&(globalParams_0->scratch_0)[_S1384 + _S1385 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1381)
        {
            wide_store_0(_S1349, 2U, tu_2, pv_2);
        }
        uint _S1386 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1386 + _S1385 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1387 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1388 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1389 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1388, _S1389);
    Island_0 * _S1390 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_16 = *_S1390;
    bool _S1391 = (((*_S1390).info_1.x) & 17U) != 0U;
    uint _S1392 = __ballot_sync(_S1387, _S1391);
    bool _S1393;
    uint _S1394;
    if(_S1391)
    {
        uint _S1395 = __ballot_sync(_S1387, true);
        _S1393 = true;
        _S1394 = _S1395;
    }
    else
    {
        bool _S1396 = wide_enter_1(tid_12, wg_4.island_2);
        bool _S1397 = !_S1396;
        uint _S1398 = __ballot_sync(_S1387, true);
        _S1393 = _S1397;
        _S1394 = _S1398;
    }
    uint _S1399 = 0U;
    uint _S1400 = __ballot_sync(_S1394, _S1393);
    if(_S1393)
    {
        return;
    }
    else
    {
        uint _S1401 = __ballot_sync(_S1394, true);
        _S1399 = _S1401;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_12, wg_4.first_0, isl_16.wide_groups_0, 2U, &tu_3, &pv_3, _S1399);
    float _S1402 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1402);
    float3  dv_4 = pv_3 / make_float3 (_S1402);
    float3  _S1403 = make_float3 (0.0f);
    float3  lu_2 = _S1403;
    float3  lv_2 = _S1403;
    uint c_24 = wg_4.begin_0 + tid_12;
    bool _S1404 = c_24 < (wg_4.end_0);
    uint _S1405 = __ballot_sync(_S1399, _S1404);
    if(_S1404)
    {
        float4  _S1406 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1406.x, _S1406.y, _S1406.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1407 = __ballot_sync(_S1399, true);
        _S1394 = _S1407;
    }
    else
    {
        uint _S1408 = __ballot_sync(_S1399, true);
        _S1394 = _S1408;
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, _S1394);
    bool _S1409 = tid_12 == 0U;
    uint _S1410 = __ballot_sync(_S1394, _S1409);
    if(_S1409)
    {
        wide_store_0(_S1389, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1411 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1412 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1413 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1412, _S1413);
    Island_0 * _S1414 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_17 = *_S1414;
    uint _S1415 = (*_S1414).info_1.x;
    bool _S1416 = (_S1415 & 1U) != 0U;
    uint _S1417 = __ballot_sync(_S1411, _S1416);
    bool _S1418;
    uint _S1419;
    if(_S1416)
    {
        uint _S1420 = __ballot_sync(_S1411, true);
        _S1418 = true;
        _S1419 = _S1420;
    }
    else
    {
        bool _S1421 = wide_enter_1(tid_13, wg_5.island_2);
        bool _S1422 = !_S1421;
        uint _S1423 = __ballot_sync(_S1411, true);
        _S1418 = _S1422;
        _S1419 = _S1423;
    }
    uint _S1424 = 0U;
    uint _S1425 = __ballot_sync(_S1419, _S1418);
    if(_S1418)
    {
        return;
    }
    else
    {
        uint _S1426 = __ballot_sync(_S1419, true);
        _S1424 = _S1426;
    }
    uint _S1427 = 0U;
    bool _S1428 = (_S1415 & 16U) != 0U;
    uint _S1429 = __ballot_sync(_S1424, _S1428);
    if(_S1428)
    {
        uint _S1430 = 0U;
        bool _S1431 = _S1413 != (wg_5.first_0);
        uint _S1432 = __ballot_sync(_S1429, _S1431);
        if(_S1431)
        {
            return;
        }
        else
        {
            uint _S1433 = __ballot_sync(_S1429, true);
            _S1430 = _S1433;
        }
        Island_0 _S1434 = isl_17;
        WideGroup_0 _S1435 = wg_5;
        Rigid_0 _S1436 = wide_rigid_frame_0(tid_13, &_S1434, &_S1435, _S1430);
        Rigid_0 rs_0 = _S1436;
        bool _S1437 = tid_13 != 0U;
        uint _S1438 = __ballot_sync(_S1430, _S1437);
        if(_S1437)
        {
            _S1418 = true;
        }
        else
        {
            _S1418 = (_S1415 & 2U) != 0U;
        }
        if(_S1418)
        {
            return;
        }
        float _S1439 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1440 = isl_17;
        integrate_rigid_0(&_S1440, &rs_0, _S1439);
        Quat_0 _S1441 = (&rs_0)->rot_0;
        float4  _S1442 = quat_vec_0(&_S1441);
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1442;
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_err_0 = (&rs_0)->rot_err_0;
        (&(globalParams_0->islands_0)[wg_5.island_2])->position_0 = make_float4 ((&rs_0)->pos_1.x, (&rs_0)->pos_1.y, (&rs_0)->pos_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->position_err_0 = make_float4 ((&rs_0)->pos_err_1.x, (&rs_0)->pos_err_1.y, (&rs_0)->pos_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_0 = make_float4 ((&rs_0)->vel_1.x, (&rs_0)->vel_1.y, (&rs_0)->vel_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_1.x, (&rs_0)->vel_err_1.y, (&rs_0)->vel_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->angular_velocity_0 = make_float4 ((&rs_0)->w_4.x, (&rs_0)->w_4.y, (&rs_0)->w_4.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_0 = make_float4 ((&rs_0)->l_2.x, (&rs_0)->l_2.y, (&rs_0)->l_2.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_err_0 = make_float4 ((&rs_0)->l_err_1.x, (&rs_0)->l_err_1.y, (&rs_0)->l_err_1.z, 0.0f);
        return;
    }
    else
    {
        uint _S1443 = __ballot_sync(_S1424, true);
        _S1427 = _S1443;
    }
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 2U, &tu_4, &pv_4, _S1427);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 4U, &lu_3, &lv_3, _S1427);
    float _S1444 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1444);
    float3  dv_5 = pv_4 / make_float3 (_S1444);
    float3  phi_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_13;
    bool _S1445 = c_25 < (wg_5.end_0);
    uint _S1446 = __ballot_sync(_S1427, _S1445);
    if(_S1445)
    {
        float4  _S1447 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1447.x, _S1447.y, _S1447.z}, tr_5, phi_4, dv_5, dw_3);
        uint _S1448 = __ballot_sync(_S1427, true);
        _S1419 = _S1448;
    }
    else
    {
        uint _S1449 = __ballot_sync(_S1427, true);
        _S1419 = _S1449;
    }
    uint _S1450 = 0U;
    bool _S1451 = _S1413 != (wg_5.first_0);
    uint _S1452 = __ballot_sync(_S1419, _S1451);
    if(_S1451)
    {
        return;
    }
    else
    {
        uint _S1453 = __ballot_sync(_S1419, true);
        _S1450 = _S1453;
    }
    Island_0 _S1454 = isl_17;
    WideGroup_0 _S1455 = wg_5;
    Rigid_0 _S1456 = wide_rigid_frame_0(tid_13, &_S1454, &_S1455, _S1450);
    Rigid_0 rg_9 = _S1456;
    bool _S1457 = tid_13 != 0U;
    uint _S1458 = __ballot_sync(_S1450, _S1457);
    if(_S1457)
    {
        return;
    }
    if(!((_S1415 & 2U) != 0U))
    {
        float _S1459 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1460 = isl_17;
        integrate_rigid_0(&_S1460, &rg_9, _S1459);
        Island_0 _S1461 = isl_17;
        drift_rigid_0(&_S1461, &rg_9, tr_5, phi_4, dv_5, dw_3);
    }
    Quat_0 _S1462 = (&rg_9)->rot_0;
    float4  _S1463 = quat_vec_0(&_S1462);
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1463;
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_err_0 = (&rg_9)->rot_err_0;
    (&(globalParams_0->islands_0)[wg_5.island_2])->position_0 = make_float4 ((&rg_9)->pos_1.x, (&rg_9)->pos_1.y, (&rg_9)->pos_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->position_err_0 = make_float4 ((&rg_9)->pos_err_1.x, (&rg_9)->pos_err_1.y, (&rg_9)->pos_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_0 = make_float4 ((&rg_9)->vel_1.x, (&rg_9)->vel_1.y, (&rg_9)->vel_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->velocity_err_0 = make_float4 ((&rg_9)->vel_err_1.x, (&rg_9)->vel_err_1.y, (&rg_9)->vel_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->angular_velocity_0 = make_float4 ((&rg_9)->w_4.x, (&rg_9)->w_4.y, (&rg_9)->w_4.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_0 = make_float4 ((&rg_9)->l_2.x, (&rg_9)->l_2.y, (&rg_9)->l_2.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_2])->momentum_err_0 = make_float4 ((&rg_9)->l_err_1.x, (&rg_9)->l_err_1.y, (&rg_9)->l_err_1.z, 0.0f);
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S1464 = 0U;
    uint _S1465 = __ballot_sync(4294967295U, true);
    uint tid_14 = threadIdx.x;
    uint _S1466 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1467 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1466, _S1467);
    bool _S1468 = _S1467 != (wg_6.first_0);
    uint _S1469 = __ballot_sync(_S1465, _S1468);
    if(_S1468)
    {
        return;
    }
    else
    {
        uint _S1470 = __ballot_sync(_S1465, true);
        _S1464 = _S1470;
    }
    uint _S1471 = 0U;
    Island_0 * _S1472 = (&(globalParams_0->islands_0)[wg_6.island_2]);
    Island_0 isl_18 = *_S1472;
    Island_0 _S1473 = *_S1472;
    bool _S1474 = wide_enter_0(tid_14, &_S1473);
    bool _S1475 = !_S1474;
    uint _S1476 = __ballot_sync(_S1464, _S1475);
    if(_S1475)
    {
        return;
    }
    else
    {
        uint _S1477 = __ballot_sync(_S1464, true);
        _S1471 = _S1477;
    }
    float3  work_4;
    float3  flags_2;
    wide_partials_0(tid_14, wg_6.first_0, (&isl_18)->wide_groups_0, 6U, &work_4, &flags_2, _S1471);
    bool _S1478 = tid_14 != 0U;
    uint _S1479 = __ballot_sync(_S1471, _S1478);
    if(_S1478)
    {
        return;
    }
    Island_0 _S1480 = isl_18;
    uint _S1481 = wide_step_0(&_S1480);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1482 = isl_18;
        Rigid_0 _S1483 = rigid_of_0(&_S1482);
        Island_0 _S1484 = isl_18;
        Rigid_0 _S1485 = _S1483;
        record_probes_0(&_S1484, &_S1485, _S1481);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1486;
    if(halt_0)
    {
        _S1486 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1486 = false;
    }
    if(_S1486)
    {
        contact_split_at_0((&isl_18)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_18)->energy_1)->x), &((&(&isl_18)->energy_1)->y), work_4.x);
    *&((&(&isl_18)->energy_1)->y) = *&((&(&isl_18)->energy_1)->y) + work_4.y;
    (&isl_18)->done_0 = (&isl_18)->done_0 + 1U;
    *&((&(&isl_18)->info_1)->y) = *&((&(&isl_18)->info_1)->y) - 1U;
    *&((&(&isl_18)->info_1)->w) = *&((&(&isl_18)->info_1)->w) + 1U;
    if(halt_0)
    {
        *&((&(&isl_18)->info_1)->z) = (((&isl_18)->info_1.z) & 4294967293U) | 1U;
    }
    uint _S1487;
    if(halt_0)
    {
        _S1487 = 128U;
    }
    else
    {
        _S1487 = 0U;
    }
    uint _S1488 = 256U | _S1487;
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        _S1487 = 262144U;
    }
    else
    {
        _S1487 = 0U;
    }
    uint _S1489 = _S1488 | _S1487;
    if((((&isl_18)->info_1.x) & 4U) != 0U)
    {
        _S1487 = 524288U;
    }
    else
    {
        _S1487 = 0U;
    }
    uint _S1490 = _S1489 | _S1487;
    if((flags_2.x) > 0.0f)
    {
        _S1487 = 32768U;
    }
    else
    {
        _S1487 = 0U;
    }
    uint _S1491 = _S1490 | _S1487;
    if((flags_2.y) > 0.0f)
    {
        _S1487 = 65536U;
    }
    else
    {
        _S1487 = 0U;
    }
    uint _S1492 = _S1491 | _S1487;
    if((flags_2.z) > 0.0f)
    {
        _S1487 = 131072U;
    }
    else
    {
        _S1487 = 0U;
    }
    (&isl_18)->coverage_0 = ((&isl_18)->coverage_0) | (_S1492 | _S1487);
    *(&(globalParams_0->islands_0)[wg_6.island_2]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_26, uint slot_2)
{
    uint _S1493 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1493 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_15, Island_0 * isl_19, uint slot_3, uint _S1494)
{
    uint _S1495;
    uint _S1496;
    float3  _S1497 = make_float3 (0.0f);
    float3  net_f_0 = _S1497;
    float3  net_m_0 = _S1497;
    uint4  _S1498 = isl_19->range_0;
    uint _S1499 = isl_19->range_0.x + tid_15;
    uint c_27 = _S1499;
    uint _S1500 = _S1494;
    for(;;)
    {
        uint _S1501 = _S1498.y;
        _S1495 = _S1501;
        bool _S1502 = c_27 < _S1501;
        uint _S1503 = __ballot_sync(_S1500, _S1502);
        if(_S1502)
        {
            uint _S1504 = __ballot_sync(_S1500, true);
        }
        else
        {
            uint _S1505 = __ballot_sync(_S1500, false);
            uint _S1506 = __ballot_sync(_S1500, false);
            uint _S1507 = __ballot_sync(_S1494, true);
            _S1496 = _S1507;
            break;
        }
        float4  _S1508 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1508.x, _S1508.y, _S1508.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1509 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1510 = isl_19->com_0;
        float4  _S1511 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1509.x, _S1509.y, _S1509.z} - float3 {_S1510.x, _S1510.y, _S1510.z}, fi_1) + float3 {_S1511.x, _S1511.y, _S1511.z});
        uint _S1512 = __ballot_sync(_S1500, true);
        c_27 = c_27 + 256U;
        _S1500 = _S1512;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, _S1496);
    float4  _S1513 = isl_19->com_0;
    float3  _S1514 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1515 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1499;
    for(;;)
    {
        if(c_27 < _S1495)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1516 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1517 = __ldg(&_S1516->center_0);
        uint _S1518 = sv_0(c_27, slot_3);
        float4  _S1519 = *(&(globalParams_0->scratch_0)[_S1518]);
        *(&(globalParams_0->scratch_0)[_S1518]) = make_float4 ((float3 {_S1519.x, _S1519.y, _S1519.z} - (_S1514 + cross_0(_S1515, float3 {_S1517.x, _S1517.y, _S1517.z} - float3 {_S1513.x, _S1513.y, _S1513.z})) * make_float3 (_S1517.w)).x, (float3 {_S1519.x, _S1519.y, _S1519.z} - (_S1514 + cross_0(_S1515, float3 {_S1517.x, _S1517.y, _S1517.z} - float3 {_S1513.x, _S1513.y, _S1513.z})) * make_float3 (_S1517.w)).y, (float3 {_S1519.x, _S1519.y, _S1519.z} - (_S1514 + cross_0(_S1515, float3 {_S1517.x, _S1517.y, _S1517.z} - float3 {_S1513.x, _S1513.y, _S1513.z})) * make_float3 (_S1517.w)).z, 0.0f);
        uint _S1520 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1521 = (&(globalParams_0->scratch_0)[_S1520]);
        float4  _S1522 = *(&(globalParams_0->scratch_0)[_S1520]);
        float3  _S1523 = float3 {_S1522.x, _S1522.y, _S1522.z};
        float4  _S1524 = __ldg(&_S1516->inertia0_0);
        float4  _S1525 = __ldg(&_S1516->inertia1_0);
        float4  _S1526 = __ldg(&_S1516->inertia2_0);
        *_S1521 = make_float4 ((_S1523 - rows_mul_0(_S1524, _S1525, _S1526, _S1515)).x, (_S1523 - rows_mul_0(_S1524, _S1525, _S1526, _S1515)).y, (_S1523 - rows_mul_0(_S1524, _S1525, _S1526, _S1515)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1527)
{
    uint _S1528;
    float4  _S1529 = make_float4 (0.0f);
    float4  acc_0 = _S1529;
    float4  unused_4 = _S1529;
    uint c_28 = c0_0 + tid_16;
    uint _S1530 = _S1527;
    for(;;)
    {
        bool _S1531 = c_28 < c1_0;
        uint _S1532 = __ballot_sync(_S1530, _S1531);
        if(_S1531)
        {
            uint _S1533 = __ballot_sync(_S1530, true);
        }
        else
        {
            uint _S1534 = __ballot_sync(_S1530, false);
            uint _S1535 = __ballot_sync(_S1530, false);
            uint _S1536 = __ballot_sync(_S1527, true);
            _S1528 = _S1536;
            break;
        }
        float4  _S1537 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1538 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1539 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1540 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1537.x, _S1537.y, _S1537.z}, float3 {_S1538.x, _S1538.y, _S1538.z}) + dot_0(float3 {_S1539.x, _S1539.y, _S1539.z}, float3 {_S1540.x, _S1540.y, _S1540.z}));
        uint _S1541 = __ballot_sync(_S1530, true);
        c_28 = c_28 + 256U;
        _S1530 = _S1541;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, _S1528);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1542, float3  * _S1543, float3  * _S1544)
{
    BondStatic_0 * _S1545 = (&(globalParams_0->bonds_0)[_S1542]);
    JointBond_0 _S1546 = slang_ldg_0(&_S1545->law_0);
    uint ca_1 = _S1546.ids_0.y;
    uint cb_1 = _S1546.ids_0.z;
    uint _S1547 = 4U * cb_1;
    float4  _S1548 = *(&(globalParams_0->state_0)[_S1547]);
    uint _S1549 = 4U * ca_1;
    float4  _S1550 = *(&(globalParams_0->state_0)[_S1549]);
    float4  _S1551 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1552 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1548.x, _S1548.y, _S1548.z} - float3 {_S1550.x, _S1550.y, _S1550.z} + (float3 {_S1551.x, _S1551.y, _S1551.z} - float3 {_S1552.x, _S1552.y, _S1552.z});
    uint _S1553 = _S1547 + 1U;
    float4  _S1554 = *(&(globalParams_0->state_0)[_S1553]);
    uint _S1555 = _S1549 + 1U;
    float4  _S1556 = *(&(globalParams_0->state_0)[_S1555]);
    uint _S1557 = sv_0(cb_1, 22U);
    float4  _S1558 = *(&(globalParams_0->scratch_0)[_S1557]);
    uint _S1559 = sv_0(ca_1, 22U);
    float4  _S1560 = *(&(globalParams_0->scratch_0)[_S1559]);
    float3  dth_0 = float3 {_S1554.x, _S1554.y, _S1554.z} - float3 {_S1556.x, _S1556.y, _S1556.z} + (float3 {_S1558.x, _S1558.y, _S1558.z} - float3 {_S1560.x, _S1560.y, _S1560.z});
    float4  _S1561 = *(&(globalParams_0->state_0)[_S1555]);
    float4  _S1562 = *(&(globalParams_0->scratch_0)[_S1559]);
    float3  ta_3 = float3 {_S1561.x, _S1561.y, _S1561.z} + float3 {_S1562.x, _S1562.y, _S1562.z};
    float4  _S1563 = *(&(globalParams_0->state_0)[_S1553]);
    float4  _S1564 = *(&(globalParams_0->scratch_0)[_S1557]);
    float3  tb_3 = float3 {_S1563.x, _S1563.y, _S1563.z} + float3 {_S1564.x, _S1564.y, _S1564.z};
    float4  _S1565 = __ldg(&_S1545->rb_0);
    float3  _S1566 = cross_0(tb_3, float3 {_S1565.x, _S1565.y, _S1565.z});
    float4  _S1567 = __ldg(&_S1545->ra_0);
    float3  _S1568 = to_local_0(_S1542, du_0 + (_S1566 - cross_0(ta_3, float3 {_S1567.x, _S1567.y, _S1567.z})));
    *_S1543 = _S1568;
    float3  _S1569 = to_local_0(_S1542, dth_0);
    *_S1544 = _S1569;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1570 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1571 = slang_ldg_0(&_S1570->law_0);
    JointBond_0 _S1572 = _S1571;
    JointState_0 _S1573 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1574 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1571.ids_0.x], &_S1572, &_S1573, d_lin_4, d_ang_3, 0.0f, false);
    return _S1574;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1575 = make_float3 (0.0f);
    *fi_2 = _S1575;
    *mi_3 = _S1575;
    uint _S1576 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1576;
    for(;;)
    {
        uint _S1577 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1577)
        {
        }
        else
        {
            break;
        }
        uint _S1578 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1578 >> int(1);
        if((_S1578 & 1U) == 0U)
        {
            uint _S1579 = 3U * bond_0;
            float4  _S1580 = *(&(globalParams_0->scratch_0)[_S1579]);
            *fi_2 = *fi_2 + float3 {_S1580.x, _S1580.y, _S1580.z};
            float4  _S1581 = *(&(globalParams_0->scratch_0)[_S1579 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1581.x, _S1581.y, _S1581.z};
        }
        else
        {
            uint _S1582 = 3U * bond_0;
            float4  _S1583 = *(&(globalParams_0->scratch_0)[_S1582]);
            *fi_2 = *fi_2 - float3 {_S1583.x, _S1583.y, _S1583.z};
            float4  _S1584 = *(&(globalParams_0->scratch_0)[_S1582 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1584.x, _S1584.y, _S1584.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1585 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1585;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1586 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1586)
        {
        }
        else
        {
            break;
        }
        uint _S1587 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1588 = 3U * (_S1587 >> int(1));
        float4  _S1589 = *(&(globalParams_0->scratch_0)[_S1588]);
        float3  f_18 = float3 {_S1589.x, _S1589.y, _S1589.z};
        float3  t_15;
        if((_S1587 & 1U) == 0U)
        {
            float4  _S1590 = *(&(globalParams_0->scratch_0)[_S1588 + 1U]);
            t_15 = float3 {_S1590.x, _S1590.y, _S1590.z};
        }
        else
        {
            float4  _S1591 = *(&(globalParams_0->scratch_0)[_S1588 + 2U]);
            t_15 = float3 {_S1591.x, _S1591.y, _S1591.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_15, t_15));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1592 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1592.x;
    uint _S1593;
    if(support_1 == 1U)
    {
        _S1593 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1593 = 7U;
        }
        else
        {
            _S1593 = 0U;
        }
    }
    return _S1593;
}

static __device__ void hold_0(uint mask_0, float4  * lin_0, float4  * ang_0, float4  keep_lin_0, float4  keep_ang_0)
{
    uint d_12 = 0U;
    for(;;)
    {
        if(d_12 < 3U)
        {
        }
        else
        {
            break;
        }
        if((mask_0 & (1U << d_12)) != 0U)
        {
            *_slang_vector_get_element_ptr(lin_0, d_12) = _slang_vector_get_element(keep_lin_0, d_12);
        }
        if((mask_0 & (1U << (d_12 + 3U))) != 0U)
        {
            *_slang_vector_get_element_ptr(ang_0, d_12) = _slang_vector_get_element(keep_ang_0, d_12);
        }
        d_12 = d_12 + 1U;
    }
    return;
}

static __device__ uint statics_bond_slot_0(uint i_19)
{
    uint _S1594 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1595 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1594 + 23U * _S1595 + 2U * i_19;
}

static __device__ void store_inverse_0(uint c_32, FixedArray<float, 36>  * a_17)
{
    uint j_6;
    float sum_4;
    FixedArray<float, 36>  l_4;
    uint k_19 = 0U;
    for(;;)
    {
        if(k_19 < 36U)
        {
        }
        else
        {
            break;
        }
        l_4[k_19] = 0.0f;
        k_19 = k_19 + 1U;
    }
    bool spd_0 = true;
    uint i_20 = 0U;
    for(;;)
    {
        bool _S1596;
        if(i_20 < 6U)
        {
            _S1596 = spd_0;
        }
        else
        {
            _S1596 = false;
        }
        if(_S1596)
        {
        }
        else
        {
            break;
        }
        j_6 = 0U;
        for(;;)
        {
            if(j_6 <= i_20)
            {
            }
            else
            {
                break;
            }
            uint _S1597 = i_20 * 6U;
            uint _S1598 = _S1597 + j_6;
            k_19 = 0U;
            sum_4 = (*a_17)[_S1598];
            for(;;)
            {
                if(k_19 < j_6)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1597 + k_19] * l_4[j_6 * 6U + k_19];
                k_19 = k_19 + 1U;
                sum_4 = sum_5;
            }
            if(i_20 == j_6)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1597 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1598] = sum_4 / l_4[j_6 * 6U + j_6];
            }
            j_6 = j_6 + 1U;
        }
        i_20 = i_20 + 1U;
    }
    FixedArray<float, 36>  inv_0;
    if(!spd_0)
    {
        k_19 = 0U;
        for(;;)
        {
            if(k_19 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_19] = 0.0f;
            k_19 = k_19 + 1U;
        }
        k_19 = 0U;
        for(;;)
        {
            if(k_19 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1599 = k_19 * 6U + k_19;
            float _S1600 = (*a_17)[_S1599];
            if(((*a_17)[_S1599]) > 0.0f)
            {
                sum_4 = 1.0f / _S1600;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1599] = sum_4;
            k_19 = k_19 + 1U;
        }
    }
    else
    {
        j_6 = 0U;
        for(;;)
        {
            if(j_6 < 6U)
            {
            }
            else
            {
                break;
            }
            FixedArray<float, 6>  y_6;
            y_6[int(0)] = 0.0f;
            y_6[int(1)] = 0.0f;
            y_6[int(2)] = 0.0f;
            y_6[int(3)] = 0.0f;
            y_6[int(4)] = 0.0f;
            y_6[int(5)] = 0.0f;
            i_20 = 0U;
            for(;;)
            {
                if(i_20 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_20 == j_6)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_19 = 0U;
                float s_8 = sum_4;
                for(;;)
                {
                    if(k_19 < i_20)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = s_8 - l_4[i_20 * 6U + k_19] * y_6[k_19];
                    k_19 = k_19 + 1U;
                    s_8 = s_9;
                }
                y_6[i_20] = s_8 / l_4[i_20 * 6U + i_20];
                i_20 = i_20 + 1U;
            }
            FixedArray<float, 6>  x_21;
            x_21[int(0)] = 0.0f;
            x_21[int(1)] = 0.0f;
            x_21[int(2)] = 0.0f;
            x_21[int(3)] = 0.0f;
            x_21[int(4)] = 0.0f;
            x_21[int(5)] = 0.0f;
            uint ii_2 = 0U;
            for(;;)
            {
                if(ii_2 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint i_21 = 5U - ii_2;
                k_19 = i_21 + 1U;
                sum_4 = y_6[i_21];
                for(;;)
                {
                    if(k_19 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = sum_4 - l_4[k_19 * 6U + i_21] * x_21[k_19];
                    k_19 = k_19 + 1U;
                    sum_4 = s_10;
                }
                x_21[i_21] = sum_4 / l_4[i_21 * 6U + i_21];
                ii_2 = ii_2 + 1U;
            }
            uint i_22 = 0U;
            for(;;)
            {
                if(i_22 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_22 * 6U + j_6] = x_21[i_22];
                i_22 = i_22 + 1U;
            }
            j_6 = j_6 + 1U;
        }
    }
    j_6 = 0U;
    for(;;)
    {
        if(j_6 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1601 = 4U * j_6;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_6)]) = make_float4 (inv_0[_S1601], inv_0[_S1601 + 1U], inv_0[_S1601 + 2U], inv_0[_S1601 + 3U]);
        j_6 = j_6 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_33)
{
    uint p_14;
    uint r_11;
    FixedArray<float, 36>  a_18;
    uint k_20 = 0U;
    for(;;)
    {
        if(k_20 < 36U)
        {
        }
        else
        {
            break;
        }
        a_18[k_20] = 0.0f;
        k_20 = k_20 + 1U;
    }
    uint _S1602 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1602;
    for(;;)
    {
        uint _S1603 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1603)
        {
        }
        else
        {
            break;
        }
        uint _S1604 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_23 = _S1604 >> int(1);
        bool _S1605 = (_S1604 & 1U) != 0U;
        BondStatic_0 * _S1606 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1607 = statics_bond_slot_0(i_23);
        float4  _S1608 = *(&(globalParams_0->scratch_0)[_S1607]);
        float4  _S1609 = *(&(globalParams_0->scratch_0)[_S1607 + 1U]);
        p_14 = 0U;
        for(;;)
        {
            if(p_14 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1610 = p_14 % 3U;
            float3  t_16;
            if(_S1610 == 0U)
            {
                float4  _S1611 = __ldg(&_S1606->t1_0);
                t_16 = float3 {_S1611.x, _S1611.y, _S1611.z};
            }
            else
            {
                if(_S1610 == 1U)
                {
                    float4  _S1612 = __ldg(&_S1606->t2_0);
                    t_16 = float3 {_S1612.x, _S1612.y, _S1612.z};
                }
                else
                {
                    float4  _S1613 = __ldg(&_S1606->normal_0);
                    t_16 = float3 {_S1613.x, _S1613.y, _S1613.z};
                }
            }
            bool _S1614 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1614)
            {
                if(_S1605)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S1605)
                {
                    float4  _S1615 = __ldg(&_S1606->rb_0);
                    row_t_0 = cross_0(float3 {_S1615.x, _S1615.y, _S1615.z}, t_16);
                }
                else
                {
                    float4  _S1616 = __ldg(&_S1606->ra_0);
                    row_t_0 = - cross_0(float3 {_S1616.x, _S1616.y, _S1616.z}, t_16);
                }
            }
            else
            {
                float3  _S1617 = make_float3 (0.0f);
                if(_S1605)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3  _S1618 = row_u_0;
                row_u_0 = _S1617;
                row_t_0 = _S1618;
            }
            float kp_0;
            if(_S1614)
            {
                kp_0 = _slang_vector_get_element(_S1608, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1609, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1619 = { {
                row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z
            } };
            r_11 = 0U;
            for(;;)
            {
                if(r_11 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint q_13 = 0U;
                for(;;)
                {
                    if(q_13 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_18[r_11 * 6U + q_13] = a_18[r_11 * 6U + q_13] + kp_0 * _S1619[r_11] * _S1619[q_13];
                    q_13 = q_13 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1620 = fixed_mask_0(c_33);
    p_14 = 0U;
    for(;;)
    {
        if(p_14 < 6U)
        {
        }
        else
        {
            break;
        }
        if((_S1620 & (1U << p_14)) != 0U)
        {
            r_11 = 0U;
            for(;;)
            {
                if(r_11 < 6U)
                {
                }
                else
                {
                    break;
                }
                a_18[p_14 * 6U + r_11] = 0.0f;
                a_18[r_11 * 6U + p_14] = 0.0f;
                r_11 = r_11 + 1U;
            }
            a_18[p_14 * 6U + p_14] = 1.0f;
        }
        p_14 = p_14 + 1U;
    }
    p_14 = 0U;
    for(;;)
    {
        if(p_14 < 6U)
        {
        }
        else
        {
            break;
        }
        if((a_18[p_14 * 6U + p_14]) == 0.0f)
        {
            a_18[p_14 * 6U + p_14] = 1.0f;
        }
        p_14 = p_14 + 1U;
    }
    FixedArray<float, 36>  _S1621 = a_18;
    store_inverse_0(c_33, &_S1621);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_24, uint j_7)
{
    uint k_21 = i_24 * 6U + j_7;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1622 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1623 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1624 = { {
        (*_S1622).x, (*_S1622).y, (*_S1622).z, (*_S1623).x, (*_S1623).y, (*_S1623).z
    } };
    FixedArray<float, 6>  z_1;
    uint i_25 = 0U;
    for(;;)
    {
        if(i_25 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_8 = 0U;
        float s_11 = 0.0f;
        for(;;)
        {
            if(j_8 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_12 = s_11 + block_get_0(c_35, i_25, j_8) * _S1624[j_8];
            j_8 = j_8 + 1U;
            s_11 = s_12;
        }
        z_1[i_25] = s_11;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_17, Island_0 * isl_20, uint slot_4, uint _S1625)
{
    uint _S1626;
    uint _S1627;
    float3  _S1628 = make_float3 (0.0f);
    float3  p_15 = _S1628;
    float3  l_5 = _S1628;
    uint4  _S1629 = isl_20->range_0;
    uint _S1630 = isl_20->range_0.x + tid_17;
    uint c_36 = _S1630;
    uint _S1631 = _S1625;
    for(;;)
    {
        uint _S1632 = _S1629.y;
        _S1626 = _S1632;
        bool _S1633 = c_36 < _S1632;
        uint _S1634 = __ballot_sync(_S1631, _S1633);
        if(_S1633)
        {
            uint _S1635 = __ballot_sync(_S1631, true);
        }
        else
        {
            uint _S1636 = __ballot_sync(_S1631, false);
            uint _S1637 = __ballot_sync(_S1631, false);
            uint _S1638 = __ballot_sync(_S1625, true);
            _S1627 = _S1638;
            break;
        }
        ChunkStatic_0 * _S1639 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1640 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1640.x, _S1640.y, _S1640.z};
        float4  _S1641 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_4 = float3 {_S1641.x, _S1641.y, _S1641.z};
        float4  _S1642 = __ldg(&_S1639->center_0);
        float4  _S1643 = isl_20->com_0;
        float3  r_12 = float3 {_S1642.x, _S1642.y, _S1642.z} - float3 {_S1643.x, _S1643.y, _S1643.z};
        float _S1644 = _S1642.w;
        p_15 = p_15 + u_3 * make_float3 (_S1644);
        float3  _S1645 = cross_0(r_12, u_3) * make_float3 (_S1644);
        float4  _S1646 = __ldg(&_S1639->inertia0_0);
        float4  _S1647 = __ldg(&_S1639->inertia1_0);
        float4  _S1648 = __ldg(&_S1639->inertia2_0);
        l_5 = l_5 + (_S1645 + rows_mul_0(_S1646, _S1647, _S1648, th_4));
        uint _S1649 = __ballot_sync(_S1631, true);
        c_36 = c_36 + 256U;
        _S1631 = _S1649;
    }
    group_sum3_0(tid_17, &p_15, &l_5, _S1627);
    float4  _S1650 = isl_20->com_0;
    float3  _S1651 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1652 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_5);
    c_36 = _S1630;
    for(;;)
    {
        if(c_36 < _S1626)
        {
        }
        else
        {
            break;
        }
        float4  _S1653 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1654 = sv_0(c_36, slot_4);
        float4  _S1655 = *(&(globalParams_0->scratch_0)[_S1654]);
        *(&(globalParams_0->scratch_0)[_S1654]) = make_float4 ((float3 {_S1655.x, _S1655.y, _S1655.z} - _S1651 - cross_0(_S1652, float3 {_S1653.x, _S1653.y, _S1653.z} - float3 {_S1650.x, _S1650.y, _S1650.z})).x, (float3 {_S1655.x, _S1655.y, _S1655.z} - _S1651 - cross_0(_S1652, float3 {_S1653.x, _S1653.y, _S1653.z} - float3 {_S1650.x, _S1650.y, _S1650.z})).y, (float3 {_S1655.x, _S1655.y, _S1655.z} - _S1651 - cross_0(_S1652, float3 {_S1653.x, _S1653.y, _S1653.z} - float3 {_S1650.x, _S1650.y, _S1650.z})).z, 0.0f);
        uint _S1656 = sv_0(c_36, slot_4 + 1U);
        float4  _S1657 = *(&(globalParams_0->scratch_0)[_S1656]);
        *(&(globalParams_0->scratch_0)[_S1656]) = make_float4 ((float3 {_S1657.x, _S1657.y, _S1657.z} - _S1652).x, (float3 {_S1657.x, _S1657.y, _S1657.z} - _S1652).y, (float3 {_S1657.x, _S1657.y, _S1657.z} - _S1652).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1658 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1659 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1660 = _S1658 + 23U * _S1659;
    uint _S1661 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1660 + 2U * _S1661 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1662, uint _S1663, float3  _S1664, float3  _S1665, float _S1666)
{
    BondStatic_0 * _S1667 = (&(globalParams_0->bonds_0)[_S1663]);
    float3  _S1668 = to_body_0(_S1663, _S1664);
    float3  _S1669 = to_body_0(_S1663, _S1665);
    uint _S1670 = 3U * _S1662;
    *(&(globalParams_0->scratch_0)[_S1670]) = make_float4 (_S1668.x, _S1668.y, _S1668.z, _S1666);
    float4  * _S1671 = (&(globalParams_0->scratch_0)[_S1670 + 1U]);
    float4  _S1672 = __ldg(&_S1667->ra_0);
    *_S1671 = make_float4 ((_S1669 + cross_0(float3 {_S1672.x, _S1672.y, _S1672.z}, _S1668)).x, (_S1669 + cross_0(float3 {_S1672.x, _S1672.y, _S1672.z}, _S1668)).y, (_S1669 + cross_0(float3 {_S1672.x, _S1672.y, _S1672.z}, _S1668)).z, 0.0f);
    float4  * _S1673 = (&(globalParams_0->scratch_0)[_S1670 + 2U]);
    float3  _S1674 = - _S1669;
    float4  _S1675 = __ldg(&_S1667->rb_0);
    *_S1673 = make_float4 ((_S1674 + cross_0(float3 {_S1675.x, _S1675.y, _S1675.z}, - _S1668)).x, (_S1674 + cross_0(float3 {_S1675.x, _S1675.y, _S1675.z}, - _S1668)).y, (_S1674 + cross_0(float3 {_S1675.x, _S1675.y, _S1675.z}, - _S1668)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1676, float3  _S1677, float3  _S1678, float3  _S1679, float3  _S1680, float3  * _S1681, float3  * _S1682)
{
    BondStatic_0 * _S1683 = (&(globalParams_0->bonds_0)[_S1676]);
    float4  _S1684 = __ldg(&_S1683->rb_0);
    float3  _S1685 = _S1679 + cross_0(_S1680, float3 {_S1684.x, _S1684.y, _S1684.z});
    float4  _S1686 = __ldg(&_S1683->ra_0);
    float3  _S1687 = to_local_0(_S1676, _S1685 - (_S1677 + cross_0(_S1678, float3 {_S1686.x, _S1686.y, _S1686.z})));
    *_S1681 = _S1687;
    float3  _S1688 = to_local_0(_S1676, _S1680 - _S1678);
    *_S1682 = _S1688;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1689 = 0U;
    uint _S1690;
    uint i_26;
    uint c_37;
    bool converged_0;
    uint _S1691;
    uint _S1692;
    uint _S1693;
    uint _S1694;
    uint _S1695;
    uint _S1696;
    uint i_27;
    uint _S1697;
    uint _S1698;
    uint _S1699;
    uint _S1700;
    uint _S1701;
    uint _S1702 = __ballot_sync(4294967295U, true);
    uint tid_18 = threadIdx.x;
    uint _S1703 = blockIdx.x;
    Island_0 * _S1704 = (&(globalParams_0->islands_0)[_S1703]);
    Island_0 isl_21 = *_S1704;
    uint _S1705 = (*_S1704).info_1.z;
    bool _S1706 = (_S1705 & 8U) == 0U;
    uint _S1707 = __ballot_sync(_S1702, _S1706);
    if(_S1706)
    {
        return;
    }
    else
    {
        uint _S1708 = __ballot_sync(_S1702, true);
        _S1689 = _S1708;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1709 = isl_21.range_0.w;
    uint _S1710 = c0_1 + tid_18;
    uint c_38 = _S1710;
    uint newton_0;
    newton_0 = _S1689;
    for(;;)
    {
        bool _S1711 = c_38 < c1_1;
        uint _S1712 = __ballot_sync(newton_0, _S1711);
        if(_S1711)
        {
            uint _S1713 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1714 = __ballot_sync(newton_0, false);
            uint _S1715 = __ballot_sync(newton_0, false);
            uint _S1716 = __ballot_sync(_S1689, true);
            _S1690 = _S1716;
            break;
        }
        float4  _S1717 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1717;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1717;
        uint _S1718 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1718;
    }
    __syncthreads();
    uint _S1719 = __ballot_sync(_S1690, free_0);
    if(free_0)
    {
        Island_0 _S1720 = isl_21;
        project_load_slot_0(tid_18, &_S1720, 0U, _S1719);
        uint _S1721 = __ballot_sync(_S1690, true);
        c_38 = _S1721;
    }
    else
    {
        uint _S1722 = __ballot_sync(_S1690, true);
        c_38 = _S1722;
    }
    float _S1723 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, c_38);
    float _S1724 = (F32_max(((F32_sqrt((_S1723)))), (1.00000000317107685e-30f)));
    float _S1725 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1726 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1727 = (U32_min((_S1726), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1728 = 0U;
        uint _S1729 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1730 = newton_0 < _S1729;
        uint _S1731 = __ballot_sync(c_38, _S1730);
        if(_S1730)
        {
            uint _S1732 = __ballot_sync(c_38, true);
            _S1728 = _S1732;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1733 = b0_0 + tid_18;
        i_26 = _S1733;
        uint _S1734;
        _S1734 = _S1728;
        for(;;)
        {
            bool _S1735 = i_26 < _S1709;
            uint _S1736 = __ballot_sync(_S1734, _S1735);
            if(_S1735)
            {
                uint _S1737 = __ballot_sync(_S1734, true);
            }
            else
            {
                uint _S1738 = __ballot_sync(_S1734, false);
                uint _S1739 = __ballot_sync(_S1734, false);
                uint _S1740 = __ballot_sync(_S1728, true);
                _S1691 = _S1740;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1741 = __ballot_sync(_S1734, true);
            i_26 = i_26 + 256U;
            _S1734 = _S1741;
        }
        __syncthreads();
        float4  _S1742 = make_float4 (0.0f);
        float4  magnitude_0 = _S1742;
        float4  unused_m_0 = _S1742;
        uint c_39 = _S1710;
        uint _S1743 = _S1691;
        for(;;)
        {
            bool _S1744 = c_39 < c1_1;
            uint _S1745 = __ballot_sync(_S1743, _S1744);
            if(_S1744)
            {
                uint _S1746 = __ballot_sync(_S1743, true);
            }
            else
            {
                uint _S1747 = __ballot_sync(_S1743, false);
                uint _S1748 = __ballot_sync(_S1743, false);
                uint _S1749 = __ballot_sync(_S1691, true);
                _S1692 = _S1749;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1750 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1750.x, _S1750.y, _S1750.z} + fi_3).x, (float3 {_S1750.x, _S1750.y, _S1750.z} + fi_3).y, (float3 {_S1750.x, _S1750.y, _S1750.z} + fi_3).z, 0.0f);
            float4  _S1751 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1751.x, _S1751.y, _S1751.z} + mi_4).x, (float3 {_S1751.x, _S1751.y, _S1751.z} + mi_4).y, (float3 {_S1751.x, _S1751.y, _S1751.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1742, _S1742);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1752 = __ballot_sync(_S1743, true);
            c_39 = c_39 + 256U;
            _S1743 = _S1752;
        }
        __syncthreads();
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, _S1692);
        uint _S1753 = __ballot_sync(_S1692, free_0);
        uint _S1754;
        if(free_0)
        {
            Island_0 _S1755 = isl_21;
            project_load_slot_0(tid_18, &_S1755, 4U, _S1753);
            uint _S1756 = __ballot_sync(_S1692, true);
            _S1754 = _S1756;
        }
        else
        {
            uint _S1757 = __ballot_sync(_S1692, true);
            _S1754 = _S1757;
        }
        float _S1758 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1754);
        float residual_1 = (F32_sqrt((_S1758))) / _S1724;
        float _S1759 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1724)));
        bool _S1760 = residual_1 <= _S1725;
        uint _S1761 = __ballot_sync(_S1754, _S1760);
        uint _S1762;
        if(_S1760)
        {
            uint _S1763 = __ballot_sync(_S1754, true);
            converged_0 = true;
            _S1762 = _S1763;
        }
        else
        {
            uint _S1764 = _S1754 & (~_S1761);
            bool _S1765 = residual_1 <= _S1759;
            uint _S1766 = __ballot_sync(_S1764, _S1765);
            if(_S1765)
            {
                bool _S1767 = residual_1 > (0.5f * previous_2);
                uint _S1768 = __ballot_sync(_S1764, true);
                converged_0 = _S1767;
            }
            else
            {
                uint _S1769 = __ballot_sync(_S1764, true);
                converged_0 = false;
            }
            uint _S1770 = __ballot_sync(_S1754, true);
            _S1762 = _S1770;
        }
        uint _S1771 = 0U;
        uint _S1772 = __ballot_sync(_S1762, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1773 = __ballot_sync(_S1762, true);
            _S1771 = _S1773;
        }
        uint i_28 = _S1733;
        uint _S1774;
        _S1774 = _S1771;
        for(;;)
        {
            bool _S1775 = i_28 < _S1709;
            uint _S1776 = __ballot_sync(_S1774, _S1775);
            if(_S1775)
            {
                uint _S1777 = __ballot_sync(_S1774, true);
            }
            else
            {
                uint _S1778 = __ballot_sync(_S1774, false);
                uint _S1779 = __ballot_sync(_S1774, false);
                uint _S1780 = __ballot_sync(_S1771, true);
                _S1693 = _S1780;
                break;
            }
            BondStatic_0 * _S1781 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S1782 = slang_ldg_0(&_S1781->law_0);
            JointBond_0 _S1783 = _S1782;
            JointState_0 _S1784 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1783, &_S1784, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1785 = statics_bond_slot_0(i_28);
            float _S1786 = _S1782.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1785]) = make_float4 (_S1786 * f_lin_2.x, _S1786 * f_lin_2.y, _S1782.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1785 + 1U]) = make_float4 (_S1782.stiff0_0.z * f_ang_2.x, _S1782.stiff0_0.w * f_ang_2.y, _S1782.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1787 = __ballot_sync(_S1774, true);
            i_28 = i_28 + 256U;
            _S1774 = _S1787;
        }
        __syncthreads();
        uint c_40 = _S1710;
        uint _S1788 = _S1693;
        for(;;)
        {
            bool _S1789 = c_40 < c1_1;
            uint _S1790 = __ballot_sync(_S1788, _S1789);
            if(_S1789)
            {
                uint _S1791 = __ballot_sync(_S1788, true);
            }
            else
            {
                uint _S1792 = __ballot_sync(_S1788, false);
                uint _S1793 = __ballot_sync(_S1788, false);
                uint _S1794 = __ballot_sync(_S1693, true);
                _S1694 = _S1794;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1742;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1742;
            uint _S1795 = __ballot_sync(_S1788, true);
            c_40 = c_40 + 256U;
            _S1788 = _S1795;
        }
        __syncthreads();
        uint c_41 = _S1710;
        uint _S1796 = _S1694;
        for(;;)
        {
            bool _S1797 = c_41 < c1_1;
            uint _S1798 = __ballot_sync(_S1796, _S1797);
            if(_S1797)
            {
                uint _S1799 = __ballot_sync(_S1796, true);
            }
            else
            {
                uint _S1800 = __ballot_sync(_S1796, false);
                uint _S1801 = __ballot_sync(_S1796, false);
                uint _S1802 = __ballot_sync(_S1694, true);
                _S1695 = _S1802;
                break;
            }
            precondition_0(c_41);
            uint _S1803 = __ballot_sync(_S1796, true);
            c_41 = c_41 + 256U;
            _S1796 = _S1803;
        }
        __syncthreads();
        uint _S1804 = __ballot_sync(_S1695, free_0);
        uint _S1805;
        if(free_0)
        {
            Island_0 _S1806 = isl_21;
            project_displacement_slot_0(tid_18, &_S1806, 6U, _S1804);
            uint _S1807 = __ballot_sync(_S1695, true);
            _S1805 = _S1807;
        }
        else
        {
            uint _S1808 = __ballot_sync(_S1695, true);
            _S1805 = _S1808;
        }
        uint c_42 = _S1710;
        uint _S1809 = _S1805;
        for(;;)
        {
            bool _S1810 = c_42 < c1_1;
            uint _S1811 = __ballot_sync(_S1809, _S1810);
            if(_S1810)
            {
                uint _S1812 = __ballot_sync(_S1809, true);
            }
            else
            {
                uint _S1813 = __ballot_sync(_S1809, false);
                uint _S1814 = __ballot_sync(_S1809, false);
                uint _S1815 = __ballot_sync(_S1805, true);
                _S1696 = _S1815;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1816 = __ballot_sync(_S1809, true);
            c_42 = c_42 + 256U;
            _S1809 = _S1816;
        }
        __syncthreads();
        float _S1817 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1696);
        float _S1818 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1696);
        float _S1819 = (F32_sqrt((_S1818)));
        float rz_0 = _S1817;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1820 = _S1696;
        for(;;)
        {
            bool _S1821 = k_22 < _S1727;
            uint _S1822 = __ballot_sync(_S1820, _S1821);
            uint _S1823;
            bool _S1824;
            if(_S1821)
            {
                bool _S1825 = _S1819 > 0.0f;
                uint _S1826 = __ballot_sync(_S1820, true);
                _S1824 = _S1825;
                _S1823 = _S1826;
            }
            else
            {
                uint _S1827 = __ballot_sync(_S1820, true);
                _S1824 = false;
                _S1823 = _S1827;
            }
            uint _S1828 = 0U;
            uint _S1829 = __ballot_sync(_S1823, _S1824);
            if(_S1824)
            {
                uint _S1830 = __ballot_sync(_S1823, true);
                _S1828 = _S1830;
            }
            else
            {
                uint _S1831 = __ballot_sync(_S1823, false);
                uint _S1832 = __ballot_sync(_S1820, false);
                uint _S1833 = __ballot_sync(_S1696, true);
                cg_total_0 = cg_total_1;
                i_27 = _S1833;
                break;
            }
            i_27 = _S1733;
            _S1697 = _S1828;
            for(;;)
            {
                bool _S1834 = i_27 < _S1709;
                uint _S1835 = __ballot_sync(_S1697, _S1834);
                if(_S1834)
                {
                    uint _S1836 = __ballot_sync(_S1697, true);
                }
                else
                {
                    uint _S1837 = __ballot_sync(_S1697, false);
                    uint _S1838 = __ballot_sync(_S1697, false);
                    uint _S1839 = __ballot_sync(_S1828, true);
                    _S1698 = _S1839;
                    break;
                }
                JointBond_0 _S1840 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S1840.ids_0.y;
                uint cb_2 = _S1840.ids_0.z;
                float4  _S1841 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1842 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1843 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1844 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S1841.x, _S1841.y, _S1841.z}, float3 {_S1842.x, _S1842.y, _S1842.z}, float3 {_S1843.x, _S1843.y, _S1843.z}, float3 {_S1844.x, _S1844.y, _S1844.z}, &d_lin_6, &d_ang_5);
                uint _S1845 = statics_bond_slot_0(i_27);
                float4  _S1846 = *(&(globalParams_0->scratch_0)[_S1845]);
                float4  _S1847 = *(&(globalParams_0->scratch_0)[_S1845 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S1846.x, _S1846.y, _S1846.z}, d_ang_5 * float3 {_S1847.x, _S1847.y, _S1847.z}, 0.0f);
                uint _S1848 = __ballot_sync(_S1697, true);
                i_27 = i_27 + 256U;
                _S1697 = _S1848;
            }
            __syncthreads();
            c_37 = _S1710;
            uint _S1849 = _S1698;
            for(;;)
            {
                bool _S1850 = c_37 < c1_1;
                uint _S1851 = __ballot_sync(_S1849, _S1850);
                if(_S1850)
                {
                    uint _S1852 = __ballot_sync(_S1849, true);
                }
                else
                {
                    uint _S1853 = __ballot_sync(_S1849, false);
                    uint _S1854 = __ballot_sync(_S1849, false);
                    uint _S1855 = __ballot_sync(_S1698, true);
                    _S1699 = _S1855;
                    break;
                }
                float3  fi_4;
                float3  mi_5;
                gather_loads_0(c_37, &fi_4, &mi_5);
                float4  ap_lin_0 = make_float4 ((- fi_4).x, (- fi_4).y, (- fi_4).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_5).x, (- mi_5).y, (- mi_5).z, 0.0f);
                hold_0(fixed_mask_0(c_37), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_37, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_37, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_37, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_37, 11U)]) = ap_ang_0;
                uint _S1856 = __ballot_sync(_S1849, true);
                c_37 = c_37 + 256U;
                _S1849 = _S1856;
            }
            uint _S1857 = 0U;
            __syncthreads();
            float _S1858 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, _S1699);
            uint _S1859 = cg_total_1 + 1U;
            bool _S1860 = _S1858 <= 0.0f;
            uint _S1861 = __ballot_sync(_S1699, _S1860);
            if(_S1860)
            {
                uint _S1862 = __ballot_sync(_S1699, false);
                uint _S1863 = __ballot_sync(_S1820, false);
                uint _S1864 = __ballot_sync(_S1696, true);
                cg_total_0 = _S1859;
                i_27 = _S1864;
                break;
            }
            else
            {
                uint _S1865 = __ballot_sync(_S1699, true);
                _S1857 = _S1865;
            }
            float _S1866 = rz_0 / _S1858;
            uint c_43 = _S1710;
            uint _S1867;
            _S1867 = _S1857;
            for(;;)
            {
                bool _S1868 = c_43 < c1_1;
                uint _S1869 = __ballot_sync(_S1867, _S1868);
                if(_S1868)
                {
                    uint _S1870 = __ballot_sync(_S1867, true);
                }
                else
                {
                    uint _S1871 = __ballot_sync(_S1867, false);
                    uint _S1872 = __ballot_sync(_S1867, false);
                    uint _S1873 = __ballot_sync(_S1857, true);
                    _S1700 = _S1873;
                    break;
                }
                uint _S1874 = sv_0(c_43, 2U);
                float4  _S1875 = *(&(globalParams_0->scratch_0)[_S1874]);
                float4  _S1876 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1874]) = make_float4 ((float3 {_S1875.x, _S1875.y, _S1875.z} + make_float3 (_S1866) * float3 {_S1876.x, _S1876.y, _S1876.z}).x, (float3 {_S1875.x, _S1875.y, _S1875.z} + make_float3 (_S1866) * float3 {_S1876.x, _S1876.y, _S1876.z}).y, (float3 {_S1875.x, _S1875.y, _S1875.z} + make_float3 (_S1866) * float3 {_S1876.x, _S1876.y, _S1876.z}).z, 0.0f);
                uint _S1877 = sv_0(c_43, 3U);
                float4  _S1878 = *(&(globalParams_0->scratch_0)[_S1877]);
                float4  _S1879 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1877]) = make_float4 ((float3 {_S1878.x, _S1878.y, _S1878.z} + make_float3 (_S1866) * float3 {_S1879.x, _S1879.y, _S1879.z}).x, (float3 {_S1878.x, _S1878.y, _S1878.z} + make_float3 (_S1866) * float3 {_S1879.x, _S1879.y, _S1879.z}).y, (float3 {_S1878.x, _S1878.y, _S1878.z} + make_float3 (_S1866) * float3 {_S1879.x, _S1879.y, _S1879.z}).z, 0.0f);
                uint _S1880 = sv_0(c_43, 4U);
                float4  _S1881 = *(&(globalParams_0->scratch_0)[_S1880]);
                float4  _S1882 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1880]) = make_float4 ((float3 {_S1881.x, _S1881.y, _S1881.z} - make_float3 (_S1866) * float3 {_S1882.x, _S1882.y, _S1882.z}).x, (float3 {_S1881.x, _S1881.y, _S1881.z} - make_float3 (_S1866) * float3 {_S1882.x, _S1882.y, _S1882.z}).y, (float3 {_S1881.x, _S1881.y, _S1881.z} - make_float3 (_S1866) * float3 {_S1882.x, _S1882.y, _S1882.z}).z, 0.0f);
                uint _S1883 = sv_0(c_43, 5U);
                float4  _S1884 = *(&(globalParams_0->scratch_0)[_S1883]);
                float4  _S1885 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1883]) = make_float4 ((float3 {_S1884.x, _S1884.y, _S1884.z} - make_float3 (_S1866) * float3 {_S1885.x, _S1885.y, _S1885.z}).x, (float3 {_S1884.x, _S1884.y, _S1884.z} - make_float3 (_S1866) * float3 {_S1885.x, _S1885.y, _S1885.z}).y, (float3 {_S1884.x, _S1884.y, _S1884.z} - make_float3 (_S1866) * float3 {_S1885.x, _S1885.y, _S1885.z}).z, 0.0f);
                uint _S1886 = __ballot_sync(_S1867, true);
                c_43 = c_43 + 256U;
                _S1867 = _S1886;
            }
            uint _S1887 = 0U;
            __syncthreads();
            float _S1888 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1700);
            bool _S1889 = (F32_sqrt((_S1888))) <= (0.00009999999747379f * _S1819);
            uint _S1890 = __ballot_sync(_S1700, _S1889);
            if(_S1889)
            {
                uint _S1891 = __ballot_sync(_S1700, false);
                uint _S1892 = __ballot_sync(_S1820, false);
                uint _S1893 = __ballot_sync(_S1696, true);
                cg_total_0 = _S1859;
                i_27 = _S1893;
                break;
            }
            else
            {
                uint _S1894 = __ballot_sync(_S1700, true);
                _S1887 = _S1894;
            }
            uint c_44 = _S1710;
            uint _S1895;
            _S1895 = _S1887;
            for(;;)
            {
                bool _S1896 = c_44 < c1_1;
                uint _S1897 = __ballot_sync(_S1895, _S1896);
                if(_S1896)
                {
                    uint _S1898 = __ballot_sync(_S1895, true);
                }
                else
                {
                    uint _S1899 = __ballot_sync(_S1895, false);
                    uint _S1900 = __ballot_sync(_S1895, false);
                    uint _S1901 = __ballot_sync(_S1887, true);
                    _S1701 = _S1901;
                    break;
                }
                precondition_0(c_44);
                uint _S1902 = __ballot_sync(_S1895, true);
                c_44 = c_44 + 256U;
                _S1895 = _S1902;
            }
            __syncthreads();
            uint _S1903 = __ballot_sync(_S1701, free_0);
            uint _S1904;
            if(free_0)
            {
                Island_0 _S1905 = isl_21;
                project_displacement_slot_0(tid_18, &_S1905, 6U, _S1903);
                uint _S1906 = __ballot_sync(_S1701, true);
                _S1904 = _S1906;
            }
            else
            {
                uint _S1907 = __ballot_sync(_S1701, true);
                _S1904 = _S1907;
            }
            float _S1908 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1904);
            float _S1909 = _S1908 / rz_0;
            uint c_45 = _S1710;
            uint _S1910 = _S1904;
            for(;;)
            {
                bool _S1911 = c_45 < c1_1;
                uint _S1912 = __ballot_sync(_S1910, _S1911);
                if(_S1911)
                {
                    uint _S1913 = __ballot_sync(_S1910, true);
                }
                else
                {
                    uint _S1914 = __ballot_sync(_S1910, false);
                    uint _S1915 = __ballot_sync(_S1910, false);
                    uint _S1916 = __ballot_sync(_S1904, true);
                    break;
                }
                uint _S1917 = sv_0(c_45, 8U);
                float4  _S1918 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S1919 = *(&(globalParams_0->scratch_0)[_S1917]);
                *(&(globalParams_0->scratch_0)[_S1917]) = make_float4 ((float3 {_S1918.x, _S1918.y, _S1918.z} + make_float3 (_S1909) * float3 {_S1919.x, _S1919.y, _S1919.z}).x, (float3 {_S1918.x, _S1918.y, _S1918.z} + make_float3 (_S1909) * float3 {_S1919.x, _S1919.y, _S1919.z}).y, (float3 {_S1918.x, _S1918.y, _S1918.z} + make_float3 (_S1909) * float3 {_S1919.x, _S1919.y, _S1919.z}).z, 0.0f);
                uint _S1920 = sv_0(c_45, 9U);
                float4  _S1921 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S1922 = *(&(globalParams_0->scratch_0)[_S1920]);
                *(&(globalParams_0->scratch_0)[_S1920]) = make_float4 ((float3 {_S1921.x, _S1921.y, _S1921.z} + make_float3 (_S1909) * float3 {_S1922.x, _S1922.y, _S1922.z}).x, (float3 {_S1921.x, _S1921.y, _S1921.z} + make_float3 (_S1909) * float3 {_S1922.x, _S1922.y, _S1922.z}).y, (float3 {_S1921.x, _S1921.y, _S1921.z} + make_float3 (_S1909) * float3 {_S1922.x, _S1922.y, _S1922.z}).z, 0.0f);
                uint _S1923 = __ballot_sync(_S1910, true);
                c_45 = c_45 + 256U;
                _S1910 = _S1923;
            }
            __syncthreads();
            uint _S1924 = __ballot_sync(_S1820, true);
            uint _S1925 = k_22 + 1U;
            rz_0 = _S1908;
            k_22 = _S1925;
            cg_total_1 = _S1859;
            _S1820 = _S1924;
        }
        c_37 = _S1710;
        _S1697 = i_27;
        for(;;)
        {
            bool _S1926 = c_37 < c1_1;
            uint _S1927 = __ballot_sync(_S1697, _S1926);
            if(_S1926)
            {
                uint _S1928 = __ballot_sync(_S1697, true);
            }
            else
            {
                uint _S1929 = __ballot_sync(_S1697, false);
                uint _S1930 = __ballot_sync(_S1697, false);
                uint _S1931 = __ballot_sync(i_27, true);
                break;
            }
            uint _S1932 = 4U * c_37;
            float4  _S1933 = *(&(globalParams_0->state_0)[_S1932]);
            float3  u_4 = float3 {_S1933.x, _S1933.y, _S1933.z};
            uint _S1934 = sv_0(c_37, 21U);
            float4  _S1935 = *(&(globalParams_0->scratch_0)[_S1934]);
            float3  u_lo_0 = float3 {_S1935.x, _S1935.y, _S1935.z};
            uint _S1936 = _S1932 + 1U;
            float4  _S1937 = *(&(globalParams_0->state_0)[_S1936]);
            float3  th_5 = float3 {_S1937.x, _S1937.y, _S1937.z};
            uint _S1938 = sv_0(c_37, 22U);
            float4  _S1939 = *(&(globalParams_0->scratch_0)[_S1938]);
            float3  th_lo_0 = float3 {_S1939.x, _S1939.y, _S1939.z};
            float4  _S1940 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S1940.x, _S1940.y, _S1940.z});
            float4  _S1941 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_5, &th_lo_0, float3 {_S1941.x, _S1941.y, _S1941.z});
            *(&(globalParams_0->state_0)[_S1932]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S1932])).w);
            *(&(globalParams_0->state_0)[_S1936]) = make_float4 (th_5.x, th_5.y, th_5.z, (*(&(globalParams_0->state_0)[_S1936])).w);
            *(&(globalParams_0->scratch_0)[_S1934]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1938]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1942 = __ballot_sync(_S1697, true);
            c_37 = c_37 + 256U;
            _S1697 = _S1942;
        }
        __syncthreads();
        uint _S1943 = newton_0 + 1U;
        uint _S1944 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1943;
        c_38 = _S1944;
    }
    i_26 = b0_0 + tid_18;
    for(;;)
    {
        if(i_26 < _S1709)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_26);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_26]);
        (&bd_1)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_5);
        (&bd_1)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_1)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_26]) = bd_1;
        write_bond_loads_0(i_26, i_26, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_26 = i_26 + 256U;
    }
    __syncthreads();
    c_37 = _S1710;
    for(;;)
    {
        if(c_37 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_5;
        float3  mi_6;
        gather_loads_0(c_37, &fi_5, &mi_6);
        float3  reaction_1;
        if((fixed_mask_0(c_37)) != 0U)
        {
            float4  _S1945 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S1945.x, _S1945.y, _S1945.z} + fi_5);
        }
        else
        {
            uint _S1946 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S1946 + 1U])).w, (*(&(globalParams_0->state_0)[_S1946 + 2U])).w, (*(&(globalParams_0->state_0)[_S1946 + 3U])).w);
        }
        uint _S1947 = 4U * c_37;
        uint _S1948 = _S1947 + 1U;
        float4  _S1949 = *(&(globalParams_0->state_0)[_S1948]);
        *(&(globalParams_0->state_0)[_S1948]) = make_float4 (float3 {_S1949.x, _S1949.y, _S1949.z}.x, float3 {_S1949.x, _S1949.y, _S1949.z}.y, float3 {_S1949.x, _S1949.y, _S1949.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S1947 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S1947 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_18 == 0U)
    {
        float4  * _S1950 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1703)]);
        float _S1951 = (U32_asfloat((newton_0)));
        float _S1952 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1950 = make_float4 (residual_0, _S1951, _S1952, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1703])->info_1)->z) = _S1705 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_19 = threadIdx.x;
    uint _S1953 = blockIdx.x;
    Island_0 * _S1954 = (&(globalParams_0->islands_0)[_S1953]);
    Island_0 isl_22 = *_S1954;
    bool _S1955;
    if((((*_S1954).info_1.x) & 16U) == 0U)
    {
        _S1955 = true;
    }
    else
    {
        _S1955 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S1955)
    {
        return;
    }
    seen_clear_0(tid_19);
    if(tid_19 == 0U)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1956 = isl_22.info_1.w;
    uint i_29 = isl_22.range_0.z + tid_19;
    for(;;)
    {
        if(i_29 < (isl_22.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1957 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S1958 = slang_ldg_0(&_S1957->law_0);
        uint _S1959 = 4U * _S1958.ids_0.y;
        float4  _S1960 = *(&(globalParams_0->state_0)[_S1959]);
        float4  _S1961 = *(&(globalParams_0->state_0)[_S1959 + 1U]);
        uint _S1962 = 4U * _S1958.ids_0.z;
        float4  _S1963 = *(&(globalParams_0->state_0)[_S1962]);
        float4  _S1964 = *(&(globalParams_0->state_0)[_S1962 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S1960.x, _S1960.y, _S1960.z}, float3 {_S1961.x, _S1961.y, _S1961.z}, float3 {_S1963.x, _S1963.y, _S1963.z}, float3 {_S1964.x, _S1964.y, _S1964.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1965 = d_lin_7;
        float3  _S1966 = d_ang_6;
        float _S1967 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1968 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1969 = _S1968 != 0U;
        JointBond_0 _S1970 = _S1958;
        JointState_0 _S1971 = previous_3;
        JointResponse_0 _S1972 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1958.ids_0.x], &_S1970, &_S1971, _S1965, _S1966, _S1967, _S1969);
        if((_S1972.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1955 = true;
        }
        else
        {
            _S1955 = (_S1972.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1955)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1972.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1972.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1972.force_lin_1.x, _S1972.force_lin_1.y, _S1972.force_lin_1.z, _S1972.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S1972.force_ang_1.x, _S1972.force_ang_1.y, _S1972.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1972.state_1.utilization_0))));
        JointState_0 _S1973 = previous_3;
        bool _S1974 = is_damaged_0(&_S1973);
        bool _S1975;
        if(!_S1974)
        {
            JointState_0 _S1976 = _S1972.state_1;
            bool _S1977 = is_damaged_0(&_S1976);
            _S1975 = _S1977;
        }
        else
        {
            _S1975 = false;
        }
        bool _S1978;
        if(_S1975)
        {
            _S1978 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1978 = false;
        }
        if(_S1978)
        {
            *&((&(&bd_2)->events_0)->x) = _S1956;
            *&((&(&bd_2)->events_0)->w) = _S1972.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S1979;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S1979 = (_S1972.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S1979 = false;
        }
        bool _S1980;
        if(_S1979)
        {
            _S1980 = (_S1972.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1980 = false;
        }
        bool _S1981;
        if(_S1980)
        {
            float _S1982 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1958.ids_0.x], _S1972.state_1.life_0);
            _S1981 = _S1982 <= 0.99000000953674316f;
        }
        else
        {
            _S1981 = false;
        }
        if(_S1981)
        {
            *&((&(&bd_2)->events_0)->y) = _S1956;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1972.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1956;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S1972.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S1972.force_lin_1, _S1972.force_ang_1, (F32_max((_S1972.measures_0.tension_0), (_S1972.measures_0.compression_0))));
        if((flags_4 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_29 = i_29 + 256U;
    }
    __syncthreads();
    if(tid_19 != 0U)
    {
        return;
    }
    if(((*&g_halt_0) | (*&g_run_0)) != 0U)
    {
        uint _S1983 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S1984 = _S1983 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1953])->info_1)->z) = _S1984 | i_29;
    }
    uint _S1985 = ((isl_22.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_29 = 128U;
    }
    else
    {
        i_29 = 0U;
    }
    (&(globalParams_0->islands_0)[_S1953])->coverage_0 = _S1985 | i_29;
    return;
}

