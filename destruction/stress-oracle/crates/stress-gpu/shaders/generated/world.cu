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
    uint4  done_0;
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

static __device__ void pair_contact_0(uint i_8)
{
    uint _S133 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S133 + 6U * i_8;
    uint _S134 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S135 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S136 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S137 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S138 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S139 = (U32_asfloat((_S138)));
    uint _S140 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S141 = (U32_asfloat((_S140)));
    float _S142 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S143 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S143 + 2U * _S136;
    WorldPoint_0 wa_0 = chunk_world_0(_S134);
    WorldPoint_0 _S144 = chunk_world_0(_S135);
    WorldPoint_0 _S145 = wa_0;
    float3  _S146 = world_diff_0(&_S144, &_S145);
    float _S147 = length_0(_S146);
    float4  _S148 = __ldg(&(&(globalParams_0->chunks_0)[_S134])->half_0);
    float _S149 = _S148.w;
    float4  _S150 = __ldg(&(&(globalParams_0->chunks_0)[_S135])->half_0);
    bool touching_0 = !(_S147 > (_S149 + _S150.w));
    uint _S151 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S152 = (&(globalParams_0->scratch_0)[_S151 + i_8]);
    float4  ledger_1 = *_S152;
    uint flags_0 = (F32_asuint(((*_S152).w)));
    float3  _S153 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S134, _S153);
    Box_0 bb_1 = chunk_box_0(_S135, _S146);
    Box_0 _S154 = ba_1;
    uint _S155 = sample_count_0(&_S154);
    Box_0 _S156 = bb_1;
    uint _S157 = sample_count_0(&_S156);
    uint _S158 = _S155 + _S157;
    uint e_1;
    bool has_state_0;
    if(!touching_0)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = 0U;
            for(;;)
            {
                if(e_1 < _S158)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S137 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
            uint _S159 = __ldg(&globalParams_0->params_0->ledger_base_0);
            *(&(globalParams_0->scratch_0)[_S159 + i_8]) = ledger_1;
        }
        return;
    }
    Box_0 _S160 = ba_1;
    Box_0 _S161 = bb_1;
    bool _S162 = may_overlap_0(&_S160, &_S161);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    if(_S162)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S134, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S135, &vb0_0, &wb0_0);
        e_1 = 0U;
        count_0 = 0U;
        uint engaged_0 = 0U;
        for(;;)
        {
            if(e_1 < _S158)
            {
            }
            else
            {
                break;
            }
            Box_0 _S163 = ba_1;
            Box_0 _S164 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S165 = pair_point_0(&_S163, &_S164, _S155, e_1, &p_2, &n_2, &d_5);
            if(!_S165)
            {
                uint _S166 = _S137 + e_1;
                if(!is_nan_0((*(&(globalParams_0->contact_state_0)[_S166])).x))
                {
                    *(&(globalParams_0->contact_state_0)[_S166]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + 1U;
                continue;
            }
            uint _S167 = count_0 + 1U;
            uint _S168 = _S137 + e_1;
            float4  * _S169 = (&(globalParams_0->contact_state_0)[_S168]);
            float4  entry_0 = *_S169;
            if(is_nan_0((*_S169).x))
            {
                has_state_0 = true;
            }
            else
            {
                float4  _S170 = entry_0;
                has_state_0 = (dot_0(float3 {_S170.y, _S170.z, _S170.w}, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S142 + 9.99999971718068537e-10f))
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
            *(&(globalParams_0->contact_state_0)[_S168]) = entry_0;
            uint engaged_1;
            if((d_5 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + 1U;
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S167;
            engaged_0 = engaged_1;
            e_1 = e_1 + 1U;
        }
        if(count_0 > 0U)
        {
            float4  _S171 = __ldg(&(&(globalParams_0->chunks_0)[_S134])->cmat_0);
            float _S172 = _S171.x;
            float4  _S173 = __ldg(&(&(globalParams_0->chunks_0)[_S135])->cmat_0);
            float _S174 = _S173.x;
            float3  _S175 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S176 = ba_1;
            Box_0 _S177 = bb_1;
            float _S178 = contact_stiffness_0(_S172, &_S176, _S174, &_S177, _S175);
            float _S179 = _S178 / (F32_max((float(engaged_0)), (10.0f)));
            e_1 = 0U;
            fa_0 = _S153;
            ta_0 = _S153;
            fb_0 = _S153;
            tb_0 = _S153;
            stored_sum_0 = 0.0f;
            for(;;)
            {
                if(e_1 < _S158)
                {
                }
                else
                {
                    break;
                }
                Box_0 _S180 = ba_1;
                Box_0 _S181 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S182 = pair_point_0(&_S180, &_S181, _S155, e_1, &p_3, &n_3, &d_6);
                if(!_S182)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S137 + e_1])).x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S179, _S139, _S141, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S142, engaged_0, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S183 = - f_1;
                float3  fb_1 = fb_0 + _S183;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S183);
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
            fa_0 = _S153;
            ta_0 = _S153;
            fb_0 = _S153;
            tb_0 = _S153;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S153;
        ta_0 = _S153;
        fb_0 = _S153;
        tb_0 = _S153;
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
            if(e_1 < _S158)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S137 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
    bool _S184;
    if(loaded_0)
    {
        _S184 = true;
    }
    else
    {
        _S184 = (flags_0 & 2U) != 0U;
    }
    if(_S184)
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
    uint _S185 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S185 + i_8]) = ledger_1;
    return;
}

static __device__ Box_0 impactor_box_0(Impactor_0 * imp_0, float3  center_3, float3  half_3)
{
    Quat_0 q_6 = quat_of_0(imp_0->rotation_1);
    Box_0 b_14;
    (&b_14)->center_1 = center_3;
    float3  _S186 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S187 = q_6;
    float3  _S188 = rotate_0(&_S187, _S186);
    (&b_14)->axis0_0 = _S188;
    float3  _S189 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S190 = q_6;
    float3  _S191 = rotate_0(&_S190, _S189);
    (&b_14)->axis1_0 = _S191;
    float3  _S192 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S193 = q_6;
    float3  _S194 = rotate_0(&_S193, _S192);
    (&b_14)->axis2_0 = _S194;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_15)
{
    uint _S195;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S195 = 1U;
    }
    else
    {
        uint _S196 = sample_count_0(b_15);
        _S195 = _S196 + 14U;
    }
    return _S195;
}

static __device__ bool sphere_contact_0(Box_0 * b_16, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S197 = make_float3 (0.0f);
    *point_0 = _S197;
    *normal_3 = _S197;
    *depth_2 = 0.0f;
    float3  _S198 = b_16->center_1;
    float3  r_3 = center_4 - b_16->center_1;
    float3  _S199 = b_16->axis0_0;
    float3  _S200 = b_16->axis1_0;
    float3  _S201 = b_16->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_16->axis0_0), dot_0(r_3, b_16->axis1_0), dot_0(r_3, b_16->axis2_0));
    uint _S202 = b_16->hull_v_0;
    if((b_16->hull_v_0) != 0U)
    {
        uint face_2;
        float _S203 = hull_signed_distance_0(b_16, local_4, &face_2);
        if(_S203 >= radius_0)
        {
            return false;
        }
        float4  _S204 = __ldg((&(globalParams_0->loads_0)[b_16->hull_at_0 + _S202 + face_2]));
        float3  _S205 = box_to_world_0(b_16, float3 {_S204.x, _S204.y, _S204.z});
        *normal_3 = _S205;
        *point_0 = center_4 - _S205 * make_float3 ((F32_max((_S203), (0.0f))));
        *depth_2 = radius_0 - _S203;
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
        *normal_3 = _S199 * make_float3 (dn_0.x) + _S200 * make_float3 (dn_0.y) + _S201 * make_float3 (dn_0.z);
        *point_0 = _S198 + _S199 * make_float3 (q_7.x) + _S200 * make_float3 (q_7.y) + _S201 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S206 = penetration_0(b_16, center_4, &inside_0, &n_4);
    if(!_S206)
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
    float3  _S207 = make_float3 (0.0f);
    *p_4 = _S207;
    *n_5 = _S207;
    *d_8 = 0.0f;
    float4  _S208 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S209 = sphere_contact_0(b_17, _S207, _S208.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S209)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S210 = sample_count_0(b_17);
    if(j_0 < _S210)
    {
        float3  _S211 = sample_point_0(b_17, j_0);
        *p_4 = _S211;
        bool _S212 = penetration_0(shrunk_0, _S211, d_8, n_5);
        return _S212;
    }
    float3  _S213 = sample_point_0(shrunk_0, j_0 - _S210);
    *p_4 = _S213;
    bool _S214 = penetration_0(b_17, _S213, d_8, n_5);
    if(!_S214)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S215)
{
    Impactor_0 * _S216 = (&(globalParams_0->impactors_0)[_S215]);
    WorldPoint_0 wi_0;
    float4  _S217 = _S216->position_1;
    (&wi_0)->hi_0 = float3 {_S217.x, _S217.y, _S217.z};
    float4  _S218 = _S216->position_err_1;
    (&wi_0)->lo_0 = float3 {_S218.x, _S218.y, _S218.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S219, float3  _S220, float3  _S221)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S219])->rotation_1);
    Box_0 b_18;
    (&b_18)->center_1 = _S220;
    float3  _S222 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S223 = q_8;
    float3  _S224 = rotate_0(&_S223, _S222);
    (&b_18)->axis0_0 = _S224;
    float3  _S225 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S226 = q_8;
    float3  _S227 = rotate_0(&_S226, _S225);
    (&b_18)->axis1_0 = _S227;
    float3  _S228 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S229 = q_8;
    float3  _S230 = rotate_0(&_S229, _S228);
    (&b_18)->axis2_0 = _S230;
    (&b_18)->half_2 = _S221;
    (&b_18)->hull_at_0 = 0U;
    (&b_18)->hull_v_0 = 0U;
    (&b_18)->hull_f_0 = 0U;
    return b_18;
}

static __device__ Box_0 impactor_shrunk_0(uint _S231, float _S232, Box_0 * _S233)
{
    Box_0 shrunk_1 = *_S233;
    (&shrunk_1)->half_2 = _S233->half_2 - min_0(make_float3 (_S232), _S233->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S234, float _S235, Box_0 * _S236, Box_0 * _S237, uint _S238, float3  * _S239, float3  * _S240, float * _S241)
{
    Impactor_0 _S242 = *(&(globalParams_0->impactors_0)[_S234]);
    float3  _S243 = make_float3 (0.0f);
    *_S239 = _S243;
    *_S240 = _S243;
    *_S241 = 0.0f;
    if((_S242.shape_0.x) == 0.0f)
    {
        bool _S244 = sphere_contact_0(_S237, _S243, _S242.shape_0.y - _S235, _S239, _S240, _S241);
        if(!_S244)
        {
            return false;
        }
        *_S240 = - *_S240;
        return true;
    }
    uint _S245 = sample_count_0(_S237);
    if(_S238 < _S245)
    {
        float3  _S246 = sample_point_0(_S237, _S238);
        *_S239 = _S246;
        bool _S247 = penetration_0(_S236, _S246, _S241, _S240);
        return _S247;
    }
    float3  _S248 = sample_point_0(_S236, _S238 - _S245);
    *_S239 = _S248;
    bool _S249 = penetration_0(_S237, _S248, _S241, _S240);
    if(!_S249)
    {
        return false;
    }
    *_S240 = - *_S240;
    return true;
}

static __device__ uint impactor_contact_count_0(uint _S250, float _S251, Box_0 * _S252, Box_0 * _S253)
{
    Impactor_0 _S254 = *(&(globalParams_0->impactors_0)[_S250]);
    uint j_1 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S255 = _S254;
        uint _S256 = impactor_slots_0(&_S255, _S253);
        if(j_1 < _S256)
        {
        }
        else
        {
            break;
        }
        float3  p_5;
        float3  n_6;
        float d_9;
        bool _S257 = impactor_contact_1(_S250, _S251, _S252, _S253, j_1, &p_5, &n_6, &d_9);
        if(_S257)
        {
            count_1 = count_1 + 1U;
        }
        j_1 = j_1 + 1U;
    }
    return count_1;
}

static __device__ void impactor_candidate_forces_0(uint k_5)
{
    uint _S258 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S259 = 3U * k_5;
    uint at_1 = _S258 + _S259;
    uint _S260 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S261 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S262 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S262]);
    float _S263 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S264 = make_float3 (0.0f);
    uint _S265 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S265 + _S259]);
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if((imp_3.cand_0.z) == 0U)
    {
        WorldPoint_0 _S266 = impactor_point_0(_S262);
        WorldPoint_0 _S267 = chunk_world_0(_S260);
        WorldPoint_0 _S268 = _S266;
        float3  _S269 = world_diff_0(&_S267, &_S268);
        float _S270 = length_0(_S269);
        float _S271 = imp_3.half_1.w;
        float4  _S272 = __ldg(&(&(globalParams_0->chunks_0)[_S260])->half_0);
        if(!(_S270 > (_S271 + _S272.w)))
        {
            float4  _S273 = imp_3.half_1;
            Box_0 _S274 = impactor_box_1(_S262, _S264, float3 {_S273.x, _S273.y, _S273.z});
            Box_0 b_19 = chunk_box_0(_S260, _S269);
            float _S275 = imp_3.mat_0.x;
            float4  _S276 = __ldg(&(&(globalParams_0->chunks_0)[_S260])->cmat_0);
            float _S277 = _S276.x;
            float3  _S278 = b_19.center_1 - _S274.center_1;
            Box_0 _S279 = _S274;
            Box_0 _S280 = b_19;
            float _S281 = contact_stiffness_0(_S275, &_S279, _S277, &_S280, _S278);
            float _S282 = imp_3.geom_0.y;
            Box_0 _S283 = _S274;
            Box_0 _S284 = impactor_shrunk_0(_S262, _S282, &_S283);
            Box_0 _S285 = _S284;
            Box_0 _S286 = b_19;
            uint _S287 = impactor_contact_count_0(_S262, _S282, &_S285, &_S286);
            bool _S288 = (imp_3.shape_0.x) == 0.0f;
            float _S289;
            if(_S288)
            {
                _S289 = _S281;
            }
            else
            {
                _S289 = _S281 / (F32_max((float(_S287)), (10.0f)));
            }
            uint _S290;
            if(_S288)
            {
                _S290 = 1U;
            }
            else
            {
                _S290 = _S287;
            }
            float4  _S291 = __ldg(&(&(globalParams_0->chunks_0)[_S260])->center_0);
            float m_1 = _S291.w;
            float _S292 = imp_3.mat_0.z;
            float _S293 = m_1 * _S292 / (m_1 + _S292);
            float _S294 = __ldg(&globalParams_0->params_0->pair_friction_0);
            float _S295;
            if(_S294 >= 0.0f)
            {
                float _S296 = __ldg(&globalParams_0->params_0->pair_friction_0);
                _S295 = _S296;
            }
            else
            {
                float _S297 = imp_3.mat_0.y;
                float4  _S298 = __ldg(&(&(globalParams_0->chunks_0)[_S260])->cmat_0);
                _S295 = (F32_min((_S297), (_S298.y)));
            }
            float4  _S299 = imp_3.velocity_1;
            float4  _S300 = imp_3.velocity_err_1;
            float3  _S301 = float3 {_S299.x, _S299.y, _S299.z} + float3 {_S300.x, _S300.y, _S300.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S260, &vc_0, &wc_0);
            uint j_2 = 0U;
            f_sum_0 = _S264;
            t_sum_0 = _S264;
            imp_f_0 = _S264;
            imp_t_0 = _S264;
            for(;;)
            {
                bool _S302;
                if(_S287 > 0U)
                {
                    Impactor_0 _S303 = imp_3;
                    Box_0 _S304 = b_19;
                    uint _S305 = impactor_slots_0(&_S303, &_S304);
                    _S302 = j_2 < _S305;
                }
                else
                {
                    _S302 = false;
                }
                if(_S302)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S306 = imp_3;
                Box_0 _S307 = _S284;
                Box_0 _S308 = b_19;
                float3  p_6;
                float3  nrm_0;
                float dep_0;
                bool _S309 = impactor_contact_0(&_S306, _S282, &_S307, &_S308, j_2, &p_6, &nrm_0, &dep_0);
                if(!_S309)
                {
                    j_2 = j_2 + 1U;
                    continue;
                }
                float4  _S310 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S289, _S293, _S295, dep_0 * imp_3.geom_0.x, nrm_0, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S301 + cross_0(float3 {_S310.x, _S310.y, _S310.z}, p_6)), _S263, _S290, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_19.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), diss_1);
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_2 = j_2 + 1U;
            }
        }
        else
        {
            f_sum_0 = _S264;
            t_sum_0 = _S264;
            imp_f_0 = _S264;
            imp_t_0 = _S264;
        }
    }
    else
    {
        f_sum_0 = _S264;
        t_sum_0 = _S264;
        imp_f_0 = _S264;
        imp_t_0 = _S264;
    }
    uint _S311 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S312 = 2U * _S261;
    *(&(globalParams_0->scratch_0)[_S311 + _S312]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S313 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S313 + _S312 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S314 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S314 + _S259]) = data_0;
    uint _S315 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S315 + _S259 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S316 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S316 + _S259 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    return;
}

static __device__ void travel_check_0(uint c_4)
{
    ChunkStatic_0 * _S317 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S318 = __ldg(&_S317->cinfo_0);
    if((_S318.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S319 = __ldg(&_S317->start_hi_0);
    float3  _S320 = wp_0.hi_0 - float3 {_S319.x, _S319.y, _S319.z};
    float4  _S321 = __ldg(&_S317->start_lo_0);
    if((length_0(_S320 + (wp_0.lo_0 - float3 {_S321.x, _S321.y, _S321.z}) + wp_0.rel_0)) > (_S319.w))
    {
        uint _S322 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S323 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S322])->info_1)->z) = ((&(globalParams_0->islands_0)[_S323])->info_1.z) | 1U;
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
    uint _S324 = __ldg(&globalParams_0->params_0->pair_count_0);
    if(i_9 < _S324)
    {
        pair_contact_0(i_9);
    }
    else
    {
        uint _S325 = __ldg(&globalParams_0->params_0->pair_count_0);
        uint _S326 = __ldg(&globalParams_0->params_0->cand_count_0);
        if(i_9 < (_S325 + _S326))
        {
            uint _S327 = __ldg(&globalParams_0->params_0->pair_count_0);
            impactor_candidate_forces_0(i_9 - _S327);
        }
        else
        {
            uint _S328 = __ldg(&globalParams_0->params_0->pair_count_0);
            uint _S329 = __ldg(&globalParams_0->params_0->cand_count_0);
            uint _S330 = _S328 + _S329;
            uint _S331 = __ldg(&globalParams_0->params_0->chunk_count_0);
            if(i_9 < (_S330 + _S331))
            {
                uint _S332 = __ldg(&globalParams_0->params_0->pair_count_0);
                uint _S333 = i_9 - _S332;
                uint _S334 = __ldg(&globalParams_0->params_0->cand_count_0);
                travel_check_0(_S333 - _S334);
            }
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S335 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S336;
    if(k_6 >= _S335)
    {
        _S336 = true;
    }
    else
    {
        _S336 = stopped_0();
    }
    if(_S336)
    {
        return;
    }
    uint _S337 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S338 = 3U * k_6;
    uint at_2 = _S337 + _S338;
    uint _S339 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S340 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S341 = (&(globalParams_0->impactors_0)[_S340]);
    Impactor_0 imp_4 = *_S341;
    if(((*_S341).cand_0.z) == 0U)
    {
        _S336 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S336 = false;
    }
    float total_0;
    float ksum_0;
    if(_S336)
    {
        WorldPoint_0 _S342 = impactor_point_0(_S340);
        WorldPoint_0 _S343 = chunk_world_0(_S339);
        WorldPoint_0 _S344 = _S342;
        float3  _S345 = world_diff_0(&_S343, &_S344);
        float _S346 = length_0(_S345);
        float _S347 = imp_4.half_1.w;
        float4  _S348 = __ldg(&(&(globalParams_0->chunks_0)[_S339])->half_0);
        if(!(_S346 > (_S347 + _S348.w)))
        {
            float4  _S349 = imp_4.half_1;
            Box_0 _S350 = impactor_box_1(_S340, make_float3 (0.0f), float3 {_S349.x, _S349.y, _S349.z});
            Box_0 b_20 = chunk_box_0(_S339, _S345);
            float _S351 = imp_4.mat_0.x;
            float4  _S352 = __ldg(&(&(globalParams_0->chunks_0)[_S339])->cmat_0);
            float _S353 = _S352.x;
            float3  _S354 = b_20.center_1 - _S350.center_1;
            Box_0 _S355 = _S350;
            Box_0 _S356 = b_20;
            float _S357 = contact_stiffness_0(_S351, &_S355, _S353, &_S356, _S354);
            float _S358 = imp_4.crush_1.w;
            Box_0 _S359 = _S350;
            Box_0 _S360 = impactor_shrunk_0(_S340, _S358, &_S359);
            Box_0 _S361 = _S360;
            Box_0 _S362 = b_20;
            uint _S363 = impactor_contact_count_0(_S340, _S358, &_S361, &_S362);
            float _S364;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S364 = _S357;
            }
            else
            {
                _S364 = _S357 / (F32_max((float(_S363)), (10.0f)));
            }
            uint j_3 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S363 > 0U)
                {
                    Impactor_0 _S365 = imp_4;
                    Box_0 _S366 = b_20;
                    uint _S367 = impactor_slots_0(&_S365, &_S366);
                    _S336 = j_3 < _S367;
                }
                else
                {
                    _S336 = false;
                }
                if(_S336)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S368 = imp_4;
                Box_0 _S369 = _S360;
                Box_0 _S370 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S371 = impactor_contact_0(&_S368, _S358, &_S369, &_S370, j_3, &p_7, &nrm_1, &dep_1);
                if(!_S371)
                {
                    j_3 = j_3 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S364;
                total_0 = total_0 + _S364 * dep_1;
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
    uint _S372 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S372 + _S338]);
    uint _S373 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S373 + _S338]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S374;
    uint _S375 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S376 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S377 = ii_0 >= _S376;
    uint _S378 = __ballot_sync(_S375, _S377);
    bool _S379;
    uint k_7;
    if(_S377)
    {
        uint _S380 = __ballot_sync(_S375, true);
        _S379 = true;
        k_7 = _S380;
    }
    else
    {
        bool _S381 = stopped_0();
        uint _S382 = __ballot_sync(_S375, true);
        _S379 = _S381;
        k_7 = _S382;
    }
    uint _S383 = 0U;
    uint _S384 = __ballot_sync(k_7, _S379);
    if(_S379)
    {
        return;
    }
    else
    {
        uint _S385 = __ballot_sync(k_7, true);
        _S383 = _S385;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S386 = make_float4 (0.0f);
    float4  shares_0 = _S386;
    float4  unused_0 = _S386;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S387;
    _S387 = _S383;
    for(;;)
    {
        bool _S388 = k_7 < ((&imp_5)->cand_0.y);
        uint _S389 = __ballot_sync(_S387, _S388);
        if(_S388)
        {
            uint _S390 = __ballot_sync(_S387, true);
        }
        else
        {
            uint _S391 = __ballot_sync(_S387, false);
            uint _S392 = __ballot_sync(_S387, false);
            uint _S393 = __ballot_sync(_S383, true);
            _S374 = _S393;
            break;
        }
        uint _S394 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S394 + 3U * k_7]);
        uint _S395 = __ballot_sync(_S387, true);
        k_7 = k_7 + 256U;
        _S387 = _S395;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S374);
    bool _S396 = tid_2 != 0U;
    uint _S397 = __ballot_sync(_S374, _S396);
    if(_S396)
    {
        _S379 = true;
    }
    else
    {
        _S379 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S379)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S379 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S379 = false;
    }
    if(_S379)
    {
        _S379 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S379 = false;
    }
    if(_S379)
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
    float3  _S398 = abs_1(x_14);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S398, *sum_1,x_14) - t_2 + _slang_select((abs_1(*sum_1)) >= _S398, x_14,*sum_1));
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
    Quat_0 _S399 = c_5;
    float3  _S400 = rotate_0(&_S399, v_4);
    return _S400;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S401 = inverse_rotate_0(q_10, v_6);
    float3  _S402 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S401));
    return _S402;
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
    float4  _S403 = abs_0(x_15);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S403, *sum_2,x_15) - t_3 + _slang_select((abs_0(*sum_2)) >= _S403, x_15,*sum_2));
    *sum_2 = t_3;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_16)
{
    Quat_0 _S404 = *hi_1;
    float4  _S405 = quat_vec_0(&_S404);
    float4  sum_3 = _S405;
    comp_add4_0(&sum_3, lo_1, x_16);
    float4  t_4 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_4 - sum_3);
    *hi_1 = quat_of_0(t_4);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_0, float dt_2)
{
    float _S406 = length_0(omega_0);
    float angle_2 = _S406 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_0 / make_float3 (_S406), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_11 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S407 = dq_0;
    Quat_0 _S408 = *hi_2;
    Quat_0 _S409 = quat_mul_0(&_S407, &_S408);
    Quat_0 _S410 = _S409;
    float4  _S411 = quat_vec_0(&_S410);
    quat_accumulate_0(hi_2, lo_2, _S411);
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S412 = 0U;
    uint _S413;
    float3  p_8;
    uint _S414 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S415 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S416 = ii_1 >= _S415;
    uint _S417 = __ballot_sync(_S414, _S416);
    if(_S416)
    {
        return;
    }
    else
    {
        uint _S418 = __ballot_sync(_S414, true);
        _S412 = _S418;
    }
    uint _S419 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S420 = (&(globalParams_0->islands_0)[_S419]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    bool _S421 = ((&imp_6)->cand_0.z) != 0U;
    uint _S422 = __ballot_sync(_S412, _S421);
    bool _S423;
    uint k_8;
    if(_S421)
    {
        uint _S424 = __ballot_sync(_S412, true);
        _S423 = true;
        k_8 = _S424;
    }
    else
    {
        bool _S425 = ((_S420->info_1.z) & 1U) != 0U;
        uint _S426 = __ballot_sync(_S412, true);
        _S423 = _S425;
        k_8 = _S426;
    }
    uint _S427 = __ballot_sync(k_8, _S423);
    if(_S423)
    {
        uint _S428 = __ballot_sync(k_8, true);
        _S423 = true;
        k_8 = _S428;
    }
    else
    {
        uint _S429 = k_8 & (~_S427);
        uint _S430 = _S420->info_1.y;
        bool _S431 = _S430 != 0U;
        uint _S432 = __ballot_sync(_S429, _S431);
        if(_S431)
        {
            bool _S433 = ((&imp_6)->cand_0.w) >= _S430;
            uint _S434 = __ballot_sync(_S429, true);
            _S423 = _S433;
        }
        else
        {
            uint _S435 = __ballot_sync(_S429, true);
            _S423 = false;
        }
        uint _S436 = __ballot_sync(k_8, true);
        k_8 = _S436;
    }
    uint _S437 = 0U;
    uint _S438 = __ballot_sync(k_8, _S423);
    if(_S423)
    {
        return;
    }
    else
    {
        uint _S439 = __ballot_sync(k_8, true);
        _S437 = _S439;
    }
    float4  _S440 = make_float4 (0.0f);
    float4  rf_0 = _S440;
    float4  rt_0 = _S440;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S437;
    for(;;)
    {
        bool _S441 = k_8 < ((&imp_6)->cand_0.y);
        uint _S442 = __ballot_sync(total_points_0, _S441);
        if(_S441)
        {
            uint _S443 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S444 = __ballot_sync(total_points_0, false);
            uint _S445 = __ballot_sync(total_points_0, false);
            uint _S446 = __ballot_sync(_S437, true);
            _S413 = _S446;
            break;
        }
        uint _S447 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S448 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S447 + _S448 + 1U]);
        uint _S449 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S449 + _S448 + 2U]);
        uint _S450 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S450;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S413);
    bool _S451 = tid_3 != 0U;
    uint _S452 = __ballot_sync(_S413, _S451);
    if(_S451)
    {
        return;
    }
    float _S453 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S454 = make_float3 (0.0f);
    uint _S455 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S455 != 0U)
    {
        float4  _S456 = (&imp_6)->half_1;
        float3  _S457 = float3 {_S456.x, _S456.y, _S456.z};
        Impactor_0 _S458 = imp_6;
        Box_0 _S459 = impactor_box_0(&_S458, _S454, _S457);
        float4  _S460 = (&imp_6)->velocity_1;
        float4  _S461 = (&imp_6)->velocity_err_1;
        float3  _S462 = float3 {_S460.x, _S460.y, _S460.z} + float3 {_S461.x, _S461.y, _S461.z};
        float _S463 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S464 = (&imp_6)->mat_0.x;
        float3  _S465 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S466 = _S459;
        Box_0 _S467 = _S459;
        float _S468 = contact_stiffness_0(_S463, &_S466, _S464, &_S467, _S465);
        float _S469 = (&imp_6)->position_1.z;
        float _S470 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S471 = _S469 - _S470;
        float _S472 = (&imp_6)->position_err_1.z;
        float _S473 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S474 = _S471 + (_S472 - _S473);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S475 = _S468 / float((U32_min((total_points_0), (5U))));
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
                Box_0 _S476 = _S459;
                float3  _S477 = sample_point_0(&_S476, s_2);
                p_8 = _S477;
            }
            if((_S474 + p_8.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_2 = s_2 + 1U;
        }
        s_2 = 0U;
        load_f_0 = _S454;
        load_t_0 = _S454;
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
                Box_0 _S478 = _S459;
                float3  _S479 = sample_point_0(&_S478, s_2);
                p_8 = _S479;
            }
            float depth_3 = - (_S474 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S480 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S462 + cross_0(float3 {_S480.x, _S480.y, _S480.z}, p_8);
            float _S481 = (&imp_6)->mat_0.z;
            float _S482 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S475, _S481, _S482, depth_3, _S465, v_7, _S453, below_0, &stored_3, &diss_2);
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
        load_f_0 = _S454;
        load_t_0 = _S454;
    }
    float4  _S483 = rf_0;
    float3  load_f_2 = float3 {_S483.x, _S483.y, _S483.z} + load_f_0;
    float4  _S484 = rt_0;
    float3  load_t_2 = float3 {_S484.x, _S484.y, _S484.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S485 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S485.x, _S485.y, _S485.z};
    float4  _S486 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S486.x, _S486.y, _S486.z};
    float3  _S487 = load_f_2 / make_float3 (m_2);
    float4  _S488 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S487 + float3 {_S488.x, _S488.y, _S488.z}) * make_float3 (_S453));
    Quat_0 _S489 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_12 = _S489;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S490 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S490.x, _S490.y, _S490.z};
    float4  _S491 = (&imp_6)->momentum_err_1;
    float3  l_err_0 = float3 {_S491.x, _S491.y, _S491.z};
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * make_float3 (_S453));
    float3  l_1 = l_hi_0 + l_err_0;
    Quat_0 _S492 = _S489;
    float3  _S493 = world_mul_0(&_S492, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S494 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S494.x, _S494.y, _S494.z};
    float4  _S495 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S495.x, _S495.y, _S495.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S453));
    turn_left_0(&q_12, &q_err_0, _S493, _S453);
    Quat_0 _S496 = q_12;
    float3  _S497 = world_mul_0(&_S496, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S497.x, _S497.y, _S497.z, 0.0f);
    Quat_0 _S498 = q_12;
    float4  _S499 = quat_vec_0(&_S498);
    (&imp_6)->rotation_1 = _S499;
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
    uint _S500 = (&imp_6)->cand_0.w - 1U;
    uint _S501 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S500 - _S501;
    uint _S502 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S502)
    {
        uint _S503 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S504 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S503 + 2U * (ii_1 * _S504 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_5)
{
    ChunkStatic_0 * _S505 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S506 = wp_1.hi_0.z;
    float _S507 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S508 = _S506 - _S507;
    float _S509 = wp_1.lo_0.z;
    float _S510 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S508 + (_S509 - _S510) + wp_1.rel_0.z;
    float4  _S511 = __ldg(&_S505->half_0);
    if((above_0 - _S511.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S512 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S513 = __ldg(&_S505->cmat_0);
    float _S514 = _S513.x;
    float3  _S515 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S516 = b_21;
    Box_0 _S517 = b_21;
    float _S518 = contact_stiffness_0(_S512, &_S516, _S514, &_S517, _S515);
    Box_0 _S519 = b_21;
    uint _S520 = sample_count_0(&_S519);
    uint s_3 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_3 < _S520)
        {
        }
        else
        {
            break;
        }
        Box_0 _S521 = b_21;
        float3  _S522 = sample_point_0(&_S521, s_3);
        if((above_0 + _S522.z) < 0.0f)
        {
            n_7 = n_7 + 1U;
        }
        s_3 = s_3 + 1U;
    }
    if(n_7 == 0U)
    {
        return;
    }
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_6, &vc_1, &wc_1);
    uint _S523 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S524 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S523 + _S524 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S520)
        {
        }
        else
        {
            break;
        }
        Box_0 _S525 = b_21;
        float3  _S526 = sample_point_0(&_S525, s_3);
        float _S527 = above_0 + _S526.z;
        if(!(_S527 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S527;
        float3  v_8 = vc_1 + cross_0(wc_1, _S526);
        float _S528 = _S518 / float((U32_max((n_7), (5U))));
        float4  _S529 = __ldg(&_S505->center_0);
        float _S530 = _S529.w;
        float _S531 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S532 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S528, _S530, _S531, depth_4, _S515, v_8, _S532, n_7, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_5 = *t_5 + cross_0(_S526, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S533 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S534 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S533 + _S534 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S535 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S536;
    if(g_1 >= _S535)
    {
        _S536 = true;
    }
    else
    {
        _S536 = stopped_0();
    }
    if(_S536)
    {
        return;
    }
    uint _S537 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S538 = 3U * g_1;
    uint _S539 = __ldg((&(globalParams_0->index_0)[_S537 + _S538]));
    uint _S540 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S541 = __ldg((&(globalParams_0->index_0)[_S540 + _S538 + 1U]));
    uint _S542 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S543 = __ldg((&(globalParams_0->index_0)[_S542 + _S538 + 2U]));
    float3  _S544 = make_float3 (0.0f);
    float3  f_5 = _S544;
    float3  t_6 = _S544;
    uint e_2 = _S541;
    for(;;)
    {
        if(e_2 < _S543)
        {
        }
        else
        {
            break;
        }
        uint _S545 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S545 == 2147483648U)
        {
            ground_contact_0(_S539, true, &f_5, &t_6);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S546 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S547 = 2U * _S545;
        float4  _S548 = *(&(globalParams_0->scratch_0)[_S546 + _S547]);
        f_5 = f_5 + float3 {_S548.x, _S548.y, _S548.z};
        uint _S549 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S550 = *(&(globalParams_0->scratch_0)[_S549 + _S547 + 1U]);
        t_6 = t_6 + float3 {_S550.x, _S550.y, _S550.z};
        e_2 = e_2 + 1U;
    }
    uint _S551 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S552 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S551 + _S552]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S553 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S553 + _S552 + 1U]) = make_float4 (t_6.x, t_6.y, t_6.z, 0.0f);
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S554 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S555 = (&(globalParams_0->islands_0)[_S554])->info_1;
    bool _S556;
    if((((&(globalParams_0->islands_0)[_S554])->info_1.z) & 1U) != 0U)
    {
        _S556 = true;
    }
    else
    {
        uint _S557 = _S555.y;
        if(_S557 != 0U)
        {
            _S556 = _S557 <= (isl_0->info_1.w);
        }
        else
        {
            _S556 = false;
        }
    }
    return _S556;
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
    float4  _S558 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S558.x, _S558.y, _S558.z};
    float4  _S559 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S559.x, _S559.y, _S559.z};
    float4  _S560 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S560.x, _S560.y, _S560.z};
    float4  _S561 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S561.x, _S561.y, _S561.z};
    float4  _S562 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S562.x, _S562.y, _S562.z};
    float4  _S563 = isl_1->momentum_0;
    (&rg_0)->l_2 = float3 {_S563.x, _S563.y, _S563.z};
    float4  _S564 = isl_1->momentum_err_0;
    (&rg_0)->l_err_1 = float3 {_S564.x, _S564.y, _S564.z};
    float3  _S565 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S565;
    (&rg_0)->a_7 = _S565;
    (&rg_0)->alpha_0 = _S565;
    return rg_0;
}

static __device__ void write_probe_0(uint slot_0, uint k_10, float value_0)
{
    uint _S566 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S567 = _S566 * 4U;
    uint _S568 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S567 + slot_0 * _S568 + k_10;
    float4  v_9 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_9, at_4 % 4U) = value_0;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_9;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_2, Rigid_0 * rg_1, uint k_11)
{
    uint4  _S569 = isl_2->probes_0;
    uint at_5 = isl_2->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S569.y))
        {
        }
        else
        {
            break;
        }
        float4  _S570 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_2 = asuint_0(_S570);
        float4  _S571 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S572 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S573 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_0 = info_2.x;
        uint i_10 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3  _S574 = rg_1->pos_1 - float3 {_S572.x, _S572.y, _S572.z} + (rg_1->pos_err_1 - float3 {_S573.x, _S573.y, _S573.z});
            float4  _S575 = __ldg(&(&(globalParams_0->chunks_0)[i_10])->center_0);
            float4  _S576 = *(&(globalParams_0->state_0)[4U * i_10]);
            float3  _S577 = rotate_0(&rg_1->rot_0, float3 {_S575.x, _S575.y, _S575.z} + float3 {_S576.x, _S576.y, _S576.z});
            value_1 = dot_0(_S574 + _S577, float3 {_S571.x, _S571.y, _S571.z});
        }
        else
        {
            if(kind_0 == 1U)
            {
                float4  _S578 = __ldg(&(&(globalParams_0->chunks_0)[i_10])->center_0);
                uint _S579 = 4U * i_10;
                float4  _S580 = *(&(globalParams_0->state_0)[_S579]);
                float4  _S581 = isl_2->com_0;
                float3  _S582 = rotate_0(&rg_1->rot_0, float3 {_S578.x, _S578.y, _S578.z} + float3 {_S580.x, _S580.y, _S580.z} - float3 {_S581.x, _S581.y, _S581.z});
                float3  _S583 = rg_1->vel_1 + rg_1->vel_err_1 + cross_0(rg_1->w_4, _S582);
                float4  _S584 = *(&(globalParams_0->state_0)[_S579 + 2U]);
                float3  _S585 = rotate_0(&rg_1->rot_0, float3 {_S584.x, _S584.y, _S584.z});
                value_1 = dot_0(_S583 + _S585, float3 {_S571.x, _S571.y, _S571.z});
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S586 = 3U * i_10;
                    float4  _S587 = *(&(globalParams_0->scratch_0)[_S586]);
                    float3  f_6 = float3 {_S587.x, _S587.y, _S587.z};
                    bool _S588 = (info_2.z) == 0U;
                    float3  mc_0;
                    if(_S588)
                    {
                        float4  _S589 = *(&(globalParams_0->scratch_0)[_S586 + 1U]);
                        mc_0 = float3 {_S589.x, _S589.y, _S589.z};
                    }
                    else
                    {
                        float4  _S590 = *(&(globalParams_0->scratch_0)[_S586 + 2U]);
                        mc_0 = float3 {_S590.x, _S590.y, _S590.z};
                    }
                    float3  fc_0;
                    if(_S588)
                    {
                        fc_0 = f_6;
                    }
                    else
                    {
                        fc_0 = - f_6;
                    }
                    value_1 = dot_0(fc_0, float3 {_S571.x, _S571.y, _S571.z}) + dot_0(mc_0, float3 {_S572.x, _S572.y, _S572.z});
                }
                else
                {
                    uint _S591 = 4U * i_10;
                    float3  _S592 = rotate_0(&rg_1->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S591 + 1U])).w, (*(&(globalParams_0->state_0)[_S591 + 2U])).w, (*(&(globalParams_0->state_0)[_S591 + 3U])).w));
                    value_1 = dot_0(_S592, float3 {_S571.x, _S571.y, _S571.z});
                }
            }
        }
        write_probe_0(info_2.w, k_11, value_1);
        at_5 = at_5 + 4U;
    }
    return;
}

static __device__ float time_since_0(float4  origin_0, uint k_12, float dt_3)
{
    float _S593 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S594 = _S593 - origin_0.x;
    float _S595 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S594 + (_S595 - origin_0.y) + float(k_12) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S596 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S596.x))
    {
        return _S596.y;
    }
    uint i_11 = 1U;
    for(;;)
    {
        if(i_11 < count_2)
        {
        }
        else
        {
            break;
        }
        uint _S597 = offset_0 + i_11;
        float4  _S598 = __ldg((&(globalParams_0->loads_0)[_S597]));
        float _S599 = _S598.x;
        if(tau_0 <= _S599)
        {
            float4  _S600 = __ldg((&(globalParams_0->loads_0)[_S597 - 1U]));
            float _S601 = _S600.x;
            float _S602 = _S600.y;
            return _S602 + (tau_0 - _S601) / (F32_max((_S599 - _S601), (1.00000000317107685e-30f))) * (_S598.y - _S602);
        }
        i_11 = i_11 + 1U;
    }
    float4  _S603 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S603.y;
}

static __device__ float eval_function_0(uint term_0, uint k_13, float dt_4, float shift_0)
{
    uint _S604 = 5U * term_0;
    float4  _S605 = __ldg((&(globalParams_0->loads_0)[_S604]));
    uint4  info_3 = asuint_0(_S605);
    float4  _S606 = __ldg((&(globalParams_0->loads_0)[_S604 + 3U]));
    float4  _S607 = __ldg((&(globalParams_0->loads_0)[_S604 + 4U]));
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S606.z;
    }
    float tau_1 = time_since_0(_S606, k_13, dt_4) + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S608 = _S607.x;
            if(tau_1 >= _S608)
            {
                shape_1 = _S607.y;
            }
            else
            {
                shape_1 = _S607.y * tau_1 / _S608;
            }
        }
        return shape_1;
    }
    bool _S609;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S609 = true;
        }
        else
        {
            _S609 = tau_1 > (_S607.x);
        }
        if(_S609)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S607.y * (F32_sin((3.14159274101257324f * tau_1 / _S607.x)));
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S607.y;
        if(sn_0 < 0.0f)
        {
            _S609 = true;
        }
        else
        {
            _S609 = sn_0 > 1.0f;
        }
        if(_S609)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S607.x * (1.0f - sn_0) * (F32_exp((- _S607.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        return table_eval_0(info_3.w, (F32_asuint((_S607.x))), tau_1);
    }
    if(kind_1 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S607.x;
        if(sn_1 < 0.0f)
        {
            _S609 = true;
        }
        else
        {
            _S609 = sn_1 > 1.0f;
        }
        if(_S609)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S607.y * sn_1)));
        }
        float clearing_0 = _S606.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S610 = _S607.w;
        return (_S610 + (_S607.z - _S610) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S611 = _S607.y;
        if(tau_1 < _S611)
        {
            return _S607.x;
        }
        float s_4 = tau_1 - _S611;
        float _S612 = _S607.w;
        if(s_4 > _S612)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S607.z * (F32_sin((3.14159274101257324f * s_4 / _S612)));
        }
        return shape_1;
    }
    float _S613 = _S607.x;
    if(_S613 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S613, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_7, float3  t_7)
{
    uint _S614 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S614 == 0U)
    {
        return;
    }
    uint _S615 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S616 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S615 + _S616]) = make_float4 (f_7.x, f_7.y, f_7.z, 0.0f);
    uint _S617 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S617 + _S616 + 1U]) = make_float4 (t_7.x, t_7.y, t_7.z, 0.0f);
    uint _S618 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S619 = (&(globalParams_0->scratch_0)[_S618 + _S616]);
    uint _S620 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S621 = *(&(globalParams_0->scratch_0)[_S620 + _S616]);
    *_S619 = make_float4 ((float3 {_S621.x, _S621.y, _S621.z} + f_7).x, (float3 {_S621.x, _S621.y, _S621.z} + f_7).y, (float3 {_S621.x, _S621.y, _S621.z} + f_7).z, 0.0f);
    uint _S622 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S623 = (&(globalParams_0->scratch_0)[_S622 + _S616 + 1U]);
    uint _S624 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S625 = *(&(globalParams_0->scratch_0)[_S624 + _S616 + 1U]);
    *_S623 = make_float4 ((float3 {_S625.x, _S625.y, _S625.z} + t_7).x, (float3 {_S625.x, _S625.y, _S625.z} + t_7).y, (float3 {_S625.x, _S625.y, _S625.z} + t_7).z, 0.0f);
    return;
}

static __device__ void chunk_external_0(uint _S626, uint _S627, Quat_0 * _S628, uint _S629, float _S630, bool _S631, float3  * _S632, float3  * _S633)
{
    bool _S634;
    ChunkStatic_0 * _S635 = (&(globalParams_0->chunks_0)[_S627]);
    float3  _S636 = make_float3 (0.0f);
    *_S632 = _S636;
    *_S633 = _S636;
    uint4  _S637 = __ldg(&_S635->load_range_0);
    uint term_1 = _S637.x;
    for(;;)
    {
        if(term_1 < (_S637.y))
        {
        }
        else
        {
            break;
        }
        uint _S638 = 5U * term_1;
        float4  _S639 = __ldg((&(globalParams_0->loads_0)[_S638]));
        uint _S640 = asuint_0(_S639).y;
        if(_S640 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4  _S641 = __ldg((&(globalParams_0->loads_0)[_S638 + 1U]));
        float4  _S642 = __ldg((&(globalParams_0->loads_0)[_S638 + 2U]));
        float value_2 = eval_function_0(term_1, _S629, _S630, 0.0f);
        if(_S640 == 0U)
        {
            _S634 = true;
        }
        else
        {
            _S634 = _S640 == 3U;
        }
        float3  fw_0;
        if(_S634)
        {
            fw_0 = float3 {_S641.x, _S641.y, _S641.z} * make_float3 (value_2);
        }
        else
        {
            float3  _S643 = rotate_0(_S628, float3 {_S641.x, _S641.y, _S641.z});
            fw_0 = _S643 * make_float3 (- value_2 * _S641.w);
        }
        float3  lever_0;
        if(_S640 == 3U)
        {
            float4  _S644 = *(&(globalParams_0->state_0)[4U * _S626]);
            lever_0 = float3 {_S642.x, _S642.y, _S642.z} - float3 {_S644.x, _S644.y, _S644.z};
        }
        else
        {
            lever_0 = float3 {_S642.x, _S642.y, _S642.z};
        }
        *_S632 = *_S632 + fw_0;
        float3  _S645 = rotate_0(_S628, lever_0);
        *_S633 = *_S633 + cross_0(_S645, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S631)
    {
        uint4  _S646 = __ldg(&_S635->cinfo_0);
        _S634 = (_S646.z) != 0U;
    }
    else
    {
        _S634 = false;
    }
    if(_S634)
    {
        uint4  _S647 = __ldg(&_S635->cinfo_0);
        uint g_2 = _S647.x;
        for(;;)
        {
            if(g_2 < (_S647.y))
            {
            }
            else
            {
                break;
            }
            uint _S648 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S649 = 2U * g_2;
            float4  _S650 = *(&(globalParams_0->scratch_0)[_S648 + _S649]);
            *_S632 = *_S632 + float3 {_S650.x, _S650.y, _S650.z};
            uint _S651 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S652 = *(&(globalParams_0->scratch_0)[_S651 + _S649 + 1U]);
            *_S633 = *_S633 + float3 {_S652.x, _S652.y, _S652.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_1, uint k_14, float dt_5, bool contact_0)
{
    float3  f_8;
    float3  t_8;
    chunk_external_0(c_8, c_8, rot_1, k_14, dt_5, contact_0, &f_8, &t_8);
    record_chunk_load_0(c_8, f_8, t_8);
    return length_0(f_8);
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_3, Rigid_0 * rg_2, uint k_15, float dt_6, bool contact_1, float3  * f_9, float3  * t_9)
{
    ChunkStatic_0 * _S653 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    chunk_external_0(c_9, c_9, &rg_2->rot_0, k_15, dt_6, contact_1, &fl_0, &tl_0);
    float3  _S654 = fl_0;
    float4  _S655 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S656 = float3 {_S655.x, _S655.y, _S655.z};
    float4  _S657 = __ldg(&_S653->center_0);
    float3  fc_1 = _S654 + _S656 * make_float3 (_S657.w);
    float3  _S658 = float3 {_S657.x, _S657.y, _S657.z};
    float4  _S659 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S660 = isl_3->com_0;
    float3  _S661 = float3 {_S660.x, _S660.y, _S660.z};
    float3  _S662 = rotate_0(&rg_2->rot_0, _S658 + float3 {_S659.x, _S659.y, _S659.z} - _S661);
    *f_9 = *f_9 + fc_1;
    *t_9 = *t_9 + (cross_0(_S662, fc_1) + tl_0);
    uint4  _S663 = __ldg(&_S653->load_range_0);
    uint term_2 = _S663.x;
    for(;;)
    {
        if(term_2 < (_S663.y))
        {
        }
        else
        {
            break;
        }
        uint _S664 = 5U * term_2;
        float4  _S665 = __ldg((&(globalParams_0->loads_0)[_S664]));
        if((asuint_0(_S665).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float kf_0 = eval_function_0(term_2, k_15, dt_6, 0.0f);
        float4  _S666 = __ldg((&(globalParams_0->loads_0)[_S664 + 1U]));
        float3  _S667 = rotate_0(&rg_2->rot_0, float3 {_S666.x, _S666.y, _S666.z} * make_float3 (kf_0));
        *f_9 = *f_9 + _S667;
        float3  _S668 = rotate_0(&rg_2->rot_0, _S658 - _S661);
        float3  _S669 = cross_0(_S668, _S667);
        float4  _S670 = __ldg((&(globalParams_0->loads_0)[_S664 + 2U]));
        float3  _S671 = rotate_0(&rg_2->rot_0, float3 {_S670.x, _S670.y, _S670.z} * make_float3 (kf_0));
        *t_9 = *t_9 + (_S669 + _S671);
        term_2 = term_2 + 1U;
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_4, Rigid_0 * rg_3, float3  f_10, float3  t_10)
{
    Quat_0 _S672 = rg_3->rot_0;
    float3  _S673 = world_mul_0(&_S672, isl_4->inertia0_1, isl_4->inertia1_1, isl_4->inertia2_1, rg_3->w_4);
    rg_3->a_7 = f_10 / make_float3 (isl_4->com_0.w);
    float3  _S674 = t_10 - cross_0(rg_3->w_4, _S673);
    Quat_0 _S675 = rg_3->rot_0;
    float3  _S676 = world_mul_0(&_S675, isl_4->inv0_1, isl_4->inv1_1, isl_4->inv2_1, _S674);
    rg_3->alpha_0 = _S676;
    rg_3->torque_0 = t_10;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_1, float dt_7, float3  v_10)
{
    float _S677 = length_0(omega_1);
    float angle_3 = _S677 * dt_7;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_8 = omega_1 / make_float3 (_S677);
    float s_5 = (F32_sin((0.5f * angle_3)));
    float3  av_0 = cross_0(a_8, v_10);
    return av_0 * make_float3 ((F32_sin((angle_3)))) + cross_0(a_8, av_0) * make_float3 (2.0f * s_5 * s_5);
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_8)
{
    comp_add_0(&rg_4->l_2, &rg_4->l_err_1, rg_4->torque_0 * make_float3 (dt_8));
    float3  l_3 = rg_4->l_2 + rg_4->l_err_1;
    comp_add_0(&rg_4->vel_1, &rg_4->vel_err_1, rg_4->a_7 * make_float3 (dt_8));
    float3  vel_2 = rg_4->vel_1 + rg_4->vel_err_1;
    float4  _S678 = isl_5->inv0_1;
    float4  _S679 = isl_5->inv1_1;
    float4  _S680 = isl_5->inv2_1;
    Quat_0 _S681 = rg_4->rot_0;
    float3  _S682 = world_mul_0(&_S681, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_3);
    float3  _S683 = vel_2 * make_float3 (dt_8);
    float4  _S684 = isl_5->com_0;
    float3  _S685 = float3 {_S684.x, _S684.y, _S684.z};
    Quat_0 _S686 = rg_4->rot_0;
    float3  _S687 = rotate_0(&_S686, _S685);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S683 - turn_difference_0(_S682, dt_8, _S687));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S682, dt_8);
    Quat_0 _S688 = rg_4->rot_0;
    float3  _S689 = world_mul_0(&_S688, _S678, _S679, _S680, l_3);
    rg_4->w_4 = _S689;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S690 = __ldg(&ptr_0->geom0_0);
    float4  _S691 = __ldg(&ptr_0->geom1_0);
    float4  _S692 = __ldg(&ptr_0->stiff0_0);
    float4  _S693 = __ldg(&ptr_0->stiff1_0);
    float4  _S694 = __ldg(&ptr_0->rebar0_0);
    float4  _S695 = __ldg(&ptr_0->rebar1_0);
    uint4  _S696 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S697 = { _S690, _S691, _S692, _S693, _S694, _S695, _S696 };
    return _S697;
}

static __device__ bool connected_0(JointState_0 * st_0, bool has_rebar_0)
{
    bool _S698;
    if((st_0->damage_0) < 1.0f)
    {
        _S698 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S698 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S698 = false;
        }
    }
    return _S698;
}

static __device__ float fdiv_0(float a_9, float b_22)
{
    return a_9 / b_22;
}

static __device__ float fsqrt_0(float a_10)
{
    return (F32_sqrt((a_10)));
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
    float _S699 = q_lin_0.z;
    float axial_0 = fdiv_0(_S699, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S700 = q_lin_0.x;
    float _S701 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S700 * _S700 + _S701 * _S701), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S702 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S702), (0.0f)));
    (&m_3)->compression_0 = _S702 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S699), (0.0f)));
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

static __device__ float fpow_0(float a_11, float b_24)
{
    return (F32_pow((a_11), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S703 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S704 = _S703.z;
    float f_11;
    if(r_5 <= _S704)
    {
        f_11 = fpow_0(fdiv_0(r_5, ref_0), _S703.y);
    }
    else
    {
        f_11 = fpow_0(fdiv_0(_S704, ref_0), _S703.y) * fpow_0(fdiv_0(r_5, _S704), _S703.w);
    }
    return clamp_0(f_11, 1.0f, mat_1->misc_0.x);
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
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S705 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S706;
    if(_S705 > 0.0f)
    {
        _S706 = fdiv_0(m_4->shear_0, _S705);
    }
    else
    {
        _S706 = infinity_0();
    }
    *&((&idx_0)->y) = _S706;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_2)), (0.0f)));
    float _S707 = b_25->stiff1_0.y;
    if(_S707 > 0.0f)
    {
        _S706 = fdiv_0(m_4->compressive_force_0, _S707);
    }
    else
    {
        _S706 = 0.0f;
    }
    *&((&idx_0)->w) = _S706;
    return idx_0;
}

static __device__ float sq_0(float x_18)
{
    return x_18 * x_18;
}

static __device__ float damage_law_0(uint kind_2, float kappa_1, float r_6)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
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

static __device__ __noinline__ float2  damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_7, float d_old_0, float psi_0)
{
    float _S708 = (F32_max((damage_law_0(kind_3, lambda_0, r_7)), (d_old_0)));
    bool _S709;
    if(_S708 <= d_old_0)
    {
        _S709 = true;
    }
    else
    {
        _S709 = d_old_0 >= 1.0f;
    }
    if(_S709)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S710 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S708, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S710), (r_7)))), (0.0f))));
        }
        return make_float2 (_S708, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S710), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S708 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S708, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S711 = - h0_0;
    float _S712 = - h1_0;
    FixedArray<float2 , 4>  _S713 = { {
        float2 {
            _S711, _S712
        }, float2 {
            h0_0, _S712
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S711, h1_0
        }
    } };
    FixedArray<float2 , 8>  poly_0;
    uint i_12 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        if(i_12 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S714 = i_12;
        uint _S715 = i_12 + 1U;
        uint _S716 = _S715 % 4U;
        float _S717 = _S713[i_12].y;
        float _S718 = _S713[i_12].x;
        float fp_0 = dz_0 + ax_0 * _S717 - ay_0 * _S718;
        float _S719 = _S713[_S716].y;
        float _S720 = _S713[_S716].x;
        float fq_0 = dz_0 + ax_0 * _S719 - ay_0 * _S720;
        bool _S721 = fp_0 < 0.0f;
        if(_S721)
        {
            uint _S722 = count_4 + 1U;
            poly_0[count_4] = _S713[_S714];
            count_3 = _S722;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S721 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S723 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S718 + t_11 * (_S720 - _S718), _S717 + t_11 * (_S719 - _S717));
            count_4 = _S723;
        }
        else
        {
            count_4 = count_3;
        }
        i_12 = _S715;
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
    i_12 = 0U;
    float a_12 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_12 < count_4)
        {
        }
        else
        {
            break;
        }
        float _S724 = o_1.x;
        float x0_0 = poly_0[i_12].x - _S724;
        float _S725 = o_1.y;
        float y0_0 = poly_0[i_12].y - _S725;
        uint _S726 = i_12 + 1U;
        uint _S727 = _S726 % count_4;
        float x1_0 = poly_0[_S727].x - _S724;
        float y1_0 = poly_0[_S727].y - _S725;
        float _S728 = x0_0 * y1_0;
        float _S729 = x1_0 * y0_0;
        float cr_0 = _S728 - _S729;
        float a_13 = a_12 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S728 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S729) * cr_0 / 24.0f;
        i_12 = _S726;
        a_12 = a_13;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_12 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_12;
    float cy_0 = sy_0 / a_12;
    (*region_0)[int(0)] = a_12;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S730 = a_12 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S730 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_12 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S730 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_8;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_8);
    float a_14 = r_8[int(0)];
    if((r_8[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_16 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_8[int(2)] - ay_1 * r_8[int(1)];
    float _S731 = a_14 * fc_3;
    float _S732 = - ay_1;
    return make_float4 (k_16 * a_14 * fc_3, k_16 * (_S731 * r_8[int(2)] + (_S732 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_16 * (_S731 * r_8[int(1)] + (_S732 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_16 * (_S731 * fc_3 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_19)
{
    float _S733;
    if(((F32_asuint((x_19))) & 2147483648U) != 0U)
    {
        _S733 = -1.0f;
    }
    else
    {
        _S733 = 1.0f;
    }
    return _S733;
}

static __device__ float2  return_map_0(float k_17, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_17 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_12 = cap_0 * signum_0(trial_0);
    return make_float2 (f_12, fdiv_0(trial_0 - f_12, k_17));
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
    float3  _S734 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S734;
    (&c_10)->q_ang_1 = _S734;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S735 = mat_4->kind_flags_0.y;
    if((_S735 & 2U) == 0U)
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
    if((_S735 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S736 = p_9.y;
        float _S737 = p_9.z;
        float _S738 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S736;
        m2_0 = _S737;
        energy_3 = _S738;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S739 = d_ang_0.x;
        float _S740 = d_ang_0.y;
        float spread_0 = (F32_abs((_S739))) * 0.4166666567325592f * w1_2 + (F32_abs((_S740))) * 0.4166666567325592f * w0_2;
        float _S741 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S741))) + spread_0);
        if((_S741 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S741 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S742 = ki_0 * _S739 * i2_0;
                float _S743 = ki_0 * _S740 * i1_0;
                float _S744 = 0.5f * ki_0 * (36.0f * _S741 * _S741 + _S739 * _S739 * i2_0 + _S740 * _S740 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S741;
                m1_0 = _S742;
                m2_0 = _S743;
                energy_3 = _S744;
            }
            else
            {
                uint i_13 = 0U;
                diss_5 = 0.0f;
                float m1_1 = 0.0f;
                float m2_1 = 0.0f;
                float energy_4 = 0.0f;
                for(;;)
                {
                    if(i_13 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S745 = SPRING_AT_0[i_13] * w0_2;
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
                        float di_0 = _S741 + _S739 * s2_0 - _S740 * _S745;
                        if(di_0 < 0.0f)
                        {
                            float f_13 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_13 * s2_0;
                            float m2_2 = m2_0 - f_13 * _S745;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_13;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_4 = j_4 + 1U;
                    }
                    i_13 = i_13 + 1U;
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
    float _S746 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S747 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S746 * _S746 + _S747 * _S747);
    bool _S748;
    if(tn_0 > slide_cap_0)
    {
        _S748 = tn_0 > 0.0f;
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        float _S749 = fdiv_0(_S746, tn_0);
        float _S750 = fdiv_0(_S747, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S749 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S750 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S749 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S750 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S746;
        *&((&(&c_10)->q_lin_1)->y) = _S747;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S751 = tq_0.x;
    float _S752 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S751))) * (F32_abs((_S752)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S752;
    *&((&(&c_10)->q_ang_1)->z) = _S751;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S751), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S753 = mat_5->kind_flags_0.y;
    if((_S753 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S753 & 4U) != 0U)
    {
        float4  _S754 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S754.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S755 = d_ang_1.x;
        float _S756 = d_ang_1.y;
        float spread_1 = (F32_abs((_S755))) * 0.4166666567325592f * w1_3 + (F32_abs((_S756))) * 0.4166666567325592f * w0_3;
        float _S757 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S757))) + spread_1);
        if((_S757 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S757 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S757;
            }
            else
            {
                uint i_14 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_14 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S758 = SPRING_AT_0[i_14] * w0_3;
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
                        float di_1 = _S757 + _S755 * (SPRING_AT_0[j_5] * w1_3) - _S756 * _S758;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_5 = j_5 + 1U;
                    }
                    i_14 = i_14 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    float3  p_11 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S759 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S760 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S759 * _S759 + _S760 * _S760);
    bool _S761;
    if(tn_1 > slide_cap_1)
    {
        _S761 = tn_1 > 0.0f;
    }
    else
    {
        _S761 = false;
    }
    if(_S761)
    {
        float _S762 = fdiv_0(_S760, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S759, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S762 * dslip_1;
    }
    *&((&p_11)->z) = *&((&p_11)->z) + return_map_0(kt_1, d_ang_1.z, p_11.z, slide_cap_1 * b_27->geom1_0.z).y;
    return p_11;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_6)
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    float _S763 = mat_6->misc_0.y;
    return fdiv_0((_S763 + 1.0f) * fpow_0(s_6, _S763), mat_6->misc_0.z);
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
    Measures_0 measures_0;
};

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_28, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_9, bool fracture_1)
{
    float kn_3 = b_28->stiff0_0.x;
    float ks_2 = b_28->stiff0_0.y;
    float kb1_0 = b_28->stiff0_0.z;
    float kb2_0 = b_28->stiff0_0.w;
    float4  _S764 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_1 = *state_2;
    bool _S765 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S766 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S767 = (F32_max(((F32_max((_S766.tension_0), (_S766.shear_0)))), (_S766.compression_0)));
    bool _S768 = dt_9 > 0.0f;
    float dif_1;
    if(_S768)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S767 - (&st_1)->governing_stress_0, dt_9)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S764.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_9, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_9, tau_2)), (1.0f)));
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S767;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S769 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S769;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S770 = weibull_0 * dif_1;
    float _S771 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = _S770 * _S771;
    Measures_0 _S772 = _S766;
    float4  _S773 = failure_indices_0(mat_7, b_28, &_S772, multiplier_1);
    float _S774 = _S773.x;
    float _S775 = _S773.y;
    (&st_1)->utilization_0 = (F32_max(((F32_max((_S774), (_S775)))), ((F32_max((_S773.z), (_S773.w))))));
    float _S776 = d_lin_2.x;
    float _S777 = d_lin_2.y;
    float _S778 = ks_2 * (sq_0(_S776) + sq_0(_S777)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S779 = d_lin_2.z;
    bool _S780 = _S779 > 0.0f;
    if(_S780)
    {
        dif_1 = kn_3 * sq_0(_S779);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S778 + dif_1);
    float psi_c_0;
    if(_S779 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S779);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3  plastic_4 = make_float3 ((&st_1)->plastic_x_0, (&st_1)->plastic_y_0, (&st_1)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_3;
    float overshoot_1;
    bool _S781;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S782 = _S774 >= _S775;
        if(_S782)
        {
            diss_contact_0 = _S774;
        }
        else
        {
            diss_contact_0 = _S775;
        }
        uint mode_ts_0;
        if(_S782)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S781 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S781 = false;
        }
        if(_S781)
        {
            _S781 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S781 = false;
        }
        uint mode_c_0;
        if(_S781)
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
            (&st_1)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2  inc_0 = damage_increment_0(mode_c_0, (&st_1)->kappa_0, diss_contact_0, intact_normal_0, (&st_1)->damage_0, psi_ts_0);
            float _S783 = inc_0.x;
            if(_S783 > ((&st_1)->damage_0))
            {
                Contact_0 _S784 = contact_part_0(mat_7, b_28, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S785 = (F32_max((_S784.energy_2 - (1.0f - (&st_1)->crush_0) * psi_c_0), (0.0f)));
                float _S786 = (F32_max((inc_0.y - _S785 * (_S783 - (&st_1)->damage_0)), (0.0f)));
                float _S787 = (F32_max(((psi_ts_0 - _S785) * (_S783 - (&st_1)->damage_0) - _S786), (0.0f)));
                (&st_1)->damage_0 = _S783;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S786;
                overshoot_1 = _S787;
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
        (&st_1)->kappa_0 = (F32_max(((&st_1)->kappa_0), (diss_contact_0)));
        float _S788 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S789 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S788) + _S789.q_ang_1 * make_float3 (_S788);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S790 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S791 = _S790;
        float4  _S792 = failure_indices_0(mat_7, b_28, &_S791, multiplier_1);
        float _S793 = _S792.z;
        float _S794 = _S792.w;
        bool _S795 = _S793 >= _S794;
        if(_S795)
        {
            psi_contact_0 = _S793;
        }
        else
        {
            psi_contact_0 = _S794;
        }
        if(_S795)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S781 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S781 = false;
        }
        if(_S781)
        {
            _S781 = psi_c_0 > 0.0f;
        }
        else
        {
            _S781 = false;
        }
        if(_S781)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_7->energy_0.w * b_28->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
                    mode_ts_0 = kind_4;
                }
                law_1 = mode_ts_0;
            }
            float2  inc_1 = damage_increment_0(law_1, (&st_1)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_1)->crush_0, psi_c_0);
            float _S796 = inc_1.x;
            if(_S796 > ((&st_1)->crush_0))
            {
                float _S797 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S797;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S796 - (&st_1)->crush_0) - _S797), (0.0f)));
                (&st_1)->crush_0 = _S796;
                (&st_1)->mode_0 = mode_c_0;
                if(_S796 >= 1.0f)
                {
                    _S781 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S781 = false;
                }
                if(_S781)
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
        (&st_1)->kappa_c_0 = (F32_max(((&st_1)->kappa_c_0), (psi_contact_0)));
    }
    else
    {
        dissipated_3 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_1)->damage_0;
    float3  _S798 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S799 = contact_offsets_0(mat_7, b_28, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S799.x;
            (&st_1)->plastic_y_0 = _S799.y;
            (&st_1)->plastic_t_0 = _S799.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S798;
        qc_ang_0 = _S798;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S800 = contact_part_0(mat_7, b_28, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S800.plastic_1.x;
        (&st_1)->plastic_y_0 = _S800.plastic_1.y;
        (&st_1)->plastic_t_0 = _S800.plastic_1.z;
        diss_contact_0 = _S800.diss_4;
        qc_lin_0 = _S800.q_lin_1;
        qc_ang_0 = _S800.q_ang_1;
        psi_contact_0 = _S800.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S780)
    {
        intact_normal_0 = kn_3 * _S779;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_3 * _S779;
    }
    float _S801 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S801 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S801 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S801 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S801) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S801 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S781 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S781 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S781)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S779, (&st_1)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S776, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S777, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S802 = nr_0.y;
        float _S803 = v1_0.y;
        float _S804 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S802))) + dowel_capacity_0 * ((F32_abs((_S803))) + (F32_abs((_S804))));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S802;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S803;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S804;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S805 = nr_0.x;
        float _S806 = v1_0.x;
        float _S807 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S805), k_axial_0) + fdiv_0(sq_0(_S806) + sq_0(_S807), k_dowel_0));
        if(fracture_1)
        {
            _S781 = ((&st_1)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S781 = false;
        }
        if(_S781)
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
            force_lin_3 = force_lin_2 + make_float3 (_S806, _S807, _S805);
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
        _S781 = _S768;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        _S781 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S781 = false;
    }
    if(_S781)
    {
        Measures_0 _S808 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S809 = _S808;
        float4  _S810 = failure_indices_0(mat_7, b_28, &_S809, weibull_0);
        float _S811 = life_rate_0(mat_7, (F32_max(((F32_max((_S810.x), (_S810.y)))), (_S810.z))));
        (&st_1)->life_0 = (F32_max(((&st_1)->life_0 - _S811 * dt_9), (0.0f)));
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S765)
    {
        JointState_0 _S812 = st_1;
        bool _S813 = connected_0(&_S812, has_rebar_1);
        _S781 = !_S813;
    }
    else
    {
        _S781 = false;
    }
    (&resp_0)->disconnected_0 = _S781;
    (&resp_0)->measures_0 = _S766;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_2, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S814 = st_2->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S814;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S815 = 1.0f - _S814;
    float _S816 = (F32_max((_S815 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_2->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S815), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S816, _S816, normal_4);
    *f_ang_0 = make_float3 (_S816);
    bool _S817;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S817 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S817 = false;
    }
    if(_S817)
    {
        float4  _S818 = b_29->rebar0_0;
        float4  _S819 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S820 = fdiv_0(_S818.y, _S819.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S820;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S820;
    }
    return;
}

static __device__ bool is_damaged_0(JointState_0 * st_3)
{
    bool _S821;
    if((st_3->damage_0) > 0.0f)
    {
        _S821 = true;
    }
    else
    {
        _S821 = (st_3->crush_0) > 0.0f;
    }
    return _S821;
}

static __device__ float3  to_local_0(uint _S822, float3  _S823)
{
    BondStatic_0 * _S824 = (&(globalParams_0->bonds_0)[_S822]);
    float4  _S825 = __ldg(&_S824->t1_0);
    float _S826 = dot_0(_S823, float3 {_S825.x, _S825.y, _S825.z});
    float4  _S827 = __ldg(&_S824->t2_0);
    float _S828 = dot_0(_S823, float3 {_S827.x, _S827.y, _S827.z});
    float4  _S829 = __ldg(&_S824->normal_0);
    return make_float3 (_S826, _S828, dot_0(_S823, float3 {_S829.x, _S829.y, _S829.z}));
}

static __device__ float3  to_body_0(uint _S830, float3  _S831)
{
    BondStatic_0 * _S832 = (&(globalParams_0->bonds_0)[_S830]);
    float4  _S833 = __ldg(&_S832->t1_0);
    float3  _S834 = float3 {_S833.x, _S833.y, _S833.z} * make_float3 (_S831.x);
    float4  _S835 = __ldg(&_S832->t2_0);
    float3  _S836 = _S834 + float3 {_S835.x, _S835.y, _S835.z} * make_float3 (_S831.y);
    float4  _S837 = __ldg(&_S832->normal_0);
    return _S836 + float3 {_S837.x, _S837.y, _S837.z} * make_float3 (_S831.z);
}

static __device__ bool bond_update_0(uint i_15, float dt_10, bool fracture_2, uint abs_step_0)
{
    BondStatic_0 * _S838 = (&(globalParams_0->bonds_0)[i_15]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_15]);
    JointBond_0 _S839 = slang_ldg_0(&_S838->law_0);
    uint ca_0 = _S839.ids_0.y;
    uint cb_0 = _S839.ids_0.z;
    float4  _S840 = __ldg(&_S838->ra_0);
    float3  ra_1 = float3 {_S840.x, _S840.y, _S840.z};
    float4  _S841 = __ldg(&_S838->rb_0);
    float3  rb_1 = float3 {_S841.x, _S841.y, _S841.z};
    uint _S842 = 4U * ca_0;
    float4  _S843 = *(&(globalParams_0->state_0)[_S842]);
    float4  _S844 = *(&(globalParams_0->state_0)[_S842 + 1U]);
    float3  ta_2 = float3 {_S844.x, _S844.y, _S844.z};
    float4  _S845 = *(&(globalParams_0->state_0)[_S842 + 2U]);
    float3  va_0 = float3 {_S845.x, _S845.y, _S845.z};
    float4  _S846 = *(&(globalParams_0->state_0)[_S842 + 3U]);
    float3  wa_1 = float3 {_S846.x, _S846.y, _S846.z};
    uint _S847 = 4U * cb_0;
    float4  _S848 = *(&(globalParams_0->state_0)[_S847]);
    float4  _S849 = *(&(globalParams_0->state_0)[_S847 + 1U]);
    float3  tb_2 = float3 {_S849.x, _S849.y, _S849.z};
    float4  _S850 = *(&(globalParams_0->state_0)[_S847 + 2U]);
    float3  vb_0 = float3 {_S850.x, _S850.y, _S850.z};
    float4  _S851 = *(&(globalParams_0->state_0)[_S847 + 3U]);
    float3  wb_0 = float3 {_S851.x, _S851.y, _S851.z};
    float3  _S852 = to_local_0(i_15, float3 {_S848.x, _S848.y, _S848.z} + cross_0(tb_2, rb_1) - (float3 {_S843.x, _S843.y, _S843.z} + cross_0(ta_2, ra_1)));
    float3  _S853 = to_local_0(i_15, tb_2 - ta_2);
    float3  _S854 = to_local_0(i_15, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S855 = to_local_0(i_15, wb_0 - wa_1);
    JointState_0 previous_0 = (&bd_0)->js_0;
    JointBond_0 _S856 = _S839;
    JointState_0 _S857 = (&bd_0)->js_0;
    JointResponse_0 _S858 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S839.ids_0.x], &_S856, &_S857, _S852, _S853, dt_10, fracture_2);
    JointBond_0 _S859 = _S839;
    JointState_0 _S860 = _S858.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S859, &_S860, _S852, &f_lin_1, &f_ang_1);
    float4  _S861 = __ldg(&_S838->c_lin_0);
    float3  qd_lin_0 = _S854 * float3 {_S861.x, _S861.y, _S861.z} * f_lin_1;
    float4  _S862 = __ldg(&_S838->c_ang_0);
    float3  qd_ang_0 = _S855 * float3 {_S862.x, _S862.y, _S862.z} * f_ang_1;
    float3  q_lin_2 = _S858.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S858.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S854) + dot_0(qd_ang_0, _S855)) * dt_10;
    float3  _S863 = to_body_0(i_15, q_lin_2);
    float3  _S864 = to_body_0(i_15, q_ang_2);
    uint _S865 = 3U * i_15;
    *(&(globalParams_0->scratch_0)[_S865]) = make_float4 (_S863.x, _S863.y, _S863.z, (F32_max((_S858.measures_0.tension_0), (_S858.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S865 + 1U]) = make_float4 ((_S864 + cross_0(ra_1, _S863)).x, (_S864 + cross_0(ra_1, _S863)).y, (_S864 + cross_0(ra_1, _S863)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S865 + 2U]) = make_float4 ((- _S864 + cross_0(rb_1, - _S863)).x, (- _S864 + cross_0(rb_1, - _S863)).y, (- _S864 + cross_0(rb_1, - _S863)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S858.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S858.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S858.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S858.state_1.utilization_0))));
    JointState_0 _S866 = previous_0;
    bool _S867 = is_damaged_0(&_S866);
    bool _S868;
    if(!_S867)
    {
        JointState_0 _S869 = _S858.state_1;
        bool _S870 = is_damaged_0(&_S869);
        _S868 = _S870;
    }
    else
    {
        _S868 = false;
    }
    if(_S868)
    {
        _S868 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S868 = false;
    }
    if(_S868)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S858.state_1.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S871 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S839.ids_0.x], previous_0.life_0);
        _S868 = _S871 > 0.99000000953674316f;
    }
    else
    {
        _S868 = false;
    }
    if(_S868)
    {
        float _S872 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S839.ids_0.x], _S858.state_1.life_0);
        _S868 = _S872 <= 0.99000000953674316f;
    }
    else
    {
        _S868 = false;
    }
    if(_S868)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
    }
    if(_S858.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S858.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_15]) = bd_0;
    return _S858.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_6, Rigid_0 * rg_5, float dt_11, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S873 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S874 = make_float3 (0.0f);
    uint _S875 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S875;
    float3  fi_0 = _S874;
    float3  mi_0 = _S874;
    for(;;)
    {
        uint _S876 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S876)
        {
        }
        else
        {
            break;
        }
        uint _S877 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S878 = 3U * (_S877 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S878]);
        if((_S877 & 1U) == 0U)
        {
            float4  _S879 = *(&(globalParams_0->scratch_0)[_S878 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S879.x, _S879.y, _S879.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S880 = *(&(globalParams_0->scratch_0)[_S878 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S880.x, _S880.y, _S880.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S881 = (F32_max((peak_0), (fa_2.w)));
        uint _S882 = e_3 + 1U;
        peak_0 = _S881;
        e_3 = _S882;
    }
    uint _S883 = 4U * c_11;
    float4  _S884 = *(&(globalParams_0->state_0)[_S883]);
    float3  u_0 = float3 {_S884.x, _S884.y, _S884.z};
    uint _S885 = _S883 + 1U;
    float4  _S886 = *(&(globalParams_0->state_0)[_S885]);
    float3  th_1 = float3 {_S886.x, _S886.y, _S886.z};
    uint _S887 = _S883 + 2U;
    float4  _S888 = *(&(globalParams_0->state_0)[_S887]);
    float3  v_11 = float3 {_S888.x, _S888.y, _S888.z};
    uint _S889 = _S883 + 3U;
    float4  _S890 = *(&(globalParams_0->state_0)[_S889]);
    float3  w_5 = float3 {_S890.x, _S890.y, _S890.z};
    float4  _S891 = __ldg(&_S873->center_0);
    float mass_0 = _S891.w;
    float3  _S892 = float3 {_S891.x, _S891.y, _S891.z};
    float4  _S893 = isl_6->com_0;
    float3  _S894 = float3 {_S893.x, _S893.y, _S893.z};
    float3  _S895 = rotate_0(&rg_5->rot_0, _S892 + u_0 - _S894);
    float3  f_load_0;
    float3  t_load_0;
    chunk_external_0(c_11, c_11, &rg_5->rot_0, step_0, dt_11, contact_3, &f_load_0, &t_load_0);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S896 = f_load_0;
    float4  _S897 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S896 + float3 {_S897.x, _S897.y, _S897.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S898 = rg_5->alpha_0;
        float3  _S899 = rg_5->w_4;
        float3  f_world_2 = f_world_0 - (rg_5->a_7 + cross_0(rg_5->alpha_0, _S895) + cross_0(rg_5->w_4, cross_0(rg_5->w_4, _S895))) * make_float3 (mass_0);
        float4  _S900 = __ldg(&_S873->inertia0_0);
        float4  _S901 = __ldg(&_S873->inertia1_0);
        float4  _S902 = __ldg(&_S873->inertia2_0);
        float3  _S903 = world_mul_0(&rg_5->rot_0, _S900, _S901, _S902, _S898);
        float3  _S904 = world_mul_0(&rg_5->rot_0, _S900, _S901, _S902, _S899);
        float3  t_world_2 = t_world_0 - (_S903 + cross_0(_S899, _S904));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S905 = inverse_rotate_0(&rg_5->rot_0, f_world_1);
    float3  _S906 = inverse_rotate_0(&rg_5->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S907 = inverse_rotate_0(&rg_5->rot_0, rg_5->w_4);
        float3  f_ext_1 = _S905 - cross_0(_S907, v_11) * make_float3 (2.0f * mass_0);
        float4  _S908 = __ldg(&_S873->inertia0_0);
        float4  _S909 = __ldg(&_S873->inertia1_0);
        float4  _S910 = __ldg(&_S873->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S908, _S909, _S910, w_5);
        float3  m_ext_1 = _S906 - (cross_0(_S907, i_w_0) + cross_0(w_5, rows_mul_0(_S908, _S909, _S910, _S907)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S905;
        m_ext_0 = _S906;
    }
    uint4  _S911 = __ldg(&_S873->load_range_0);
    uint term_3 = _S911.x;
    for(;;)
    {
        if(term_3 < (_S911.y))
        {
        }
        else
        {
            break;
        }
        uint _S912 = 5U * term_3;
        float4  _S913 = __ldg((&(globalParams_0->loads_0)[_S912]));
        if((asuint_0(_S913).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float kf_1 = eval_function_0(term_3, step_0, dt_11, dt_11);
        float4  _S914 = __ldg((&(globalParams_0->loads_0)[_S912 + 1U]));
        float3  f_ext_2 = f_ext_0 + float3 {_S914.x, _S914.y, _S914.z} * make_float3 (kf_1);
        float4  _S915 = __ldg((&(globalParams_0->loads_0)[_S912 + 2U]));
        float3  m_ext_2 = m_ext_0 + float3 {_S915.x, _S915.y, _S915.z} * make_float3 (kf_1);
        f_ext_0 = f_ext_2;
        m_ext_0 = m_ext_2;
        term_3 = term_3 + 1U;
    }
    float3  f_14 = f_ext_0 + fi_0;
    float3  m_5 = m_ext_0 + mi_0;
    uint4  _S916 = __ldg(&_S873->info_0);
    uint support_0 = _S916.x;
    float3  _S917 = make_float3 ((*(&(globalParams_0->state_0)[_S885])).w, (*(&(globalParams_0->state_0)[_S887])).w, (*(&(globalParams_0->state_0)[_S889])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_2;
    float3  v_12;
    float3  w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_14;
        u_1 = u_0;
        th_2 = th_1;
        v_12 = _S874;
        w_6 = _S874;
    }
    else
    {
        float4  _S918 = __ldg(&_S873->inv0_0);
        float4  _S919 = __ldg(&_S873->inv1_0);
        float4  _S920 = __ldg(&_S873->inv2_0);
        float3  _S921 = rows_mul_0(_S918, _S919, _S920, m_5);
        float4  _S922 = __ldg(&_S873->scale_0);
        float3  w_7 = w_5 + _S921 * make_float3 (dt_11 * _S922.z);
        float3  th_3 = th_1 + w_7 * make_float3 (dt_11);
        if(support_0 == 2U)
        {
            reaction_0 = - f_14;
            u_1 = u_0;
            th_2 = _S874;
        }
        else
        {
            float3  v_13 = v_11 + f_14 * make_float3 (dt_11 * _S922.y);
            float3  u_2 = u_0 + v_13 * make_float3 (dt_11);
            reaction_0 = _S917;
            u_1 = u_2;
            th_2 = v_13;
        }
        float3  _S923 = th_2;
        th_2 = th_3;
        v_12 = _S923;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S883]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S885]) = make_float4 (th_2.x, th_2.y, th_2.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S887]) = make_float4 (v_12.x, v_12.y, v_12.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S889]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S924 = rotate_0(&rg_5->rot_0, _S892 + u_1 - _S894);
    float3  _S925 = rg_5->vel_1 + rg_5->vel_err_1 + cross_0(rg_5->w_4, _S924);
    float3  _S926 = rotate_0(&rg_5->rot_0, v_12);
    float3  v_world_0 = _S925 + _S926;
    float3  _S927 = rotate_0(&rg_5->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_5->w_4 + _S927)) * dt_11);
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S928 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S929 = __ldg(&_S928->center_0);
    float _S930 = _S929.w;
    float4  _S931 = __ldg(&_S928->scale_0);
    float m_6 = _S930 * _S931.x;
    uint _S932 = 4U * c_12;
    float4  _S933 = *(&(globalParams_0->state_0)[_S932]);
    *tu_0 = *tu_0 + float3 {_S933.x, _S933.y, _S933.z} * make_float3 (m_6);
    float4  _S934 = *(&(globalParams_0->state_0)[_S932 + 2U]);
    *pv_0 = *pv_0 + float3 {_S934.x, _S934.y, _S934.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S935 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S936 = __ldg(&_S935->center_0);
    float3  r_9 = float3 {_S936.x, _S936.y, _S936.z} - wcom_1;
    float4  _S937 = __ldg(&_S935->scale_0);
    float kw_0 = _S937.x;
    uint _S938 = 4U * c_13;
    float4  _S939 = *(&(globalParams_0->state_0)[_S938]);
    float _S940 = _S936.w;
    float3  _S941 = cross_0(r_9, float3 {_S939.x, _S939.y, _S939.z} - tr_0) * make_float3 (_S940);
    float4  _S942 = __ldg(&_S935->inertia0_0);
    float4  _S943 = __ldg(&_S935->inertia1_0);
    float4  _S944 = __ldg(&_S935->inertia2_0);
    float4  _S945 = *(&(globalParams_0->state_0)[_S938 + 1U]);
    *lu_0 = *lu_0 + (_S941 + rows_mul_0(_S942, _S943, _S944, float3 {_S945.x, _S945.y, _S945.z})) * make_float3 (kw_0);
    float4  _S946 = *(&(globalParams_0->state_0)[_S938 + 2U]);
    float4  _S947 = *(&(globalParams_0->state_0)[_S938 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S946.x, _S946.y, _S946.z} - dv_0) * make_float3 (_S940) + rows_mul_0(_S942, _S943, _S944, float3 {_S947.x, _S947.y, _S947.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S948 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S948.x, _S948.y, _S948.z} - wcom_2;
    uint _S949 = 4U * c_14;
    float4  _S950 = *(&(globalParams_0->state_0)[_S949]);
    *(&(globalParams_0->state_0)[_S949]) = make_float4 ((float3 {_S950.x, _S950.y, _S950.z} - (tr_1 + cross_0(phi_0, r_10))).x, (float3 {_S950.x, _S950.y, _S950.z} - (tr_1 + cross_0(phi_0, r_10))).y, (float3 {_S950.x, _S950.y, _S950.z} - (tr_1 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S949])).w);
    uint _S951 = _S949 + 1U;
    float4  _S952 = *(&(globalParams_0->state_0)[_S951]);
    *(&(globalParams_0->state_0)[_S951]) = make_float4 ((float3 {_S952.x, _S952.y, _S952.z} - phi_0).x, (float3 {_S952.x, _S952.y, _S952.z} - phi_0).y, (float3 {_S952.x, _S952.y, _S952.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S951])).w);
    uint _S953 = _S949 + 2U;
    float4  _S954 = *(&(globalParams_0->state_0)[_S953]);
    *(&(globalParams_0->state_0)[_S953]) = make_float4 ((float3 {_S954.x, _S954.y, _S954.z} - (dv_1 + cross_0(dw_0, r_10))).x, (float3 {_S954.x, _S954.y, _S954.z} - (dv_1 + cross_0(dw_0, r_10))).y, (float3 {_S954.x, _S954.y, _S954.z} - (dv_1 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S953])).w);
    uint _S955 = _S949 + 3U;
    float4  _S956 = *(&(globalParams_0->state_0)[_S955]);
    *(&(globalParams_0->state_0)[_S955]) = make_float4 ((float3 {_S956.x, _S956.y, _S956.z} - dw_0).x, (float3 {_S956.x, _S956.y, _S956.z} - dw_0).y, (float3 {_S956.x, _S956.y, _S956.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S955])).w);
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
    Quat_0 _S957 = *hi_3;
    Quat_0 _S958 = dq_1;
    Quat_0 _S959 = quat_mul_0(&_S957, &_S958);
    Quat_0 _S960 = _S959;
    float4  _S961 = quat_vec_0(&_S960);
    quat_accumulate_0(hi_3, lo_3, _S961);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_7, Rigid_0 * rg_6, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S962 = isl_7->wcom_0;
    float3  wcom_3 = float3 {_S962.x, _S962.y, _S962.z};
    Quat_0 rot_2 = rg_6->rot_0;
    float3  _S963 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S964 = rg_6->rot_0;
    float3  _S965 = rotate_0(&_S964, _S963);
    comp_add_0(&rg_6->pos_1, &rg_6->pos_err_1, _S965);
    Quat_0 _S966 = rg_6->rot_0;
    float3  _S967 = inverse_rotate_0(&_S966, rg_6->w_4);
    float4  _S968 = isl_7->inertia0_1;
    float4  _S969 = isl_7->inertia1_1;
    float4  _S970 = isl_7->inertia2_1;
    float3  _S971 = cross_0(phi_2, rows_mul_0(isl_7->inertia0_1, isl_7->inertia1_1, isl_7->inertia2_1, _S967)) - rows_mul_0(isl_7->inertia0_1, isl_7->inertia1_1, isl_7->inertia2_1, cross_0(phi_2, _S967));
    Quat_0 _S972 = rg_6->rot_0;
    float3  _S973 = rotate_0(&_S972, _S971);
    turn_right_0(&rg_6->rot_0, &rg_6->rot_err_0, phi_2);
    float4  _S974 = isl_7->com_0;
    float3  _S975 = dv_2 + cross_0(dw_1, float3 {_S974.x, _S974.y, _S974.z} - wcom_3);
    Quat_0 _S976 = rot_2;
    float3  _S977 = rotate_0(&_S976, _S975);
    comp_add_0(&rg_6->vel_1, &rg_6->vel_err_1, _S977);
    Quat_0 _S978 = rot_2;
    float3  _S979 = rotate_0(&_S978, dw_1);
    rg_6->w_4 = rg_6->w_4 + _S979;
    Quat_0 _S980 = rg_6->rot_0;
    float3  _S981 = world_mul_0(&_S980, _S968, _S969, _S970, _S979);
    comp_add_0(&rg_6->l_2, &rg_6->l_err_1, _S973 + _S981);
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S982 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S982])->info_1.y;
    uint _S983 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S984;
    if(previous_1 == 0U)
    {
        _S984 = at_6;
    }
    else
    {
        _S984 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S983])->info_1)->y) = _S984;
    return;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S985;
    uint _S986;
    uint _S987;
    uint _S988;
    uint _S989;
    uint _S990;
    uint _S991;
    uint _S992 = __ballot_sync(4294967295U, true);
    uint tid_4 = threadIdx.x;
    uint _S993 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S993]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S994 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S995 = __ballot_sync(_S992, _S994);
    bool _S996;
    uint _S997;
    if(_S994)
    {
        bool _S998 = !driven_0;
        uint _S999 = __ballot_sync(_S992, true);
        _S996 = _S998;
        _S997 = _S999;
    }
    else
    {
        uint _S1000 = __ballot_sync(_S992, true);
        _S996 = false;
        _S997 = _S1000;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S1001 = (((&isl_8)->info_1.x) & 16U) != 0U;
    bool _S1002 = tid_4 == 0U;
    uint _S1003 = __ballot_sync(_S997, _S1002);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1002)
    {
        uint _S1004 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1005 = contact_island_0 != (_S1004 == 1U);
        uint _S1006 = __ballot_sync(_S1003, _S1005);
        if(_S1005)
        {
            uint _S1007 = __ballot_sync(_S1003, true);
            settled_0 = true;
            run_0 = _S1007;
        }
        else
        {
            bool _S1008 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1009 = __ballot_sync(_S1003, true);
            settled_0 = _S1008;
            run_0 = _S1009;
        }
        uint _S1010 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1011 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1011;
        }
        else
        {
            uint _S1012 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1012;
        }
        uint _S1013 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1014 = isl_8;
            bool _S1015 = contact_stopped_0(&_S1014);
            uint _S1016 = __ballot_sync(done_1, true);
            settled_0 = _S1015;
            done_1 = _S1016;
        }
        else
        {
            uint _S1017 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1017;
        }
        uint _S1018 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1019 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1020 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1021 = __ballot_sync(_S997, true);
        _S997 = _S1021;
    }
    else
    {
        uint _S1022 = __ballot_sync(_S997, true);
        _S997 = _S1022;
    }
    __syncthreads();
    bool _S1023 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1024 = __ballot_sync(_S997, _S1023);
    if(_S1023)
    {
        uint _S1025 = __ballot_sync(_S997, true);
        settled_0 = true;
        _S997 = _S1025;
    }
    else
    {
        bool _S1026 = (*&g_run_0) == 0U;
        uint _S1027 = __ballot_sync(_S997, true);
        settled_0 = _S1026;
        _S997 = _S1027;
    }
    uint _S1028 = __ballot_sync(_S997, settled_0);
    if(settled_0)
    {
        uint _S1029 = __ballot_sync(_S997, true);
        _S997 = 0U;
        run_0 = _S1029;
    }
    else
    {
        uint _S1030 = (&isl_8)->info_1.y;
        uint _S1031 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1032 = (U32_min((_S1030), (_S1031)));
        uint _S1033 = __ballot_sync(_S997, true);
        _S997 = _S1032;
        run_0 = _S1033;
    }
    float _S1034 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1035 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1036 = _S1035 != 0U;
    uint _S1037 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1038 = _S1037 != 0U;
    Island_0 _S1039 = isl_8;
    Rigid_0 _S1040 = rigid_of_0(&_S1039);
    Rigid_0 rg_7 = _S1040;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1001;
    done_1 = 0U;
    bool woke_1 = false;
    uint s_7 = 0U;
    uint _S1041 = run_0;
    for(;;)
    {
        uint _S1042 = 0U;
        bool _S1043 = s_7 < _S997;
        uint _S1044 = __ballot_sync(_S1041, _S1043);
        if(_S1043)
        {
            uint _S1045 = __ballot_sync(_S1041, true);
            _S1042 = _S1045;
        }
        else
        {
            uint _S1046 = __ballot_sync(_S1041, false);
            uint _S1047 = __ballot_sync(_S1041, false);
            uint _S1048 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            _S997 = _S1048;
            break;
        }
        uint _S1049 = 0U;
        uint abs_step_1 = (&isl_8)->info_1.w + s_7 + 1U;
        uint _S1050 = abs_step_1 - 1U;
        uint _S1051 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1050 - _S1051;
        bool _S1052 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1053 = __ballot_sync(_S1042, _S1052);
        bool _S1054;
        bool settled_1;
        uint c_15;
        if(_S1052)
        {
            uint _S1055 = __ballot_sync(_S1053, _S1002);
            if(_S1002)
            {
                bool _S1056 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
                uint _S1057 = __ballot_sync(_S1053, true);
                _S1054 = _S1056;
                c_15 = _S1057;
            }
            else
            {
                uint _S1058 = __ballot_sync(_S1053, true);
                _S1054 = false;
                c_15 = _S1058;
            }
            uint _S1059 = __ballot_sync(c_15, _S1054);
            if(_S1054)
            {
                Island_0 _S1060 = isl_8;
                Rigid_0 _S1061 = rg_7;
                record_probes_0(&_S1060, &_S1061, k_18);
                uint _S1062 = __ballot_sync(c_15, true);
            }
            else
            {
                uint _S1063 = __ballot_sync(c_15, true);
            }
            uint _S1064 = s_7 + 1U;
            uint _S1065 = __ballot_sync(_S1042, false);
            uint _S1066 = __ballot_sync(_S1041, true);
            settled_1 = settled_0;
            done_1 = _S1064;
            woke_0 = woke_1;
            _S1041 = _S1066;
            uint _S1067 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S1067;
            continue;
        }
        else
        {
            uint _S1068 = __ballot_sync(_S1042, true);
            _S1049 = _S1068;
        }
        uint _S1069 = __ballot_sync(_S1049, settled_0);
        uint c_16;
        uint i_16;
        if(settled_0)
        {
            float3  _S1070 = make_float3 (0.0f);
            float3  norm_0 = _S1070;
            float3  unused0_0 = _S1070;
            c_15 = (&isl_8)->range_0.x + tid_4;
            c_16 = _S1069;
            for(;;)
            {
                bool _S1071 = c_15 < ((&isl_8)->range_0.y);
                uint _S1072 = __ballot_sync(c_16, _S1071);
                if(_S1071)
                {
                    uint _S1073 = __ballot_sync(c_16, true);
                }
                else
                {
                    uint _S1074 = __ballot_sync(c_16, false);
                    uint _S1075 = __ballot_sync(c_16, false);
                    uint _S1076 = __ballot_sync(_S1069, true);
                    _S985 = _S1076;
                    break;
                }
                Quat_0 _S1077 = (&rg_7)->rot_0;
                float _S1078 = settled_chunk_load_0(c_15, &_S1077, k_18, _S1034, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1078;
                uint _S1079 = __ballot_sync(c_16, true);
                c_15 = c_15 + 256U;
                c_16 = _S1079;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0, _S985);
            uint _S1080 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1081 = _S1080 == 1U;
            uint _S1082 = __ballot_sync(_S985, _S1081);
            if(_S1081)
            {
                bool _S1083 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1084 = __ballot_sync(_S985, true);
                _S1054 = _S1083;
                i_16 = _S1084;
            }
            else
            {
                uint _S1085 = __ballot_sync(_S985, true);
                _S1054 = false;
                i_16 = _S1085;
            }
            uint _S1086 = __ballot_sync(i_16, _S1054);
            if(_S1054)
            {
                uint _S1087 = __ballot_sync(i_16, true);
                settled_1 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1088 = __ballot_sync(i_16, true);
                settled_1 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1089 = __ballot_sync(_S1049, true);
            c_15 = _S1089;
        }
        else
        {
            uint _S1090 = __ballot_sync(_S1049, true);
            settled_1 = settled_0;
            woke_0 = woke_1;
            c_15 = _S1090;
        }
        uint _S1091 = __ballot_sync(c_15, _S994);
        if(_S994)
        {
            float3  _S1092 = make_float3 (0.0f);
            float3  f_15 = _S1092;
            float3  t_12 = _S1092;
            c_16 = (&isl_8)->range_0.x + tid_4;
            i_16 = _S1091;
            for(;;)
            {
                bool _S1093 = c_16 < ((&isl_8)->range_0.y);
                uint _S1094 = __ballot_sync(i_16, _S1093);
                if(_S1093)
                {
                    uint _S1095 = __ballot_sync(i_16, true);
                }
                else
                {
                    uint _S1096 = __ballot_sync(i_16, false);
                    uint _S1097 = __ballot_sync(i_16, false);
                    uint _S1098 = __ballot_sync(_S1091, true);
                    _S986 = _S1098;
                    break;
                }
                Island_0 _S1099 = isl_8;
                Rigid_0 _S1100 = rg_7;
                net_load_0(c_16, &_S1099, &_S1100, k_18, _S1034, contact_island_0, &f_15, &t_12);
                uint _S1101 = __ballot_sync(i_16, true);
                c_16 = c_16 + 256U;
                i_16 = _S1101;
            }
            group_sum3_0(tid_4, &f_15, &t_12, _S986);
            Island_0 _S1102 = isl_8;
            rigid_acceleration_0(&_S1102, &rg_7, f_15, t_12);
            uint _S1103 = __ballot_sync(c_15, true);
            c_16 = _S1103;
        }
        else
        {
            uint _S1104 = __ballot_sync(c_15, true);
            c_16 = _S1104;
        }
        uint _S1105 = 0U;
        uint _S1106 = __ballot_sync(c_16, settled_1);
        uint _S1107;
        if(settled_1)
        {
            uint _S1108 = __ballot_sync(_S1106, _S996);
            if(_S996)
            {
                Island_0 _S1109 = isl_8;
                integrate_rigid_0(&_S1109, &rg_7, _S1034);
                uint _S1110 = __ballot_sync(_S1106, true);
                i_16 = _S1110;
            }
            else
            {
                uint _S1111 = __ballot_sync(_S1106, true);
                i_16 = _S1111;
            }
            uint _S1112 = __ballot_sync(i_16, _S1002);
            if(_S1002)
            {
                bool _S1113 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
                uint _S1114 = __ballot_sync(i_16, true);
                _S1054 = _S1113;
                _S1107 = _S1114;
            }
            else
            {
                uint _S1115 = __ballot_sync(i_16, true);
                _S1054 = false;
                _S1107 = _S1115;
            }
            uint _S1116 = __ballot_sync(_S1107, _S1054);
            if(_S1054)
            {
                Island_0 _S1117 = isl_8;
                Rigid_0 _S1118 = rg_7;
                record_probes_0(&_S1117, &_S1118, k_18);
                uint _S1119 = __ballot_sync(_S1107, true);
            }
            else
            {
                uint _S1120 = __ballot_sync(_S1107, true);
            }
            uint _S1121 = s_7 + 1U;
            uint _S1122 = __ballot_sync(c_16, false);
            uint _S1123 = __ballot_sync(_S1041, true);
            done_1 = _S1121;
            _S1041 = _S1123;
            uint _S1067 = s_7 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S1067;
            continue;
        }
        else
        {
            uint _S1124 = __ballot_sync(c_16, true);
            _S1105 = _S1124;
        }
        i_16 = (&isl_8)->range_0.z + tid_4;
        _S1107 = _S1105;
        for(;;)
        {
            uint _S1125 = 0U;
            bool _S1126 = i_16 < ((&isl_8)->range_0.w);
            uint _S1127 = __ballot_sync(_S1107, _S1126);
            if(_S1126)
            {
                uint _S1128 = __ballot_sync(_S1107, true);
                _S1125 = _S1128;
            }
            else
            {
                uint _S1129 = __ballot_sync(_S1107, false);
                uint _S1130 = __ballot_sync(_S1107, false);
                uint _S1131 = __ballot_sync(_S1105, true);
                _S987 = _S1131;
                break;
            }
            bool _S1132 = bond_update_0(i_16, _S1034, _S1036, abs_step_1);
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
            uint _S1136 = __ballot_sync(_S1107, true);
            i_16 = i_16 + 256U;
            _S1107 = _S1136;
        }
        __syncthreads();
        uint c_17 = (&isl_8)->range_0.x + tid_4;
        uint _S1137 = _S987;
        for(;;)
        {
            bool _S1138 = c_17 < ((&isl_8)->range_0.y);
            uint _S1139 = __ballot_sync(_S1137, _S1138);
            if(_S1138)
            {
                uint _S1140 = __ballot_sync(_S1137, true);
            }
            else
            {
                uint _S1141 = __ballot_sync(_S1137, false);
                uint _S1142 = __ballot_sync(_S1137, false);
                uint _S1143 = __ballot_sync(_S987, true);
                _S988 = _S1143;
                break;
            }
            Island_0 _S1144 = isl_8;
            Rigid_0 _S1145 = rg_7;
            chunk_update_0(c_17, &_S1144, &_S1145, _S1034, _S1038, k_18, contact_island_0, &work_2, &work_err_1);
            uint _S1146 = __ballot_sync(_S1137, true);
            c_17 = c_17 + 256U;
            _S1137 = _S1146;
        }
        __syncthreads();
        uint _S1147 = __ballot_sync(_S988, _S996);
        uint _S1148;
        if(_S996)
        {
            Island_0 _S1149 = isl_8;
            integrate_rigid_0(&_S1149, &rg_7, _S1034);
            uint _S1150 = __ballot_sync(_S988, true);
            _S1148 = _S1150;
        }
        else
        {
            uint _S1151 = __ballot_sync(_S988, true);
            _S1148 = _S1151;
        }
        uint _S1152 = __ballot_sync(_S1148, _S994);
        uint c_18;
        uint _S1153;
        uint c_19;
        if(_S994)
        {
            float4  _S1154 = (&isl_8)->wcom_0;
            float3  _S1155 = float3 {_S1154.x, _S1154.y, _S1154.z};
            float3  _S1156 = make_float3 (0.0f);
            float3  tu_1 = _S1156;
            float3  pv_1 = _S1156;
            c_18 = (&isl_8)->range_0.x + tid_4;
            _S1153 = _S1152;
            for(;;)
            {
                bool _S1157 = c_18 < ((&isl_8)->range_0.y);
                uint _S1158 = __ballot_sync(_S1153, _S1157);
                if(_S1157)
                {
                    uint _S1159 = __ballot_sync(_S1153, true);
                }
                else
                {
                    uint _S1160 = __ballot_sync(_S1153, false);
                    uint _S1161 = __ballot_sync(_S1153, false);
                    uint _S1162 = __ballot_sync(_S1152, true);
                    _S989 = _S1162;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1163 = __ballot_sync(_S1153, true);
                c_18 = c_18 + 256U;
                _S1153 = _S1163;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1, _S989);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1156;
            float3  lv_1 = _S1156;
            c_19 = (&isl_8)->range_0.x + tid_4;
            uint _S1164 = _S989;
            for(;;)
            {
                bool _S1165 = c_19 < ((&isl_8)->range_0.y);
                uint _S1166 = __ballot_sync(_S1164, _S1165);
                if(_S1165)
                {
                    uint _S1167 = __ballot_sync(_S1164, true);
                }
                else
                {
                    uint _S1168 = __ballot_sync(_S1164, false);
                    uint _S1169 = __ballot_sync(_S1164, false);
                    uint _S1170 = __ballot_sync(_S989, true);
                    _S990 = _S1170;
                    break;
                }
                drift_angular_0(c_19, _S1155, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1171 = __ballot_sync(_S1164, true);
                c_19 = c_19 + 256U;
                _S1164 = _S1171;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, _S990);
            float3  phi_3 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_4;
            uint _S1172 = _S990;
            for(;;)
            {
                bool _S1173 = c_20 < ((&isl_8)->range_0.y);
                uint _S1174 = __ballot_sync(_S1172, _S1173);
                if(_S1173)
                {
                    uint _S1175 = __ballot_sync(_S1172, true);
                }
                else
                {
                    uint _S1176 = __ballot_sync(_S1172, false);
                    uint _S1177 = __ballot_sync(_S1172, false);
                    uint _S1178 = __ballot_sync(_S990, true);
                    _S991 = _S1178;
                    break;
                }
                drift_apply_0(c_20, _S1155, tr_3, phi_3, dv_3, dw_2);
                uint _S1179 = __ballot_sync(_S1172, true);
                c_20 = c_20 + 256U;
                _S1172 = _S1179;
            }
            bool _S1180 = !driven_0;
            uint _S1181 = __ballot_sync(_S991, _S1180);
            if(_S1180)
            {
                Island_0 _S1182 = isl_8;
                drift_rigid_0(&_S1182, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S1183 = __ballot_sync(_S991, true);
            }
            else
            {
                uint _S1184 = __ballot_sync(_S991, true);
            }
            __syncthreads();
            uint _S1185 = __ballot_sync(_S1148, true);
            c_18 = _S1185;
        }
        else
        {
            uint _S1186 = __ballot_sync(_S1148, true);
            c_18 = _S1186;
        }
        uint _S1187 = __ballot_sync(c_18, _S1002);
        if(_S1002)
        {
            bool _S1188 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1189 = __ballot_sync(c_18, true);
            _S1054 = _S1188;
            _S1153 = _S1189;
        }
        else
        {
            uint _S1190 = __ballot_sync(c_18, true);
            _S1054 = false;
            _S1153 = _S1190;
        }
        uint _S1191 = __ballot_sync(_S1153, _S1054);
        if(_S1054)
        {
            Island_0 _S1192 = isl_8;
            Rigid_0 _S1193 = rg_7;
            record_probes_0(&_S1192, &_S1193, k_18);
            uint _S1194 = __ballot_sync(_S1153, true);
            c_19 = _S1194;
        }
        else
        {
            uint _S1195 = __ballot_sync(_S1153, true);
            c_19 = _S1195;
        }
        uint _S1196 = s_7 + 1U;
        bool _S1197 = (*&g_halt_0) != 0U;
        uint _S1198 = __ballot_sync(c_19, _S1197);
        if(_S1197)
        {
            uint _S1199 = __ballot_sync(c_19, false);
            uint _S1200 = __ballot_sync(_S1041, false);
            uint _S1201 = __ballot_sync(run_0, true);
            done_1 = _S1196;
            _S997 = _S1201;
            break;
        }
        else
        {
            uint _S1202 = __ballot_sync(c_19, true);
        }
        uint _S1203 = __ballot_sync(_S1041, true);
        done_1 = _S1196;
        _S1041 = _S1203;
        uint _S1067 = s_7 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_7 = _S1067;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_4, &wsum_0, &unused_1, _S997);
    uint _S1204 = __ballot_sync(_S997, _S1002);
    if(_S1002)
    {
        Quat_0 _S1205 = (&rg_7)->rot_0;
        float4  _S1206 = quat_vec_0(&_S1205);
        (&isl_8)->rotation_0 = _S1206;
        (&isl_8)->rotation_err_0 = (&rg_7)->rot_err_0;
        (&isl_8)->position_0 = make_float4 ((&rg_7)->pos_1.x, (&rg_7)->pos_1.y, (&rg_7)->pos_1.z, 0.0f);
        (&isl_8)->position_err_0 = make_float4 ((&rg_7)->pos_err_1.x, (&rg_7)->pos_err_1.y, (&rg_7)->pos_err_1.z, 0.0f);
        (&isl_8)->velocity_0 = make_float4 ((&rg_7)->vel_1.x, (&rg_7)->vel_1.y, (&rg_7)->vel_1.z, 0.0f);
        (&isl_8)->velocity_err_0 = make_float4 ((&rg_7)->vel_err_1.x, (&rg_7)->vel_err_1.y, (&rg_7)->vel_err_1.z, 0.0f);
        (&isl_8)->angular_velocity_0 = make_float4 ((&rg_7)->w_4.x, (&rg_7)->w_4.y, (&rg_7)->w_4.z, 0.0f);
        (&isl_8)->momentum_0 = make_float4 ((&rg_7)->l_2.x, (&rg_7)->l_2.y, (&rg_7)->l_2.z, 0.0f);
        (&isl_8)->momentum_err_0 = make_float4 ((&rg_7)->l_err_1.x, (&rg_7)->l_err_1.y, (&rg_7)->l_err_1.z, 0.0f);
        *&((&(&isl_8)->done_0)->x) = done_1;
        *&((&(&isl_8)->info_1)->y) = *&((&(&isl_8)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S996 = contact_island_0;
        }
        else
        {
            _S996 = false;
        }
        if(_S996)
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
        if(woke_0)
        {
            *&((&(&isl_8)->info_1)->x) = (*&((&(&isl_8)->info_1)->x)) & 4294967279U;
            *&((&(&isl_8)->info_1)->z) = (*&((&(&isl_8)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[_S993]) = isl_8;
    }
    return;
}

struct WideGroup_0
{
    uint island_0;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_3)
{
    WideGroup_0 w_8;
    uint _S1207 = table_0 + 4U * g_3;
    uint _S1208 = __ldg((&(globalParams_0->index_0)[_S1207]));
    (&w_8)->island_0 = _S1208;
    uint _S1209 = __ldg((&(globalParams_0->index_0)[_S1207 + 1U]));
    (&w_8)->begin_0 = _S1209;
    uint _S1210 = __ldg((&(globalParams_0->index_0)[_S1207 + 2U]));
    (&w_8)->end_0 = _S1210;
    uint _S1211 = __ldg((&(globalParams_0->index_0)[_S1207 + 3U]));
    (&w_8)->first_0 = _S1211;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1212 = isl_9->info_1;
    bool _S1213;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1213 = true;
    }
    else
    {
        _S1213 = (_S1212.y) == 0U;
    }
    if(_S1213)
    {
        return false;
    }
    if(((_S1212.x) & 4U) == 0U)
    {
        _S1213 = true;
    }
    else
    {
        bool _S1214 = contact_stopped_0(isl_9);
        _S1213 = !_S1214;
    }
    return _S1213;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_5, Island_0 * isl_10)
{
    if(tid_5 == 0U)
    {
        bool _S1215 = wide_runs_0(isl_10);
        int _S1216;
        if(_S1215)
        {
            _S1216 = int(1);
        }
        else
        {
            _S1216 = int(0);
        }
        *&g_wide_run_0 = uint(_S1216);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1217 = isl_11->info_1.w;
    uint _S1218 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1217 - _S1218;
}

static __device__ bool contact_stopped_1(uint _S1219)
{
    Island_0 * _S1220 = (&(globalParams_0->islands_0)[_S1219]);
    uint _S1221 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S1222 = (&(globalParams_0->islands_0)[_S1221])->info_1;
    bool _S1223;
    if((((&(globalParams_0->islands_0)[_S1221])->info_1.z) & 1U) != 0U)
    {
        _S1223 = true;
    }
    else
    {
        uint _S1224 = _S1222.y;
        if(_S1224 != 0U)
        {
            _S1223 = _S1224 <= (_S1220->info_1.w);
        }
        else
        {
            _S1223 = false;
        }
    }
    return _S1223;
}

static __device__ bool wide_runs_1(uint _S1225)
{
    uint4  _S1226 = (&(globalParams_0->islands_0)[_S1225])->info_1;
    bool _S1227;
    if((((&(globalParams_0->islands_0)[_S1225])->info_1.z) & 1U) != 0U)
    {
        _S1227 = true;
    }
    else
    {
        _S1227 = (_S1226.y) == 0U;
    }
    if(_S1227)
    {
        return false;
    }
    if(((_S1226.x) & 4U) == 0U)
    {
        _S1227 = true;
    }
    else
    {
        bool _S1228 = contact_stopped_1(_S1225);
        _S1227 = !_S1228;
    }
    return _S1227;
}

static __device__ bool wide_enter_1(uint _S1229, uint _S1230)
{
    if(_S1229 == 0U)
    {
        bool _S1231 = wide_runs_1(_S1230);
        int _S1232;
        if(_S1231)
        {
            _S1232 = int(1);
        }
        else
        {
            _S1232 = int(0);
        }
        *&g_wide_run_0 = uint(_S1232);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1233 = 0U;
    uint _S1234;
    uint _S1235 = __ballot_sync(4294967295U, true);
    uint tid_6 = threadIdx.x;
    uint _S1236 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1237 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1236, _S1237);
    bool _S1238 = _S1237 != (wg_0.first_0);
    uint _S1239 = __ballot_sync(_S1235, _S1238);
    if(_S1238)
    {
        return;
    }
    else
    {
        uint _S1240 = __ballot_sync(_S1235, true);
        _S1233 = _S1240;
    }
    Island_0 * _S1241 = (&(globalParams_0->islands_0)[wg_0.island_0]);
    Island_0 isl_12 = *_S1241;
    uint _S1242 = (*_S1241).info_1.x;
    bool _S1243 = (_S1242 & 16U) == 0U;
    uint _S1244 = __ballot_sync(_S1233, _S1243);
    bool _S1245;
    uint c_21;
    if(_S1243)
    {
        uint _S1246 = __ballot_sync(_S1233, true);
        _S1245 = true;
        c_21 = _S1246;
    }
    else
    {
        bool _S1247 = wide_enter_1(tid_6, wg_0.island_0);
        bool _S1248 = !_S1247;
        uint _S1249 = __ballot_sync(_S1233, true);
        _S1245 = _S1248;
        c_21 = _S1249;
    }
    uint _S1250 = 0U;
    uint _S1251 = __ballot_sync(c_21, _S1245);
    if(_S1245)
    {
        return;
    }
    else
    {
        uint _S1252 = __ballot_sync(c_21, true);
        _S1250 = _S1252;
    }
    Quat_0 _S1253 = quat_of_0(isl_12.rotation_0);
    bool _S1254 = (_S1242 & 4U) != 0U;
    float3  _S1255 = make_float3 (0.0f);
    float3  norm_1 = _S1255;
    float3  unused_2 = _S1255;
    c_21 = isl_12.range_0.x + tid_6;
    uint _S1256;
    _S1256 = _S1250;
    for(;;)
    {
        bool _S1257 = c_21 < (isl_12.range_0.y);
        uint _S1258 = __ballot_sync(_S1256, _S1257);
        if(_S1257)
        {
            uint _S1259 = __ballot_sync(_S1256, true);
        }
        else
        {
            uint _S1260 = __ballot_sync(_S1256, false);
            uint _S1261 = __ballot_sync(_S1256, false);
            uint _S1262 = __ballot_sync(_S1250, true);
            _S1234 = _S1262;
            break;
        }
        Island_0 _S1263 = isl_12;
        uint _S1264 = wide_step_0(&_S1263);
        float _S1265 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1266 = _S1253;
        float _S1267 = settled_chunk_load_0(c_21, &_S1266, _S1264, _S1265, _S1254);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1267;
        uint _S1268 = __ballot_sync(_S1256, true);
        c_21 = c_21 + 256U;
        _S1256 = _S1268;
    }
    group_sum3_0(tid_6, &norm_1, &unused_2, _S1234);
    bool _S1269 = tid_6 == 0U;
    uint _S1270 = __ballot_sync(_S1234, _S1269);
    if(_S1269)
    {
        uint _S1271 = __ldg(&globalParams_0->params_0->solve_mode_0);
        _S1245 = _S1271 == 1U;
    }
    else
    {
        _S1245 = false;
    }
    if(_S1245)
    {
        _S1245 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1245 = false;
    }
    if(_S1245)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_0])->info_1)->x) = _S1242 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_0])->info_1)->z) = (isl_12.info_1.z) | 4U;
    }
    return;
}

static __device__ void wide_store_0(uint slot_1, uint p_12, float3  a_15, float3  b_30)
{
    uint _S1272 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1273 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1272 + _S1273 + p_12]) = make_float4 (a_15.x, a_15.y, a_15.z, 0.0f);
    uint _S1274 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1274 + _S1273 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1275 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1276 = blockIdx.x;
    uint _S1277 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1276 < _S1277;
    uint _S1278 = __ballot_sync(_S1275, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1279;
    if(bond_group_0)
    {
        uint _S1280 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1281 = wide_group_0(_S1280, _S1276);
        uint _S1282 = __ballot_sync(_S1275, true);
        wg_1 = _S1281;
        _S1279 = _S1282;
    }
    else
    {
        uint _S1283 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1284 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1285 = wide_group_0(_S1283, _S1276 - _S1284);
        uint _S1286 = __ballot_sync(_S1275, true);
        wg_1 = _S1285;
        _S1279 = _S1286;
    }
    uint _S1287 = 0U;
    WideGroup_0 _S1288 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_0]);
    bool _S1289 = wide_enter_1(tid_7, wg_1.island_0);
    bool _S1290 = !_S1289;
    uint _S1291 = __ballot_sync(_S1279, _S1290);
    if(_S1290)
    {
        return;
    }
    else
    {
        uint _S1292 = __ballot_sync(_S1279, true);
        _S1287 = _S1292;
    }
    uint _S1293 = 0U;
    Island_0 _S1294 = isl_13;
    uint _S1295 = wide_step_0(&_S1294);
    uint _S1296 = __ballot_sync(_S1287, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_17 = wg_1.begin_0 + tid_7;
        bool _S1297;
        if(i_17 < (wg_1.end_0))
        {
            float _S1298 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1299 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1300 = bond_update_0(i_17, _S1298, _S1299 != 0U, isl_13.info_1.w + 1U);
            _S1297 = _S1300;
        }
        else
        {
            _S1297 = false;
        }
        if(_S1297)
        {
            *&((&(&(globalParams_0->islands_0)[_S1288.island_0])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1301 = __ballot_sync(_S1287, true);
        _S1293 = _S1301;
    }
    uint _S1302 = 0U;
    uint _S1303 = isl_13.info_1.x;
    bool _S1304 = (_S1303 & 1U) != 0U;
    uint _S1305 = __ballot_sync(_S1293, _S1304);
    if(_S1304)
    {
        return;
    }
    else
    {
        uint _S1306 = __ballot_sync(_S1293, true);
        _S1302 = _S1306;
    }
    float3  _S1307 = make_float3 (0.0f);
    float3  f_16 = _S1307;
    float3  t_13 = _S1307;
    uint c_22 = wg_1.begin_0 + tid_7;
    bool _S1308 = c_22 < (wg_1.end_0);
    uint _S1309 = __ballot_sync(_S1302, _S1308);
    if(_S1308)
    {
        Island_0 _S1310 = isl_13;
        Rigid_0 _S1311 = rigid_of_0(&_S1310);
        float _S1312 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1313 = (_S1303 & 4U) != 0U;
        Island_0 _S1314 = isl_13;
        Rigid_0 _S1315 = _S1311;
        net_load_0(c_22, &_S1314, &_S1315, _S1295, _S1312, _S1313, &f_16, &t_13);
        uint _S1316 = __ballot_sync(_S1302, true);
        _S1279 = _S1316;
    }
    else
    {
        uint _S1317 = __ballot_sync(_S1302, true);
        _S1279 = _S1317;
    }
    group_sum3_0(tid_7, &f_16, &t_13, _S1279);
    bool _S1318 = tid_7 == 0U;
    uint _S1319 = __ballot_sync(_S1279, _S1318);
    if(_S1318)
    {
        uint _S1320 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1276 - _S1320, 0U, f_16, t_13);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_8, uint first_1, uint count_5, uint p_13, float3  * a_16, float3  * b_31, uint _S1321)
{
    uint _S1322;
    float4  _S1323 = make_float4 (0.0f);
    float4  x_20 = _S1323;
    float4  y_5 = _S1323;
    uint s_8 = tid_8;
    uint _S1324 = _S1321;
    for(;;)
    {
        bool _S1325 = s_8 < count_5;
        uint _S1326 = __ballot_sync(_S1324, _S1325);
        if(_S1325)
        {
            uint _S1327 = __ballot_sync(_S1324, true);
        }
        else
        {
            uint _S1328 = __ballot_sync(_S1324, false);
            uint _S1329 = __ballot_sync(_S1324, false);
            uint _S1330 = __ballot_sync(_S1321, true);
            _S1322 = _S1330;
            break;
        }
        uint _S1331 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1332 = 8U * (first_1 + s_8);
        x_20 = x_20 + *(&(globalParams_0->scratch_0)[_S1331 + _S1332 + p_13]);
        uint _S1333 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1333 + _S1332 + p_13 + 1U]);
        uint _S1334 = __ballot_sync(_S1324, true);
        s_8 = s_8 + 256U;
        _S1324 = _S1334;
    }
    group_sum2_0(tid_8, &x_20, &y_5, _S1322);
    float4  _S1335 = x_20;
    *a_16 = float3 {_S1335.x, _S1335.y, _S1335.z};
    float4  _S1336 = y_5;
    *b_31 = float3 {_S1336.x, _S1336.y, _S1336.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_9, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1337)
{
    Rigid_0 _S1338 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1338;
    bool _S1339 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1340 = __ballot_sync(_S1337, _S1339);
    if(_S1339)
    {
        float3  f_17;
        float3  t_14;
        wide_partials_0(tid_9, wg_2->first_0, isl_14->done_0.z, 0U, &f_17, &t_14, _S1340);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_14);
        uint _S1341 = __ballot_sync(_S1337, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1342 = 0U;
    uint _S1343 = __ballot_sync(4294967295U, true);
    uint tid_10 = threadIdx.x;
    uint _S1344 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1345 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1344, _S1345);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_0]);
    bool _S1346 = wide_enter_1(tid_10, wg_3.island_0);
    bool _S1347 = !_S1346;
    uint _S1348 = __ballot_sync(_S1343, _S1347);
    if(_S1347)
    {
        return;
    }
    else
    {
        uint _S1349 = __ballot_sync(_S1343, true);
        _S1342 = _S1349;
    }
    uint _S1350 = 0U;
    uint _S1351 = isl_15.info_1.x;
    bool anchored_0 = (_S1351 & 1U) != 0U;
    bool _S1352 = (_S1351 & 16U) != 0U;
    uint _S1353 = __ballot_sync(_S1342, _S1352);
    if(_S1352)
    {
        if(tid_10 == 0U)
        {
            uint _S1354 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1354 + 8U * _S1345 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1355 = __ballot_sync(_S1342, true);
        _S1350 = _S1355;
    }
    Island_0 _S1356 = isl_15;
    WideGroup_0 _S1357 = wg_3;
    Rigid_0 _S1358 = wide_rigid_frame_0(tid_10, &_S1356, &_S1357, _S1350);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1359 = make_float3 (0.0f);
    float3  tu_2 = _S1359;
    float3  pv_2 = _S1359;
    uint c_23 = wg_3.begin_0 + tid_10;
    bool _S1360 = c_23 < (wg_3.end_0);
    uint _S1361 = __ballot_sync(_S1350, _S1360);
    uint _S1362;
    if(_S1360)
    {
        float _S1363 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1364 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1365 = _S1364 != 0U;
        Island_0 _S1366 = isl_15;
        uint _S1367 = wide_step_0(&_S1366);
        bool _S1368 = (_S1351 & 4U) != 0U;
        Island_0 _S1369 = isl_15;
        Rigid_0 _S1370 = _S1358;
        chunk_update_0(c_23, &_S1369, &_S1370, _S1363, _S1365, _S1367, _S1368, &work_3, &work_err_2);
        bool _S1371 = !anchored_0;
        uint _S1372 = __ballot_sync(_S1361, _S1371);
        if(_S1371)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1373 = __ballot_sync(_S1361, true);
        }
        else
        {
            uint _S1374 = __ballot_sync(_S1361, true);
        }
        uint _S1375 = __ballot_sync(_S1350, true);
        _S1362 = _S1375;
    }
    else
    {
        uint _S1376 = __ballot_sync(_S1350, true);
        _S1362 = _S1376;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_3 = _S1359;
    group_sum3_0(tid_10, &wsum_1, &unused_3, _S1362);
    bool _S1377 = !anchored_0;
    uint _S1378 = __ballot_sync(_S1362, _S1377);
    if(_S1377)
    {
        group_sum3_0(tid_10, &tu_2, &pv_2, _S1378);
        uint _S1379 = __ballot_sync(_S1362, true);
    }
    if(tid_10 == 0U)
    {
        uint _S1380 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1380 + 8U * _S1345 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1377)
        {
            wide_store_0(_S1345, 2U, tu_2, pv_2);
        }
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1381 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1382 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1383 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1382, _S1383);
    Island_0 * _S1384 = (&(globalParams_0->islands_0)[wg_4.island_0]);
    Island_0 isl_16 = *_S1384;
    bool _S1385 = (((*_S1384).info_1.x) & 17U) != 0U;
    uint _S1386 = __ballot_sync(_S1381, _S1385);
    bool _S1387;
    uint _S1388;
    if(_S1385)
    {
        uint _S1389 = __ballot_sync(_S1381, true);
        _S1387 = true;
        _S1388 = _S1389;
    }
    else
    {
        bool _S1390 = wide_enter_1(tid_11, wg_4.island_0);
        bool _S1391 = !_S1390;
        uint _S1392 = __ballot_sync(_S1381, true);
        _S1387 = _S1391;
        _S1388 = _S1392;
    }
    uint _S1393 = 0U;
    uint _S1394 = __ballot_sync(_S1388, _S1387);
    if(_S1387)
    {
        return;
    }
    else
    {
        uint _S1395 = __ballot_sync(_S1388, true);
        _S1393 = _S1395;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_11, wg_4.first_0, isl_16.done_0.z, 2U, &tu_3, &pv_3, _S1393);
    float _S1396 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1396);
    float3  dv_4 = pv_3 / make_float3 (_S1396);
    float3  _S1397 = make_float3 (0.0f);
    float3  lu_2 = _S1397;
    float3  lv_2 = _S1397;
    uint c_24 = wg_4.begin_0 + tid_11;
    bool _S1398 = c_24 < (wg_4.end_0);
    uint _S1399 = __ballot_sync(_S1393, _S1398);
    if(_S1398)
    {
        float4  _S1400 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1400.x, _S1400.y, _S1400.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1401 = __ballot_sync(_S1393, true);
        _S1388 = _S1401;
    }
    else
    {
        uint _S1402 = __ballot_sync(_S1393, true);
        _S1388 = _S1402;
    }
    group_sum3_0(tid_11, &lu_2, &lv_2, _S1388);
    bool _S1403 = tid_11 == 0U;
    uint _S1404 = __ballot_sync(_S1388, _S1403);
    if(_S1403)
    {
        wide_store_0(_S1383, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1405 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1406 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1407 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1406, _S1407);
    Island_0 * _S1408 = (&(globalParams_0->islands_0)[wg_5.island_0]);
    Island_0 isl_17 = *_S1408;
    uint _S1409 = (*_S1408).info_1.x;
    bool _S1410 = (_S1409 & 1U) != 0U;
    uint _S1411 = __ballot_sync(_S1405, _S1410);
    bool _S1412;
    uint _S1413;
    if(_S1410)
    {
        uint _S1414 = __ballot_sync(_S1405, true);
        _S1412 = true;
        _S1413 = _S1414;
    }
    else
    {
        bool _S1415 = wide_enter_1(tid_12, wg_5.island_0);
        bool _S1416 = !_S1415;
        uint _S1417 = __ballot_sync(_S1405, true);
        _S1412 = _S1416;
        _S1413 = _S1417;
    }
    uint _S1418 = 0U;
    uint _S1419 = __ballot_sync(_S1413, _S1412);
    if(_S1412)
    {
        return;
    }
    else
    {
        uint _S1420 = __ballot_sync(_S1413, true);
        _S1418 = _S1420;
    }
    uint _S1421 = 0U;
    bool _S1422 = (_S1409 & 16U) != 0U;
    uint _S1423 = __ballot_sync(_S1418, _S1422);
    if(_S1422)
    {
        uint _S1424 = 0U;
        bool _S1425 = _S1407 != (wg_5.first_0);
        uint _S1426 = __ballot_sync(_S1423, _S1425);
        if(_S1425)
        {
            return;
        }
        else
        {
            uint _S1427 = __ballot_sync(_S1423, true);
            _S1424 = _S1427;
        }
        Island_0 _S1428 = isl_17;
        WideGroup_0 _S1429 = wg_5;
        Rigid_0 _S1430 = wide_rigid_frame_0(tid_12, &_S1428, &_S1429, _S1424);
        Rigid_0 rs_0 = _S1430;
        bool _S1431 = tid_12 != 0U;
        uint _S1432 = __ballot_sync(_S1424, _S1431);
        if(_S1431)
        {
            _S1412 = true;
        }
        else
        {
            _S1412 = (_S1409 & 2U) != 0U;
        }
        if(_S1412)
        {
            return;
        }
        float _S1433 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1434 = isl_17;
        integrate_rigid_0(&_S1434, &rs_0, _S1433);
        Quat_0 _S1435 = (&rs_0)->rot_0;
        float4  _S1436 = quat_vec_0(&_S1435);
        (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_0 = _S1436;
        (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_err_0 = (&rs_0)->rot_err_0;
        (&(globalParams_0->islands_0)[wg_5.island_0])->position_0 = make_float4 ((&rs_0)->pos_1.x, (&rs_0)->pos_1.y, (&rs_0)->pos_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->position_err_0 = make_float4 ((&rs_0)->pos_err_1.x, (&rs_0)->pos_err_1.y, (&rs_0)->pos_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_0 = make_float4 ((&rs_0)->vel_1.x, (&rs_0)->vel_1.y, (&rs_0)->vel_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_1.x, (&rs_0)->vel_err_1.y, (&rs_0)->vel_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->angular_velocity_0 = make_float4 ((&rs_0)->w_4.x, (&rs_0)->w_4.y, (&rs_0)->w_4.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->momentum_0 = make_float4 ((&rs_0)->l_2.x, (&rs_0)->l_2.y, (&rs_0)->l_2.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->momentum_err_0 = make_float4 ((&rs_0)->l_err_1.x, (&rs_0)->l_err_1.y, (&rs_0)->l_err_1.z, 0.0f);
        return;
    }
    else
    {
        uint _S1437 = __ballot_sync(_S1418, true);
        _S1421 = _S1437;
    }
    uint _S1438 = isl_17.done_0.z;
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_12, wg_5.first_0, _S1438, 2U, &tu_4, &pv_4, _S1421);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_12, wg_5.first_0, _S1438, 4U, &lu_3, &lv_3, _S1421);
    float _S1439 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1439);
    float3  dv_5 = pv_4 / make_float3 (_S1439);
    float3  phi_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_12;
    bool _S1440 = c_25 < (wg_5.end_0);
    uint _S1441 = __ballot_sync(_S1421, _S1440);
    if(_S1440)
    {
        float4  _S1442 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1442.x, _S1442.y, _S1442.z}, tr_5, phi_4, dv_5, dw_3);
        uint _S1443 = __ballot_sync(_S1421, true);
        _S1413 = _S1443;
    }
    else
    {
        uint _S1444 = __ballot_sync(_S1421, true);
        _S1413 = _S1444;
    }
    uint _S1445 = 0U;
    bool _S1446 = _S1407 != (wg_5.first_0);
    uint _S1447 = __ballot_sync(_S1413, _S1446);
    if(_S1446)
    {
        return;
    }
    else
    {
        uint _S1448 = __ballot_sync(_S1413, true);
        _S1445 = _S1448;
    }
    Island_0 _S1449 = isl_17;
    WideGroup_0 _S1450 = wg_5;
    Rigid_0 _S1451 = wide_rigid_frame_0(tid_12, &_S1449, &_S1450, _S1445);
    Rigid_0 rg_9 = _S1451;
    bool _S1452 = tid_12 != 0U;
    uint _S1453 = __ballot_sync(_S1445, _S1452);
    if(_S1452)
    {
        return;
    }
    if(!((_S1409 & 2U) != 0U))
    {
        float _S1454 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1455 = isl_17;
        integrate_rigid_0(&_S1455, &rg_9, _S1454);
        Island_0 _S1456 = isl_17;
        drift_rigid_0(&_S1456, &rg_9, tr_5, phi_4, dv_5, dw_3);
    }
    Quat_0 _S1457 = (&rg_9)->rot_0;
    float4  _S1458 = quat_vec_0(&_S1457);
    (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_0 = _S1458;
    (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_err_0 = (&rg_9)->rot_err_0;
    (&(globalParams_0->islands_0)[wg_5.island_0])->position_0 = make_float4 ((&rg_9)->pos_1.x, (&rg_9)->pos_1.y, (&rg_9)->pos_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->position_err_0 = make_float4 ((&rg_9)->pos_err_1.x, (&rg_9)->pos_err_1.y, (&rg_9)->pos_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_0 = make_float4 ((&rg_9)->vel_1.x, (&rg_9)->vel_1.y, (&rg_9)->vel_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_err_0 = make_float4 ((&rg_9)->vel_err_1.x, (&rg_9)->vel_err_1.y, (&rg_9)->vel_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->angular_velocity_0 = make_float4 ((&rg_9)->w_4.x, (&rg_9)->w_4.y, (&rg_9)->w_4.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->momentum_0 = make_float4 ((&rg_9)->l_2.x, (&rg_9)->l_2.y, (&rg_9)->l_2.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->momentum_err_0 = make_float4 ((&rg_9)->l_err_1.x, (&rg_9)->l_err_1.y, (&rg_9)->l_err_1.z, 0.0f);
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S1459 = 0U;
    uint _S1460 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1461 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1462 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1461, _S1462);
    bool _S1463 = _S1462 != (wg_6.first_0);
    uint _S1464 = __ballot_sync(_S1460, _S1463);
    if(_S1463)
    {
        return;
    }
    else
    {
        uint _S1465 = __ballot_sync(_S1460, true);
        _S1459 = _S1465;
    }
    uint _S1466 = 0U;
    Island_0 * _S1467 = (&(globalParams_0->islands_0)[wg_6.island_0]);
    Island_0 isl_18 = *_S1467;
    Island_0 _S1468 = *_S1467;
    bool _S1469 = wide_enter_0(tid_13, &_S1468);
    bool _S1470 = !_S1469;
    uint _S1471 = __ballot_sync(_S1459, _S1470);
    if(_S1470)
    {
        return;
    }
    else
    {
        uint _S1472 = __ballot_sync(_S1459, true);
        _S1466 = _S1472;
    }
    float3  work_4;
    float3  unused_4;
    wide_partials_0(tid_13, wg_6.first_0, (&isl_18)->done_0.z, 6U, &work_4, &unused_4, _S1466);
    bool _S1473 = tid_13 != 0U;
    uint _S1474 = __ballot_sync(_S1466, _S1473);
    if(_S1473)
    {
        return;
    }
    Island_0 _S1475 = isl_18;
    uint _S1476 = wide_step_0(&_S1475);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1477 = isl_18;
        Rigid_0 _S1478 = rigid_of_0(&_S1477);
        Island_0 _S1479 = isl_18;
        Rigid_0 _S1480 = _S1478;
        record_probes_0(&_S1479, &_S1480, _S1476);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1481;
    if(halt_0)
    {
        _S1481 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1481 = false;
    }
    if(_S1481)
    {
        contact_split_at_0((&isl_18)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_18)->energy_1)->x), &((&(&isl_18)->energy_1)->y), work_4.x);
    *&((&(&isl_18)->energy_1)->y) = *&((&(&isl_18)->energy_1)->y) + work_4.y;
    *&((&(&isl_18)->done_0)->x) = *&((&(&isl_18)->done_0)->x) + 1U;
    *&((&(&isl_18)->info_1)->y) = *&((&(&isl_18)->info_1)->y) - 1U;
    *&((&(&isl_18)->info_1)->w) = *&((&(&isl_18)->info_1)->w) + 1U;
    if(halt_0)
    {
        *&((&(&isl_18)->info_1)->z) = (((&isl_18)->info_1.z) & 4294967293U) | 1U;
    }
    *(&(globalParams_0->islands_0)[wg_6.island_0]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_26, uint slot_2)
{
    uint _S1482 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1482 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_14, Island_0 * isl_19, uint slot_3, uint _S1483)
{
    uint _S1484;
    uint _S1485;
    float3  _S1486 = make_float3 (0.0f);
    float3  net_f_0 = _S1486;
    float3  net_m_0 = _S1486;
    uint4  _S1487 = isl_19->range_0;
    uint _S1488 = isl_19->range_0.x + tid_14;
    uint c_27 = _S1488;
    uint _S1489 = _S1483;
    for(;;)
    {
        uint _S1490 = _S1487.y;
        _S1484 = _S1490;
        bool _S1491 = c_27 < _S1490;
        uint _S1492 = __ballot_sync(_S1489, _S1491);
        if(_S1491)
        {
            uint _S1493 = __ballot_sync(_S1489, true);
        }
        else
        {
            uint _S1494 = __ballot_sync(_S1489, false);
            uint _S1495 = __ballot_sync(_S1489, false);
            uint _S1496 = __ballot_sync(_S1483, true);
            _S1485 = _S1496;
            break;
        }
        float4  _S1497 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1497.x, _S1497.y, _S1497.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1498 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1499 = isl_19->com_0;
        float4  _S1500 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1498.x, _S1498.y, _S1498.z} - float3 {_S1499.x, _S1499.y, _S1499.z}, fi_1) + float3 {_S1500.x, _S1500.y, _S1500.z});
        uint _S1501 = __ballot_sync(_S1489, true);
        c_27 = c_27 + 256U;
        _S1489 = _S1501;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0, _S1485);
    float4  _S1502 = isl_19->com_0;
    float3  _S1503 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1504 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1488;
    for(;;)
    {
        if(c_27 < _S1484)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1505 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1506 = __ldg(&_S1505->center_0);
        uint _S1507 = sv_0(c_27, slot_3);
        float4  _S1508 = *(&(globalParams_0->scratch_0)[_S1507]);
        *(&(globalParams_0->scratch_0)[_S1507]) = make_float4 ((float3 {_S1508.x, _S1508.y, _S1508.z} - (_S1503 + cross_0(_S1504, float3 {_S1506.x, _S1506.y, _S1506.z} - float3 {_S1502.x, _S1502.y, _S1502.z})) * make_float3 (_S1506.w)).x, (float3 {_S1508.x, _S1508.y, _S1508.z} - (_S1503 + cross_0(_S1504, float3 {_S1506.x, _S1506.y, _S1506.z} - float3 {_S1502.x, _S1502.y, _S1502.z})) * make_float3 (_S1506.w)).y, (float3 {_S1508.x, _S1508.y, _S1508.z} - (_S1503 + cross_0(_S1504, float3 {_S1506.x, _S1506.y, _S1506.z} - float3 {_S1502.x, _S1502.y, _S1502.z})) * make_float3 (_S1506.w)).z, 0.0f);
        uint _S1509 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1510 = (&(globalParams_0->scratch_0)[_S1509]);
        float4  _S1511 = *(&(globalParams_0->scratch_0)[_S1509]);
        float3  _S1512 = float3 {_S1511.x, _S1511.y, _S1511.z};
        float4  _S1513 = __ldg(&_S1505->inertia0_0);
        float4  _S1514 = __ldg(&_S1505->inertia1_0);
        float4  _S1515 = __ldg(&_S1505->inertia2_0);
        *_S1510 = make_float4 ((_S1512 - rows_mul_0(_S1513, _S1514, _S1515, _S1504)).x, (_S1512 - rows_mul_0(_S1513, _S1514, _S1515, _S1504)).y, (_S1512 - rows_mul_0(_S1513, _S1514, _S1515, _S1504)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1516)
{
    uint _S1517;
    float4  _S1518 = make_float4 (0.0f);
    float4  acc_0 = _S1518;
    float4  unused_5 = _S1518;
    uint c_28 = c0_0 + tid_15;
    uint _S1519 = _S1516;
    for(;;)
    {
        bool _S1520 = c_28 < c1_0;
        uint _S1521 = __ballot_sync(_S1519, _S1520);
        if(_S1520)
        {
            uint _S1522 = __ballot_sync(_S1519, true);
        }
        else
        {
            uint _S1523 = __ballot_sync(_S1519, false);
            uint _S1524 = __ballot_sync(_S1519, false);
            uint _S1525 = __ballot_sync(_S1516, true);
            _S1517 = _S1525;
            break;
        }
        float4  _S1526 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1527 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1528 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1529 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1526.x, _S1526.y, _S1526.z}, float3 {_S1527.x, _S1527.y, _S1527.z}) + dot_0(float3 {_S1528.x, _S1528.y, _S1528.z}, float3 {_S1529.x, _S1529.y, _S1529.z}));
        uint _S1530 = __ballot_sync(_S1519, true);
        c_28 = c_28 + 256U;
        _S1519 = _S1530;
    }
    group_sum2_0(tid_15, &acc_0, &unused_5, _S1517);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1531, float3  * _S1532, float3  * _S1533)
{
    BondStatic_0 * _S1534 = (&(globalParams_0->bonds_0)[_S1531]);
    JointBond_0 _S1535 = slang_ldg_0(&_S1534->law_0);
    uint ca_1 = _S1535.ids_0.y;
    uint cb_1 = _S1535.ids_0.z;
    uint _S1536 = 4U * cb_1;
    float4  _S1537 = *(&(globalParams_0->state_0)[_S1536]);
    uint _S1538 = 4U * ca_1;
    float4  _S1539 = *(&(globalParams_0->state_0)[_S1538]);
    float4  _S1540 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1541 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1537.x, _S1537.y, _S1537.z} - float3 {_S1539.x, _S1539.y, _S1539.z} + (float3 {_S1540.x, _S1540.y, _S1540.z} - float3 {_S1541.x, _S1541.y, _S1541.z});
    uint _S1542 = _S1536 + 1U;
    float4  _S1543 = *(&(globalParams_0->state_0)[_S1542]);
    uint _S1544 = _S1538 + 1U;
    float4  _S1545 = *(&(globalParams_0->state_0)[_S1544]);
    uint _S1546 = sv_0(cb_1, 22U);
    float4  _S1547 = *(&(globalParams_0->scratch_0)[_S1546]);
    uint _S1548 = sv_0(ca_1, 22U);
    float4  _S1549 = *(&(globalParams_0->scratch_0)[_S1548]);
    float3  dth_0 = float3 {_S1543.x, _S1543.y, _S1543.z} - float3 {_S1545.x, _S1545.y, _S1545.z} + (float3 {_S1547.x, _S1547.y, _S1547.z} - float3 {_S1549.x, _S1549.y, _S1549.z});
    float4  _S1550 = *(&(globalParams_0->state_0)[_S1544]);
    float4  _S1551 = *(&(globalParams_0->scratch_0)[_S1548]);
    float3  ta_3 = float3 {_S1550.x, _S1550.y, _S1550.z} + float3 {_S1551.x, _S1551.y, _S1551.z};
    float4  _S1552 = *(&(globalParams_0->state_0)[_S1542]);
    float4  _S1553 = *(&(globalParams_0->scratch_0)[_S1546]);
    float3  tb_3 = float3 {_S1552.x, _S1552.y, _S1552.z} + float3 {_S1553.x, _S1553.y, _S1553.z};
    float4  _S1554 = __ldg(&_S1534->rb_0);
    float3  _S1555 = cross_0(tb_3, float3 {_S1554.x, _S1554.y, _S1554.z});
    float4  _S1556 = __ldg(&_S1534->ra_0);
    float3  _S1557 = to_local_0(_S1531, du_0 + (_S1555 - cross_0(ta_3, float3 {_S1556.x, _S1556.y, _S1556.z})));
    *_S1532 = _S1557;
    float3  _S1558 = to_local_0(_S1531, dth_0);
    *_S1533 = _S1558;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1559 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1560 = slang_ldg_0(&_S1559->law_0);
    JointBond_0 _S1561 = _S1560;
    JointState_0 _S1562 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1563 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1560.ids_0.x], &_S1561, &_S1562, d_lin_4, d_ang_3, 0.0f, false);
    return _S1563;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1564 = make_float3 (0.0f);
    *fi_2 = _S1564;
    *mi_3 = _S1564;
    uint _S1565 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1565;
    for(;;)
    {
        uint _S1566 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1566)
        {
        }
        else
        {
            break;
        }
        uint _S1567 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1567 >> int(1);
        if((_S1567 & 1U) == 0U)
        {
            uint _S1568 = 3U * bond_0;
            float4  _S1569 = *(&(globalParams_0->scratch_0)[_S1568]);
            *fi_2 = *fi_2 + float3 {_S1569.x, _S1569.y, _S1569.z};
            float4  _S1570 = *(&(globalParams_0->scratch_0)[_S1568 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1570.x, _S1570.y, _S1570.z};
        }
        else
        {
            uint _S1571 = 3U * bond_0;
            float4  _S1572 = *(&(globalParams_0->scratch_0)[_S1571]);
            *fi_2 = *fi_2 - float3 {_S1572.x, _S1572.y, _S1572.z};
            float4  _S1573 = *(&(globalParams_0->scratch_0)[_S1571 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1573.x, _S1573.y, _S1573.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1574 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1574;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1575 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1575)
        {
        }
        else
        {
            break;
        }
        uint _S1576 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1577 = 3U * (_S1576 >> int(1));
        float4  _S1578 = *(&(globalParams_0->scratch_0)[_S1577]);
        float3  f_18 = float3 {_S1578.x, _S1578.y, _S1578.z};
        float3  t_15;
        if((_S1576 & 1U) == 0U)
        {
            float4  _S1579 = *(&(globalParams_0->scratch_0)[_S1577 + 1U]);
            t_15 = float3 {_S1579.x, _S1579.y, _S1579.z};
        }
        else
        {
            float4  _S1580 = *(&(globalParams_0->scratch_0)[_S1577 + 2U]);
            t_15 = float3 {_S1580.x, _S1580.y, _S1580.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_15, t_15));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1581 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1581.x;
    uint _S1582;
    if(support_1 == 1U)
    {
        _S1582 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1582 = 7U;
        }
        else
        {
            _S1582 = 0U;
        }
    }
    return _S1582;
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
    uint _S1583 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1584 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1583 + 23U * _S1584 + 2U * i_19;
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
        bool _S1585;
        if(i_20 < 6U)
        {
            _S1585 = spd_0;
        }
        else
        {
            _S1585 = false;
        }
        if(_S1585)
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
            uint _S1586 = i_20 * 6U;
            uint _S1587 = _S1586 + j_6;
            k_19 = 0U;
            sum_4 = (*a_17)[_S1587];
            for(;;)
            {
                if(k_19 < j_6)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1586 + k_19] * l_4[j_6 * 6U + k_19];
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
                l_4[_S1586 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1587] = sum_4 / l_4[j_6 * 6U + j_6];
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
            uint _S1588 = k_19 * 6U + k_19;
            float _S1589 = (*a_17)[_S1588];
            if(((*a_17)[_S1588]) > 0.0f)
            {
                sum_4 = 1.0f / _S1589;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1588] = sum_4;
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
                float s_9 = sum_4;
                for(;;)
                {
                    if(k_19 < i_20)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_10 = s_9 - l_4[i_20 * 6U + k_19] * y_6[k_19];
                    k_19 = k_19 + 1U;
                    s_9 = s_10;
                }
                y_6[i_20] = s_9 / l_4[i_20 * 6U + i_20];
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
                    float s_11 = sum_4 - l_4[k_19 * 6U + i_21] * x_21[k_19];
                    k_19 = k_19 + 1U;
                    sum_4 = s_11;
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
        uint _S1590 = 4U * j_6;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_6)]) = make_float4 (inv_0[_S1590], inv_0[_S1590 + 1U], inv_0[_S1590 + 2U], inv_0[_S1590 + 3U]);
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
    uint _S1591 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1591;
    for(;;)
    {
        uint _S1592 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1592)
        {
        }
        else
        {
            break;
        }
        uint _S1593 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_23 = _S1593 >> int(1);
        bool _S1594 = (_S1593 & 1U) != 0U;
        BondStatic_0 * _S1595 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1596 = statics_bond_slot_0(i_23);
        float4  _S1597 = *(&(globalParams_0->scratch_0)[_S1596]);
        float4  _S1598 = *(&(globalParams_0->scratch_0)[_S1596 + 1U]);
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
            uint _S1599 = p_14 % 3U;
            float3  t_16;
            if(_S1599 == 0U)
            {
                float4  _S1600 = __ldg(&_S1595->t1_0);
                t_16 = float3 {_S1600.x, _S1600.y, _S1600.z};
            }
            else
            {
                if(_S1599 == 1U)
                {
                    float4  _S1601 = __ldg(&_S1595->t2_0);
                    t_16 = float3 {_S1601.x, _S1601.y, _S1601.z};
                }
                else
                {
                    float4  _S1602 = __ldg(&_S1595->normal_0);
                    t_16 = float3 {_S1602.x, _S1602.y, _S1602.z};
                }
            }
            bool _S1603 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1603)
            {
                if(_S1594)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S1594)
                {
                    float4  _S1604 = __ldg(&_S1595->rb_0);
                    row_t_0 = cross_0(float3 {_S1604.x, _S1604.y, _S1604.z}, t_16);
                }
                else
                {
                    float4  _S1605 = __ldg(&_S1595->ra_0);
                    row_t_0 = - cross_0(float3 {_S1605.x, _S1605.y, _S1605.z}, t_16);
                }
            }
            else
            {
                float3  _S1606 = make_float3 (0.0f);
                if(_S1594)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3  _S1607 = row_u_0;
                row_u_0 = _S1606;
                row_t_0 = _S1607;
            }
            float kp_0;
            if(_S1603)
            {
                kp_0 = _slang_vector_get_element(_S1597, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1598, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1608 = { {
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
                    a_18[r_11 * 6U + q_13] = a_18[r_11 * 6U + q_13] + kp_0 * _S1608[r_11] * _S1608[q_13];
                    q_13 = q_13 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1609 = fixed_mask_0(c_33);
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
        if((_S1609 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1610 = a_18;
    store_inverse_0(c_33, &_S1610);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_24, uint j_7)
{
    uint k_21 = i_24 * 6U + j_7;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1611 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1612 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1613 = { {
        (*_S1611).x, (*_S1611).y, (*_S1611).z, (*_S1612).x, (*_S1612).y, (*_S1612).z
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
        float s_12 = 0.0f;
        for(;;)
        {
            if(j_8 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_13 = s_12 + block_get_0(c_35, i_25, j_8) * _S1613[j_8];
            j_8 = j_8 + 1U;
            s_12 = s_13;
        }
        z_1[i_25] = s_12;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_16, Island_0 * isl_20, uint slot_4, uint _S1614)
{
    uint _S1615;
    uint _S1616;
    float3  _S1617 = make_float3 (0.0f);
    float3  p_15 = _S1617;
    float3  l_5 = _S1617;
    uint4  _S1618 = isl_20->range_0;
    uint _S1619 = isl_20->range_0.x + tid_16;
    uint c_36 = _S1619;
    uint _S1620 = _S1614;
    for(;;)
    {
        uint _S1621 = _S1618.y;
        _S1615 = _S1621;
        bool _S1622 = c_36 < _S1621;
        uint _S1623 = __ballot_sync(_S1620, _S1622);
        if(_S1622)
        {
            uint _S1624 = __ballot_sync(_S1620, true);
        }
        else
        {
            uint _S1625 = __ballot_sync(_S1620, false);
            uint _S1626 = __ballot_sync(_S1620, false);
            uint _S1627 = __ballot_sync(_S1614, true);
            _S1616 = _S1627;
            break;
        }
        ChunkStatic_0 * _S1628 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1629 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1629.x, _S1629.y, _S1629.z};
        float4  _S1630 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_4 = float3 {_S1630.x, _S1630.y, _S1630.z};
        float4  _S1631 = __ldg(&_S1628->center_0);
        float4  _S1632 = isl_20->com_0;
        float3  r_12 = float3 {_S1631.x, _S1631.y, _S1631.z} - float3 {_S1632.x, _S1632.y, _S1632.z};
        float _S1633 = _S1631.w;
        p_15 = p_15 + u_3 * make_float3 (_S1633);
        float3  _S1634 = cross_0(r_12, u_3) * make_float3 (_S1633);
        float4  _S1635 = __ldg(&_S1628->inertia0_0);
        float4  _S1636 = __ldg(&_S1628->inertia1_0);
        float4  _S1637 = __ldg(&_S1628->inertia2_0);
        l_5 = l_5 + (_S1634 + rows_mul_0(_S1635, _S1636, _S1637, th_4));
        uint _S1638 = __ballot_sync(_S1620, true);
        c_36 = c_36 + 256U;
        _S1620 = _S1638;
    }
    group_sum3_0(tid_16, &p_15, &l_5, _S1616);
    float4  _S1639 = isl_20->com_0;
    float3  _S1640 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1641 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_5);
    c_36 = _S1619;
    for(;;)
    {
        if(c_36 < _S1615)
        {
        }
        else
        {
            break;
        }
        float4  _S1642 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1643 = sv_0(c_36, slot_4);
        float4  _S1644 = *(&(globalParams_0->scratch_0)[_S1643]);
        *(&(globalParams_0->scratch_0)[_S1643]) = make_float4 ((float3 {_S1644.x, _S1644.y, _S1644.z} - _S1640 - cross_0(_S1641, float3 {_S1642.x, _S1642.y, _S1642.z} - float3 {_S1639.x, _S1639.y, _S1639.z})).x, (float3 {_S1644.x, _S1644.y, _S1644.z} - _S1640 - cross_0(_S1641, float3 {_S1642.x, _S1642.y, _S1642.z} - float3 {_S1639.x, _S1639.y, _S1639.z})).y, (float3 {_S1644.x, _S1644.y, _S1644.z} - _S1640 - cross_0(_S1641, float3 {_S1642.x, _S1642.y, _S1642.z} - float3 {_S1639.x, _S1639.y, _S1639.z})).z, 0.0f);
        uint _S1645 = sv_0(c_36, slot_4 + 1U);
        float4  _S1646 = *(&(globalParams_0->scratch_0)[_S1645]);
        *(&(globalParams_0->scratch_0)[_S1645]) = make_float4 ((float3 {_S1646.x, _S1646.y, _S1646.z} - _S1641).x, (float3 {_S1646.x, _S1646.y, _S1646.z} - _S1641).y, (float3 {_S1646.x, _S1646.y, _S1646.z} - _S1641).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_1)
{
    uint _S1647 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1648 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1649 = _S1647 + 23U * _S1648;
    uint _S1650 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1649 + 2U * _S1650 + island_1;
}

static __device__ void write_bond_loads_0(uint _S1651, uint _S1652, float3  _S1653, float3  _S1654, float _S1655)
{
    BondStatic_0 * _S1656 = (&(globalParams_0->bonds_0)[_S1652]);
    float3  _S1657 = to_body_0(_S1652, _S1653);
    float3  _S1658 = to_body_0(_S1652, _S1654);
    uint _S1659 = 3U * _S1651;
    *(&(globalParams_0->scratch_0)[_S1659]) = make_float4 (_S1657.x, _S1657.y, _S1657.z, _S1655);
    float4  * _S1660 = (&(globalParams_0->scratch_0)[_S1659 + 1U]);
    float4  _S1661 = __ldg(&_S1656->ra_0);
    *_S1660 = make_float4 ((_S1658 + cross_0(float3 {_S1661.x, _S1661.y, _S1661.z}, _S1657)).x, (_S1658 + cross_0(float3 {_S1661.x, _S1661.y, _S1661.z}, _S1657)).y, (_S1658 + cross_0(float3 {_S1661.x, _S1661.y, _S1661.z}, _S1657)).z, 0.0f);
    float4  * _S1662 = (&(globalParams_0->scratch_0)[_S1659 + 2U]);
    float3  _S1663 = - _S1658;
    float4  _S1664 = __ldg(&_S1656->rb_0);
    *_S1662 = make_float4 ((_S1663 + cross_0(float3 {_S1664.x, _S1664.y, _S1664.z}, - _S1657)).x, (_S1663 + cross_0(float3 {_S1664.x, _S1664.y, _S1664.z}, - _S1657)).y, (_S1663 + cross_0(float3 {_S1664.x, _S1664.y, _S1664.z}, - _S1657)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1665, float3  _S1666, float3  _S1667, float3  _S1668, float3  _S1669, float3  * _S1670, float3  * _S1671)
{
    BondStatic_0 * _S1672 = (&(globalParams_0->bonds_0)[_S1665]);
    float4  _S1673 = __ldg(&_S1672->rb_0);
    float3  _S1674 = _S1668 + cross_0(_S1669, float3 {_S1673.x, _S1673.y, _S1673.z});
    float4  _S1675 = __ldg(&_S1672->ra_0);
    float3  _S1676 = to_local_0(_S1665, _S1674 - (_S1666 + cross_0(_S1667, float3 {_S1675.x, _S1675.y, _S1675.z})));
    *_S1670 = _S1676;
    float3  _S1677 = to_local_0(_S1665, _S1669 - _S1667);
    *_S1671 = _S1677;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1678 = 0U;
    uint _S1679;
    uint i_26;
    uint c_37;
    bool converged_0;
    uint _S1680;
    uint _S1681;
    uint _S1682;
    uint _S1683;
    uint _S1684;
    uint _S1685;
    uint i_27;
    uint _S1686;
    uint _S1687;
    uint _S1688;
    uint _S1689;
    uint _S1690;
    uint _S1691 = __ballot_sync(4294967295U, true);
    uint tid_17 = threadIdx.x;
    uint _S1692 = blockIdx.x;
    Island_0 * _S1693 = (&(globalParams_0->islands_0)[_S1692]);
    Island_0 isl_21 = *_S1693;
    uint _S1694 = (*_S1693).info_1.z;
    bool _S1695 = (_S1694 & 8U) == 0U;
    uint _S1696 = __ballot_sync(_S1691, _S1695);
    if(_S1695)
    {
        return;
    }
    else
    {
        uint _S1697 = __ballot_sync(_S1691, true);
        _S1678 = _S1697;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1698 = isl_21.range_0.w;
    uint _S1699 = c0_1 + tid_17;
    uint c_38 = _S1699;
    uint newton_0;
    newton_0 = _S1678;
    for(;;)
    {
        bool _S1700 = c_38 < c1_1;
        uint _S1701 = __ballot_sync(newton_0, _S1700);
        if(_S1700)
        {
            uint _S1702 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1703 = __ballot_sync(newton_0, false);
            uint _S1704 = __ballot_sync(newton_0, false);
            uint _S1705 = __ballot_sync(_S1678, true);
            _S1679 = _S1705;
            break;
        }
        float4  _S1706 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1706;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1706;
        uint _S1707 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1707;
    }
    __syncthreads();
    uint _S1708 = __ballot_sync(_S1679, free_0);
    if(free_0)
    {
        Island_0 _S1709 = isl_21;
        project_load_slot_0(tid_17, &_S1709, 0U, _S1708);
        uint _S1710 = __ballot_sync(_S1679, true);
        c_38 = _S1710;
    }
    else
    {
        uint _S1711 = __ballot_sync(_S1679, true);
        c_38 = _S1711;
    }
    float _S1712 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U, c_38);
    float _S1713 = (F32_max(((F32_sqrt((_S1712)))), (1.00000000317107685e-30f)));
    float _S1714 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1715 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1716 = (U32_min((_S1715), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1717 = 0U;
        uint _S1718 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1719 = newton_0 < _S1718;
        uint _S1720 = __ballot_sync(c_38, _S1719);
        if(_S1719)
        {
            uint _S1721 = __ballot_sync(c_38, true);
            _S1717 = _S1721;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1722 = b0_0 + tid_17;
        i_26 = _S1722;
        uint _S1723;
        _S1723 = _S1717;
        for(;;)
        {
            bool _S1724 = i_26 < _S1698;
            uint _S1725 = __ballot_sync(_S1723, _S1724);
            if(_S1724)
            {
                uint _S1726 = __ballot_sync(_S1723, true);
            }
            else
            {
                uint _S1727 = __ballot_sync(_S1723, false);
                uint _S1728 = __ballot_sync(_S1723, false);
                uint _S1729 = __ballot_sync(_S1717, true);
                _S1680 = _S1729;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1730 = __ballot_sync(_S1723, true);
            i_26 = i_26 + 256U;
            _S1723 = _S1730;
        }
        __syncthreads();
        float4  _S1731 = make_float4 (0.0f);
        float4  magnitude_0 = _S1731;
        float4  unused_m_0 = _S1731;
        uint c_39 = _S1699;
        uint _S1732 = _S1680;
        for(;;)
        {
            bool _S1733 = c_39 < c1_1;
            uint _S1734 = __ballot_sync(_S1732, _S1733);
            if(_S1733)
            {
                uint _S1735 = __ballot_sync(_S1732, true);
            }
            else
            {
                uint _S1736 = __ballot_sync(_S1732, false);
                uint _S1737 = __ballot_sync(_S1732, false);
                uint _S1738 = __ballot_sync(_S1680, true);
                _S1681 = _S1738;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1739 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1739.x, _S1739.y, _S1739.z} + fi_3).x, (float3 {_S1739.x, _S1739.y, _S1739.z} + fi_3).y, (float3 {_S1739.x, _S1739.y, _S1739.z} + fi_3).z, 0.0f);
            float4  _S1740 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1740.x, _S1740.y, _S1740.z} + mi_4).x, (float3 {_S1740.x, _S1740.y, _S1740.z} + mi_4).y, (float3 {_S1740.x, _S1740.y, _S1740.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1731, _S1731);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1741 = __ballot_sync(_S1732, true);
            c_39 = c_39 + 256U;
            _S1732 = _S1741;
        }
        __syncthreads();
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0, _S1681);
        uint _S1742 = __ballot_sync(_S1681, free_0);
        uint _S1743;
        if(free_0)
        {
            Island_0 _S1744 = isl_21;
            project_load_slot_0(tid_17, &_S1744, 4U, _S1742);
            uint _S1745 = __ballot_sync(_S1681, true);
            _S1743 = _S1745;
        }
        else
        {
            uint _S1746 = __ballot_sync(_S1681, true);
            _S1743 = _S1746;
        }
        float _S1747 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, _S1743);
        float residual_1 = (F32_sqrt((_S1747))) / _S1713;
        float _S1748 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1713)));
        bool _S1749 = residual_1 <= _S1714;
        uint _S1750 = __ballot_sync(_S1743, _S1749);
        uint _S1751;
        if(_S1749)
        {
            uint _S1752 = __ballot_sync(_S1743, true);
            converged_0 = true;
            _S1751 = _S1752;
        }
        else
        {
            uint _S1753 = _S1743 & (~_S1750);
            bool _S1754 = residual_1 <= _S1748;
            uint _S1755 = __ballot_sync(_S1753, _S1754);
            if(_S1754)
            {
                bool _S1756 = residual_1 > (0.5f * previous_2);
                uint _S1757 = __ballot_sync(_S1753, true);
                converged_0 = _S1756;
            }
            else
            {
                uint _S1758 = __ballot_sync(_S1753, true);
                converged_0 = false;
            }
            uint _S1759 = __ballot_sync(_S1743, true);
            _S1751 = _S1759;
        }
        uint _S1760 = 0U;
        uint _S1761 = __ballot_sync(_S1751, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1762 = __ballot_sync(_S1751, true);
            _S1760 = _S1762;
        }
        uint i_28 = _S1722;
        uint _S1763;
        _S1763 = _S1760;
        for(;;)
        {
            bool _S1764 = i_28 < _S1698;
            uint _S1765 = __ballot_sync(_S1763, _S1764);
            if(_S1764)
            {
                uint _S1766 = __ballot_sync(_S1763, true);
            }
            else
            {
                uint _S1767 = __ballot_sync(_S1763, false);
                uint _S1768 = __ballot_sync(_S1763, false);
                uint _S1769 = __ballot_sync(_S1760, true);
                _S1682 = _S1769;
                break;
            }
            BondStatic_0 * _S1770 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S1771 = slang_ldg_0(&_S1770->law_0);
            JointBond_0 _S1772 = _S1771;
            JointState_0 _S1773 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1772, &_S1773, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1774 = statics_bond_slot_0(i_28);
            float _S1775 = _S1771.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1774]) = make_float4 (_S1775 * f_lin_2.x, _S1775 * f_lin_2.y, _S1771.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1774 + 1U]) = make_float4 (_S1771.stiff0_0.z * f_ang_2.x, _S1771.stiff0_0.w * f_ang_2.y, _S1771.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1776 = __ballot_sync(_S1763, true);
            i_28 = i_28 + 256U;
            _S1763 = _S1776;
        }
        __syncthreads();
        uint c_40 = _S1699;
        uint _S1777 = _S1682;
        for(;;)
        {
            bool _S1778 = c_40 < c1_1;
            uint _S1779 = __ballot_sync(_S1777, _S1778);
            if(_S1778)
            {
                uint _S1780 = __ballot_sync(_S1777, true);
            }
            else
            {
                uint _S1781 = __ballot_sync(_S1777, false);
                uint _S1782 = __ballot_sync(_S1777, false);
                uint _S1783 = __ballot_sync(_S1682, true);
                _S1683 = _S1783;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1731;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1731;
            uint _S1784 = __ballot_sync(_S1777, true);
            c_40 = c_40 + 256U;
            _S1777 = _S1784;
        }
        __syncthreads();
        uint c_41 = _S1699;
        uint _S1785 = _S1683;
        for(;;)
        {
            bool _S1786 = c_41 < c1_1;
            uint _S1787 = __ballot_sync(_S1785, _S1786);
            if(_S1786)
            {
                uint _S1788 = __ballot_sync(_S1785, true);
            }
            else
            {
                uint _S1789 = __ballot_sync(_S1785, false);
                uint _S1790 = __ballot_sync(_S1785, false);
                uint _S1791 = __ballot_sync(_S1683, true);
                _S1684 = _S1791;
                break;
            }
            precondition_0(c_41);
            uint _S1792 = __ballot_sync(_S1785, true);
            c_41 = c_41 + 256U;
            _S1785 = _S1792;
        }
        __syncthreads();
        uint _S1793 = __ballot_sync(_S1684, free_0);
        uint _S1794;
        if(free_0)
        {
            Island_0 _S1795 = isl_21;
            project_displacement_slot_0(tid_17, &_S1795, 6U, _S1793);
            uint _S1796 = __ballot_sync(_S1684, true);
            _S1794 = _S1796;
        }
        else
        {
            uint _S1797 = __ballot_sync(_S1684, true);
            _S1794 = _S1797;
        }
        uint c_42 = _S1699;
        uint _S1798 = _S1794;
        for(;;)
        {
            bool _S1799 = c_42 < c1_1;
            uint _S1800 = __ballot_sync(_S1798, _S1799);
            if(_S1799)
            {
                uint _S1801 = __ballot_sync(_S1798, true);
            }
            else
            {
                uint _S1802 = __ballot_sync(_S1798, false);
                uint _S1803 = __ballot_sync(_S1798, false);
                uint _S1804 = __ballot_sync(_S1794, true);
                _S1685 = _S1804;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1805 = __ballot_sync(_S1798, true);
            c_42 = c_42 + 256U;
            _S1798 = _S1805;
        }
        __syncthreads();
        float _S1806 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, _S1685);
        float _S1807 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, _S1685);
        float _S1808 = (F32_sqrt((_S1807)));
        float rz_0 = _S1806;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1809 = _S1685;
        for(;;)
        {
            bool _S1810 = k_22 < _S1716;
            uint _S1811 = __ballot_sync(_S1809, _S1810);
            uint _S1812;
            bool _S1813;
            if(_S1810)
            {
                bool _S1814 = _S1808 > 0.0f;
                uint _S1815 = __ballot_sync(_S1809, true);
                _S1813 = _S1814;
                _S1812 = _S1815;
            }
            else
            {
                uint _S1816 = __ballot_sync(_S1809, true);
                _S1813 = false;
                _S1812 = _S1816;
            }
            uint _S1817 = 0U;
            uint _S1818 = __ballot_sync(_S1812, _S1813);
            if(_S1813)
            {
                uint _S1819 = __ballot_sync(_S1812, true);
                _S1817 = _S1819;
            }
            else
            {
                uint _S1820 = __ballot_sync(_S1812, false);
                uint _S1821 = __ballot_sync(_S1809, false);
                uint _S1822 = __ballot_sync(_S1685, true);
                cg_total_0 = cg_total_1;
                i_27 = _S1822;
                break;
            }
            i_27 = _S1722;
            _S1686 = _S1817;
            for(;;)
            {
                bool _S1823 = i_27 < _S1698;
                uint _S1824 = __ballot_sync(_S1686, _S1823);
                if(_S1823)
                {
                    uint _S1825 = __ballot_sync(_S1686, true);
                }
                else
                {
                    uint _S1826 = __ballot_sync(_S1686, false);
                    uint _S1827 = __ballot_sync(_S1686, false);
                    uint _S1828 = __ballot_sync(_S1817, true);
                    _S1687 = _S1828;
                    break;
                }
                JointBond_0 _S1829 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S1829.ids_0.y;
                uint cb_2 = _S1829.ids_0.z;
                float4  _S1830 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1831 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1832 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1833 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S1830.x, _S1830.y, _S1830.z}, float3 {_S1831.x, _S1831.y, _S1831.z}, float3 {_S1832.x, _S1832.y, _S1832.z}, float3 {_S1833.x, _S1833.y, _S1833.z}, &d_lin_6, &d_ang_5);
                uint _S1834 = statics_bond_slot_0(i_27);
                float4  _S1835 = *(&(globalParams_0->scratch_0)[_S1834]);
                float4  _S1836 = *(&(globalParams_0->scratch_0)[_S1834 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S1835.x, _S1835.y, _S1835.z}, d_ang_5 * float3 {_S1836.x, _S1836.y, _S1836.z}, 0.0f);
                uint _S1837 = __ballot_sync(_S1686, true);
                i_27 = i_27 + 256U;
                _S1686 = _S1837;
            }
            __syncthreads();
            c_37 = _S1699;
            uint _S1838 = _S1687;
            for(;;)
            {
                bool _S1839 = c_37 < c1_1;
                uint _S1840 = __ballot_sync(_S1838, _S1839);
                if(_S1839)
                {
                    uint _S1841 = __ballot_sync(_S1838, true);
                }
                else
                {
                    uint _S1842 = __ballot_sync(_S1838, false);
                    uint _S1843 = __ballot_sync(_S1838, false);
                    uint _S1844 = __ballot_sync(_S1687, true);
                    _S1688 = _S1844;
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
                uint _S1845 = __ballot_sync(_S1838, true);
                c_37 = c_37 + 256U;
                _S1838 = _S1845;
            }
            uint _S1846 = 0U;
            __syncthreads();
            float _S1847 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U, _S1688);
            uint _S1848 = cg_total_1 + 1U;
            bool _S1849 = _S1847 <= 0.0f;
            uint _S1850 = __ballot_sync(_S1688, _S1849);
            if(_S1849)
            {
                uint _S1851 = __ballot_sync(_S1688, false);
                uint _S1852 = __ballot_sync(_S1809, false);
                uint _S1853 = __ballot_sync(_S1685, true);
                cg_total_0 = _S1848;
                i_27 = _S1853;
                break;
            }
            else
            {
                uint _S1854 = __ballot_sync(_S1688, true);
                _S1846 = _S1854;
            }
            float _S1855 = rz_0 / _S1847;
            uint c_43 = _S1699;
            uint _S1856;
            _S1856 = _S1846;
            for(;;)
            {
                bool _S1857 = c_43 < c1_1;
                uint _S1858 = __ballot_sync(_S1856, _S1857);
                if(_S1857)
                {
                    uint _S1859 = __ballot_sync(_S1856, true);
                }
                else
                {
                    uint _S1860 = __ballot_sync(_S1856, false);
                    uint _S1861 = __ballot_sync(_S1856, false);
                    uint _S1862 = __ballot_sync(_S1846, true);
                    _S1689 = _S1862;
                    break;
                }
                uint _S1863 = sv_0(c_43, 2U);
                float4  _S1864 = *(&(globalParams_0->scratch_0)[_S1863]);
                float4  _S1865 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1863]) = make_float4 ((float3 {_S1864.x, _S1864.y, _S1864.z} + make_float3 (_S1855) * float3 {_S1865.x, _S1865.y, _S1865.z}).x, (float3 {_S1864.x, _S1864.y, _S1864.z} + make_float3 (_S1855) * float3 {_S1865.x, _S1865.y, _S1865.z}).y, (float3 {_S1864.x, _S1864.y, _S1864.z} + make_float3 (_S1855) * float3 {_S1865.x, _S1865.y, _S1865.z}).z, 0.0f);
                uint _S1866 = sv_0(c_43, 3U);
                float4  _S1867 = *(&(globalParams_0->scratch_0)[_S1866]);
                float4  _S1868 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1866]) = make_float4 ((float3 {_S1867.x, _S1867.y, _S1867.z} + make_float3 (_S1855) * float3 {_S1868.x, _S1868.y, _S1868.z}).x, (float3 {_S1867.x, _S1867.y, _S1867.z} + make_float3 (_S1855) * float3 {_S1868.x, _S1868.y, _S1868.z}).y, (float3 {_S1867.x, _S1867.y, _S1867.z} + make_float3 (_S1855) * float3 {_S1868.x, _S1868.y, _S1868.z}).z, 0.0f);
                uint _S1869 = sv_0(c_43, 4U);
                float4  _S1870 = *(&(globalParams_0->scratch_0)[_S1869]);
                float4  _S1871 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1869]) = make_float4 ((float3 {_S1870.x, _S1870.y, _S1870.z} - make_float3 (_S1855) * float3 {_S1871.x, _S1871.y, _S1871.z}).x, (float3 {_S1870.x, _S1870.y, _S1870.z} - make_float3 (_S1855) * float3 {_S1871.x, _S1871.y, _S1871.z}).y, (float3 {_S1870.x, _S1870.y, _S1870.z} - make_float3 (_S1855) * float3 {_S1871.x, _S1871.y, _S1871.z}).z, 0.0f);
                uint _S1872 = sv_0(c_43, 5U);
                float4  _S1873 = *(&(globalParams_0->scratch_0)[_S1872]);
                float4  _S1874 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1872]) = make_float4 ((float3 {_S1873.x, _S1873.y, _S1873.z} - make_float3 (_S1855) * float3 {_S1874.x, _S1874.y, _S1874.z}).x, (float3 {_S1873.x, _S1873.y, _S1873.z} - make_float3 (_S1855) * float3 {_S1874.x, _S1874.y, _S1874.z}).y, (float3 {_S1873.x, _S1873.y, _S1873.z} - make_float3 (_S1855) * float3 {_S1874.x, _S1874.y, _S1874.z}).z, 0.0f);
                uint _S1875 = __ballot_sync(_S1856, true);
                c_43 = c_43 + 256U;
                _S1856 = _S1875;
            }
            uint _S1876 = 0U;
            __syncthreads();
            float _S1877 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, _S1689);
            bool _S1878 = (F32_sqrt((_S1877))) <= (0.00009999999747379f * _S1808);
            uint _S1879 = __ballot_sync(_S1689, _S1878);
            if(_S1878)
            {
                uint _S1880 = __ballot_sync(_S1689, false);
                uint _S1881 = __ballot_sync(_S1809, false);
                uint _S1882 = __ballot_sync(_S1685, true);
                cg_total_0 = _S1848;
                i_27 = _S1882;
                break;
            }
            else
            {
                uint _S1883 = __ballot_sync(_S1689, true);
                _S1876 = _S1883;
            }
            uint c_44 = _S1699;
            uint _S1884;
            _S1884 = _S1876;
            for(;;)
            {
                bool _S1885 = c_44 < c1_1;
                uint _S1886 = __ballot_sync(_S1884, _S1885);
                if(_S1885)
                {
                    uint _S1887 = __ballot_sync(_S1884, true);
                }
                else
                {
                    uint _S1888 = __ballot_sync(_S1884, false);
                    uint _S1889 = __ballot_sync(_S1884, false);
                    uint _S1890 = __ballot_sync(_S1876, true);
                    _S1690 = _S1890;
                    break;
                }
                precondition_0(c_44);
                uint _S1891 = __ballot_sync(_S1884, true);
                c_44 = c_44 + 256U;
                _S1884 = _S1891;
            }
            __syncthreads();
            uint _S1892 = __ballot_sync(_S1690, free_0);
            uint _S1893;
            if(free_0)
            {
                Island_0 _S1894 = isl_21;
                project_displacement_slot_0(tid_17, &_S1894, 6U, _S1892);
                uint _S1895 = __ballot_sync(_S1690, true);
                _S1893 = _S1895;
            }
            else
            {
                uint _S1896 = __ballot_sync(_S1690, true);
                _S1893 = _S1896;
            }
            float _S1897 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, _S1893);
            float _S1898 = _S1897 / rz_0;
            uint c_45 = _S1699;
            uint _S1899 = _S1893;
            for(;;)
            {
                bool _S1900 = c_45 < c1_1;
                uint _S1901 = __ballot_sync(_S1899, _S1900);
                if(_S1900)
                {
                    uint _S1902 = __ballot_sync(_S1899, true);
                }
                else
                {
                    uint _S1903 = __ballot_sync(_S1899, false);
                    uint _S1904 = __ballot_sync(_S1899, false);
                    uint _S1905 = __ballot_sync(_S1893, true);
                    break;
                }
                uint _S1906 = sv_0(c_45, 8U);
                float4  _S1907 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S1908 = *(&(globalParams_0->scratch_0)[_S1906]);
                *(&(globalParams_0->scratch_0)[_S1906]) = make_float4 ((float3 {_S1907.x, _S1907.y, _S1907.z} + make_float3 (_S1898) * float3 {_S1908.x, _S1908.y, _S1908.z}).x, (float3 {_S1907.x, _S1907.y, _S1907.z} + make_float3 (_S1898) * float3 {_S1908.x, _S1908.y, _S1908.z}).y, (float3 {_S1907.x, _S1907.y, _S1907.z} + make_float3 (_S1898) * float3 {_S1908.x, _S1908.y, _S1908.z}).z, 0.0f);
                uint _S1909 = sv_0(c_45, 9U);
                float4  _S1910 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S1911 = *(&(globalParams_0->scratch_0)[_S1909]);
                *(&(globalParams_0->scratch_0)[_S1909]) = make_float4 ((float3 {_S1910.x, _S1910.y, _S1910.z} + make_float3 (_S1898) * float3 {_S1911.x, _S1911.y, _S1911.z}).x, (float3 {_S1910.x, _S1910.y, _S1910.z} + make_float3 (_S1898) * float3 {_S1911.x, _S1911.y, _S1911.z}).y, (float3 {_S1910.x, _S1910.y, _S1910.z} + make_float3 (_S1898) * float3 {_S1911.x, _S1911.y, _S1911.z}).z, 0.0f);
                uint _S1912 = __ballot_sync(_S1899, true);
                c_45 = c_45 + 256U;
                _S1899 = _S1912;
            }
            __syncthreads();
            uint _S1913 = __ballot_sync(_S1809, true);
            uint _S1914 = k_22 + 1U;
            rz_0 = _S1897;
            k_22 = _S1914;
            cg_total_1 = _S1848;
            _S1809 = _S1913;
        }
        c_37 = _S1699;
        _S1686 = i_27;
        for(;;)
        {
            bool _S1915 = c_37 < c1_1;
            uint _S1916 = __ballot_sync(_S1686, _S1915);
            if(_S1915)
            {
                uint _S1917 = __ballot_sync(_S1686, true);
            }
            else
            {
                uint _S1918 = __ballot_sync(_S1686, false);
                uint _S1919 = __ballot_sync(_S1686, false);
                uint _S1920 = __ballot_sync(i_27, true);
                break;
            }
            uint _S1921 = 4U * c_37;
            float4  _S1922 = *(&(globalParams_0->state_0)[_S1921]);
            float3  u_4 = float3 {_S1922.x, _S1922.y, _S1922.z};
            uint _S1923 = sv_0(c_37, 21U);
            float4  _S1924 = *(&(globalParams_0->scratch_0)[_S1923]);
            float3  u_lo_0 = float3 {_S1924.x, _S1924.y, _S1924.z};
            uint _S1925 = _S1921 + 1U;
            float4  _S1926 = *(&(globalParams_0->state_0)[_S1925]);
            float3  th_5 = float3 {_S1926.x, _S1926.y, _S1926.z};
            uint _S1927 = sv_0(c_37, 22U);
            float4  _S1928 = *(&(globalParams_0->scratch_0)[_S1927]);
            float3  th_lo_0 = float3 {_S1928.x, _S1928.y, _S1928.z};
            float4  _S1929 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S1929.x, _S1929.y, _S1929.z});
            float4  _S1930 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_5, &th_lo_0, float3 {_S1930.x, _S1930.y, _S1930.z});
            *(&(globalParams_0->state_0)[_S1921]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S1921])).w);
            *(&(globalParams_0->state_0)[_S1925]) = make_float4 (th_5.x, th_5.y, th_5.z, (*(&(globalParams_0->state_0)[_S1925])).w);
            *(&(globalParams_0->scratch_0)[_S1923]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1927]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1931 = __ballot_sync(_S1686, true);
            c_37 = c_37 + 256U;
            _S1686 = _S1931;
        }
        __syncthreads();
        uint _S1932 = newton_0 + 1U;
        uint _S1933 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1932;
        c_38 = _S1933;
    }
    i_26 = b0_0 + tid_17;
    for(;;)
    {
        if(i_26 < _S1698)
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
    c_37 = _S1699;
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
            float4  _S1934 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S1934.x, _S1934.y, _S1934.z} + fi_5);
        }
        else
        {
            uint _S1935 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S1935 + 1U])).w, (*(&(globalParams_0->state_0)[_S1935 + 2U])).w, (*(&(globalParams_0->state_0)[_S1935 + 3U])).w);
        }
        uint _S1936 = 4U * c_37;
        uint _S1937 = _S1936 + 1U;
        float4  _S1938 = *(&(globalParams_0->state_0)[_S1937]);
        *(&(globalParams_0->state_0)[_S1937]) = make_float4 (float3 {_S1938.x, _S1938.y, _S1938.z}.x, float3 {_S1938.x, _S1938.y, _S1938.z}.y, float3 {_S1938.x, _S1938.y, _S1938.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S1936 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S1936 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_17 == 0U)
    {
        float4  * _S1939 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1692)]);
        float _S1940 = (U32_asfloat((newton_0)));
        float _S1941 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1939 = make_float4 (residual_0, _S1940, _S1941, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1692])->info_1)->z) = _S1694 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_18 = threadIdx.x;
    uint _S1942 = blockIdx.x;
    Island_0 * _S1943 = (&(globalParams_0->islands_0)[_S1942]);
    Island_0 isl_22 = *_S1943;
    bool _S1944;
    if((((*_S1943).info_1.x) & 16U) == 0U)
    {
        _S1944 = true;
    }
    else
    {
        _S1944 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S1944)
    {
        return;
    }
    bool _S1945 = tid_18 == 0U;
    if(_S1945)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1946 = isl_22.info_1.w;
    uint i_29 = isl_22.range_0.z + tid_18;
    for(;;)
    {
        if(i_29 < (isl_22.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1947 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S1948 = slang_ldg_0(&_S1947->law_0);
        uint _S1949 = 4U * _S1948.ids_0.y;
        float4  _S1950 = *(&(globalParams_0->state_0)[_S1949]);
        float4  _S1951 = *(&(globalParams_0->state_0)[_S1949 + 1U]);
        uint _S1952 = 4U * _S1948.ids_0.z;
        float4  _S1953 = *(&(globalParams_0->state_0)[_S1952]);
        float4  _S1954 = *(&(globalParams_0->state_0)[_S1952 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S1950.x, _S1950.y, _S1950.z}, float3 {_S1951.x, _S1951.y, _S1951.z}, float3 {_S1953.x, _S1953.y, _S1953.z}, float3 {_S1954.x, _S1954.y, _S1954.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1955 = d_lin_7;
        float3  _S1956 = d_ang_6;
        float _S1957 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1958 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1959 = _S1958 != 0U;
        JointBond_0 _S1960 = _S1948;
        JointState_0 _S1961 = previous_3;
        JointResponse_0 _S1962 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1948.ids_0.x], &_S1960, &_S1961, _S1955, _S1956, _S1957, _S1959);
        if((_S1962.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1944 = true;
        }
        else
        {
            _S1944 = (_S1962.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_2;
        if(_S1944)
        {
            flags_2 = 16U;
        }
        else
        {
            flags_2 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1962.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1962.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1962.force_lin_1.x, _S1962.force_lin_1.y, _S1962.force_lin_1.z, _S1962.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S1962.force_ang_1.x, _S1962.force_ang_1.y, _S1962.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1962.state_1.utilization_0))));
        JointState_0 _S1963 = previous_3;
        bool _S1964 = is_damaged_0(&_S1963);
        bool _S1965;
        if(!_S1964)
        {
            JointState_0 _S1966 = _S1962.state_1;
            bool _S1967 = is_damaged_0(&_S1966);
            _S1965 = _S1967;
        }
        else
        {
            _S1965 = false;
        }
        bool _S1968;
        if(_S1965)
        {
            _S1968 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1968 = false;
        }
        if(_S1968)
        {
            *&((&(&bd_2)->events_0)->x) = _S1946;
            *&((&(&bd_2)->events_0)->w) = _S1962.state_1.mode_0;
        }
        bool _S1969;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1970 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1948.ids_0.x], previous_3.life_0);
            _S1969 = _S1970 > 0.99000000953674316f;
        }
        else
        {
            _S1969 = false;
        }
        bool _S1971;
        if(_S1969)
        {
            float _S1972 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1948.ids_0.x], _S1962.state_1.life_0);
            _S1971 = _S1972 <= 0.99000000953674316f;
        }
        else
        {
            _S1971 = false;
        }
        if(_S1971)
        {
            *&((&(&bd_2)->events_0)->y) = _S1946;
        }
        uint flags_3;
        if(_S1962.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1946;
            flags_3 = flags_2 | 32U;
        }
        else
        {
            flags_3 = flags_2;
        }
        (&bd_2)->js_0 = _S1962.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S1962.force_lin_1, _S1962.force_ang_1, (F32_max((_S1962.measures_0.tension_0), (_S1962.measures_0.compression_0))));
        if((flags_3 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_3 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_29 = i_29 + 256U;
    }
    __syncthreads();
    if(_S1945)
    {
        _S1944 = ((*&g_halt_0) | (*&g_run_0)) != 0U;
    }
    else
    {
        _S1944 = false;
    }
    if(_S1944)
    {
        uint _S1973 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S1974 = _S1973 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1942])->info_1)->z) = _S1974 | i_29;
    }
    return;
}

