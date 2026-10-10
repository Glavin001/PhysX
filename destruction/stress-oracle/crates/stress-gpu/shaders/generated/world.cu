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
    float4  unused_0;
    float4  ledger_0;
    uint4  cand_0;
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

static __device__ float dot_0(float3  x_4, float3  y_2)
{
    return x_4.x * y_2.x + x_4.y * y_2.y + x_4.z * y_2.z;
}

static __device__ float3  abs_0(float3  x_5)
{
    float3  result_2;
    int i_2 = int(0);
    for(;;)
    {
        if(i_2 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_abs((_slang_vector_get_element(x_5, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float3  min_0(float3  x_6, float3  y_3)
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
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_min((_slang_vector_get_element(x_6, i_3)), (_slang_vector_get_element(y_3, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_3;
}

static __device__ float3  clamp_1(float3  x_7, float3  minBound_1, float3  maxBound_1)
{
    return min_0(max_0(x_7, minBound_1), maxBound_1);
}

static __device__ bool any_0(bool3  x_8)
{
    bool result_4 = false;
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
        if(result_4)
        {
            result_4 = true;
        }
        else
        {
            result_4 = (bool((_slang_vector_get_element(x_8, i_4))));
        }
        i_4 = i_4 + int(1);
    }
    return result_4;
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

static __device__ float length_0(float3  x_9)
{
    return (F32_sqrt((dot_0(x_9, x_9))));
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
    float x_10;
    float y_4;
    float z_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_10 = q_0.x;
    (&r_0)->y_4 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_10, q_1->y_4, q_1->z_0);
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
    (&q_3)->x_10 = a_3.x * s_0;
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
    uint i_5 = 0U;
    for(;;)
    {
        if(i_5 < 15U)
        {
        }
        else
        {
            break;
        }
        float3  l_0;
        if(i_5 < 6U)
        {
            l_0 = _S71[i_5];
        }
        else
        {
            uint _S72 = i_5 - 6U;
            l_0 = cross_0(_S71[_S72 / 3U], _S71[3U + _S72 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_5 = i_5 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S61, l_0)))) > (_S62.x * (F32_abs((dot_0(_S65, l_0)))) + _S62.y * (F32_abs((dot_0(_S66, l_0)))) + _S62.z * (F32_abs((dot_0(_S67, l_0)))) + (_S63.x * (F32_abs((dot_0(_S68, l_0)))) + _S63.y * (F32_abs((dot_0(_S69, l_0)))) + _S63.z * (F32_abs((dot_0(_S70, l_0))))) + _S64 * len_0))
        {
            return false;
        }
        i_5 = i_5 + 1U;
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

static __device__ float3  sample_point_0(Box_0 * b_8, uint i_6)
{
    uint _S98 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_6 < _S98)
        {
            float4  _S99 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + i_6]));
            local_1 = float3 {_S99.x, _S99.y, _S99.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S100 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + _S98 + b_8->hull_f_0 + (i_6 - _S98)]));
            local_1 = float3 {_S100.x, _S100.y, _S100.z};
        }
        float3  _S101 = b_8->center_1;
        float3  _S102 = box_to_world_0(b_8, local_1);
        return _S101 + _S102;
    }
    float sign_0;
    if(i_6 < 8U)
    {
        float3  h_0 = b_8->half_2 * make_float3 (0.89999997615814209f);
        if((i_6 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S103;
        if((i_6 & 2U) == 0U)
        {
            _S103 = - h_0.y;
        }
        else
        {
            _S103 = h_0.y;
        }
        float _S104;
        if((i_6 & 4U) == 0U)
        {
            _S104 = - h_0.z;
        }
        else
        {
            _S104 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * make_float3 (sign_0) + b_8->axis1_0 * make_float3 (_S103) + b_8->axis2_0 * make_float3 (_S104);
    }
    uint _S105 = i_6 - 8U;
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

static __device__ bool is_nan_0(float x_11)
{
    return ((F32_asuint((x_11))) & 2147483647U) > 2139095040U;
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

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_12)
{
    float t_1 = *sum_0 + x_12;
    if((F32_abs((*sum_0))) >= (F32_abs((x_12))))
    {
        *err_0 = *err_0 + (*sum_0 - t_1 + x_12);
    }
    else
    {
        *err_0 = *err_0 + (x_12 - t_1 + *sum_0);
    }
    *sum_0 = t_1;
    return;
}

static __device__ void pair_contact_0(uint i_7)
{
    uint _S133 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S133 + 6U * i_7;
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
    float4  * _S152 = (&(globalParams_0->scratch_0)[_S151 + i_7]);
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
            *(&(globalParams_0->scratch_0)[_S159 + i_7]) = ledger_1;
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
    *(&(globalParams_0->scratch_0)[_S185 + i_7]) = ledger_1;
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
    uint i_8 = (blockIdx * blockDim + threadIdx).x;
    if(stopped_0())
    {
        return;
    }
    uint _S324 = __ldg(&globalParams_0->params_0->pair_count_0);
    if(i_8 < _S324)
    {
        pair_contact_0(i_8);
    }
    else
    {
        uint _S325 = __ldg(&globalParams_0->params_0->pair_count_0);
        uint _S326 = __ldg(&globalParams_0->params_0->cand_count_0);
        if(i_8 < (_S325 + _S326))
        {
            uint _S327 = __ldg(&globalParams_0->params_0->pair_count_0);
            impactor_candidate_forces_0(i_8 - _S327);
        }
        else
        {
            uint _S328 = __ldg(&globalParams_0->params_0->pair_count_0);
            uint _S329 = __ldg(&globalParams_0->params_0->cand_count_0);
            uint _S330 = _S328 + _S329;
            uint _S331 = __ldg(&globalParams_0->params_0->chunk_count_0);
            if(i_8 < (_S330 + _S331))
            {
                uint _S332 = __ldg(&globalParams_0->params_0->pair_count_0);
                uint _S333 = i_8 - _S332;
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
    float4  unused_1 = _S386;
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
    group_sum2_0(tid_2, &shares_0, &unused_1, _S374);
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

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_13)
{
    float3  t_2 = *sum_1 + x_13;
    float3  _S398 = abs_0(x_13);
    *err_1 = *err_1 + (_slang_select((abs_0(*sum_1)) >= _S398, *sum_1,x_13) - t_2 + _slang_select((abs_0(*sum_1)) >= _S398, x_13,*sum_1));
    *sum_1 = t_2;
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_4)
{
    Quat_0 c_5;
    (&c_5)->w_1 = q_9->w_1;
    (&c_5)->x_10 = - q_9->x_10;
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

static __device__ Quat_0 quat_mul_0(Quat_0 * a_6, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_10 * o_0->x_10 - a_6->y_4 * o_0->y_4 - a_6->z_0 * o_0->z_0;
    (&r_4)->x_10 = a_6->w_1 * o_0->x_10 + a_6->x_10 * o_0->w_1 + a_6->y_4 * o_0->z_0 - a_6->z_0 * o_0->y_4;
    (&r_4)->y_4 = a_6->w_1 * o_0->y_4 - a_6->x_10 * o_0->z_0 + a_6->y_4 * o_0->w_1 + a_6->z_0 * o_0->x_10;
    (&r_4)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_10 * o_0->y_4 - a_6->y_4 * o_0->x_10 + a_6->z_0 * o_0->w_1;
    return r_4;
}

static __device__ Quat_0 normalized_0(Quat_0 * q_11)
{
    float n_7 = (F32_sqrt((q_11->w_1 * q_11->w_1 + q_11->x_10 * q_11->x_10 + q_11->y_4 * q_11->y_4 + q_11->z_0 * q_11->z_0)));
    Quat_0 r_5;
    (&r_5)->w_1 = q_11->w_1 / n_7;
    (&r_5)->x_10 = q_11->x_10 / n_7;
    (&r_5)->y_4 = q_11->y_4 / n_7;
    (&r_5)->z_0 = q_11->z_0 / n_7;
    return r_5;
}

static __device__ Quat_0 integrate_rotation_0(Quat_0 * q_12, float3  omega_0, float dt_2)
{
    float angle_1 = length_0(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return *q_12;
    }
    Quat_0 _S403 = from_axis_angle_0(omega_0, angle_1);
    Quat_0 _S404 = quat_mul_0(&_S403, q_12);
    Quat_0 _S405 = _S404;
    Quat_0 _S406 = normalized_0(&_S405);
    return _S406;
}

static __device__ float4  quat_vec_0(Quat_0 * q_13)
{
    return make_float4 (q_13->x_10, q_13->y_4, q_13->z_0, q_13->w_1);
}

extern "C" __global__ void impactor_integrate()
{
    uint _S407 = 0U;
    uint _S408;
    float3  p_8;
    uint _S409 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S410 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S411 = ii_1 >= _S410;
    uint _S412 = __ballot_sync(_S409, _S411);
    if(_S411)
    {
        return;
    }
    else
    {
        uint _S413 = __ballot_sync(_S409, true);
        _S407 = _S413;
    }
    uint _S414 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S415 = (&(globalParams_0->islands_0)[_S414]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    bool _S416 = ((&imp_6)->cand_0.z) != 0U;
    uint _S417 = __ballot_sync(_S407, _S416);
    bool _S418;
    uint k_8;
    if(_S416)
    {
        uint _S419 = __ballot_sync(_S407, true);
        _S418 = true;
        k_8 = _S419;
    }
    else
    {
        bool _S420 = ((_S415->info_1.z) & 1U) != 0U;
        uint _S421 = __ballot_sync(_S407, true);
        _S418 = _S420;
        k_8 = _S421;
    }
    uint _S422 = __ballot_sync(k_8, _S418);
    if(_S418)
    {
        uint _S423 = __ballot_sync(k_8, true);
        _S418 = true;
        k_8 = _S423;
    }
    else
    {
        uint _S424 = k_8 & (~_S422);
        uint _S425 = _S415->info_1.y;
        bool _S426 = _S425 != 0U;
        uint _S427 = __ballot_sync(_S424, _S426);
        if(_S426)
        {
            bool _S428 = ((&imp_6)->cand_0.w) >= _S425;
            uint _S429 = __ballot_sync(_S424, true);
            _S418 = _S428;
        }
        else
        {
            uint _S430 = __ballot_sync(_S424, true);
            _S418 = false;
        }
        uint _S431 = __ballot_sync(k_8, true);
        k_8 = _S431;
    }
    uint _S432 = 0U;
    uint _S433 = __ballot_sync(k_8, _S418);
    if(_S418)
    {
        return;
    }
    else
    {
        uint _S434 = __ballot_sync(k_8, true);
        _S432 = _S434;
    }
    float4  _S435 = make_float4 (0.0f);
    float4  rf_0 = _S435;
    float4  rt_0 = _S435;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S432;
    for(;;)
    {
        bool _S436 = k_8 < ((&imp_6)->cand_0.y);
        uint _S437 = __ballot_sync(total_points_0, _S436);
        if(_S436)
        {
            uint _S438 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S439 = __ballot_sync(total_points_0, false);
            uint _S440 = __ballot_sync(total_points_0, false);
            uint _S441 = __ballot_sync(_S432, true);
            _S408 = _S441;
            break;
        }
        uint _S442 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S443 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S442 + _S443 + 1U]);
        uint _S444 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S444 + _S443 + 2U]);
        uint _S445 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S445;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S408);
    bool _S446 = tid_3 != 0U;
    uint _S447 = __ballot_sync(_S408, _S446);
    if(_S446)
    {
        return;
    }
    float _S448 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S449 = make_float3 (0.0f);
    uint _S450 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S450 != 0U)
    {
        float4  _S451 = (&imp_6)->half_1;
        float3  _S452 = float3 {_S451.x, _S451.y, _S451.z};
        Impactor_0 _S453 = imp_6;
        Box_0 _S454 = impactor_box_0(&_S453, _S449, _S452);
        float4  _S455 = (&imp_6)->velocity_1;
        float4  _S456 = (&imp_6)->velocity_err_1;
        float3  _S457 = float3 {_S455.x, _S455.y, _S455.z} + float3 {_S456.x, _S456.y, _S456.z};
        float _S458 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S459 = (&imp_6)->mat_0.x;
        float3  _S460 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S461 = _S454;
        Box_0 _S462 = _S454;
        float _S463 = contact_stiffness_0(_S458, &_S461, _S459, &_S462, _S460);
        float _S464 = (&imp_6)->position_1.z;
        float _S465 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S466 = _S464 - _S465;
        float _S467 = (&imp_6)->position_err_1.z;
        float _S468 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S469 = _S466 + (_S467 - _S468);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S470 = _S463 / float((U32_min((total_points_0), (5U))));
        uint s_1 = 0U;
        uint below_0 = 0U;
        for(;;)
        {
            if(s_1 < total_points_0)
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
                Box_0 _S471 = _S454;
                float3  _S472 = sample_point_0(&_S471, s_1);
                p_8 = _S472;
            }
            if((_S469 + p_8.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_1 = s_1 + 1U;
        }
        s_1 = 0U;
        load_f_0 = _S449;
        load_t_0 = _S449;
        for(;;)
        {
            if(s_1 < total_points_0)
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
                Box_0 _S473 = _S454;
                float3  _S474 = sample_point_0(&_S473, s_1);
                p_8 = _S474;
            }
            float depth_3 = - (_S469 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_1 = s_1 + 1U;
                continue;
            }
            float4  _S475 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S457 + cross_0(float3 {_S475.x, _S475.y, _S475.z}, p_8);
            float _S476 = (&imp_6)->mat_0.z;
            float _S477 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S470, _S476, _S477, depth_3, _S460, v_7, _S448, below_0, &stored_3, &diss_2);
            float3  load_f_1 = load_f_0 + f_3;
            float3  load_t_1 = load_t_0 + cross_0(p_8, f_3);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_2);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_1 = s_1 + 1U;
        }
    }
    else
    {
        load_f_0 = _S449;
        load_t_0 = _S449;
    }
    float4  _S478 = rf_0;
    float3  load_f_2 = float3 {_S478.x, _S478.y, _S478.z} + load_f_0;
    float4  _S479 = rt_0;
    float3  load_t_2 = float3 {_S479.x, _S479.y, _S479.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S480 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S480.x, _S480.y, _S480.z};
    float4  _S481 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S481.x, _S481.y, _S481.z};
    float3  _S482 = load_f_2 / make_float3 (m_2);
    float4  _S483 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S482 + float3 {_S483.x, _S483.y, _S483.z}) * make_float3 (_S448));
    Quat_0 q_14 = quat_of_0((&imp_6)->rotation_1);
    float4  _S484 = (&imp_6)->angular_velocity_1;
    float3  _S485 = float3 {_S484.x, _S484.y, _S484.z};
    Quat_0 _S486 = q_14;
    float3  _S487 = world_mul_0(&_S486, (&imp_6)->inertia0_2, (&imp_6)->inertia1_2, (&imp_6)->inertia2_2, _S485);
    float3  l_1 = _S487 + load_t_2 * make_float3 (_S448);
    Quat_0 _S488 = q_14;
    float3  _S489 = world_mul_0(&_S488, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S490 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S490.x, _S490.y, _S490.z};
    float4  _S491 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S491.x, _S491.y, _S491.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S448));
    Quat_0 _S492 = q_14;
    Quat_0 _S493 = integrate_rotation_0(&_S492, _S489, _S448);
    Quat_0 _S494 = _S493;
    float3  _S495 = world_mul_0(&_S494, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S495.x, _S495.y, _S495.z, 0.0f);
    Quat_0 _S496 = _S493;
    float4  _S497 = quat_vec_0(&_S496);
    (&imp_6)->rotation_1 = _S497;
    (&imp_6)->position_1 = make_float4 (pos_0.x, pos_0.y, pos_0.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_0.x, pos_err_0.y, pos_err_0.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_0.x, vel_0.y, vel_0.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_0.x, vel_err_0.y, vel_err_0.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_1]) = imp_6;
    uint _S498 = (&imp_6)->cand_0.w - 1U;
    uint _S499 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S498 - _S499;
    uint _S500 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S500)
    {
        uint _S501 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S502 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S501 + 2U * (ii_1 * _S502 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_3)
{
    ChunkStatic_0 * _S503 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S504 = wp_1.hi_0.z;
    float _S505 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S506 = _S504 - _S505;
    float _S507 = wp_1.lo_0.z;
    float _S508 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S506 + (_S507 - _S508) + wp_1.rel_0.z;
    float4  _S509 = __ldg(&_S503->half_0);
    if((above_0 - _S509.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S510 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S511 = __ldg(&_S503->cmat_0);
    float _S512 = _S511.x;
    float3  _S513 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S514 = b_21;
    Box_0 _S515 = b_21;
    float _S516 = contact_stiffness_0(_S510, &_S514, _S512, &_S515, _S513);
    Box_0 _S517 = b_21;
    uint _S518 = sample_count_0(&_S517);
    uint s_2 = 0U;
    uint n_8 = 0U;
    for(;;)
    {
        if(s_2 < _S518)
        {
        }
        else
        {
            break;
        }
        Box_0 _S519 = b_21;
        float3  _S520 = sample_point_0(&_S519, s_2);
        if((above_0 + _S520.z) < 0.0f)
        {
            n_8 = n_8 + 1U;
        }
        s_2 = s_2 + 1U;
    }
    if(n_8 == 0U)
    {
        return;
    }
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_6, &vc_1, &wc_1);
    uint _S521 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S522 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S521 + _S522 + c_6]);
    s_2 = 0U;
    for(;;)
    {
        if(s_2 < _S518)
        {
        }
        else
        {
            break;
        }
        Box_0 _S523 = b_21;
        float3  _S524 = sample_point_0(&_S523, s_2);
        float _S525 = above_0 + _S524.z;
        if(!(_S525 < 0.0f))
        {
            s_2 = s_2 + 1U;
            continue;
        }
        float depth_4 = - _S525;
        float3  v_8 = vc_1 + cross_0(wc_1, _S524);
        float _S526 = _S516 / float((U32_max((n_8), (5U))));
        float4  _S527 = __ldg(&_S503->center_0);
        float _S528 = _S527.w;
        float _S529 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S530 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S526, _S528, _S529, depth_4, _S513, v_8, _S530, n_8, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_3 = *t_3 + cross_0(_S524, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_2 = s_2 + 1U;
    }
    if(account_0)
    {
        uint _S531 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S532 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S531 + _S532 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S533 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S534;
    if(g_1 >= _S533)
    {
        _S534 = true;
    }
    else
    {
        _S534 = stopped_0();
    }
    if(_S534)
    {
        return;
    }
    uint _S535 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S536 = 3U * g_1;
    uint _S537 = __ldg((&(globalParams_0->index_0)[_S535 + _S536]));
    uint _S538 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S539 = __ldg((&(globalParams_0->index_0)[_S538 + _S536 + 1U]));
    uint _S540 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S541 = __ldg((&(globalParams_0->index_0)[_S540 + _S536 + 2U]));
    float3  _S542 = make_float3 (0.0f);
    float3  f_5 = _S542;
    float3  t_4 = _S542;
    uint e_2 = _S539;
    for(;;)
    {
        if(e_2 < _S541)
        {
        }
        else
        {
            break;
        }
        uint _S543 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S543 == 2147483648U)
        {
            ground_contact_0(_S537, true, &f_5, &t_4);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S544 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S545 = 2U * _S543;
        float4  _S546 = *(&(globalParams_0->scratch_0)[_S544 + _S545]);
        f_5 = f_5 + float3 {_S546.x, _S546.y, _S546.z};
        uint _S547 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S548 = *(&(globalParams_0->scratch_0)[_S547 + _S545 + 1U]);
        t_4 = t_4 + float3 {_S548.x, _S548.y, _S548.z};
        e_2 = e_2 + 1U;
    }
    uint _S549 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S550 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S549 + _S550]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S551 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S551 + _S550 + 1U]) = make_float4 (t_4.x, t_4.y, t_4.z, 0.0f);
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S552 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S553 = (&(globalParams_0->islands_0)[_S552])->info_1;
    bool _S554;
    if((((&(globalParams_0->islands_0)[_S552])->info_1.z) & 1U) != 0U)
    {
        _S554 = true;
    }
    else
    {
        uint _S555 = _S553.y;
        if(_S555 != 0U)
        {
            _S554 = _S555 <= (isl_0->info_1.w);
        }
        else
        {
            _S554 = false;
        }
    }
    return _S554;
}

__device__ __shared__ uint g_run_0;

__device__ __shared__ uint g_halt_0;

struct Rigid_0
{
    Quat_0 rot_0;
    float3  pos_1;
    float3  pos_err_1;
    float3  vel_1;
    float3  vel_err_1;
    float3  w_4;
    float3  a_7;
    float3  alpha_0;
};

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_1)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(isl_1->rotation_0);
    float4  _S556 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S556.x, _S556.y, _S556.z};
    float4  _S557 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S557.x, _S557.y, _S557.z};
    float4  _S558 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S558.x, _S558.y, _S558.z};
    float4  _S559 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S559.x, _S559.y, _S559.z};
    float4  _S560 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S560.x, _S560.y, _S560.z};
    float3  _S561 = make_float3 (0.0f);
    (&rg_0)->a_7 = _S561;
    (&rg_0)->alpha_0 = _S561;
    return rg_0;
}

static __device__ void write_probe_0(uint slot_0, uint k_10, float value_0)
{
    uint _S562 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S563 = _S562 * 4U;
    uint _S564 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S563 + slot_0 * _S564 + k_10;
    float4  v_9 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_9, at_4 % 4U) = value_0;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_9;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_2, Rigid_0 * rg_1, uint k_11)
{
    uint4  _S565 = isl_2->probes_0;
    uint at_5 = isl_2->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S565.y))
        {
        }
        else
        {
            break;
        }
        float4  _S566 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_2 = asuint_0(_S566);
        float4  _S567 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S568 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S569 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_0 = info_2.x;
        uint i_9 = info_2.y;
        float value_1;
        if(kind_0 == 0U)
        {
            float3  _S570 = rg_1->pos_1 - float3 {_S568.x, _S568.y, _S568.z} + (rg_1->pos_err_1 - float3 {_S569.x, _S569.y, _S569.z});
            float4  _S571 = __ldg(&(&(globalParams_0->chunks_0)[i_9])->center_0);
            float4  _S572 = *(&(globalParams_0->state_0)[4U * i_9]);
            float3  _S573 = rotate_0(&rg_1->rot_0, float3 {_S571.x, _S571.y, _S571.z} + float3 {_S572.x, _S572.y, _S572.z});
            value_1 = dot_0(_S570 + _S573, float3 {_S567.x, _S567.y, _S567.z});
        }
        else
        {
            if(kind_0 == 1U)
            {
                float4  _S574 = __ldg(&(&(globalParams_0->chunks_0)[i_9])->center_0);
                uint _S575 = 4U * i_9;
                float4  _S576 = *(&(globalParams_0->state_0)[_S575]);
                float4  _S577 = isl_2->com_0;
                float3  _S578 = rotate_0(&rg_1->rot_0, float3 {_S574.x, _S574.y, _S574.z} + float3 {_S576.x, _S576.y, _S576.z} - float3 {_S577.x, _S577.y, _S577.z});
                float3  _S579 = rg_1->vel_1 + rg_1->vel_err_1 + cross_0(rg_1->w_4, _S578);
                float4  _S580 = *(&(globalParams_0->state_0)[_S575 + 2U]);
                float3  _S581 = rotate_0(&rg_1->rot_0, float3 {_S580.x, _S580.y, _S580.z});
                value_1 = dot_0(_S579 + _S581, float3 {_S567.x, _S567.y, _S567.z});
            }
            else
            {
                if(kind_0 == 2U)
                {
                    uint _S582 = 3U * i_9;
                    float4  _S583 = *(&(globalParams_0->scratch_0)[_S582]);
                    float3  f_6 = float3 {_S583.x, _S583.y, _S583.z};
                    bool _S584 = (info_2.z) == 0U;
                    float3  mc_0;
                    if(_S584)
                    {
                        float4  _S585 = *(&(globalParams_0->scratch_0)[_S582 + 1U]);
                        mc_0 = float3 {_S585.x, _S585.y, _S585.z};
                    }
                    else
                    {
                        float4  _S586 = *(&(globalParams_0->scratch_0)[_S582 + 2U]);
                        mc_0 = float3 {_S586.x, _S586.y, _S586.z};
                    }
                    float3  fc_0;
                    if(_S584)
                    {
                        fc_0 = f_6;
                    }
                    else
                    {
                        fc_0 = - f_6;
                    }
                    value_1 = dot_0(fc_0, float3 {_S567.x, _S567.y, _S567.z}) + dot_0(mc_0, float3 {_S568.x, _S568.y, _S568.z});
                }
                else
                {
                    uint _S587 = 4U * i_9;
                    float3  _S588 = rotate_0(&rg_1->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S587 + 1U])).w, (*(&(globalParams_0->state_0)[_S587 + 2U])).w, (*(&(globalParams_0->state_0)[_S587 + 3U])).w));
                    value_1 = dot_0(_S588, float3 {_S567.x, _S567.y, _S567.z});
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
    float _S589 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S590 = _S589 - origin_0.x;
    float _S591 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S590 + (_S591 - origin_0.y) + float(k_12) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S592 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S592.x))
    {
        return _S592.y;
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
        uint _S593 = offset_0 + i_10;
        float4  _S594 = __ldg((&(globalParams_0->loads_0)[_S593]));
        float _S595 = _S594.x;
        if(tau_0 <= _S595)
        {
            float4  _S596 = __ldg((&(globalParams_0->loads_0)[_S593 - 1U]));
            float _S597 = _S596.x;
            float _S598 = _S596.y;
            return _S598 + (tau_0 - _S597) / (F32_max((_S595 - _S597), (1.00000000317107685e-30f))) * (_S594.y - _S598);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S599 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S599.y;
}

static __device__ float eval_function_0(uint term_0, uint k_13, float dt_4, float shift_0)
{
    uint _S600 = 5U * term_0;
    float4  _S601 = __ldg((&(globalParams_0->loads_0)[_S600]));
    uint4  info_3 = asuint_0(_S601);
    float4  _S602 = __ldg((&(globalParams_0->loads_0)[_S600 + 3U]));
    float4  _S603 = __ldg((&(globalParams_0->loads_0)[_S600 + 4U]));
    uint kind_1 = info_3.z;
    if(kind_1 == 0U)
    {
        return _S602.z;
    }
    float tau_1 = time_since_0(_S602, k_13, dt_4) + shift_0;
    float shape_1;
    if(kind_1 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S604 = _S603.x;
            if(tau_1 >= _S604)
            {
                shape_1 = _S603.y;
            }
            else
            {
                shape_1 = _S603.y * tau_1 / _S604;
            }
        }
        return shape_1;
    }
    bool _S605;
    if(kind_1 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S605 = true;
        }
        else
        {
            _S605 = tau_1 > (_S603.x);
        }
        if(_S605)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S603.y * (F32_sin((3.14159274101257324f * tau_1 / _S603.x)));
        }
        return shape_1;
    }
    if(kind_1 == 3U)
    {
        float sn_0 = tau_1 / _S603.y;
        if(sn_0 < 0.0f)
        {
            _S605 = true;
        }
        else
        {
            _S605 = sn_0 > 1.0f;
        }
        if(_S605)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S603.x * (1.0f - sn_0) * (F32_exp((- _S603.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_1 == 4U)
    {
        return table_eval_0(info_3.w, (F32_asuint((_S603.x))), tau_1);
    }
    if(kind_1 == 5U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S603.x;
        if(sn_1 < 0.0f)
        {
            _S605 = true;
        }
        else
        {
            _S605 = sn_1 > 1.0f;
        }
        if(_S605)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S603.y * sn_1)));
        }
        float clearing_0 = _S602.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S606 = _S603.w;
        return (_S606 + (_S603.z - _S606) * relax_0) * shape_1;
    }
    if(kind_1 == 7U)
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S607 = _S603.y;
        if(tau_1 < _S607)
        {
            return _S603.x;
        }
        float s_3 = tau_1 - _S607;
        float _S608 = _S603.w;
        if(s_3 > _S608)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S603.z * (F32_sin((3.14159274101257324f * s_3 / _S608)));
        }
        return shape_1;
    }
    float _S609 = _S603.x;
    if(_S609 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S609, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_7, float3  t_5)
{
    uint _S610 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S610 == 0U)
    {
        return;
    }
    uint _S611 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S612 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S611 + _S612]) = make_float4 (f_7.x, f_7.y, f_7.z, 0.0f);
    uint _S613 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S613 + _S612 + 1U]) = make_float4 (t_5.x, t_5.y, t_5.z, 0.0f);
    uint _S614 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S615 = (&(globalParams_0->scratch_0)[_S614 + _S612]);
    uint _S616 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S617 = *(&(globalParams_0->scratch_0)[_S616 + _S612]);
    *_S615 = make_float4 ((float3 {_S617.x, _S617.y, _S617.z} + f_7).x, (float3 {_S617.x, _S617.y, _S617.z} + f_7).y, (float3 {_S617.x, _S617.y, _S617.z} + f_7).z, 0.0f);
    uint _S618 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S619 = (&(globalParams_0->scratch_0)[_S618 + _S612 + 1U]);
    uint _S620 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S621 = *(&(globalParams_0->scratch_0)[_S620 + _S612 + 1U]);
    *_S619 = make_float4 ((float3 {_S621.x, _S621.y, _S621.z} + t_5).x, (float3 {_S621.x, _S621.y, _S621.z} + t_5).y, (float3 {_S621.x, _S621.y, _S621.z} + t_5).z, 0.0f);
    return;
}

static __device__ void chunk_external_0(uint _S622, uint _S623, Quat_0 * _S624, uint _S625, float _S626, bool _S627, float3  * _S628, float3  * _S629)
{
    bool _S630;
    ChunkStatic_0 * _S631 = (&(globalParams_0->chunks_0)[_S623]);
    float3  _S632 = make_float3 (0.0f);
    *_S628 = _S632;
    *_S629 = _S632;
    uint4  _S633 = __ldg(&_S631->load_range_0);
    uint term_1 = _S633.x;
    for(;;)
    {
        if(term_1 < (_S633.y))
        {
        }
        else
        {
            break;
        }
        uint _S634 = 5U * term_1;
        float4  _S635 = __ldg((&(globalParams_0->loads_0)[_S634]));
        uint _S636 = asuint_0(_S635).y;
        if(_S636 == 2U)
        {
            term_1 = term_1 + 1U;
            continue;
        }
        float4  _S637 = __ldg((&(globalParams_0->loads_0)[_S634 + 1U]));
        float4  _S638 = __ldg((&(globalParams_0->loads_0)[_S634 + 2U]));
        float value_2 = eval_function_0(term_1, _S625, _S626, 0.0f);
        if(_S636 == 0U)
        {
            _S630 = true;
        }
        else
        {
            _S630 = _S636 == 3U;
        }
        float3  fw_0;
        if(_S630)
        {
            fw_0 = float3 {_S637.x, _S637.y, _S637.z} * make_float3 (value_2);
        }
        else
        {
            float3  _S639 = rotate_0(_S624, float3 {_S637.x, _S637.y, _S637.z});
            fw_0 = _S639 * make_float3 (- value_2 * _S637.w);
        }
        float3  lever_0;
        if(_S636 == 3U)
        {
            float4  _S640 = *(&(globalParams_0->state_0)[4U * _S622]);
            lever_0 = float3 {_S638.x, _S638.y, _S638.z} - float3 {_S640.x, _S640.y, _S640.z};
        }
        else
        {
            lever_0 = float3 {_S638.x, _S638.y, _S638.z};
        }
        *_S628 = *_S628 + fw_0;
        float3  _S641 = rotate_0(_S624, lever_0);
        *_S629 = *_S629 + cross_0(_S641, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S627)
    {
        uint4  _S642 = __ldg(&_S631->cinfo_0);
        _S630 = (_S642.z) != 0U;
    }
    else
    {
        _S630 = false;
    }
    if(_S630)
    {
        uint4  _S643 = __ldg(&_S631->cinfo_0);
        uint g_2 = _S643.x;
        for(;;)
        {
            if(g_2 < (_S643.y))
            {
            }
            else
            {
                break;
            }
            uint _S644 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S645 = 2U * g_2;
            float4  _S646 = *(&(globalParams_0->scratch_0)[_S644 + _S645]);
            *_S628 = *_S628 + float3 {_S646.x, _S646.y, _S646.z};
            uint _S647 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S648 = *(&(globalParams_0->scratch_0)[_S647 + _S645 + 1U]);
            *_S629 = *_S629 + float3 {_S648.x, _S648.y, _S648.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_1, uint k_14, float dt_5, bool contact_0)
{
    float3  f_8;
    float3  t_6;
    chunk_external_0(c_8, c_8, rot_1, k_14, dt_5, contact_0, &f_8, &t_6);
    record_chunk_load_0(c_8, f_8, t_6);
    return length_0(f_8);
}

static __device__ void net_load_0(uint c_9, Island_0 * isl_3, Rigid_0 * rg_2, uint k_15, float dt_6, bool contact_1, float3  * f_9, float3  * t_7)
{
    ChunkStatic_0 * _S649 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    chunk_external_0(c_9, c_9, &rg_2->rot_0, k_15, dt_6, contact_1, &fl_0, &tl_0);
    float3  _S650 = fl_0;
    float4  _S651 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S652 = float3 {_S651.x, _S651.y, _S651.z};
    float4  _S653 = __ldg(&_S649->center_0);
    float3  fc_1 = _S650 + _S652 * make_float3 (_S653.w);
    float3  _S654 = float3 {_S653.x, _S653.y, _S653.z};
    float4  _S655 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S656 = isl_3->com_0;
    float3  _S657 = float3 {_S656.x, _S656.y, _S656.z};
    float3  _S658 = rotate_0(&rg_2->rot_0, _S654 + float3 {_S655.x, _S655.y, _S655.z} - _S657);
    *f_9 = *f_9 + fc_1;
    *t_7 = *t_7 + (cross_0(_S658, fc_1) + tl_0);
    uint4  _S659 = __ldg(&_S649->load_range_0);
    uint term_2 = _S659.x;
    for(;;)
    {
        if(term_2 < (_S659.y))
        {
        }
        else
        {
            break;
        }
        uint _S660 = 5U * term_2;
        float4  _S661 = __ldg((&(globalParams_0->loads_0)[_S660]));
        if((asuint_0(_S661).y) != 2U)
        {
            term_2 = term_2 + 1U;
            continue;
        }
        float kf_0 = eval_function_0(term_2, k_15, dt_6, 0.0f);
        float4  _S662 = __ldg((&(globalParams_0->loads_0)[_S660 + 1U]));
        float3  _S663 = rotate_0(&rg_2->rot_0, float3 {_S662.x, _S662.y, _S662.z} * make_float3 (kf_0));
        *f_9 = *f_9 + _S663;
        float3  _S664 = rotate_0(&rg_2->rot_0, _S654 - _S657);
        float3  _S665 = cross_0(_S664, _S663);
        float4  _S666 = __ldg((&(globalParams_0->loads_0)[_S660 + 2U]));
        float3  _S667 = rotate_0(&rg_2->rot_0, float3 {_S666.x, _S666.y, _S666.z} * make_float3 (kf_0));
        *t_7 = *t_7 + (_S665 + _S667);
        term_2 = term_2 + 1U;
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_4, Rigid_0 * rg_3, float3  f_10, float3  t_8)
{
    Quat_0 _S668 = rg_3->rot_0;
    float3  _S669 = world_mul_0(&_S668, isl_4->inertia0_1, isl_4->inertia1_1, isl_4->inertia2_1, rg_3->w_4);
    rg_3->a_7 = f_10 / make_float3 (isl_4->com_0.w);
    float3  _S670 = t_8 - cross_0(rg_3->w_4, _S669);
    Quat_0 _S671 = rg_3->rot_0;
    float3  _S672 = world_mul_0(&_S671, isl_4->inv0_1, isl_4->inv1_1, isl_4->inv2_1, _S670);
    rg_3->alpha_0 = _S672;
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_7)
{
    Quat_0 _S673 = rg_4->rot_0;
    float3  _S674 = world_mul_0(&_S673, isl_5->inertia0_1, isl_5->inertia1_1, isl_5->inertia2_1, rg_4->w_4);
    Quat_0 _S675 = rg_4->rot_0;
    float3  _S676 = world_mul_0(&_S675, isl_5->inertia0_1, isl_5->inertia1_1, isl_5->inertia2_1, rg_4->alpha_0);
    float3  l_2 = _S674 + (_S676 + cross_0(rg_4->w_4, _S674)) * make_float3 (dt_7);
    comp_add_0(&rg_4->vel_1, &rg_4->vel_err_1, rg_4->a_7 * make_float3 (dt_7));
    float3  vel_2 = rg_4->vel_1 + rg_4->vel_err_1;
    float4  _S677 = isl_5->inv0_1;
    float4  _S678 = isl_5->inv1_1;
    float4  _S679 = isl_5->inv2_1;
    Quat_0 _S680 = rg_4->rot_0;
    float3  _S681 = world_mul_0(&_S680, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_2);
    Quat_0 _S682 = rg_4->rot_0;
    Quat_0 _S683 = integrate_rotation_0(&_S682, _S681, dt_7);
    float3  _S684 = vel_2 * make_float3 (dt_7);
    float4  _S685 = isl_5->com_0;
    float3  _S686 = float3 {_S685.x, _S685.y, _S685.z};
    Quat_0 _S687 = rg_4->rot_0;
    float3  _S688 = rotate_0(&_S687, _S686);
    Quat_0 _S689 = _S683;
    float3  _S690 = rotate_0(&_S689, _S686);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S684 + (_S688 - _S690));
    rg_4->rot_0 = _S683;
    Quat_0 _S691 = _S683;
    float3  _S692 = world_mul_0(&_S691, _S677, _S678, _S679, l_2);
    rg_4->w_4 = _S692;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S693 = __ldg(&ptr_0->geom0_0);
    float4  _S694 = __ldg(&ptr_0->geom1_0);
    float4  _S695 = __ldg(&ptr_0->stiff0_0);
    float4  _S696 = __ldg(&ptr_0->stiff1_0);
    float4  _S697 = __ldg(&ptr_0->rebar0_0);
    float4  _S698 = __ldg(&ptr_0->rebar1_0);
    uint4  _S699 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S700 = { _S693, _S694, _S695, _S696, _S697, _S698, _S699 };
    return _S700;
}

static __device__ bool connected_0(JointState_0 * st_0, bool has_rebar_0)
{
    bool _S701;
    if((st_0->damage_0) < 1.0f)
    {
        _S701 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S701 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S701 = false;
        }
    }
    return _S701;
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
    float _S702 = q_lin_0.z;
    float axial_0 = fdiv_0(_S702, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S703 = q_lin_0.x;
    float _S704 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S703 * _S703 + _S704 * _S704), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S705 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S705), (0.0f)));
    (&m_3)->compression_0 = _S705 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S702), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_14)
{
    if((F32_abs((x_14))) < 0.00100000004749745f)
    {
        return x_14 * (1.0f + x_14 * (0.5f + x_14 * 0.1666666716337204f));
    }
    return (F32_exp((x_14))) - 1.0f;
}

static __device__ float fpow_0(float a_10, float b_24)
{
    return (F32_pow((a_10), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_6 = (F32_abs((strain_rate_1)));
    float4  _S706 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    float _S707 = _S706.z;
    float f_11;
    if(r_6 <= _S707)
    {
        f_11 = fpow_0(fdiv_0(r_6, ref_0), _S706.y);
    }
    else
    {
        f_11 = fpow_0(fdiv_0(_S707, ref_0), _S706.y) * fpow_0(fdiv_0(r_6, _S707), _S706.w);
    }
    return clamp_0(f_11, 1.0f, mat_1->misc_0.x);
}

static __device__ float fatigue_factor_0(JointMaterial_0 * mat_2, float fatigue_1)
{
    if(((mat_2->kind_flags_0.y) & 64U) == 0U)
    {
        return 1.0f;
    }
    return fpow_0(1.0f - clamp_0(fatigue_1, 0.0f, 1.0f), fdiv_0(1.0f, mat_2->misc_0.y - 2.0f));
}

static __device__ float infinity_0()
{
    return (U32_asfloat((2139095040U)));
}

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_25, Measures_0 * m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S708 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S709;
    if(_S708 > 0.0f)
    {
        _S709 = fdiv_0(m_4->shear_0, _S708);
    }
    else
    {
        _S709 = infinity_0();
    }
    *&((&idx_0)->y) = _S709;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_2)), (0.0f)));
    float _S710 = b_25->stiff1_0.y;
    if(_S710 > 0.0f)
    {
        _S709 = fdiv_0(m_4->compressive_force_0, _S710);
    }
    else
    {
        _S709 = 0.0f;
    }
    *&((&idx_0)->w) = _S709;
    return idx_0;
}

static __device__ float sq_0(float x_15)
{
    return x_15 * x_15;
}

static __device__ float damage_law_0(uint kind_2, float kappa_1, float r_7)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_7 <= 1.0f)
        {
            return 1.0f;
        }
        return (F32_min((fdiv_0(r_7 * (kappa_1 - 1.0f), kappa_1 * (r_7 - 1.0f))), (1.0f)));
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

static __device__ __noinline__ float2  damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_8, float d_old_0, float psi_0)
{
    float _S711 = (F32_max((damage_law_0(kind_3, lambda_0, r_8)), (d_old_0)));
    bool _S712;
    if(_S711 <= d_old_0)
    {
        _S712 = true;
    }
    else
    {
        _S712 = d_old_0 >= 1.0f;
    }
    if(_S712)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S713 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_8 > 1.0f)
        {
            return make_float2 (_S711, fdiv_0(u0_0 * r_8, r_8 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_8))) - (F32_min((_S713), (r_8)))), (0.0f))));
        }
        return make_float2 (_S711, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_8 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S713), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S711 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S711, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S714 = - h0_0;
    float _S715 = - h1_0;
    FixedArray<float2 , 4>  _S716 = { {
        float2 {
            _S714, _S715
        }, float2 {
            h0_0, _S715
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S714, h1_0
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
        uint _S717 = i_11;
        uint _S718 = i_11 + 1U;
        uint _S719 = _S718 % 4U;
        float _S720 = _S716[i_11].y;
        float _S721 = _S716[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S720 - ay_0 * _S721;
        float _S722 = _S716[_S719].y;
        float _S723 = _S716[_S719].x;
        float fq_0 = dz_0 + ax_0 * _S722 - ay_0 * _S723;
        bool _S724 = fp_0 < 0.0f;
        if(_S724)
        {
            uint _S725 = count_4 + 1U;
            poly_0[count_4] = _S716[_S717];
            count_3 = _S725;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S724 != (fq_0 < 0.0f))
        {
            float t_9 = fp_0 / (fp_0 - fq_0);
            uint _S726 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S721 + t_9 * (_S723 - _S721), _S720 + t_9 * (_S722 - _S720));
            count_4 = _S726;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S718;
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
        float _S727 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S727;
        float _S728 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S728;
        uint _S729 = i_11 + 1U;
        uint _S730 = _S729 % count_4;
        float x1_0 = poly_0[_S730].x - _S727;
        float y1_0 = poly_0[_S730].y - _S728;
        float _S731 = x0_0 * y1_0;
        float _S732 = x1_0 * y0_0;
        float cr_0 = _S731 - _S732;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S731 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S732) * cr_0 / 24.0f;
        i_11 = _S729;
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
    float _S733 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S733 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S733 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_9;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_9);
    float a_13 = r_9[int(0)];
    if((r_9[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_16 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_9[int(2)] - ay_1 * r_9[int(1)];
    float _S734 = a_13 * fc_3;
    float _S735 = - ay_1;
    return make_float4 (k_16 * a_13 * fc_3, k_16 * (_S734 * r_9[int(2)] + (_S735 * r_9[int(5)] + ax_1 * r_9[int(4)])), - k_16 * (_S734 * r_9[int(1)] + (_S735 * r_9[int(3)] + ax_1 * r_9[int(5)])), 0.5f * k_16 * (_S734 * fc_3 + ay_1 * ay_1 * r_9[int(3)] + ax_1 * ax_1 * r_9[int(4)] - 2.0f * ax_1 * ay_1 * r_9[int(5)]));
}

static __device__ float signum_0(float x_16)
{
    float _S736;
    if(((F32_asuint((x_16))) & 2147483648U) != 0U)
    {
        _S736 = -1.0f;
    }
    else
    {
        _S736 = 1.0f;
    }
    return _S736;
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
    float3  _S737 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S737;
    (&c_10)->q_ang_1 = _S737;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S738 = mat_4->kind_flags_0.y;
    if((_S738 & 2U) == 0U)
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
    if((_S738 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S739 = p_9.y;
        float _S740 = p_9.z;
        float _S741 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S739;
        m2_0 = _S740;
        energy_3 = _S741;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S742 = d_ang_0.x;
        float _S743 = d_ang_0.y;
        float spread_0 = (F32_abs((_S742))) * 0.4166666567325592f * w1_2 + (F32_abs((_S743))) * 0.4166666567325592f * w0_2;
        float _S744 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S744))) + spread_0);
        if((_S744 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S744 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S745 = ki_0 * _S742 * i2_0;
                float _S746 = ki_0 * _S743 * i1_0;
                float _S747 = 0.5f * ki_0 * (36.0f * _S744 * _S744 + _S742 * _S742 * i2_0 + _S743 * _S743 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S744;
                m1_0 = _S745;
                m2_0 = _S746;
                energy_3 = _S747;
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
                    float _S748 = SPRING_AT_0[i_12] * w0_2;
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
                        float di_0 = _S744 + _S742 * s2_0 - _S743 * _S748;
                        if(di_0 < 0.0f)
                        {
                            float f_13 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_13 * s2_0;
                            float m2_2 = m2_0 - f_13 * _S748;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_13;
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
    float _S749 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S750 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S749 * _S749 + _S750 * _S750);
    bool _S751;
    if(tn_0 > slide_cap_0)
    {
        _S751 = tn_0 > 0.0f;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        float _S752 = fdiv_0(_S749, tn_0);
        float _S753 = fdiv_0(_S750, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S752 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S753 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S752 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S753 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S749;
        *&((&(&c_10)->q_lin_1)->y) = _S750;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S754 = tq_0.x;
    float _S755 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S754))) * (F32_abs((_S755)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S755;
    *&((&(&c_10)->q_ang_1)->z) = _S754;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S754), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S756 = mat_5->kind_flags_0.y;
    if((_S756 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S756 & 4U) != 0U)
    {
        float4  _S757 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S757.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S758 = d_ang_1.x;
        float _S759 = d_ang_1.y;
        float spread_1 = (F32_abs((_S758))) * 0.4166666567325592f * w1_3 + (F32_abs((_S759))) * 0.4166666567325592f * w0_3;
        float _S760 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S760))) + spread_1);
        if((_S760 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S760 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S760;
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
                    float _S761 = SPRING_AT_0[i_13] * w0_3;
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
                        float di_1 = _S760 + _S758 * (SPRING_AT_0[j_5] * w1_3) - _S759 * _S761;
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
    float _S762 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S763 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S762 * _S762 + _S763 * _S763);
    bool _S764;
    if(tn_1 > slide_cap_1)
    {
        _S764 = tn_1 > 0.0f;
    }
    else
    {
        _S764 = false;
    }
    if(_S764)
    {
        float _S765 = fdiv_0(_S763, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S762, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S765 * dslip_1;
    }
    *&((&p_11)->z) = *&((&p_11)->z) + return_map_0(kt_1, d_ang_1.z, p_11.z, slide_cap_1 * b_27->geom1_0.z).y;
    return p_11;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_4)
{
    if(s_4 <= 0.0f)
    {
        return 0.0f;
    }
    float _S766 = mat_6->misc_0.y;
    return fdiv_0((_S766 + 1.0f) * fpow_0(s_4, _S766), mat_6->misc_0.z);
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

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_28, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_8, bool fracture_1)
{
    float kn_3 = b_28->stiff0_0.x;
    float ks_2 = b_28->stiff0_0.y;
    float kb1_0 = b_28->stiff0_0.z;
    float kb2_0 = b_28->stiff0_0.w;
    float4  _S767 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_1 = *state_2;
    bool _S768 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S769 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S770 = (F32_max(((F32_max((_S769.tension_0), (_S769.shear_0)))), (_S769.compression_0)));
    bool _S771 = dt_8 > 0.0f;
    float dif_1;
    if(_S771)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S770 - (&st_1)->governing_stress_0, dt_8)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S767.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_8, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_8, tau_2)), (1.0f)));
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S770;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S772 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S772;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S773 = weibull_0 * dif_1;
    float _S774 = fatigue_factor_0(mat_7, (&st_1)->fatigue_0);
    float multiplier_1 = _S773 * _S774;
    Measures_0 _S775 = _S769;
    float4  _S776 = failure_indices_0(mat_7, b_28, &_S775, multiplier_1);
    float _S777 = _S776.x;
    float _S778 = _S776.y;
    (&st_1)->utilization_0 = (F32_max(((F32_max((_S777), (_S778)))), ((F32_max((_S776.z), (_S776.w))))));
    float _S779 = d_lin_2.x;
    float _S780 = d_lin_2.y;
    float _S781 = ks_2 * (sq_0(_S779) + sq_0(_S780)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S782 = d_lin_2.z;
    bool _S783 = _S782 > 0.0f;
    if(_S783)
    {
        dif_1 = kn_3 * sq_0(_S782);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S781 + dif_1);
    float psi_c_0;
    if(_S782 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S782);
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
    bool _S784;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S785 = _S777 >= _S778;
        if(_S785)
        {
            diss_contact_0 = _S777;
        }
        else
        {
            diss_contact_0 = _S778;
        }
        uint mode_ts_0;
        if(_S785)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S784 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S784 = false;
        }
        if(_S784)
        {
            _S784 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S784 = false;
        }
        uint mode_c_0;
        if(_S784)
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
            float _S786 = inc_0.x;
            if(_S786 > ((&st_1)->damage_0))
            {
                Contact_0 _S787 = contact_part_0(mat_7, b_28, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S788 = (F32_max((_S787.energy_2 - (1.0f - (&st_1)->crush_0) * psi_c_0), (0.0f)));
                float _S789 = (F32_max((inc_0.y - _S788 * (_S786 - (&st_1)->damage_0)), (0.0f)));
                float _S790 = (F32_max(((psi_ts_0 - _S788) * (_S786 - (&st_1)->damage_0) - _S789), (0.0f)));
                (&st_1)->damage_0 = _S786;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S789;
                overshoot_1 = _S790;
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
        float _S791 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S792 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S791) + _S792.q_ang_1 * make_float3 (_S791);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S793 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S794 = _S793;
        float4  _S795 = failure_indices_0(mat_7, b_28, &_S794, multiplier_1);
        float _S796 = _S795.z;
        float _S797 = _S795.w;
        bool _S798 = _S796 >= _S797;
        if(_S798)
        {
            psi_contact_0 = _S796;
        }
        else
        {
            psi_contact_0 = _S797;
        }
        if(_S798)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S784 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S784 = false;
        }
        if(_S784)
        {
            _S784 = psi_c_0 > 0.0f;
        }
        else
        {
            _S784 = false;
        }
        if(_S784)
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
            float _S799 = inc_1.x;
            if(_S799 > ((&st_1)->crush_0))
            {
                float _S800 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S800;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S799 - (&st_1)->crush_0) - _S800), (0.0f)));
                (&st_1)->crush_0 = _S799;
                (&st_1)->mode_0 = mode_c_0;
                if(_S799 >= 1.0f)
                {
                    _S784 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S784 = false;
                }
                if(_S784)
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
    float3  _S801 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S802 = contact_offsets_0(mat_7, b_28, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S802.x;
            (&st_1)->plastic_y_0 = _S802.y;
            (&st_1)->plastic_t_0 = _S802.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S801;
        qc_ang_0 = _S801;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S803 = contact_part_0(mat_7, b_28, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S803.plastic_1.x;
        (&st_1)->plastic_y_0 = _S803.plastic_1.y;
        (&st_1)->plastic_t_0 = _S803.plastic_1.z;
        diss_contact_0 = _S803.diss_4;
        qc_lin_0 = _S803.q_lin_1;
        qc_ang_0 = _S803.q_ang_1;
        psi_contact_0 = _S803.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S783)
    {
        intact_normal_0 = kn_3 * _S782;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_3 * _S782;
    }
    float _S804 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S804 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S804 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S804 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S804) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S804 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S784 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S784 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S784)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S782, (&st_1)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S779, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S780, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S805 = nr_0.y;
        float _S806 = v1_0.y;
        float _S807 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S805))) + dowel_capacity_0 * ((F32_abs((_S806))) + (F32_abs((_S807))));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S805;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S806;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S807;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S808 = nr_0.x;
        float _S809 = v1_0.x;
        float _S810 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S808), k_axial_0) + fdiv_0(sq_0(_S809) + sq_0(_S810), k_dowel_0));
        if(fracture_1)
        {
            _S784 = ((&st_1)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S784 = false;
        }
        if(_S784)
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
            force_lin_3 = force_lin_2 + make_float3 (_S809, _S810, _S808);
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
        _S784 = _S771;
    }
    else
    {
        _S784 = false;
    }
    if(_S784)
    {
        _S784 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S784 = false;
    }
    if(_S784)
    {
        Measures_0 _S811 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S812 = _S811;
        float4  _S813 = failure_indices_0(mat_7, b_28, &_S812, weibull_0);
        float _S814 = life_rate_0(mat_7, (F32_max(((F32_max((_S813.x), (_S813.y)))), (_S813.z))));
        (&st_1)->fatigue_0 = (F32_min(((&st_1)->fatigue_0 + _S814 * dt_8), (1.0f)));
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S768)
    {
        JointState_0 _S815 = st_1;
        bool _S816 = connected_0(&_S815, has_rebar_1);
        _S784 = !_S816;
    }
    else
    {
        _S784 = false;
    }
    (&resp_0)->disconnected_0 = _S784;
    (&resp_0)->measures_0 = _S769;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_2, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S817 = st_2->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S817;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S818 = 1.0f - _S817;
    float _S819 = (F32_max((_S818 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_2->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S818), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S819, _S819, normal_4);
    *f_ang_0 = make_float3 (_S819);
    bool _S820;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S820 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S820 = false;
    }
    if(_S820)
    {
        float4  _S821 = b_29->rebar0_0;
        float4  _S822 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S823 = fdiv_0(_S821.y, _S822.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S823;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S823;
    }
    return;
}

static __device__ bool is_damaged_0(JointState_0 * st_3)
{
    bool _S824;
    if((st_3->damage_0) > 0.0f)
    {
        _S824 = true;
    }
    else
    {
        _S824 = (st_3->crush_0) > 0.0f;
    }
    return _S824;
}

static __device__ float3  to_local_0(uint _S825, float3  _S826)
{
    BondStatic_0 * _S827 = (&(globalParams_0->bonds_0)[_S825]);
    float4  _S828 = __ldg(&_S827->t1_0);
    float _S829 = dot_0(_S826, float3 {_S828.x, _S828.y, _S828.z});
    float4  _S830 = __ldg(&_S827->t2_0);
    float _S831 = dot_0(_S826, float3 {_S830.x, _S830.y, _S830.z});
    float4  _S832 = __ldg(&_S827->normal_0);
    return make_float3 (_S829, _S831, dot_0(_S826, float3 {_S832.x, _S832.y, _S832.z}));
}

static __device__ float3  to_body_0(uint _S833, float3  _S834)
{
    BondStatic_0 * _S835 = (&(globalParams_0->bonds_0)[_S833]);
    float4  _S836 = __ldg(&_S835->t1_0);
    float3  _S837 = float3 {_S836.x, _S836.y, _S836.z} * make_float3 (_S834.x);
    float4  _S838 = __ldg(&_S835->t2_0);
    float3  _S839 = _S837 + float3 {_S838.x, _S838.y, _S838.z} * make_float3 (_S834.y);
    float4  _S840 = __ldg(&_S835->normal_0);
    return _S839 + float3 {_S840.x, _S840.y, _S840.z} * make_float3 (_S834.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_9, bool fracture_2, uint abs_step_0)
{
    BondStatic_0 * _S841 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    JointBond_0 _S842 = slang_ldg_0(&_S841->law_0);
    uint ca_0 = _S842.ids_0.y;
    uint cb_0 = _S842.ids_0.z;
    float4  _S843 = __ldg(&_S841->ra_0);
    float3  ra_1 = float3 {_S843.x, _S843.y, _S843.z};
    float4  _S844 = __ldg(&_S841->rb_0);
    float3  rb_1 = float3 {_S844.x, _S844.y, _S844.z};
    uint _S845 = 4U * ca_0;
    float4  _S846 = *(&(globalParams_0->state_0)[_S845]);
    float4  _S847 = *(&(globalParams_0->state_0)[_S845 + 1U]);
    float3  ta_2 = float3 {_S847.x, _S847.y, _S847.z};
    float4  _S848 = *(&(globalParams_0->state_0)[_S845 + 2U]);
    float3  va_0 = float3 {_S848.x, _S848.y, _S848.z};
    float4  _S849 = *(&(globalParams_0->state_0)[_S845 + 3U]);
    float3  wa_1 = float3 {_S849.x, _S849.y, _S849.z};
    uint _S850 = 4U * cb_0;
    float4  _S851 = *(&(globalParams_0->state_0)[_S850]);
    float4  _S852 = *(&(globalParams_0->state_0)[_S850 + 1U]);
    float3  tb_2 = float3 {_S852.x, _S852.y, _S852.z};
    float4  _S853 = *(&(globalParams_0->state_0)[_S850 + 2U]);
    float3  vb_0 = float3 {_S853.x, _S853.y, _S853.z};
    float4  _S854 = *(&(globalParams_0->state_0)[_S850 + 3U]);
    float3  wb_0 = float3 {_S854.x, _S854.y, _S854.z};
    float3  _S855 = to_local_0(i_14, float3 {_S851.x, _S851.y, _S851.z} + cross_0(tb_2, rb_1) - (float3 {_S846.x, _S846.y, _S846.z} + cross_0(ta_2, ra_1)));
    float3  _S856 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S857 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S858 = to_local_0(i_14, wb_0 - wa_1);
    JointState_0 previous_0 = (&bd_0)->js_0;
    JointBond_0 _S859 = _S842;
    JointState_0 _S860 = (&bd_0)->js_0;
    JointResponse_0 _S861 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S842.ids_0.x], &_S859, &_S860, _S855, _S856, dt_9, fracture_2);
    JointBond_0 _S862 = _S842;
    JointState_0 _S863 = _S861.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S862, &_S863, _S855, &f_lin_1, &f_ang_1);
    float4  _S864 = __ldg(&_S841->c_lin_0);
    float3  qd_lin_0 = _S857 * float3 {_S864.x, _S864.y, _S864.z} * f_lin_1;
    float4  _S865 = __ldg(&_S841->c_ang_0);
    float3  qd_ang_0 = _S858 * float3 {_S865.x, _S865.y, _S865.z} * f_ang_1;
    float3  q_lin_2 = _S861.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S861.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S857) + dot_0(qd_ang_0, _S858)) * dt_9;
    float3  _S866 = to_body_0(i_14, q_lin_2);
    float3  _S867 = to_body_0(i_14, q_ang_2);
    uint _S868 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S868]) = make_float4 (_S866.x, _S866.y, _S866.z, (F32_max((_S861.measures_0.tension_0), (_S861.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S868 + 1U]) = make_float4 ((_S867 + cross_0(ra_1, _S866)).x, (_S867 + cross_0(ra_1, _S866)).y, (_S867 + cross_0(ra_1, _S866)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S868 + 2U]) = make_float4 ((- _S867 + cross_0(rb_1, - _S866)).x, (- _S867 + cross_0(rb_1, - _S866)).y, (- _S867 + cross_0(rb_1, - _S866)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S861.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S861.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S861.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S861.state_1.utilization_0))));
    JointState_0 _S869 = previous_0;
    bool _S870 = is_damaged_0(&_S869);
    bool _S871;
    if(!_S870)
    {
        JointState_0 _S872 = _S861.state_1;
        bool _S873 = is_damaged_0(&_S872);
        _S871 = _S873;
    }
    else
    {
        _S871 = false;
    }
    if(_S871)
    {
        _S871 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S871 = false;
    }
    if(_S871)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S861.state_1.mode_0;
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        float _S874 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S842.ids_0.x], previous_0.fatigue_0);
        _S871 = _S874 > 0.99000000953674316f;
    }
    else
    {
        _S871 = false;
    }
    if(_S871)
    {
        float _S875 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S842.ids_0.x], _S861.state_1.fatigue_0);
        _S871 = _S875 <= 0.99000000953674316f;
    }
    else
    {
        _S871 = false;
    }
    if(_S871)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
    }
    if(_S861.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S861.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S861.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_6, Rigid_0 * rg_5, float dt_10, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S876 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S877 = make_float3 (0.0f);
    uint _S878 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S878;
    float3  fi_0 = _S877;
    float3  mi_0 = _S877;
    for(;;)
    {
        uint _S879 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S879)
        {
        }
        else
        {
            break;
        }
        uint _S880 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S881 = 3U * (_S880 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S881]);
        if((_S880 & 1U) == 0U)
        {
            float4  _S882 = *(&(globalParams_0->scratch_0)[_S881 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S882.x, _S882.y, _S882.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S883 = *(&(globalParams_0->scratch_0)[_S881 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S883.x, _S883.y, _S883.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S884 = (F32_max((peak_0), (fa_2.w)));
        uint _S885 = e_3 + 1U;
        peak_0 = _S884;
        e_3 = _S885;
    }
    uint _S886 = 4U * c_11;
    float4  _S887 = *(&(globalParams_0->state_0)[_S886]);
    float3  u_0 = float3 {_S887.x, _S887.y, _S887.z};
    uint _S888 = _S886 + 1U;
    float4  _S889 = *(&(globalParams_0->state_0)[_S888]);
    float3  th_1 = float3 {_S889.x, _S889.y, _S889.z};
    uint _S890 = _S886 + 2U;
    float4  _S891 = *(&(globalParams_0->state_0)[_S890]);
    float3  v_10 = float3 {_S891.x, _S891.y, _S891.z};
    uint _S892 = _S886 + 3U;
    float4  _S893 = *(&(globalParams_0->state_0)[_S892]);
    float3  w_5 = float3 {_S893.x, _S893.y, _S893.z};
    float4  _S894 = __ldg(&_S876->center_0);
    float mass_0 = _S894.w;
    float3  _S895 = float3 {_S894.x, _S894.y, _S894.z};
    float4  _S896 = isl_6->com_0;
    float3  _S897 = float3 {_S896.x, _S896.y, _S896.z};
    float3  _S898 = rotate_0(&rg_5->rot_0, _S895 + u_0 - _S897);
    float3  f_load_0;
    float3  t_load_0;
    chunk_external_0(c_11, c_11, &rg_5->rot_0, step_0, dt_10, contact_3, &f_load_0, &t_load_0);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S899 = f_load_0;
    float4  _S900 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S899 + float3 {_S900.x, _S900.y, _S900.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S901 = rg_5->alpha_0;
        float3  _S902 = rg_5->w_4;
        float3  f_world_2 = f_world_0 - (rg_5->a_7 + cross_0(rg_5->alpha_0, _S898) + cross_0(rg_5->w_4, cross_0(rg_5->w_4, _S898))) * make_float3 (mass_0);
        float4  _S903 = __ldg(&_S876->inertia0_0);
        float4  _S904 = __ldg(&_S876->inertia1_0);
        float4  _S905 = __ldg(&_S876->inertia2_0);
        float3  _S906 = world_mul_0(&rg_5->rot_0, _S903, _S904, _S905, _S901);
        float3  _S907 = world_mul_0(&rg_5->rot_0, _S903, _S904, _S905, _S902);
        float3  t_world_2 = t_world_0 - (_S906 + cross_0(_S902, _S907));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S908 = inverse_rotate_0(&rg_5->rot_0, f_world_1);
    float3  _S909 = inverse_rotate_0(&rg_5->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S910 = inverse_rotate_0(&rg_5->rot_0, rg_5->w_4);
        float3  f_ext_1 = _S908 - cross_0(_S910, v_10) * make_float3 (2.0f * mass_0);
        float4  _S911 = __ldg(&_S876->inertia0_0);
        float4  _S912 = __ldg(&_S876->inertia1_0);
        float4  _S913 = __ldg(&_S876->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S911, _S912, _S913, w_5);
        float3  m_ext_1 = _S909 - (cross_0(_S910, i_w_0) + cross_0(w_5, rows_mul_0(_S911, _S912, _S913, _S910)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S908;
        m_ext_0 = _S909;
    }
    uint4  _S914 = __ldg(&_S876->load_range_0);
    uint term_3 = _S914.x;
    for(;;)
    {
        if(term_3 < (_S914.y))
        {
        }
        else
        {
            break;
        }
        uint _S915 = 5U * term_3;
        float4  _S916 = __ldg((&(globalParams_0->loads_0)[_S915]));
        if((asuint_0(_S916).y) != 2U)
        {
            term_3 = term_3 + 1U;
            continue;
        }
        float kf_1 = eval_function_0(term_3, step_0, dt_10, dt_10);
        float4  _S917 = __ldg((&(globalParams_0->loads_0)[_S915 + 1U]));
        float3  f_ext_2 = f_ext_0 + float3 {_S917.x, _S917.y, _S917.z} * make_float3 (kf_1);
        float4  _S918 = __ldg((&(globalParams_0->loads_0)[_S915 + 2U]));
        float3  m_ext_2 = m_ext_0 + float3 {_S918.x, _S918.y, _S918.z} * make_float3 (kf_1);
        f_ext_0 = f_ext_2;
        m_ext_0 = m_ext_2;
        term_3 = term_3 + 1U;
    }
    float3  f_14 = f_ext_0 + fi_0;
    float3  m_5 = m_ext_0 + mi_0;
    uint4  _S919 = __ldg(&_S876->info_0);
    uint support_0 = _S919.x;
    float3  _S920 = make_float3 ((*(&(globalParams_0->state_0)[_S888])).w, (*(&(globalParams_0->state_0)[_S890])).w, (*(&(globalParams_0->state_0)[_S892])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_2;
    float3  v_11;
    float3  w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_14;
        u_1 = u_0;
        th_2 = th_1;
        v_11 = _S877;
        w_6 = _S877;
    }
    else
    {
        float4  _S921 = __ldg(&_S876->inv0_0);
        float4  _S922 = __ldg(&_S876->inv1_0);
        float4  _S923 = __ldg(&_S876->inv2_0);
        float3  _S924 = rows_mul_0(_S921, _S922, _S923, m_5);
        float4  _S925 = __ldg(&_S876->scale_0);
        float3  w_7 = w_5 + _S924 * make_float3 (dt_10 * _S925.z);
        float3  th_3 = th_1 + w_7 * make_float3 (dt_10);
        if(support_0 == 2U)
        {
            reaction_0 = - f_14;
            u_1 = u_0;
            th_2 = _S877;
        }
        else
        {
            float3  v_12 = v_10 + f_14 * make_float3 (dt_10 * _S925.y);
            float3  u_2 = u_0 + v_12 * make_float3 (dt_10);
            reaction_0 = _S920;
            u_1 = u_2;
            th_2 = v_12;
        }
        float3  _S926 = th_2;
        th_2 = th_3;
        v_11 = _S926;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S886]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S888]) = make_float4 (th_2.x, th_2.y, th_2.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S890]) = make_float4 (v_11.x, v_11.y, v_11.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S892]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S927 = rotate_0(&rg_5->rot_0, _S895 + u_1 - _S897);
    float3  _S928 = rg_5->vel_1 + rg_5->vel_err_1 + cross_0(rg_5->w_4, _S927);
    float3  _S929 = rotate_0(&rg_5->rot_0, v_11);
    float3  v_world_0 = _S928 + _S929;
    float3  _S930 = rotate_0(&rg_5->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_5->w_4 + _S930)) * dt_10);
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S931 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S932 = __ldg(&_S931->center_0);
    float _S933 = _S932.w;
    float4  _S934 = __ldg(&_S931->scale_0);
    float m_6 = _S933 * _S934.x;
    uint _S935 = 4U * c_12;
    float4  _S936 = *(&(globalParams_0->state_0)[_S935]);
    *tu_0 = *tu_0 + float3 {_S936.x, _S936.y, _S936.z} * make_float3 (m_6);
    float4  _S937 = *(&(globalParams_0->state_0)[_S935 + 2U]);
    *pv_0 = *pv_0 + float3 {_S937.x, _S937.y, _S937.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S938 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S939 = __ldg(&_S938->center_0);
    float3  r_10 = float3 {_S939.x, _S939.y, _S939.z} - wcom_1;
    float4  _S940 = __ldg(&_S938->scale_0);
    float kw_0 = _S940.x;
    uint _S941 = 4U * c_13;
    float4  _S942 = *(&(globalParams_0->state_0)[_S941]);
    float _S943 = _S939.w;
    float3  _S944 = cross_0(r_10, float3 {_S942.x, _S942.y, _S942.z} - tr_0) * make_float3 (_S943);
    float4  _S945 = __ldg(&_S938->inertia0_0);
    float4  _S946 = __ldg(&_S938->inertia1_0);
    float4  _S947 = __ldg(&_S938->inertia2_0);
    float4  _S948 = *(&(globalParams_0->state_0)[_S941 + 1U]);
    *lu_0 = *lu_0 + (_S944 + rows_mul_0(_S945, _S946, _S947, float3 {_S948.x, _S948.y, _S948.z})) * make_float3 (kw_0);
    float4  _S949 = *(&(globalParams_0->state_0)[_S941 + 2U]);
    float4  _S950 = *(&(globalParams_0->state_0)[_S941 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_10, float3 {_S949.x, _S949.y, _S949.z} - dv_0) * make_float3 (_S943) + rows_mul_0(_S945, _S946, _S947, float3 {_S950.x, _S950.y, _S950.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S951 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_11 = float3 {_S951.x, _S951.y, _S951.z} - wcom_2;
    uint _S952 = 4U * c_14;
    float4  _S953 = *(&(globalParams_0->state_0)[_S952]);
    *(&(globalParams_0->state_0)[_S952]) = make_float4 ((float3 {_S953.x, _S953.y, _S953.z} - (tr_1 + cross_0(phi_0, r_11))).x, (float3 {_S953.x, _S953.y, _S953.z} - (tr_1 + cross_0(phi_0, r_11))).y, (float3 {_S953.x, _S953.y, _S953.z} - (tr_1 + cross_0(phi_0, r_11))).z, (*(&(globalParams_0->state_0)[_S952])).w);
    uint _S954 = _S952 + 1U;
    float4  _S955 = *(&(globalParams_0->state_0)[_S954]);
    *(&(globalParams_0->state_0)[_S954]) = make_float4 ((float3 {_S955.x, _S955.y, _S955.z} - phi_0).x, (float3 {_S955.x, _S955.y, _S955.z} - phi_0).y, (float3 {_S955.x, _S955.y, _S955.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S954])).w);
    uint _S956 = _S952 + 2U;
    float4  _S957 = *(&(globalParams_0->state_0)[_S956]);
    *(&(globalParams_0->state_0)[_S956]) = make_float4 ((float3 {_S957.x, _S957.y, _S957.z} - (dv_1 + cross_0(dw_0, r_11))).x, (float3 {_S957.x, _S957.y, _S957.z} - (dv_1 + cross_0(dw_0, r_11))).y, (float3 {_S957.x, _S957.y, _S957.z} - (dv_1 + cross_0(dw_0, r_11))).z, (*(&(globalParams_0->state_0)[_S956])).w);
    uint _S958 = _S952 + 3U;
    float4  _S959 = *(&(globalParams_0->state_0)[_S958]);
    *(&(globalParams_0->state_0)[_S958]) = make_float4 ((float3 {_S959.x, _S959.y, _S959.z} - dw_0).x, (float3 {_S959.x, _S959.y, _S959.z} - dw_0).y, (float3 {_S959.x, _S959.y, _S959.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S958])).w);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_7, Rigid_0 * rg_6, float3  tr_2, float3  phi_1, float3  dv_2, float3  dw_1)
{
    float4  _S960 = isl_7->wcom_0;
    float3  wcom_3 = float3 {_S960.x, _S960.y, _S960.z};
    Quat_0 rot_2 = rg_6->rot_0;
    float3  _S961 = tr_2 - cross_0(phi_1, wcom_3);
    Quat_0 _S962 = rg_6->rot_0;
    float3  _S963 = rotate_0(&_S962, _S961);
    comp_add_0(&rg_6->pos_1, &rg_6->pos_err_1, _S963);
    Quat_0 _S964 = from_axis_angle_0(phi_1, length_0(phi_1));
    Quat_0 _S965 = rg_6->rot_0;
    Quat_0 _S966 = _S964;
    Quat_0 _S967 = quat_mul_0(&_S965, &_S966);
    Quat_0 _S968 = _S967;
    Quat_0 _S969 = normalized_0(&_S968);
    rg_6->rot_0 = _S969;
    float4  _S970 = isl_7->com_0;
    float3  _S971 = dv_2 + cross_0(dw_1, float3 {_S970.x, _S970.y, _S970.z} - wcom_3);
    Quat_0 _S972 = rot_2;
    float3  _S973 = rotate_0(&_S972, _S971);
    comp_add_0(&rg_6->vel_1, &rg_6->vel_err_1, _S973);
    Quat_0 _S974 = rot_2;
    float3  _S975 = rotate_0(&_S974, dw_1);
    rg_6->w_4 = rg_6->w_4 + _S975;
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S976 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S976])->info_1.y;
    uint _S977 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S978;
    if(previous_1 == 0U)
    {
        _S978 = at_6;
    }
    else
    {
        _S978 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S977])->info_1)->y) = _S978;
    return;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S979;
    uint _S980;
    uint _S981;
    uint _S982;
    uint _S983;
    uint _S984;
    uint _S985;
    uint _S986 = __ballot_sync(4294967295U, true);
    uint tid_4 = threadIdx.x;
    uint _S987 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S987]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S988 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S989 = __ballot_sync(_S986, _S988);
    bool _S990;
    uint _S991;
    if(_S988)
    {
        bool _S992 = !driven_0;
        uint _S993 = __ballot_sync(_S986, true);
        _S990 = _S992;
        _S991 = _S993;
    }
    else
    {
        uint _S994 = __ballot_sync(_S986, true);
        _S990 = false;
        _S991 = _S994;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S995 = (((&isl_8)->info_1.x) & 16U) != 0U;
    bool _S996 = tid_4 == 0U;
    uint _S997 = __ballot_sync(_S991, _S996);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S996)
    {
        uint _S998 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S999 = contact_island_0 != (_S998 == 1U);
        uint _S1000 = __ballot_sync(_S997, _S999);
        if(_S999)
        {
            uint _S1001 = __ballot_sync(_S997, true);
            settled_0 = true;
            run_0 = _S1001;
        }
        else
        {
            bool _S1002 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1003 = __ballot_sync(_S997, true);
            settled_0 = _S1002;
            run_0 = _S1003;
        }
        uint _S1004 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1005 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1005;
        }
        else
        {
            uint _S1006 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1006;
        }
        uint _S1007 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1008 = isl_8;
            bool _S1009 = contact_stopped_0(&_S1008);
            uint _S1010 = __ballot_sync(done_1, true);
            settled_0 = _S1009;
            done_1 = _S1010;
        }
        else
        {
            uint _S1011 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1011;
        }
        uint _S1012 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1013 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1014 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1015 = __ballot_sync(_S991, true);
        _S991 = _S1015;
    }
    else
    {
        uint _S1016 = __ballot_sync(_S991, true);
        _S991 = _S1016;
    }
    __syncthreads();
    bool _S1017 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1018 = __ballot_sync(_S991, _S1017);
    if(_S1017)
    {
        uint _S1019 = __ballot_sync(_S991, true);
        settled_0 = true;
        _S991 = _S1019;
    }
    else
    {
        bool _S1020 = (*&g_run_0) == 0U;
        uint _S1021 = __ballot_sync(_S991, true);
        settled_0 = _S1020;
        _S991 = _S1021;
    }
    uint _S1022 = __ballot_sync(_S991, settled_0);
    if(settled_0)
    {
        uint _S1023 = __ballot_sync(_S991, true);
        _S991 = 0U;
        run_0 = _S1023;
    }
    else
    {
        uint _S1024 = (&isl_8)->info_1.y;
        uint _S1025 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1026 = (U32_min((_S1024), (_S1025)));
        uint _S1027 = __ballot_sync(_S991, true);
        _S991 = _S1026;
        run_0 = _S1027;
    }
    float _S1028 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1029 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1030 = _S1029 != 0U;
    uint _S1031 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1032 = _S1031 != 0U;
    Island_0 _S1033 = isl_8;
    Rigid_0 _S1034 = rigid_of_0(&_S1033);
    Rigid_0 rg_7 = _S1034;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S995;
    done_1 = 0U;
    bool woke_1 = false;
    uint s_5 = 0U;
    uint _S1035 = run_0;
    for(;;)
    {
        uint _S1036 = 0U;
        bool _S1037 = s_5 < _S991;
        uint _S1038 = __ballot_sync(_S1035, _S1037);
        if(_S1037)
        {
            uint _S1039 = __ballot_sync(_S1035, true);
            _S1036 = _S1039;
        }
        else
        {
            uint _S1040 = __ballot_sync(_S1035, false);
            uint _S1041 = __ballot_sync(_S1035, false);
            uint _S1042 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            _S991 = _S1042;
            break;
        }
        uint _S1043 = 0U;
        uint abs_step_1 = (&isl_8)->info_1.w + s_5 + 1U;
        uint _S1044 = abs_step_1 - 1U;
        uint _S1045 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1044 - _S1045;
        bool _S1046 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1047 = __ballot_sync(_S1036, _S1046);
        bool _S1048;
        bool settled_1;
        uint c_15;
        if(_S1046)
        {
            uint _S1049 = __ballot_sync(_S1047, _S996);
            if(_S996)
            {
                bool _S1050 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
                uint _S1051 = __ballot_sync(_S1047, true);
                _S1048 = _S1050;
                c_15 = _S1051;
            }
            else
            {
                uint _S1052 = __ballot_sync(_S1047, true);
                _S1048 = false;
                c_15 = _S1052;
            }
            uint _S1053 = __ballot_sync(c_15, _S1048);
            if(_S1048)
            {
                Island_0 _S1054 = isl_8;
                Rigid_0 _S1055 = rg_7;
                record_probes_0(&_S1054, &_S1055, k_18);
                uint _S1056 = __ballot_sync(c_15, true);
            }
            else
            {
                uint _S1057 = __ballot_sync(c_15, true);
            }
            uint _S1058 = s_5 + 1U;
            uint _S1059 = __ballot_sync(_S1036, false);
            uint _S1060 = __ballot_sync(_S1035, true);
            settled_1 = settled_0;
            done_1 = _S1058;
            woke_0 = woke_1;
            _S1035 = _S1060;
            uint _S1061 = s_5 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_5 = _S1061;
            continue;
        }
        else
        {
            uint _S1062 = __ballot_sync(_S1036, true);
            _S1043 = _S1062;
        }
        uint _S1063 = __ballot_sync(_S1043, settled_0);
        uint c_16;
        uint i_15;
        if(settled_0)
        {
            float3  _S1064 = make_float3 (0.0f);
            float3  norm_0 = _S1064;
            float3  unused0_0 = _S1064;
            c_15 = (&isl_8)->range_0.x + tid_4;
            c_16 = _S1063;
            for(;;)
            {
                bool _S1065 = c_15 < ((&isl_8)->range_0.y);
                uint _S1066 = __ballot_sync(c_16, _S1065);
                if(_S1065)
                {
                    uint _S1067 = __ballot_sync(c_16, true);
                }
                else
                {
                    uint _S1068 = __ballot_sync(c_16, false);
                    uint _S1069 = __ballot_sync(c_16, false);
                    uint _S1070 = __ballot_sync(_S1063, true);
                    _S979 = _S1070;
                    break;
                }
                Quat_0 _S1071 = (&rg_7)->rot_0;
                float _S1072 = settled_chunk_load_0(c_15, &_S1071, k_18, _S1028, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1072;
                uint _S1073 = __ballot_sync(c_16, true);
                c_15 = c_15 + 256U;
                c_16 = _S1073;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0, _S979);
            uint _S1074 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1075 = _S1074 == 1U;
            uint _S1076 = __ballot_sync(_S979, _S1075);
            if(_S1075)
            {
                bool _S1077 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1078 = __ballot_sync(_S979, true);
                _S1048 = _S1077;
                i_15 = _S1078;
            }
            else
            {
                uint _S1079 = __ballot_sync(_S979, true);
                _S1048 = false;
                i_15 = _S1079;
            }
            uint _S1080 = __ballot_sync(i_15, _S1048);
            if(_S1048)
            {
                uint _S1081 = __ballot_sync(i_15, true);
                settled_1 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1082 = __ballot_sync(i_15, true);
                settled_1 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1083 = __ballot_sync(_S1043, true);
            c_15 = _S1083;
        }
        else
        {
            uint _S1084 = __ballot_sync(_S1043, true);
            settled_1 = settled_0;
            woke_0 = woke_1;
            c_15 = _S1084;
        }
        uint _S1085 = __ballot_sync(c_15, _S988);
        if(_S988)
        {
            float3  _S1086 = make_float3 (0.0f);
            float3  f_15 = _S1086;
            float3  t_10 = _S1086;
            c_16 = (&isl_8)->range_0.x + tid_4;
            i_15 = _S1085;
            for(;;)
            {
                bool _S1087 = c_16 < ((&isl_8)->range_0.y);
                uint _S1088 = __ballot_sync(i_15, _S1087);
                if(_S1087)
                {
                    uint _S1089 = __ballot_sync(i_15, true);
                }
                else
                {
                    uint _S1090 = __ballot_sync(i_15, false);
                    uint _S1091 = __ballot_sync(i_15, false);
                    uint _S1092 = __ballot_sync(_S1085, true);
                    _S980 = _S1092;
                    break;
                }
                Island_0 _S1093 = isl_8;
                Rigid_0 _S1094 = rg_7;
                net_load_0(c_16, &_S1093, &_S1094, k_18, _S1028, contact_island_0, &f_15, &t_10);
                uint _S1095 = __ballot_sync(i_15, true);
                c_16 = c_16 + 256U;
                i_15 = _S1095;
            }
            group_sum3_0(tid_4, &f_15, &t_10, _S980);
            Island_0 _S1096 = isl_8;
            rigid_acceleration_0(&_S1096, &rg_7, f_15, t_10);
            uint _S1097 = __ballot_sync(c_15, true);
            c_16 = _S1097;
        }
        else
        {
            uint _S1098 = __ballot_sync(c_15, true);
            c_16 = _S1098;
        }
        uint _S1099 = 0U;
        uint _S1100 = __ballot_sync(c_16, settled_1);
        uint _S1101;
        if(settled_1)
        {
            uint _S1102 = __ballot_sync(_S1100, _S990);
            if(_S990)
            {
                Island_0 _S1103 = isl_8;
                integrate_rigid_0(&_S1103, &rg_7, _S1028);
                uint _S1104 = __ballot_sync(_S1100, true);
                i_15 = _S1104;
            }
            else
            {
                uint _S1105 = __ballot_sync(_S1100, true);
                i_15 = _S1105;
            }
            uint _S1106 = __ballot_sync(i_15, _S996);
            if(_S996)
            {
                bool _S1107 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
                uint _S1108 = __ballot_sync(i_15, true);
                _S1048 = _S1107;
                _S1101 = _S1108;
            }
            else
            {
                uint _S1109 = __ballot_sync(i_15, true);
                _S1048 = false;
                _S1101 = _S1109;
            }
            uint _S1110 = __ballot_sync(_S1101, _S1048);
            if(_S1048)
            {
                Island_0 _S1111 = isl_8;
                Rigid_0 _S1112 = rg_7;
                record_probes_0(&_S1111, &_S1112, k_18);
                uint _S1113 = __ballot_sync(_S1101, true);
            }
            else
            {
                uint _S1114 = __ballot_sync(_S1101, true);
            }
            uint _S1115 = s_5 + 1U;
            uint _S1116 = __ballot_sync(c_16, false);
            uint _S1117 = __ballot_sync(_S1035, true);
            done_1 = _S1115;
            _S1035 = _S1117;
            uint _S1061 = s_5 + 1U;
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_5 = _S1061;
            continue;
        }
        else
        {
            uint _S1118 = __ballot_sync(c_16, true);
            _S1099 = _S1118;
        }
        i_15 = (&isl_8)->range_0.z + tid_4;
        _S1101 = _S1099;
        for(;;)
        {
            uint _S1119 = 0U;
            bool _S1120 = i_15 < ((&isl_8)->range_0.w);
            uint _S1121 = __ballot_sync(_S1101, _S1120);
            if(_S1120)
            {
                uint _S1122 = __ballot_sync(_S1101, true);
                _S1119 = _S1122;
            }
            else
            {
                uint _S1123 = __ballot_sync(_S1101, false);
                uint _S1124 = __ballot_sync(_S1101, false);
                uint _S1125 = __ballot_sync(_S1099, true);
                _S981 = _S1125;
                break;
            }
            bool _S1126 = bond_update_0(i_15, _S1028, _S1030, abs_step_1);
            uint _S1127 = __ballot_sync(_S1119, _S1126);
            if(_S1126)
            {
                *&g_halt_0 = 1U;
                uint _S1128 = __ballot_sync(_S1119, true);
            }
            else
            {
                uint _S1129 = __ballot_sync(_S1119, true);
            }
            uint _S1130 = __ballot_sync(_S1101, true);
            i_15 = i_15 + 256U;
            _S1101 = _S1130;
        }
        __syncthreads();
        uint c_17 = (&isl_8)->range_0.x + tid_4;
        uint _S1131 = _S981;
        for(;;)
        {
            bool _S1132 = c_17 < ((&isl_8)->range_0.y);
            uint _S1133 = __ballot_sync(_S1131, _S1132);
            if(_S1132)
            {
                uint _S1134 = __ballot_sync(_S1131, true);
            }
            else
            {
                uint _S1135 = __ballot_sync(_S1131, false);
                uint _S1136 = __ballot_sync(_S1131, false);
                uint _S1137 = __ballot_sync(_S981, true);
                _S982 = _S1137;
                break;
            }
            Island_0 _S1138 = isl_8;
            Rigid_0 _S1139 = rg_7;
            chunk_update_0(c_17, &_S1138, &_S1139, _S1028, _S1032, k_18, contact_island_0, &work_2, &work_err_1);
            uint _S1140 = __ballot_sync(_S1131, true);
            c_17 = c_17 + 256U;
            _S1131 = _S1140;
        }
        __syncthreads();
        uint _S1141 = __ballot_sync(_S982, _S990);
        uint _S1142;
        if(_S990)
        {
            Island_0 _S1143 = isl_8;
            integrate_rigid_0(&_S1143, &rg_7, _S1028);
            uint _S1144 = __ballot_sync(_S982, true);
            _S1142 = _S1144;
        }
        else
        {
            uint _S1145 = __ballot_sync(_S982, true);
            _S1142 = _S1145;
        }
        uint _S1146 = __ballot_sync(_S1142, _S988);
        uint c_18;
        uint _S1147;
        uint c_19;
        if(_S988)
        {
            float4  _S1148 = (&isl_8)->wcom_0;
            float3  _S1149 = float3 {_S1148.x, _S1148.y, _S1148.z};
            float3  _S1150 = make_float3 (0.0f);
            float3  tu_1 = _S1150;
            float3  pv_1 = _S1150;
            c_18 = (&isl_8)->range_0.x + tid_4;
            _S1147 = _S1146;
            for(;;)
            {
                bool _S1151 = c_18 < ((&isl_8)->range_0.y);
                uint _S1152 = __ballot_sync(_S1147, _S1151);
                if(_S1151)
                {
                    uint _S1153 = __ballot_sync(_S1147, true);
                }
                else
                {
                    uint _S1154 = __ballot_sync(_S1147, false);
                    uint _S1155 = __ballot_sync(_S1147, false);
                    uint _S1156 = __ballot_sync(_S1146, true);
                    _S983 = _S1156;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1157 = __ballot_sync(_S1147, true);
                c_18 = c_18 + 256U;
                _S1147 = _S1157;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1, _S983);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1150;
            float3  lv_1 = _S1150;
            c_19 = (&isl_8)->range_0.x + tid_4;
            uint _S1158 = _S983;
            for(;;)
            {
                bool _S1159 = c_19 < ((&isl_8)->range_0.y);
                uint _S1160 = __ballot_sync(_S1158, _S1159);
                if(_S1159)
                {
                    uint _S1161 = __ballot_sync(_S1158, true);
                }
                else
                {
                    uint _S1162 = __ballot_sync(_S1158, false);
                    uint _S1163 = __ballot_sync(_S1158, false);
                    uint _S1164 = __ballot_sync(_S983, true);
                    _S984 = _S1164;
                    break;
                }
                drift_angular_0(c_19, _S1149, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1165 = __ballot_sync(_S1158, true);
                c_19 = c_19 + 256U;
                _S1158 = _S1165;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, _S984);
            float3  phi_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_4;
            uint _S1166 = _S984;
            for(;;)
            {
                bool _S1167 = c_20 < ((&isl_8)->range_0.y);
                uint _S1168 = __ballot_sync(_S1166, _S1167);
                if(_S1167)
                {
                    uint _S1169 = __ballot_sync(_S1166, true);
                }
                else
                {
                    uint _S1170 = __ballot_sync(_S1166, false);
                    uint _S1171 = __ballot_sync(_S1166, false);
                    uint _S1172 = __ballot_sync(_S984, true);
                    _S985 = _S1172;
                    break;
                }
                drift_apply_0(c_20, _S1149, tr_3, phi_2, dv_3, dw_2);
                uint _S1173 = __ballot_sync(_S1166, true);
                c_20 = c_20 + 256U;
                _S1166 = _S1173;
            }
            bool _S1174 = !driven_0;
            uint _S1175 = __ballot_sync(_S985, _S1174);
            if(_S1174)
            {
                Island_0 _S1176 = isl_8;
                drift_rigid_0(&_S1176, &rg_7, tr_3, phi_2, dv_3, dw_2);
                uint _S1177 = __ballot_sync(_S985, true);
            }
            else
            {
                uint _S1178 = __ballot_sync(_S985, true);
            }
            __syncthreads();
            uint _S1179 = __ballot_sync(_S1142, true);
            c_18 = _S1179;
        }
        else
        {
            uint _S1180 = __ballot_sync(_S1142, true);
            c_18 = _S1180;
        }
        uint _S1181 = __ballot_sync(c_18, _S996);
        if(_S996)
        {
            bool _S1182 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1183 = __ballot_sync(c_18, true);
            _S1048 = _S1182;
            _S1147 = _S1183;
        }
        else
        {
            uint _S1184 = __ballot_sync(c_18, true);
            _S1048 = false;
            _S1147 = _S1184;
        }
        uint _S1185 = __ballot_sync(_S1147, _S1048);
        if(_S1048)
        {
            Island_0 _S1186 = isl_8;
            Rigid_0 _S1187 = rg_7;
            record_probes_0(&_S1186, &_S1187, k_18);
            uint _S1188 = __ballot_sync(_S1147, true);
            c_19 = _S1188;
        }
        else
        {
            uint _S1189 = __ballot_sync(_S1147, true);
            c_19 = _S1189;
        }
        uint _S1190 = s_5 + 1U;
        bool _S1191 = (*&g_halt_0) != 0U;
        uint _S1192 = __ballot_sync(c_19, _S1191);
        if(_S1191)
        {
            uint _S1193 = __ballot_sync(c_19, false);
            uint _S1194 = __ballot_sync(_S1035, false);
            uint _S1195 = __ballot_sync(run_0, true);
            done_1 = _S1190;
            _S991 = _S1195;
            break;
        }
        else
        {
            uint _S1196 = __ballot_sync(c_19, true);
        }
        uint _S1197 = __ballot_sync(_S1035, true);
        done_1 = _S1190;
        _S1035 = _S1197;
        uint _S1061 = s_5 + 1U;
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_5 = _S1061;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_2 = make_float3 (0.0f);
    group_sum3_0(tid_4, &wsum_0, &unused_2, _S991);
    uint _S1198 = __ballot_sync(_S991, _S996);
    if(_S996)
    {
        Quat_0 _S1199 = (&rg_7)->rot_0;
        float4  _S1200 = quat_vec_0(&_S1199);
        (&isl_8)->rotation_0 = _S1200;
        (&isl_8)->position_0 = make_float4 ((&rg_7)->pos_1.x, (&rg_7)->pos_1.y, (&rg_7)->pos_1.z, 0.0f);
        (&isl_8)->position_err_0 = make_float4 ((&rg_7)->pos_err_1.x, (&rg_7)->pos_err_1.y, (&rg_7)->pos_err_1.z, 0.0f);
        (&isl_8)->velocity_0 = make_float4 ((&rg_7)->vel_1.x, (&rg_7)->vel_1.y, (&rg_7)->vel_1.z, 0.0f);
        (&isl_8)->velocity_err_0 = make_float4 ((&rg_7)->vel_err_1.x, (&rg_7)->vel_err_1.y, (&rg_7)->vel_err_1.z, 0.0f);
        (&isl_8)->angular_velocity_0 = make_float4 ((&rg_7)->w_4.x, (&rg_7)->w_4.y, (&rg_7)->w_4.z, 0.0f);
        *&((&(&isl_8)->done_0)->x) = done_1;
        *&((&(&isl_8)->info_1)->y) = *&((&(&isl_8)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S990 = contact_island_0;
        }
        else
        {
            _S990 = false;
        }
        if(_S990)
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
        *(&(globalParams_0->islands_0)[_S987]) = isl_8;
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
    uint _S1201 = table_0 + 4U * g_3;
    uint _S1202 = __ldg((&(globalParams_0->index_0)[_S1201]));
    (&w_8)->island_0 = _S1202;
    uint _S1203 = __ldg((&(globalParams_0->index_0)[_S1201 + 1U]));
    (&w_8)->begin_0 = _S1203;
    uint _S1204 = __ldg((&(globalParams_0->index_0)[_S1201 + 2U]));
    (&w_8)->end_0 = _S1204;
    uint _S1205 = __ldg((&(globalParams_0->index_0)[_S1201 + 3U]));
    (&w_8)->first_0 = _S1205;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1206 = isl_9->info_1;
    bool _S1207;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1207 = true;
    }
    else
    {
        _S1207 = (_S1206.y) == 0U;
    }
    if(_S1207)
    {
        return false;
    }
    if(((_S1206.x) & 4U) == 0U)
    {
        _S1207 = true;
    }
    else
    {
        bool _S1208 = contact_stopped_0(isl_9);
        _S1207 = !_S1208;
    }
    return _S1207;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_5, Island_0 * isl_10)
{
    if(tid_5 == 0U)
    {
        bool _S1209 = wide_runs_0(isl_10);
        int _S1210;
        if(_S1209)
        {
            _S1210 = int(1);
        }
        else
        {
            _S1210 = int(0);
        }
        *&g_wide_run_0 = uint(_S1210);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1211 = isl_11->info_1.w;
    uint _S1212 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1211 - _S1212;
}

static __device__ bool contact_stopped_1(uint _S1213)
{
    Island_0 * _S1214 = (&(globalParams_0->islands_0)[_S1213]);
    uint _S1215 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S1216 = (&(globalParams_0->islands_0)[_S1215])->info_1;
    bool _S1217;
    if((((&(globalParams_0->islands_0)[_S1215])->info_1.z) & 1U) != 0U)
    {
        _S1217 = true;
    }
    else
    {
        uint _S1218 = _S1216.y;
        if(_S1218 != 0U)
        {
            _S1217 = _S1218 <= (_S1214->info_1.w);
        }
        else
        {
            _S1217 = false;
        }
    }
    return _S1217;
}

static __device__ bool wide_runs_1(uint _S1219)
{
    uint4  _S1220 = (&(globalParams_0->islands_0)[_S1219])->info_1;
    bool _S1221;
    if((((&(globalParams_0->islands_0)[_S1219])->info_1.z) & 1U) != 0U)
    {
        _S1221 = true;
    }
    else
    {
        _S1221 = (_S1220.y) == 0U;
    }
    if(_S1221)
    {
        return false;
    }
    if(((_S1220.x) & 4U) == 0U)
    {
        _S1221 = true;
    }
    else
    {
        bool _S1222 = contact_stopped_1(_S1219);
        _S1221 = !_S1222;
    }
    return _S1221;
}

static __device__ bool wide_enter_1(uint _S1223, uint _S1224)
{
    if(_S1223 == 0U)
    {
        bool _S1225 = wide_runs_1(_S1224);
        int _S1226;
        if(_S1225)
        {
            _S1226 = int(1);
        }
        else
        {
            _S1226 = int(0);
        }
        *&g_wide_run_0 = uint(_S1226);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1227 = 0U;
    uint _S1228;
    uint _S1229 = __ballot_sync(4294967295U, true);
    uint tid_6 = threadIdx.x;
    uint _S1230 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1231 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1230, _S1231);
    bool _S1232 = _S1231 != (wg_0.first_0);
    uint _S1233 = __ballot_sync(_S1229, _S1232);
    if(_S1232)
    {
        return;
    }
    else
    {
        uint _S1234 = __ballot_sync(_S1229, true);
        _S1227 = _S1234;
    }
    Island_0 * _S1235 = (&(globalParams_0->islands_0)[wg_0.island_0]);
    Island_0 isl_12 = *_S1235;
    uint _S1236 = (*_S1235).info_1.x;
    bool _S1237 = (_S1236 & 16U) == 0U;
    uint _S1238 = __ballot_sync(_S1227, _S1237);
    bool _S1239;
    uint c_21;
    if(_S1237)
    {
        uint _S1240 = __ballot_sync(_S1227, true);
        _S1239 = true;
        c_21 = _S1240;
    }
    else
    {
        bool _S1241 = wide_enter_1(tid_6, wg_0.island_0);
        bool _S1242 = !_S1241;
        uint _S1243 = __ballot_sync(_S1227, true);
        _S1239 = _S1242;
        c_21 = _S1243;
    }
    uint _S1244 = 0U;
    uint _S1245 = __ballot_sync(c_21, _S1239);
    if(_S1239)
    {
        return;
    }
    else
    {
        uint _S1246 = __ballot_sync(c_21, true);
        _S1244 = _S1246;
    }
    Quat_0 _S1247 = quat_of_0(isl_12.rotation_0);
    bool _S1248 = (_S1236 & 4U) != 0U;
    float3  _S1249 = make_float3 (0.0f);
    float3  norm_1 = _S1249;
    float3  unused_3 = _S1249;
    c_21 = isl_12.range_0.x + tid_6;
    uint _S1250;
    _S1250 = _S1244;
    for(;;)
    {
        bool _S1251 = c_21 < (isl_12.range_0.y);
        uint _S1252 = __ballot_sync(_S1250, _S1251);
        if(_S1251)
        {
            uint _S1253 = __ballot_sync(_S1250, true);
        }
        else
        {
            uint _S1254 = __ballot_sync(_S1250, false);
            uint _S1255 = __ballot_sync(_S1250, false);
            uint _S1256 = __ballot_sync(_S1244, true);
            _S1228 = _S1256;
            break;
        }
        Island_0 _S1257 = isl_12;
        uint _S1258 = wide_step_0(&_S1257);
        float _S1259 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1260 = _S1247;
        float _S1261 = settled_chunk_load_0(c_21, &_S1260, _S1258, _S1259, _S1248);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1261;
        uint _S1262 = __ballot_sync(_S1250, true);
        c_21 = c_21 + 256U;
        _S1250 = _S1262;
    }
    group_sum3_0(tid_6, &norm_1, &unused_3, _S1228);
    bool _S1263 = tid_6 == 0U;
    uint _S1264 = __ballot_sync(_S1228, _S1263);
    if(_S1263)
    {
        uint _S1265 = __ldg(&globalParams_0->params_0->solve_mode_0);
        _S1239 = _S1265 == 1U;
    }
    else
    {
        _S1239 = false;
    }
    if(_S1239)
    {
        _S1239 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1239 = false;
    }
    if(_S1239)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_0])->info_1)->x) = _S1236 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_0])->info_1)->z) = (isl_12.info_1.z) | 4U;
    }
    return;
}

static __device__ void wide_store_0(uint slot_1, uint p_12, float3  a_14, float3  b_30)
{
    uint _S1266 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1267 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1266 + _S1267 + p_12]) = make_float4 (a_14.x, a_14.y, a_14.z, 0.0f);
    uint _S1268 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1268 + _S1267 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1269 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1270 = blockIdx.x;
    uint _S1271 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1270 < _S1271;
    uint _S1272 = __ballot_sync(_S1269, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1273;
    if(bond_group_0)
    {
        uint _S1274 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1275 = wide_group_0(_S1274, _S1270);
        uint _S1276 = __ballot_sync(_S1269, true);
        wg_1 = _S1275;
        _S1273 = _S1276;
    }
    else
    {
        uint _S1277 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1278 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1279 = wide_group_0(_S1277, _S1270 - _S1278);
        uint _S1280 = __ballot_sync(_S1269, true);
        wg_1 = _S1279;
        _S1273 = _S1280;
    }
    uint _S1281 = 0U;
    WideGroup_0 _S1282 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_0]);
    bool _S1283 = wide_enter_1(tid_7, wg_1.island_0);
    bool _S1284 = !_S1283;
    uint _S1285 = __ballot_sync(_S1273, _S1284);
    if(_S1284)
    {
        return;
    }
    else
    {
        uint _S1286 = __ballot_sync(_S1273, true);
        _S1281 = _S1286;
    }
    uint _S1287 = 0U;
    Island_0 _S1288 = isl_13;
    uint _S1289 = wide_step_0(&_S1288);
    uint _S1290 = __ballot_sync(_S1281, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_16 = wg_1.begin_0 + tid_7;
        bool _S1291;
        if(i_16 < (wg_1.end_0))
        {
            float _S1292 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1293 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1294 = bond_update_0(i_16, _S1292, _S1293 != 0U, isl_13.info_1.w + 1U);
            _S1291 = _S1294;
        }
        else
        {
            _S1291 = false;
        }
        if(_S1291)
        {
            *&((&(&(globalParams_0->islands_0)[_S1282.island_0])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1295 = __ballot_sync(_S1281, true);
        _S1287 = _S1295;
    }
    uint _S1296 = 0U;
    uint _S1297 = isl_13.info_1.x;
    bool _S1298 = (_S1297 & 1U) != 0U;
    uint _S1299 = __ballot_sync(_S1287, _S1298);
    if(_S1298)
    {
        return;
    }
    else
    {
        uint _S1300 = __ballot_sync(_S1287, true);
        _S1296 = _S1300;
    }
    float3  _S1301 = make_float3 (0.0f);
    float3  f_16 = _S1301;
    float3  t_11 = _S1301;
    uint c_22 = wg_1.begin_0 + tid_7;
    bool _S1302 = c_22 < (wg_1.end_0);
    uint _S1303 = __ballot_sync(_S1296, _S1302);
    if(_S1302)
    {
        Island_0 _S1304 = isl_13;
        Rigid_0 _S1305 = rigid_of_0(&_S1304);
        float _S1306 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1307 = (_S1297 & 4U) != 0U;
        Island_0 _S1308 = isl_13;
        Rigid_0 _S1309 = _S1305;
        net_load_0(c_22, &_S1308, &_S1309, _S1289, _S1306, _S1307, &f_16, &t_11);
        uint _S1310 = __ballot_sync(_S1296, true);
        _S1273 = _S1310;
    }
    else
    {
        uint _S1311 = __ballot_sync(_S1296, true);
        _S1273 = _S1311;
    }
    group_sum3_0(tid_7, &f_16, &t_11, _S1273);
    bool _S1312 = tid_7 == 0U;
    uint _S1313 = __ballot_sync(_S1273, _S1312);
    if(_S1312)
    {
        uint _S1314 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1270 - _S1314, 0U, f_16, t_11);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_8, uint first_1, uint count_5, uint p_13, float3  * a_15, float3  * b_31, uint _S1315)
{
    uint _S1316;
    float4  _S1317 = make_float4 (0.0f);
    float4  x_17 = _S1317;
    float4  y_5 = _S1317;
    uint s_6 = tid_8;
    uint _S1318 = _S1315;
    for(;;)
    {
        bool _S1319 = s_6 < count_5;
        uint _S1320 = __ballot_sync(_S1318, _S1319);
        if(_S1319)
        {
            uint _S1321 = __ballot_sync(_S1318, true);
        }
        else
        {
            uint _S1322 = __ballot_sync(_S1318, false);
            uint _S1323 = __ballot_sync(_S1318, false);
            uint _S1324 = __ballot_sync(_S1315, true);
            _S1316 = _S1324;
            break;
        }
        uint _S1325 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1326 = 8U * (first_1 + s_6);
        x_17 = x_17 + *(&(globalParams_0->scratch_0)[_S1325 + _S1326 + p_13]);
        uint _S1327 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1327 + _S1326 + p_13 + 1U]);
        uint _S1328 = __ballot_sync(_S1318, true);
        s_6 = s_6 + 256U;
        _S1318 = _S1328;
    }
    group_sum2_0(tid_8, &x_17, &y_5, _S1316);
    float4  _S1329 = x_17;
    *a_15 = float3 {_S1329.x, _S1329.y, _S1329.z};
    float4  _S1330 = y_5;
    *b_31 = float3 {_S1330.x, _S1330.y, _S1330.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_9, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1331)
{
    Rigid_0 _S1332 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1332;
    bool _S1333 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1334 = __ballot_sync(_S1331, _S1333);
    if(_S1333)
    {
        float3  f_17;
        float3  t_12;
        wide_partials_0(tid_9, wg_2->first_0, isl_14->done_0.z, 0U, &f_17, &t_12, _S1334);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_12);
        uint _S1335 = __ballot_sync(_S1331, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1336 = 0U;
    uint _S1337 = __ballot_sync(4294967295U, true);
    uint tid_10 = threadIdx.x;
    uint _S1338 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1339 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1338, _S1339);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_0]);
    bool _S1340 = wide_enter_1(tid_10, wg_3.island_0);
    bool _S1341 = !_S1340;
    uint _S1342 = __ballot_sync(_S1337, _S1341);
    if(_S1341)
    {
        return;
    }
    else
    {
        uint _S1343 = __ballot_sync(_S1337, true);
        _S1336 = _S1343;
    }
    uint _S1344 = 0U;
    uint _S1345 = isl_15.info_1.x;
    bool anchored_0 = (_S1345 & 1U) != 0U;
    bool _S1346 = (_S1345 & 16U) != 0U;
    uint _S1347 = __ballot_sync(_S1336, _S1346);
    if(_S1346)
    {
        if(tid_10 == 0U)
        {
            uint _S1348 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1348 + 8U * _S1339 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1349 = __ballot_sync(_S1336, true);
        _S1344 = _S1349;
    }
    Island_0 _S1350 = isl_15;
    WideGroup_0 _S1351 = wg_3;
    Rigid_0 _S1352 = wide_rigid_frame_0(tid_10, &_S1350, &_S1351, _S1344);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1353 = make_float3 (0.0f);
    float3  tu_2 = _S1353;
    float3  pv_2 = _S1353;
    uint c_23 = wg_3.begin_0 + tid_10;
    bool _S1354 = c_23 < (wg_3.end_0);
    uint _S1355 = __ballot_sync(_S1344, _S1354);
    uint _S1356;
    if(_S1354)
    {
        float _S1357 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1358 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1359 = _S1358 != 0U;
        Island_0 _S1360 = isl_15;
        uint _S1361 = wide_step_0(&_S1360);
        bool _S1362 = (_S1345 & 4U) != 0U;
        Island_0 _S1363 = isl_15;
        Rigid_0 _S1364 = _S1352;
        chunk_update_0(c_23, &_S1363, &_S1364, _S1357, _S1359, _S1361, _S1362, &work_3, &work_err_2);
        bool _S1365 = !anchored_0;
        uint _S1366 = __ballot_sync(_S1355, _S1365);
        if(_S1365)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1367 = __ballot_sync(_S1355, true);
        }
        else
        {
            uint _S1368 = __ballot_sync(_S1355, true);
        }
        uint _S1369 = __ballot_sync(_S1344, true);
        _S1356 = _S1369;
    }
    else
    {
        uint _S1370 = __ballot_sync(_S1344, true);
        _S1356 = _S1370;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_4 = _S1353;
    group_sum3_0(tid_10, &wsum_1, &unused_4, _S1356);
    bool _S1371 = !anchored_0;
    uint _S1372 = __ballot_sync(_S1356, _S1371);
    if(_S1371)
    {
        group_sum3_0(tid_10, &tu_2, &pv_2, _S1372);
        uint _S1373 = __ballot_sync(_S1356, true);
    }
    if(tid_10 == 0U)
    {
        uint _S1374 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1374 + 8U * _S1339 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1371)
        {
            wide_store_0(_S1339, 2U, tu_2, pv_2);
        }
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1375 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1376 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1377 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1376, _S1377);
    Island_0 * _S1378 = (&(globalParams_0->islands_0)[wg_4.island_0]);
    Island_0 isl_16 = *_S1378;
    bool _S1379 = (((*_S1378).info_1.x) & 17U) != 0U;
    uint _S1380 = __ballot_sync(_S1375, _S1379);
    bool _S1381;
    uint _S1382;
    if(_S1379)
    {
        uint _S1383 = __ballot_sync(_S1375, true);
        _S1381 = true;
        _S1382 = _S1383;
    }
    else
    {
        bool _S1384 = wide_enter_1(tid_11, wg_4.island_0);
        bool _S1385 = !_S1384;
        uint _S1386 = __ballot_sync(_S1375, true);
        _S1381 = _S1385;
        _S1382 = _S1386;
    }
    uint _S1387 = 0U;
    uint _S1388 = __ballot_sync(_S1382, _S1381);
    if(_S1381)
    {
        return;
    }
    else
    {
        uint _S1389 = __ballot_sync(_S1382, true);
        _S1387 = _S1389;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_11, wg_4.first_0, isl_16.done_0.z, 2U, &tu_3, &pv_3, _S1387);
    float _S1390 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1390);
    float3  dv_4 = pv_3 / make_float3 (_S1390);
    float3  _S1391 = make_float3 (0.0f);
    float3  lu_2 = _S1391;
    float3  lv_2 = _S1391;
    uint c_24 = wg_4.begin_0 + tid_11;
    bool _S1392 = c_24 < (wg_4.end_0);
    uint _S1393 = __ballot_sync(_S1387, _S1392);
    if(_S1392)
    {
        float4  _S1394 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1394.x, _S1394.y, _S1394.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1395 = __ballot_sync(_S1387, true);
        _S1382 = _S1395;
    }
    else
    {
        uint _S1396 = __ballot_sync(_S1387, true);
        _S1382 = _S1396;
    }
    group_sum3_0(tid_11, &lu_2, &lv_2, _S1382);
    bool _S1397 = tid_11 == 0U;
    uint _S1398 = __ballot_sync(_S1382, _S1397);
    if(_S1397)
    {
        wide_store_0(_S1377, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1399 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1400 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1401 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1400, _S1401);
    Island_0 * _S1402 = (&(globalParams_0->islands_0)[wg_5.island_0]);
    Island_0 isl_17 = *_S1402;
    uint _S1403 = (*_S1402).info_1.x;
    bool _S1404 = (_S1403 & 1U) != 0U;
    uint _S1405 = __ballot_sync(_S1399, _S1404);
    bool _S1406;
    uint _S1407;
    if(_S1404)
    {
        uint _S1408 = __ballot_sync(_S1399, true);
        _S1406 = true;
        _S1407 = _S1408;
    }
    else
    {
        bool _S1409 = wide_enter_1(tid_12, wg_5.island_0);
        bool _S1410 = !_S1409;
        uint _S1411 = __ballot_sync(_S1399, true);
        _S1406 = _S1410;
        _S1407 = _S1411;
    }
    uint _S1412 = 0U;
    uint _S1413 = __ballot_sync(_S1407, _S1406);
    if(_S1406)
    {
        return;
    }
    else
    {
        uint _S1414 = __ballot_sync(_S1407, true);
        _S1412 = _S1414;
    }
    uint _S1415 = 0U;
    bool _S1416 = (_S1403 & 16U) != 0U;
    uint _S1417 = __ballot_sync(_S1412, _S1416);
    if(_S1416)
    {
        uint _S1418 = 0U;
        bool _S1419 = _S1401 != (wg_5.first_0);
        uint _S1420 = __ballot_sync(_S1417, _S1419);
        if(_S1419)
        {
            return;
        }
        else
        {
            uint _S1421 = __ballot_sync(_S1417, true);
            _S1418 = _S1421;
        }
        Island_0 _S1422 = isl_17;
        WideGroup_0 _S1423 = wg_5;
        Rigid_0 _S1424 = wide_rigid_frame_0(tid_12, &_S1422, &_S1423, _S1418);
        Rigid_0 rs_0 = _S1424;
        bool _S1425 = tid_12 != 0U;
        uint _S1426 = __ballot_sync(_S1418, _S1425);
        if(_S1425)
        {
            _S1406 = true;
        }
        else
        {
            _S1406 = (_S1403 & 2U) != 0U;
        }
        if(_S1406)
        {
            return;
        }
        float _S1427 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1428 = isl_17;
        integrate_rigid_0(&_S1428, &rs_0, _S1427);
        Quat_0 _S1429 = (&rs_0)->rot_0;
        float4  _S1430 = quat_vec_0(&_S1429);
        (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_0 = _S1430;
        (&(globalParams_0->islands_0)[wg_5.island_0])->position_0 = make_float4 ((&rs_0)->pos_1.x, (&rs_0)->pos_1.y, (&rs_0)->pos_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->position_err_0 = make_float4 ((&rs_0)->pos_err_1.x, (&rs_0)->pos_err_1.y, (&rs_0)->pos_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_0 = make_float4 ((&rs_0)->vel_1.x, (&rs_0)->vel_1.y, (&rs_0)->vel_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_1.x, (&rs_0)->vel_err_1.y, (&rs_0)->vel_err_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_5.island_0])->angular_velocity_0 = make_float4 ((&rs_0)->w_4.x, (&rs_0)->w_4.y, (&rs_0)->w_4.z, 0.0f);
        return;
    }
    else
    {
        uint _S1431 = __ballot_sync(_S1412, true);
        _S1415 = _S1431;
    }
    uint _S1432 = isl_17.done_0.z;
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_12, wg_5.first_0, _S1432, 2U, &tu_4, &pv_4, _S1415);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_12, wg_5.first_0, _S1432, 4U, &lu_3, &lv_3, _S1415);
    float _S1433 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1433);
    float3  dv_5 = pv_4 / make_float3 (_S1433);
    float3  phi_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_12;
    bool _S1434 = c_25 < (wg_5.end_0);
    uint _S1435 = __ballot_sync(_S1415, _S1434);
    if(_S1434)
    {
        float4  _S1436 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1436.x, _S1436.y, _S1436.z}, tr_5, phi_3, dv_5, dw_3);
        uint _S1437 = __ballot_sync(_S1415, true);
        _S1407 = _S1437;
    }
    else
    {
        uint _S1438 = __ballot_sync(_S1415, true);
        _S1407 = _S1438;
    }
    uint _S1439 = 0U;
    bool _S1440 = _S1401 != (wg_5.first_0);
    uint _S1441 = __ballot_sync(_S1407, _S1440);
    if(_S1440)
    {
        return;
    }
    else
    {
        uint _S1442 = __ballot_sync(_S1407, true);
        _S1439 = _S1442;
    }
    Island_0 _S1443 = isl_17;
    WideGroup_0 _S1444 = wg_5;
    Rigid_0 _S1445 = wide_rigid_frame_0(tid_12, &_S1443, &_S1444, _S1439);
    Rigid_0 rg_9 = _S1445;
    bool _S1446 = tid_12 != 0U;
    uint _S1447 = __ballot_sync(_S1439, _S1446);
    if(_S1446)
    {
        return;
    }
    if(!((_S1403 & 2U) != 0U))
    {
        float _S1448 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1449 = isl_17;
        integrate_rigid_0(&_S1449, &rg_9, _S1448);
        Island_0 _S1450 = isl_17;
        drift_rigid_0(&_S1450, &rg_9, tr_5, phi_3, dv_5, dw_3);
    }
    Quat_0 _S1451 = (&rg_9)->rot_0;
    float4  _S1452 = quat_vec_0(&_S1451);
    (&(globalParams_0->islands_0)[wg_5.island_0])->rotation_0 = _S1452;
    (&(globalParams_0->islands_0)[wg_5.island_0])->position_0 = make_float4 ((&rg_9)->pos_1.x, (&rg_9)->pos_1.y, (&rg_9)->pos_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->position_err_0 = make_float4 ((&rg_9)->pos_err_1.x, (&rg_9)->pos_err_1.y, (&rg_9)->pos_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_0 = make_float4 ((&rg_9)->vel_1.x, (&rg_9)->vel_1.y, (&rg_9)->vel_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->velocity_err_0 = make_float4 ((&rg_9)->vel_err_1.x, (&rg_9)->vel_err_1.y, (&rg_9)->vel_err_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_5.island_0])->angular_velocity_0 = make_float4 ((&rg_9)->w_4.x, (&rg_9)->w_4.y, (&rg_9)->w_4.z, 0.0f);
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S1453 = 0U;
    uint _S1454 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1455 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1456 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1455, _S1456);
    bool _S1457 = _S1456 != (wg_6.first_0);
    uint _S1458 = __ballot_sync(_S1454, _S1457);
    if(_S1457)
    {
        return;
    }
    else
    {
        uint _S1459 = __ballot_sync(_S1454, true);
        _S1453 = _S1459;
    }
    uint _S1460 = 0U;
    Island_0 * _S1461 = (&(globalParams_0->islands_0)[wg_6.island_0]);
    Island_0 isl_18 = *_S1461;
    Island_0 _S1462 = *_S1461;
    bool _S1463 = wide_enter_0(tid_13, &_S1462);
    bool _S1464 = !_S1463;
    uint _S1465 = __ballot_sync(_S1453, _S1464);
    if(_S1464)
    {
        return;
    }
    else
    {
        uint _S1466 = __ballot_sync(_S1453, true);
        _S1460 = _S1466;
    }
    float3  work_4;
    float3  unused_5;
    wide_partials_0(tid_13, wg_6.first_0, (&isl_18)->done_0.z, 6U, &work_4, &unused_5, _S1460);
    bool _S1467 = tid_13 != 0U;
    uint _S1468 = __ballot_sync(_S1460, _S1467);
    if(_S1467)
    {
        return;
    }
    Island_0 _S1469 = isl_18;
    uint _S1470 = wide_step_0(&_S1469);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1471 = isl_18;
        Rigid_0 _S1472 = rigid_of_0(&_S1471);
        Island_0 _S1473 = isl_18;
        Rigid_0 _S1474 = _S1472;
        record_probes_0(&_S1473, &_S1474, _S1470);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1475;
    if(halt_0)
    {
        _S1475 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1475 = false;
    }
    if(_S1475)
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
    uint _S1476 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1476 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_14, Island_0 * isl_19, uint slot_3, uint _S1477)
{
    uint _S1478;
    uint _S1479;
    float3  _S1480 = make_float3 (0.0f);
    float3  net_f_0 = _S1480;
    float3  net_m_0 = _S1480;
    uint4  _S1481 = isl_19->range_0;
    uint _S1482 = isl_19->range_0.x + tid_14;
    uint c_27 = _S1482;
    uint _S1483 = _S1477;
    for(;;)
    {
        uint _S1484 = _S1481.y;
        _S1478 = _S1484;
        bool _S1485 = c_27 < _S1484;
        uint _S1486 = __ballot_sync(_S1483, _S1485);
        if(_S1485)
        {
            uint _S1487 = __ballot_sync(_S1483, true);
        }
        else
        {
            uint _S1488 = __ballot_sync(_S1483, false);
            uint _S1489 = __ballot_sync(_S1483, false);
            uint _S1490 = __ballot_sync(_S1477, true);
            _S1479 = _S1490;
            break;
        }
        float4  _S1491 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1491.x, _S1491.y, _S1491.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1492 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1493 = isl_19->com_0;
        float4  _S1494 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1492.x, _S1492.y, _S1492.z} - float3 {_S1493.x, _S1493.y, _S1493.z}, fi_1) + float3 {_S1494.x, _S1494.y, _S1494.z});
        uint _S1495 = __ballot_sync(_S1483, true);
        c_27 = c_27 + 256U;
        _S1483 = _S1495;
    }
    group_sum3_0(tid_14, &net_f_0, &net_m_0, _S1479);
    float4  _S1496 = isl_19->com_0;
    float3  _S1497 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1498 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1482;
    for(;;)
    {
        if(c_27 < _S1478)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1499 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1500 = __ldg(&_S1499->center_0);
        uint _S1501 = sv_0(c_27, slot_3);
        float4  _S1502 = *(&(globalParams_0->scratch_0)[_S1501]);
        *(&(globalParams_0->scratch_0)[_S1501]) = make_float4 ((float3 {_S1502.x, _S1502.y, _S1502.z} - (_S1497 + cross_0(_S1498, float3 {_S1500.x, _S1500.y, _S1500.z} - float3 {_S1496.x, _S1496.y, _S1496.z})) * make_float3 (_S1500.w)).x, (float3 {_S1502.x, _S1502.y, _S1502.z} - (_S1497 + cross_0(_S1498, float3 {_S1500.x, _S1500.y, _S1500.z} - float3 {_S1496.x, _S1496.y, _S1496.z})) * make_float3 (_S1500.w)).y, (float3 {_S1502.x, _S1502.y, _S1502.z} - (_S1497 + cross_0(_S1498, float3 {_S1500.x, _S1500.y, _S1500.z} - float3 {_S1496.x, _S1496.y, _S1496.z})) * make_float3 (_S1500.w)).z, 0.0f);
        uint _S1503 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1504 = (&(globalParams_0->scratch_0)[_S1503]);
        float4  _S1505 = *(&(globalParams_0->scratch_0)[_S1503]);
        float3  _S1506 = float3 {_S1505.x, _S1505.y, _S1505.z};
        float4  _S1507 = __ldg(&_S1499->inertia0_0);
        float4  _S1508 = __ldg(&_S1499->inertia1_0);
        float4  _S1509 = __ldg(&_S1499->inertia2_0);
        *_S1504 = make_float4 ((_S1506 - rows_mul_0(_S1507, _S1508, _S1509, _S1498)).x, (_S1506 - rows_mul_0(_S1507, _S1508, _S1509, _S1498)).y, (_S1506 - rows_mul_0(_S1507, _S1508, _S1509, _S1498)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_15, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1510)
{
    uint _S1511;
    float4  _S1512 = make_float4 (0.0f);
    float4  acc_0 = _S1512;
    float4  unused_6 = _S1512;
    uint c_28 = c0_0 + tid_15;
    uint _S1513 = _S1510;
    for(;;)
    {
        bool _S1514 = c_28 < c1_0;
        uint _S1515 = __ballot_sync(_S1513, _S1514);
        if(_S1514)
        {
            uint _S1516 = __ballot_sync(_S1513, true);
        }
        else
        {
            uint _S1517 = __ballot_sync(_S1513, false);
            uint _S1518 = __ballot_sync(_S1513, false);
            uint _S1519 = __ballot_sync(_S1510, true);
            _S1511 = _S1519;
            break;
        }
        float4  _S1520 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1521 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1522 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1523 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1520.x, _S1520.y, _S1520.z}, float3 {_S1521.x, _S1521.y, _S1521.z}) + dot_0(float3 {_S1522.x, _S1522.y, _S1522.z}, float3 {_S1523.x, _S1523.y, _S1523.z}));
        uint _S1524 = __ballot_sync(_S1513, true);
        c_28 = c_28 + 256U;
        _S1513 = _S1524;
    }
    group_sum2_0(tid_15, &acc_0, &unused_6, _S1511);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1525, float3  * _S1526, float3  * _S1527)
{
    BondStatic_0 * _S1528 = (&(globalParams_0->bonds_0)[_S1525]);
    JointBond_0 _S1529 = slang_ldg_0(&_S1528->law_0);
    uint ca_1 = _S1529.ids_0.y;
    uint cb_1 = _S1529.ids_0.z;
    uint _S1530 = 4U * cb_1;
    float4  _S1531 = *(&(globalParams_0->state_0)[_S1530]);
    uint _S1532 = 4U * ca_1;
    float4  _S1533 = *(&(globalParams_0->state_0)[_S1532]);
    float4  _S1534 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1535 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1531.x, _S1531.y, _S1531.z} - float3 {_S1533.x, _S1533.y, _S1533.z} + (float3 {_S1534.x, _S1534.y, _S1534.z} - float3 {_S1535.x, _S1535.y, _S1535.z});
    uint _S1536 = _S1530 + 1U;
    float4  _S1537 = *(&(globalParams_0->state_0)[_S1536]);
    uint _S1538 = _S1532 + 1U;
    float4  _S1539 = *(&(globalParams_0->state_0)[_S1538]);
    uint _S1540 = sv_0(cb_1, 22U);
    float4  _S1541 = *(&(globalParams_0->scratch_0)[_S1540]);
    uint _S1542 = sv_0(ca_1, 22U);
    float4  _S1543 = *(&(globalParams_0->scratch_0)[_S1542]);
    float3  dth_0 = float3 {_S1537.x, _S1537.y, _S1537.z} - float3 {_S1539.x, _S1539.y, _S1539.z} + (float3 {_S1541.x, _S1541.y, _S1541.z} - float3 {_S1543.x, _S1543.y, _S1543.z});
    float4  _S1544 = *(&(globalParams_0->state_0)[_S1538]);
    float4  _S1545 = *(&(globalParams_0->scratch_0)[_S1542]);
    float3  ta_3 = float3 {_S1544.x, _S1544.y, _S1544.z} + float3 {_S1545.x, _S1545.y, _S1545.z};
    float4  _S1546 = *(&(globalParams_0->state_0)[_S1536]);
    float4  _S1547 = *(&(globalParams_0->scratch_0)[_S1540]);
    float3  tb_3 = float3 {_S1546.x, _S1546.y, _S1546.z} + float3 {_S1547.x, _S1547.y, _S1547.z};
    float4  _S1548 = __ldg(&_S1528->rb_0);
    float3  _S1549 = cross_0(tb_3, float3 {_S1548.x, _S1548.y, _S1548.z});
    float4  _S1550 = __ldg(&_S1528->ra_0);
    float3  _S1551 = to_local_0(_S1525, du_0 + (_S1549 - cross_0(ta_3, float3 {_S1550.x, _S1550.y, _S1550.z})));
    *_S1526 = _S1551;
    float3  _S1552 = to_local_0(_S1525, dth_0);
    *_S1527 = _S1552;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_17)
{
    BondStatic_0 * _S1553 = (&(globalParams_0->bonds_0)[i_17]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_17, &d_lin_4, &d_ang_3);
    JointBond_0 _S1554 = slang_ldg_0(&_S1553->law_0);
    JointBond_0 _S1555 = _S1554;
    JointState_0 _S1556 = (&(globalParams_0->bond_dyn_0)[i_17])->js_0;
    JointResponse_0 _S1557 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1554.ids_0.x], &_S1555, &_S1556, d_lin_4, d_ang_3, 0.0f, false);
    return _S1557;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1558 = make_float3 (0.0f);
    *fi_2 = _S1558;
    *mi_3 = _S1558;
    uint _S1559 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1559;
    for(;;)
    {
        uint _S1560 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1560)
        {
        }
        else
        {
            break;
        }
        uint _S1561 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1561 >> int(1);
        if((_S1561 & 1U) == 0U)
        {
            uint _S1562 = 3U * bond_0;
            float4  _S1563 = *(&(globalParams_0->scratch_0)[_S1562]);
            *fi_2 = *fi_2 + float3 {_S1563.x, _S1563.y, _S1563.z};
            float4  _S1564 = *(&(globalParams_0->scratch_0)[_S1562 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1564.x, _S1564.y, _S1564.z};
        }
        else
        {
            uint _S1565 = 3U * bond_0;
            float4  _S1566 = *(&(globalParams_0->scratch_0)[_S1565]);
            *fi_2 = *fi_2 - float3 {_S1566.x, _S1566.y, _S1566.z};
            float4  _S1567 = *(&(globalParams_0->scratch_0)[_S1565 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1567.x, _S1567.y, _S1567.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1568 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1568;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1569 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1569)
        {
        }
        else
        {
            break;
        }
        uint _S1570 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1571 = 3U * (_S1570 >> int(1));
        float4  _S1572 = *(&(globalParams_0->scratch_0)[_S1571]);
        float3  f_18 = float3 {_S1572.x, _S1572.y, _S1572.z};
        float3  t_13;
        if((_S1570 & 1U) == 0U)
        {
            float4  _S1573 = *(&(globalParams_0->scratch_0)[_S1571 + 1U]);
            t_13 = float3 {_S1573.x, _S1573.y, _S1573.z};
        }
        else
        {
            float4  _S1574 = *(&(globalParams_0->scratch_0)[_S1571 + 2U]);
            t_13 = float3 {_S1574.x, _S1574.y, _S1574.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_13, t_13));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1575 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1575.x;
    uint _S1576;
    if(support_1 == 1U)
    {
        _S1576 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1576 = 7U;
        }
        else
        {
            _S1576 = 0U;
        }
    }
    return _S1576;
}

static __device__ void hold_0(uint mask_0, float4  * lin_0, float4  * ang_0, float4  keep_lin_0, float4  keep_ang_0)
{
    uint d_10 = 0U;
    for(;;)
    {
        if(d_10 < 3U)
        {
        }
        else
        {
            break;
        }
        if((mask_0 & (1U << d_10)) != 0U)
        {
            *_slang_vector_get_element_ptr(lin_0, d_10) = _slang_vector_get_element(keep_lin_0, d_10);
        }
        if((mask_0 & (1U << (d_10 + 3U))) != 0U)
        {
            *_slang_vector_get_element_ptr(ang_0, d_10) = _slang_vector_get_element(keep_ang_0, d_10);
        }
        d_10 = d_10 + 1U;
    }
    return;
}

static __device__ uint statics_bond_slot_0(uint i_18)
{
    uint _S1577 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1578 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1577 + 23U * _S1578 + 2U * i_18;
}

static __device__ void store_inverse_0(uint c_32, FixedArray<float, 36>  * a_16)
{
    uint j_6;
    float sum_2;
    FixedArray<float, 36>  l_3;
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
        l_3[k_19] = 0.0f;
        k_19 = k_19 + 1U;
    }
    bool spd_0 = true;
    uint i_19 = 0U;
    for(;;)
    {
        bool _S1579;
        if(i_19 < 6U)
        {
            _S1579 = spd_0;
        }
        else
        {
            _S1579 = false;
        }
        if(_S1579)
        {
        }
        else
        {
            break;
        }
        j_6 = 0U;
        for(;;)
        {
            if(j_6 <= i_19)
            {
            }
            else
            {
                break;
            }
            uint _S1580 = i_19 * 6U;
            uint _S1581 = _S1580 + j_6;
            k_19 = 0U;
            sum_2 = (*a_16)[_S1581];
            for(;;)
            {
                if(k_19 < j_6)
                {
                }
                else
                {
                    break;
                }
                float sum_3 = sum_2 - l_3[_S1580 + k_19] * l_3[j_6 * 6U + k_19];
                k_19 = k_19 + 1U;
                sum_2 = sum_3;
            }
            if(i_19 == j_6)
            {
                if(sum_2 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_3[_S1580 + i_19] = (F32_sqrt((sum_2)));
            }
            else
            {
                l_3[_S1581] = sum_2 / l_3[j_6 * 6U + j_6];
            }
            j_6 = j_6 + 1U;
        }
        i_19 = i_19 + 1U;
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
            uint _S1582 = k_19 * 6U + k_19;
            float _S1583 = (*a_16)[_S1582];
            if(((*a_16)[_S1582]) > 0.0f)
            {
                sum_2 = 1.0f / _S1583;
            }
            else
            {
                sum_2 = 0.0f;
            }
            inv_0[_S1582] = sum_2;
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
            i_19 = 0U;
            for(;;)
            {
                if(i_19 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_19 == j_6)
                {
                    sum_2 = 1.0f;
                }
                else
                {
                    sum_2 = 0.0f;
                }
                k_19 = 0U;
                float s_7 = sum_2;
                for(;;)
                {
                    if(k_19 < i_19)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = s_7 - l_3[i_19 * 6U + k_19] * y_6[k_19];
                    k_19 = k_19 + 1U;
                    s_7 = s_8;
                }
                y_6[i_19] = s_7 / l_3[i_19 * 6U + i_19];
                i_19 = i_19 + 1U;
            }
            FixedArray<float, 6>  x_18;
            x_18[int(0)] = 0.0f;
            x_18[int(1)] = 0.0f;
            x_18[int(2)] = 0.0f;
            x_18[int(3)] = 0.0f;
            x_18[int(4)] = 0.0f;
            x_18[int(5)] = 0.0f;
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
                uint i_20 = 5U - ii_2;
                k_19 = i_20 + 1U;
                sum_2 = y_6[i_20];
                for(;;)
                {
                    if(k_19 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_9 = sum_2 - l_3[k_19 * 6U + i_20] * x_18[k_19];
                    k_19 = k_19 + 1U;
                    sum_2 = s_9;
                }
                x_18[i_20] = sum_2 / l_3[i_20 * 6U + i_20];
                ii_2 = ii_2 + 1U;
            }
            uint i_21 = 0U;
            for(;;)
            {
                if(i_21 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_21 * 6U + j_6] = x_18[i_21];
                i_21 = i_21 + 1U;
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
        uint _S1584 = 4U * j_6;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_6)]) = make_float4 (inv_0[_S1584], inv_0[_S1584 + 1U], inv_0[_S1584 + 2U], inv_0[_S1584 + 3U]);
        j_6 = j_6 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_33)
{
    uint p_14;
    uint r_12;
    FixedArray<float, 36>  a_17;
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
        a_17[k_20] = 0.0f;
        k_20 = k_20 + 1U;
    }
    uint _S1585 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1585;
    for(;;)
    {
        uint _S1586 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1586)
        {
        }
        else
        {
            break;
        }
        uint _S1587 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_22 = _S1587 >> int(1);
        bool _S1588 = (_S1587 & 1U) != 0U;
        BondStatic_0 * _S1589 = (&(globalParams_0->bonds_0)[i_22]);
        uint _S1590 = statics_bond_slot_0(i_22);
        float4  _S1591 = *(&(globalParams_0->scratch_0)[_S1590]);
        float4  _S1592 = *(&(globalParams_0->scratch_0)[_S1590 + 1U]);
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
            uint _S1593 = p_14 % 3U;
            float3  t_14;
            if(_S1593 == 0U)
            {
                float4  _S1594 = __ldg(&_S1589->t1_0);
                t_14 = float3 {_S1594.x, _S1594.y, _S1594.z};
            }
            else
            {
                if(_S1593 == 1U)
                {
                    float4  _S1595 = __ldg(&_S1589->t2_0);
                    t_14 = float3 {_S1595.x, _S1595.y, _S1595.z};
                }
                else
                {
                    float4  _S1596 = __ldg(&_S1589->normal_0);
                    t_14 = float3 {_S1596.x, _S1596.y, _S1596.z};
                }
            }
            bool _S1597 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1597)
            {
                if(_S1588)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                if(_S1588)
                {
                    float4  _S1598 = __ldg(&_S1589->rb_0);
                    row_t_0 = cross_0(float3 {_S1598.x, _S1598.y, _S1598.z}, t_14);
                }
                else
                {
                    float4  _S1599 = __ldg(&_S1589->ra_0);
                    row_t_0 = - cross_0(float3 {_S1599.x, _S1599.y, _S1599.z}, t_14);
                }
            }
            else
            {
                float3  _S1600 = make_float3 (0.0f);
                if(_S1588)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                float3  _S1601 = row_u_0;
                row_u_0 = _S1600;
                row_t_0 = _S1601;
            }
            float kp_0;
            if(_S1597)
            {
                kp_0 = _slang_vector_get_element(_S1591, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1592, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1602 = { {
                row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z
            } };
            r_12 = 0U;
            for(;;)
            {
                if(r_12 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint q_15 = 0U;
                for(;;)
                {
                    if(q_15 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_17[r_12 * 6U + q_15] = a_17[r_12 * 6U + q_15] + kp_0 * _S1602[r_12] * _S1602[q_15];
                    q_15 = q_15 + 1U;
                }
                r_12 = r_12 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1603 = fixed_mask_0(c_33);
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
        if((_S1603 & (1U << p_14)) != 0U)
        {
            r_12 = 0U;
            for(;;)
            {
                if(r_12 < 6U)
                {
                }
                else
                {
                    break;
                }
                a_17[p_14 * 6U + r_12] = 0.0f;
                a_17[r_12 * 6U + p_14] = 0.0f;
                r_12 = r_12 + 1U;
            }
            a_17[p_14 * 6U + p_14] = 1.0f;
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
        if((a_17[p_14 * 6U + p_14]) == 0.0f)
        {
            a_17[p_14 * 6U + p_14] = 1.0f;
        }
        p_14 = p_14 + 1U;
    }
    FixedArray<float, 36>  _S1604 = a_17;
    store_inverse_0(c_33, &_S1604);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_23, uint j_7)
{
    uint k_21 = i_23 * 6U + j_7;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1605 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1606 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1607 = { {
        (*_S1605).x, (*_S1605).y, (*_S1605).z, (*_S1606).x, (*_S1606).y, (*_S1606).z
    } };
    FixedArray<float, 6>  z_1;
    uint i_24 = 0U;
    for(;;)
    {
        if(i_24 < 6U)
        {
        }
        else
        {
            break;
        }
        uint j_8 = 0U;
        float s_10 = 0.0f;
        for(;;)
        {
            if(j_8 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_11 = s_10 + block_get_0(c_35, i_24, j_8) * _S1607[j_8];
            j_8 = j_8 + 1U;
            s_10 = s_11;
        }
        z_1[i_24] = s_10;
        i_24 = i_24 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_16, Island_0 * isl_20, uint slot_4, uint _S1608)
{
    uint _S1609;
    uint _S1610;
    float3  _S1611 = make_float3 (0.0f);
    float3  p_15 = _S1611;
    float3  l_4 = _S1611;
    uint4  _S1612 = isl_20->range_0;
    uint _S1613 = isl_20->range_0.x + tid_16;
    uint c_36 = _S1613;
    uint _S1614 = _S1608;
    for(;;)
    {
        uint _S1615 = _S1612.y;
        _S1609 = _S1615;
        bool _S1616 = c_36 < _S1615;
        uint _S1617 = __ballot_sync(_S1614, _S1616);
        if(_S1616)
        {
            uint _S1618 = __ballot_sync(_S1614, true);
        }
        else
        {
            uint _S1619 = __ballot_sync(_S1614, false);
            uint _S1620 = __ballot_sync(_S1614, false);
            uint _S1621 = __ballot_sync(_S1608, true);
            _S1610 = _S1621;
            break;
        }
        ChunkStatic_0 * _S1622 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1623 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1623.x, _S1623.y, _S1623.z};
        float4  _S1624 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_4 = float3 {_S1624.x, _S1624.y, _S1624.z};
        float4  _S1625 = __ldg(&_S1622->center_0);
        float4  _S1626 = isl_20->com_0;
        float3  r_13 = float3 {_S1625.x, _S1625.y, _S1625.z} - float3 {_S1626.x, _S1626.y, _S1626.z};
        float _S1627 = _S1625.w;
        p_15 = p_15 + u_3 * make_float3 (_S1627);
        float3  _S1628 = cross_0(r_13, u_3) * make_float3 (_S1627);
        float4  _S1629 = __ldg(&_S1622->inertia0_0);
        float4  _S1630 = __ldg(&_S1622->inertia1_0);
        float4  _S1631 = __ldg(&_S1622->inertia2_0);
        l_4 = l_4 + (_S1628 + rows_mul_0(_S1629, _S1630, _S1631, th_4));
        uint _S1632 = __ballot_sync(_S1614, true);
        c_36 = c_36 + 256U;
        _S1614 = _S1632;
    }
    group_sum3_0(tid_16, &p_15, &l_4, _S1610);
    float4  _S1633 = isl_20->com_0;
    float3  _S1634 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1635 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_4);
    c_36 = _S1613;
    for(;;)
    {
        if(c_36 < _S1609)
        {
        }
        else
        {
            break;
        }
        float4  _S1636 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1637 = sv_0(c_36, slot_4);
        float4  _S1638 = *(&(globalParams_0->scratch_0)[_S1637]);
        *(&(globalParams_0->scratch_0)[_S1637]) = make_float4 ((float3 {_S1638.x, _S1638.y, _S1638.z} - _S1634 - cross_0(_S1635, float3 {_S1636.x, _S1636.y, _S1636.z} - float3 {_S1633.x, _S1633.y, _S1633.z})).x, (float3 {_S1638.x, _S1638.y, _S1638.z} - _S1634 - cross_0(_S1635, float3 {_S1636.x, _S1636.y, _S1636.z} - float3 {_S1633.x, _S1633.y, _S1633.z})).y, (float3 {_S1638.x, _S1638.y, _S1638.z} - _S1634 - cross_0(_S1635, float3 {_S1636.x, _S1636.y, _S1636.z} - float3 {_S1633.x, _S1633.y, _S1633.z})).z, 0.0f);
        uint _S1639 = sv_0(c_36, slot_4 + 1U);
        float4  _S1640 = *(&(globalParams_0->scratch_0)[_S1639]);
        *(&(globalParams_0->scratch_0)[_S1639]) = make_float4 ((float3 {_S1640.x, _S1640.y, _S1640.z} - _S1635).x, (float3 {_S1640.x, _S1640.y, _S1640.z} - _S1635).y, (float3 {_S1640.x, _S1640.y, _S1640.z} - _S1635).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_1)
{
    uint _S1641 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1642 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1643 = _S1641 + 23U * _S1642;
    uint _S1644 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1643 + 2U * _S1644 + island_1;
}

static __device__ void write_bond_loads_0(uint _S1645, uint _S1646, float3  _S1647, float3  _S1648, float _S1649)
{
    BondStatic_0 * _S1650 = (&(globalParams_0->bonds_0)[_S1646]);
    float3  _S1651 = to_body_0(_S1646, _S1647);
    float3  _S1652 = to_body_0(_S1646, _S1648);
    uint _S1653 = 3U * _S1645;
    *(&(globalParams_0->scratch_0)[_S1653]) = make_float4 (_S1651.x, _S1651.y, _S1651.z, _S1649);
    float4  * _S1654 = (&(globalParams_0->scratch_0)[_S1653 + 1U]);
    float4  _S1655 = __ldg(&_S1650->ra_0);
    *_S1654 = make_float4 ((_S1652 + cross_0(float3 {_S1655.x, _S1655.y, _S1655.z}, _S1651)).x, (_S1652 + cross_0(float3 {_S1655.x, _S1655.y, _S1655.z}, _S1651)).y, (_S1652 + cross_0(float3 {_S1655.x, _S1655.y, _S1655.z}, _S1651)).z, 0.0f);
    float4  * _S1656 = (&(globalParams_0->scratch_0)[_S1653 + 2U]);
    float3  _S1657 = - _S1652;
    float4  _S1658 = __ldg(&_S1650->rb_0);
    *_S1656 = make_float4 ((_S1657 + cross_0(float3 {_S1658.x, _S1658.y, _S1658.z}, - _S1651)).x, (_S1657 + cross_0(float3 {_S1658.x, _S1658.y, _S1658.z}, - _S1651)).y, (_S1657 + cross_0(float3 {_S1658.x, _S1658.y, _S1658.z}, - _S1651)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1659, float3  _S1660, float3  _S1661, float3  _S1662, float3  _S1663, float3  * _S1664, float3  * _S1665)
{
    BondStatic_0 * _S1666 = (&(globalParams_0->bonds_0)[_S1659]);
    float4  _S1667 = __ldg(&_S1666->rb_0);
    float3  _S1668 = _S1662 + cross_0(_S1663, float3 {_S1667.x, _S1667.y, _S1667.z});
    float4  _S1669 = __ldg(&_S1666->ra_0);
    float3  _S1670 = to_local_0(_S1659, _S1668 - (_S1660 + cross_0(_S1661, float3 {_S1669.x, _S1669.y, _S1669.z})));
    *_S1664 = _S1670;
    float3  _S1671 = to_local_0(_S1659, _S1663 - _S1661);
    *_S1665 = _S1671;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1672 = 0U;
    uint _S1673;
    uint i_25;
    uint c_37;
    bool converged_0;
    uint _S1674;
    uint _S1675;
    uint _S1676;
    uint _S1677;
    uint _S1678;
    uint _S1679;
    uint i_26;
    uint _S1680;
    uint _S1681;
    uint _S1682;
    uint _S1683;
    uint _S1684;
    uint _S1685 = __ballot_sync(4294967295U, true);
    uint tid_17 = threadIdx.x;
    uint _S1686 = blockIdx.x;
    Island_0 * _S1687 = (&(globalParams_0->islands_0)[_S1686]);
    Island_0 isl_21 = *_S1687;
    uint _S1688 = (*_S1687).info_1.z;
    bool _S1689 = (_S1688 & 8U) == 0U;
    uint _S1690 = __ballot_sync(_S1685, _S1689);
    if(_S1689)
    {
        return;
    }
    else
    {
        uint _S1691 = __ballot_sync(_S1685, true);
        _S1672 = _S1691;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1692 = isl_21.range_0.w;
    uint _S1693 = c0_1 + tid_17;
    uint c_38 = _S1693;
    uint newton_0;
    newton_0 = _S1672;
    for(;;)
    {
        bool _S1694 = c_38 < c1_1;
        uint _S1695 = __ballot_sync(newton_0, _S1694);
        if(_S1694)
        {
            uint _S1696 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1697 = __ballot_sync(newton_0, false);
            uint _S1698 = __ballot_sync(newton_0, false);
            uint _S1699 = __ballot_sync(_S1672, true);
            _S1673 = _S1699;
            break;
        }
        float4  _S1700 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1700;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1700;
        uint _S1701 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1701;
    }
    __syncthreads();
    uint _S1702 = __ballot_sync(_S1673, free_0);
    if(free_0)
    {
        Island_0 _S1703 = isl_21;
        project_load_slot_0(tid_17, &_S1703, 0U, _S1702);
        uint _S1704 = __ballot_sync(_S1673, true);
        c_38 = _S1704;
    }
    else
    {
        uint _S1705 = __ballot_sync(_S1673, true);
        c_38 = _S1705;
    }
    float _S1706 = island_dot_0(tid_17, c0_1, c1_1, 0U, 0U, c_38);
    float _S1707 = (F32_max(((F32_sqrt((_S1706)))), (1.00000000317107685e-30f)));
    float _S1708 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1709 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1710 = (U32_min((_S1709), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1711 = 0U;
        uint _S1712 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1713 = newton_0 < _S1712;
        uint _S1714 = __ballot_sync(c_38, _S1713);
        if(_S1713)
        {
            uint _S1715 = __ballot_sync(c_38, true);
            _S1711 = _S1715;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1716 = b0_0 + tid_17;
        i_25 = _S1716;
        uint _S1717;
        _S1717 = _S1711;
        for(;;)
        {
            bool _S1718 = i_25 < _S1692;
            uint _S1719 = __ballot_sync(_S1717, _S1718);
            if(_S1718)
            {
                uint _S1720 = __ballot_sync(_S1717, true);
            }
            else
            {
                uint _S1721 = __ballot_sync(_S1717, false);
                uint _S1722 = __ballot_sync(_S1717, false);
                uint _S1723 = __ballot_sync(_S1711, true);
                _S1674 = _S1723;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_25);
            write_bond_loads_0(i_25, i_25, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1724 = __ballot_sync(_S1717, true);
            i_25 = i_25 + 256U;
            _S1717 = _S1724;
        }
        __syncthreads();
        float4  _S1725 = make_float4 (0.0f);
        float4  magnitude_0 = _S1725;
        float4  unused_m_0 = _S1725;
        uint c_39 = _S1693;
        uint _S1726 = _S1674;
        for(;;)
        {
            bool _S1727 = c_39 < c1_1;
            uint _S1728 = __ballot_sync(_S1726, _S1727);
            if(_S1727)
            {
                uint _S1729 = __ballot_sync(_S1726, true);
            }
            else
            {
                uint _S1730 = __ballot_sync(_S1726, false);
                uint _S1731 = __ballot_sync(_S1726, false);
                uint _S1732 = __ballot_sync(_S1674, true);
                _S1675 = _S1732;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1733 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1733.x, _S1733.y, _S1733.z} + fi_3).x, (float3 {_S1733.x, _S1733.y, _S1733.z} + fi_3).y, (float3 {_S1733.x, _S1733.y, _S1733.z} + fi_3).z, 0.0f);
            float4  _S1734 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1734.x, _S1734.y, _S1734.z} + mi_4).x, (float3 {_S1734.x, _S1734.y, _S1734.z} + mi_4).y, (float3 {_S1734.x, _S1734.y, _S1734.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1725, _S1725);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1735 = __ballot_sync(_S1726, true);
            c_39 = c_39 + 256U;
            _S1726 = _S1735;
        }
        __syncthreads();
        group_sum2_0(tid_17, &magnitude_0, &unused_m_0, _S1675);
        uint _S1736 = __ballot_sync(_S1675, free_0);
        uint _S1737;
        if(free_0)
        {
            Island_0 _S1738 = isl_21;
            project_load_slot_0(tid_17, &_S1738, 4U, _S1736);
            uint _S1739 = __ballot_sync(_S1675, true);
            _S1737 = _S1739;
        }
        else
        {
            uint _S1740 = __ballot_sync(_S1675, true);
            _S1737 = _S1740;
        }
        float _S1741 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, _S1737);
        float residual_1 = (F32_sqrt((_S1741))) / _S1707;
        float _S1742 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1707)));
        bool _S1743 = residual_1 <= _S1708;
        uint _S1744 = __ballot_sync(_S1737, _S1743);
        uint _S1745;
        if(_S1743)
        {
            uint _S1746 = __ballot_sync(_S1737, true);
            converged_0 = true;
            _S1745 = _S1746;
        }
        else
        {
            uint _S1747 = _S1737 & (~_S1744);
            bool _S1748 = residual_1 <= _S1742;
            uint _S1749 = __ballot_sync(_S1747, _S1748);
            if(_S1748)
            {
                bool _S1750 = residual_1 > (0.5f * previous_2);
                uint _S1751 = __ballot_sync(_S1747, true);
                converged_0 = _S1750;
            }
            else
            {
                uint _S1752 = __ballot_sync(_S1747, true);
                converged_0 = false;
            }
            uint _S1753 = __ballot_sync(_S1737, true);
            _S1745 = _S1753;
        }
        uint _S1754 = 0U;
        uint _S1755 = __ballot_sync(_S1745, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1756 = __ballot_sync(_S1745, true);
            _S1754 = _S1756;
        }
        uint i_27 = _S1716;
        uint _S1757;
        _S1757 = _S1754;
        for(;;)
        {
            bool _S1758 = i_27 < _S1692;
            uint _S1759 = __ballot_sync(_S1757, _S1758);
            if(_S1758)
            {
                uint _S1760 = __ballot_sync(_S1757, true);
            }
            else
            {
                uint _S1761 = __ballot_sync(_S1757, false);
                uint _S1762 = __ballot_sync(_S1757, false);
                uint _S1763 = __ballot_sync(_S1754, true);
                _S1676 = _S1763;
                break;
            }
            BondStatic_0 * _S1764 = (&(globalParams_0->bonds_0)[i_27]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_27, &d_lin_5, &d_ang_4);
            JointBond_0 _S1765 = slang_ldg_0(&_S1764->law_0);
            JointBond_0 _S1766 = _S1765;
            JointState_0 _S1767 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1766, &_S1767, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1768 = statics_bond_slot_0(i_27);
            float _S1769 = _S1765.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1768]) = make_float4 (_S1769 * f_lin_2.x, _S1769 * f_lin_2.y, _S1765.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1768 + 1U]) = make_float4 (_S1765.stiff0_0.z * f_ang_2.x, _S1765.stiff0_0.w * f_ang_2.y, _S1765.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1770 = __ballot_sync(_S1757, true);
            i_27 = i_27 + 256U;
            _S1757 = _S1770;
        }
        __syncthreads();
        uint c_40 = _S1693;
        uint _S1771 = _S1676;
        for(;;)
        {
            bool _S1772 = c_40 < c1_1;
            uint _S1773 = __ballot_sync(_S1771, _S1772);
            if(_S1772)
            {
                uint _S1774 = __ballot_sync(_S1771, true);
            }
            else
            {
                uint _S1775 = __ballot_sync(_S1771, false);
                uint _S1776 = __ballot_sync(_S1771, false);
                uint _S1777 = __ballot_sync(_S1676, true);
                _S1677 = _S1777;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1725;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1725;
            uint _S1778 = __ballot_sync(_S1771, true);
            c_40 = c_40 + 256U;
            _S1771 = _S1778;
        }
        __syncthreads();
        uint c_41 = _S1693;
        uint _S1779 = _S1677;
        for(;;)
        {
            bool _S1780 = c_41 < c1_1;
            uint _S1781 = __ballot_sync(_S1779, _S1780);
            if(_S1780)
            {
                uint _S1782 = __ballot_sync(_S1779, true);
            }
            else
            {
                uint _S1783 = __ballot_sync(_S1779, false);
                uint _S1784 = __ballot_sync(_S1779, false);
                uint _S1785 = __ballot_sync(_S1677, true);
                _S1678 = _S1785;
                break;
            }
            precondition_0(c_41);
            uint _S1786 = __ballot_sync(_S1779, true);
            c_41 = c_41 + 256U;
            _S1779 = _S1786;
        }
        __syncthreads();
        uint _S1787 = __ballot_sync(_S1678, free_0);
        uint _S1788;
        if(free_0)
        {
            Island_0 _S1789 = isl_21;
            project_displacement_slot_0(tid_17, &_S1789, 6U, _S1787);
            uint _S1790 = __ballot_sync(_S1678, true);
            _S1788 = _S1790;
        }
        else
        {
            uint _S1791 = __ballot_sync(_S1678, true);
            _S1788 = _S1791;
        }
        uint c_42 = _S1693;
        uint _S1792 = _S1788;
        for(;;)
        {
            bool _S1793 = c_42 < c1_1;
            uint _S1794 = __ballot_sync(_S1792, _S1793);
            if(_S1793)
            {
                uint _S1795 = __ballot_sync(_S1792, true);
            }
            else
            {
                uint _S1796 = __ballot_sync(_S1792, false);
                uint _S1797 = __ballot_sync(_S1792, false);
                uint _S1798 = __ballot_sync(_S1788, true);
                _S1679 = _S1798;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1799 = __ballot_sync(_S1792, true);
            c_42 = c_42 + 256U;
            _S1792 = _S1799;
        }
        __syncthreads();
        float _S1800 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, _S1679);
        float _S1801 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, _S1679);
        float _S1802 = (F32_sqrt((_S1801)));
        float rz_0 = _S1800;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1803 = _S1679;
        for(;;)
        {
            bool _S1804 = k_22 < _S1710;
            uint _S1805 = __ballot_sync(_S1803, _S1804);
            uint _S1806;
            bool _S1807;
            if(_S1804)
            {
                bool _S1808 = _S1802 > 0.0f;
                uint _S1809 = __ballot_sync(_S1803, true);
                _S1807 = _S1808;
                _S1806 = _S1809;
            }
            else
            {
                uint _S1810 = __ballot_sync(_S1803, true);
                _S1807 = false;
                _S1806 = _S1810;
            }
            uint _S1811 = 0U;
            uint _S1812 = __ballot_sync(_S1806, _S1807);
            if(_S1807)
            {
                uint _S1813 = __ballot_sync(_S1806, true);
                _S1811 = _S1813;
            }
            else
            {
                uint _S1814 = __ballot_sync(_S1806, false);
                uint _S1815 = __ballot_sync(_S1803, false);
                uint _S1816 = __ballot_sync(_S1679, true);
                cg_total_0 = cg_total_1;
                i_26 = _S1816;
                break;
            }
            i_26 = _S1716;
            _S1680 = _S1811;
            for(;;)
            {
                bool _S1817 = i_26 < _S1692;
                uint _S1818 = __ballot_sync(_S1680, _S1817);
                if(_S1817)
                {
                    uint _S1819 = __ballot_sync(_S1680, true);
                }
                else
                {
                    uint _S1820 = __ballot_sync(_S1680, false);
                    uint _S1821 = __ballot_sync(_S1680, false);
                    uint _S1822 = __ballot_sync(_S1811, true);
                    _S1681 = _S1822;
                    break;
                }
                JointBond_0 _S1823 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_26])->law_0);
                uint ca_2 = _S1823.ids_0.y;
                uint cb_2 = _S1823.ids_0.z;
                float4  _S1824 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1825 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1826 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1827 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_26, float3 {_S1824.x, _S1824.y, _S1824.z}, float3 {_S1825.x, _S1825.y, _S1825.z}, float3 {_S1826.x, _S1826.y, _S1826.z}, float3 {_S1827.x, _S1827.y, _S1827.z}, &d_lin_6, &d_ang_5);
                uint _S1828 = statics_bond_slot_0(i_26);
                float4  _S1829 = *(&(globalParams_0->scratch_0)[_S1828]);
                float4  _S1830 = *(&(globalParams_0->scratch_0)[_S1828 + 1U]);
                write_bond_loads_0(i_26, i_26, d_lin_6 * float3 {_S1829.x, _S1829.y, _S1829.z}, d_ang_5 * float3 {_S1830.x, _S1830.y, _S1830.z}, 0.0f);
                uint _S1831 = __ballot_sync(_S1680, true);
                i_26 = i_26 + 256U;
                _S1680 = _S1831;
            }
            __syncthreads();
            c_37 = _S1693;
            uint _S1832 = _S1681;
            for(;;)
            {
                bool _S1833 = c_37 < c1_1;
                uint _S1834 = __ballot_sync(_S1832, _S1833);
                if(_S1833)
                {
                    uint _S1835 = __ballot_sync(_S1832, true);
                }
                else
                {
                    uint _S1836 = __ballot_sync(_S1832, false);
                    uint _S1837 = __ballot_sync(_S1832, false);
                    uint _S1838 = __ballot_sync(_S1681, true);
                    _S1682 = _S1838;
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
                uint _S1839 = __ballot_sync(_S1832, true);
                c_37 = c_37 + 256U;
                _S1832 = _S1839;
            }
            uint _S1840 = 0U;
            __syncthreads();
            float _S1841 = island_dot_0(tid_17, c0_1, c1_1, 8U, 10U, _S1682);
            uint _S1842 = cg_total_1 + 1U;
            bool _S1843 = _S1841 <= 0.0f;
            uint _S1844 = __ballot_sync(_S1682, _S1843);
            if(_S1843)
            {
                uint _S1845 = __ballot_sync(_S1682, false);
                uint _S1846 = __ballot_sync(_S1803, false);
                uint _S1847 = __ballot_sync(_S1679, true);
                cg_total_0 = _S1842;
                i_26 = _S1847;
                break;
            }
            else
            {
                uint _S1848 = __ballot_sync(_S1682, true);
                _S1840 = _S1848;
            }
            float _S1849 = rz_0 / _S1841;
            uint c_43 = _S1693;
            uint _S1850;
            _S1850 = _S1840;
            for(;;)
            {
                bool _S1851 = c_43 < c1_1;
                uint _S1852 = __ballot_sync(_S1850, _S1851);
                if(_S1851)
                {
                    uint _S1853 = __ballot_sync(_S1850, true);
                }
                else
                {
                    uint _S1854 = __ballot_sync(_S1850, false);
                    uint _S1855 = __ballot_sync(_S1850, false);
                    uint _S1856 = __ballot_sync(_S1840, true);
                    _S1683 = _S1856;
                    break;
                }
                uint _S1857 = sv_0(c_43, 2U);
                float4  _S1858 = *(&(globalParams_0->scratch_0)[_S1857]);
                float4  _S1859 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1857]) = make_float4 ((float3 {_S1858.x, _S1858.y, _S1858.z} + make_float3 (_S1849) * float3 {_S1859.x, _S1859.y, _S1859.z}).x, (float3 {_S1858.x, _S1858.y, _S1858.z} + make_float3 (_S1849) * float3 {_S1859.x, _S1859.y, _S1859.z}).y, (float3 {_S1858.x, _S1858.y, _S1858.z} + make_float3 (_S1849) * float3 {_S1859.x, _S1859.y, _S1859.z}).z, 0.0f);
                uint _S1860 = sv_0(c_43, 3U);
                float4  _S1861 = *(&(globalParams_0->scratch_0)[_S1860]);
                float4  _S1862 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1860]) = make_float4 ((float3 {_S1861.x, _S1861.y, _S1861.z} + make_float3 (_S1849) * float3 {_S1862.x, _S1862.y, _S1862.z}).x, (float3 {_S1861.x, _S1861.y, _S1861.z} + make_float3 (_S1849) * float3 {_S1862.x, _S1862.y, _S1862.z}).y, (float3 {_S1861.x, _S1861.y, _S1861.z} + make_float3 (_S1849) * float3 {_S1862.x, _S1862.y, _S1862.z}).z, 0.0f);
                uint _S1863 = sv_0(c_43, 4U);
                float4  _S1864 = *(&(globalParams_0->scratch_0)[_S1863]);
                float4  _S1865 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1863]) = make_float4 ((float3 {_S1864.x, _S1864.y, _S1864.z} - make_float3 (_S1849) * float3 {_S1865.x, _S1865.y, _S1865.z}).x, (float3 {_S1864.x, _S1864.y, _S1864.z} - make_float3 (_S1849) * float3 {_S1865.x, _S1865.y, _S1865.z}).y, (float3 {_S1864.x, _S1864.y, _S1864.z} - make_float3 (_S1849) * float3 {_S1865.x, _S1865.y, _S1865.z}).z, 0.0f);
                uint _S1866 = sv_0(c_43, 5U);
                float4  _S1867 = *(&(globalParams_0->scratch_0)[_S1866]);
                float4  _S1868 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1866]) = make_float4 ((float3 {_S1867.x, _S1867.y, _S1867.z} - make_float3 (_S1849) * float3 {_S1868.x, _S1868.y, _S1868.z}).x, (float3 {_S1867.x, _S1867.y, _S1867.z} - make_float3 (_S1849) * float3 {_S1868.x, _S1868.y, _S1868.z}).y, (float3 {_S1867.x, _S1867.y, _S1867.z} - make_float3 (_S1849) * float3 {_S1868.x, _S1868.y, _S1868.z}).z, 0.0f);
                uint _S1869 = __ballot_sync(_S1850, true);
                c_43 = c_43 + 256U;
                _S1850 = _S1869;
            }
            uint _S1870 = 0U;
            __syncthreads();
            float _S1871 = island_dot_0(tid_17, c0_1, c1_1, 4U, 4U, _S1683);
            bool _S1872 = (F32_sqrt((_S1871))) <= (0.00009999999747379f * _S1802);
            uint _S1873 = __ballot_sync(_S1683, _S1872);
            if(_S1872)
            {
                uint _S1874 = __ballot_sync(_S1683, false);
                uint _S1875 = __ballot_sync(_S1803, false);
                uint _S1876 = __ballot_sync(_S1679, true);
                cg_total_0 = _S1842;
                i_26 = _S1876;
                break;
            }
            else
            {
                uint _S1877 = __ballot_sync(_S1683, true);
                _S1870 = _S1877;
            }
            uint c_44 = _S1693;
            uint _S1878;
            _S1878 = _S1870;
            for(;;)
            {
                bool _S1879 = c_44 < c1_1;
                uint _S1880 = __ballot_sync(_S1878, _S1879);
                if(_S1879)
                {
                    uint _S1881 = __ballot_sync(_S1878, true);
                }
                else
                {
                    uint _S1882 = __ballot_sync(_S1878, false);
                    uint _S1883 = __ballot_sync(_S1878, false);
                    uint _S1884 = __ballot_sync(_S1870, true);
                    _S1684 = _S1884;
                    break;
                }
                precondition_0(c_44);
                uint _S1885 = __ballot_sync(_S1878, true);
                c_44 = c_44 + 256U;
                _S1878 = _S1885;
            }
            __syncthreads();
            uint _S1886 = __ballot_sync(_S1684, free_0);
            uint _S1887;
            if(free_0)
            {
                Island_0 _S1888 = isl_21;
                project_displacement_slot_0(tid_17, &_S1888, 6U, _S1886);
                uint _S1889 = __ballot_sync(_S1684, true);
                _S1887 = _S1889;
            }
            else
            {
                uint _S1890 = __ballot_sync(_S1684, true);
                _S1887 = _S1890;
            }
            float _S1891 = island_dot_0(tid_17, c0_1, c1_1, 4U, 6U, _S1887);
            float _S1892 = _S1891 / rz_0;
            uint c_45 = _S1693;
            uint _S1893 = _S1887;
            for(;;)
            {
                bool _S1894 = c_45 < c1_1;
                uint _S1895 = __ballot_sync(_S1893, _S1894);
                if(_S1894)
                {
                    uint _S1896 = __ballot_sync(_S1893, true);
                }
                else
                {
                    uint _S1897 = __ballot_sync(_S1893, false);
                    uint _S1898 = __ballot_sync(_S1893, false);
                    uint _S1899 = __ballot_sync(_S1887, true);
                    break;
                }
                uint _S1900 = sv_0(c_45, 8U);
                float4  _S1901 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S1902 = *(&(globalParams_0->scratch_0)[_S1900]);
                *(&(globalParams_0->scratch_0)[_S1900]) = make_float4 ((float3 {_S1901.x, _S1901.y, _S1901.z} + make_float3 (_S1892) * float3 {_S1902.x, _S1902.y, _S1902.z}).x, (float3 {_S1901.x, _S1901.y, _S1901.z} + make_float3 (_S1892) * float3 {_S1902.x, _S1902.y, _S1902.z}).y, (float3 {_S1901.x, _S1901.y, _S1901.z} + make_float3 (_S1892) * float3 {_S1902.x, _S1902.y, _S1902.z}).z, 0.0f);
                uint _S1903 = sv_0(c_45, 9U);
                float4  _S1904 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S1905 = *(&(globalParams_0->scratch_0)[_S1903]);
                *(&(globalParams_0->scratch_0)[_S1903]) = make_float4 ((float3 {_S1904.x, _S1904.y, _S1904.z} + make_float3 (_S1892) * float3 {_S1905.x, _S1905.y, _S1905.z}).x, (float3 {_S1904.x, _S1904.y, _S1904.z} + make_float3 (_S1892) * float3 {_S1905.x, _S1905.y, _S1905.z}).y, (float3 {_S1904.x, _S1904.y, _S1904.z} + make_float3 (_S1892) * float3 {_S1905.x, _S1905.y, _S1905.z}).z, 0.0f);
                uint _S1906 = __ballot_sync(_S1893, true);
                c_45 = c_45 + 256U;
                _S1893 = _S1906;
            }
            __syncthreads();
            uint _S1907 = __ballot_sync(_S1803, true);
            uint _S1908 = k_22 + 1U;
            rz_0 = _S1891;
            k_22 = _S1908;
            cg_total_1 = _S1842;
            _S1803 = _S1907;
        }
        c_37 = _S1693;
        _S1680 = i_26;
        for(;;)
        {
            bool _S1909 = c_37 < c1_1;
            uint _S1910 = __ballot_sync(_S1680, _S1909);
            if(_S1909)
            {
                uint _S1911 = __ballot_sync(_S1680, true);
            }
            else
            {
                uint _S1912 = __ballot_sync(_S1680, false);
                uint _S1913 = __ballot_sync(_S1680, false);
                uint _S1914 = __ballot_sync(i_26, true);
                break;
            }
            uint _S1915 = 4U * c_37;
            float4  _S1916 = *(&(globalParams_0->state_0)[_S1915]);
            float3  u_4 = float3 {_S1916.x, _S1916.y, _S1916.z};
            uint _S1917 = sv_0(c_37, 21U);
            float4  _S1918 = *(&(globalParams_0->scratch_0)[_S1917]);
            float3  u_lo_0 = float3 {_S1918.x, _S1918.y, _S1918.z};
            uint _S1919 = _S1915 + 1U;
            float4  _S1920 = *(&(globalParams_0->state_0)[_S1919]);
            float3  th_5 = float3 {_S1920.x, _S1920.y, _S1920.z};
            uint _S1921 = sv_0(c_37, 22U);
            float4  _S1922 = *(&(globalParams_0->scratch_0)[_S1921]);
            float3  th_lo_0 = float3 {_S1922.x, _S1922.y, _S1922.z};
            float4  _S1923 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S1923.x, _S1923.y, _S1923.z});
            float4  _S1924 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_5, &th_lo_0, float3 {_S1924.x, _S1924.y, _S1924.z});
            *(&(globalParams_0->state_0)[_S1915]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S1915])).w);
            *(&(globalParams_0->state_0)[_S1919]) = make_float4 (th_5.x, th_5.y, th_5.z, (*(&(globalParams_0->state_0)[_S1919])).w);
            *(&(globalParams_0->scratch_0)[_S1917]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1921]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1925 = __ballot_sync(_S1680, true);
            c_37 = c_37 + 256U;
            _S1680 = _S1925;
        }
        __syncthreads();
        uint _S1926 = newton_0 + 1U;
        uint _S1927 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1926;
        c_38 = _S1927;
    }
    i_25 = b0_0 + tid_17;
    for(;;)
    {
        if(i_25 < _S1692)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_25);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_25]);
        (&bd_1)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_5);
        (&bd_1)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_1)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_25]) = bd_1;
        write_bond_loads_0(i_25, i_25, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_25 = i_25 + 256U;
    }
    __syncthreads();
    c_37 = _S1693;
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
            float4  _S1928 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S1928.x, _S1928.y, _S1928.z} + fi_5);
        }
        else
        {
            uint _S1929 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S1929 + 1U])).w, (*(&(globalParams_0->state_0)[_S1929 + 2U])).w, (*(&(globalParams_0->state_0)[_S1929 + 3U])).w);
        }
        uint _S1930 = 4U * c_37;
        uint _S1931 = _S1930 + 1U;
        float4  _S1932 = *(&(globalParams_0->state_0)[_S1931]);
        *(&(globalParams_0->state_0)[_S1931]) = make_float4 (float3 {_S1932.x, _S1932.y, _S1932.z}.x, float3 {_S1932.x, _S1932.y, _S1932.z}.y, float3 {_S1932.x, _S1932.y, _S1932.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S1930 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S1930 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_17 == 0U)
    {
        float4  * _S1933 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1686)]);
        float _S1934 = (U32_asfloat((newton_0)));
        float _S1935 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S1933 = make_float4 (residual_0, _S1934, _S1935, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1686])->info_1)->z) = _S1688 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_18 = threadIdx.x;
    uint _S1936 = blockIdx.x;
    Island_0 * _S1937 = (&(globalParams_0->islands_0)[_S1936]);
    Island_0 isl_22 = *_S1937;
    bool _S1938;
    if((((*_S1937).info_1.x) & 16U) == 0U)
    {
        _S1938 = true;
    }
    else
    {
        _S1938 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S1938)
    {
        return;
    }
    bool _S1939 = tid_18 == 0U;
    if(_S1939)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1940 = isl_22.info_1.w;
    uint i_28 = isl_22.range_0.z + tid_18;
    for(;;)
    {
        if(i_28 < (isl_22.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1941 = (&(globalParams_0->bonds_0)[i_28]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_28]);
        JointBond_0 _S1942 = slang_ldg_0(&_S1941->law_0);
        uint _S1943 = 4U * _S1942.ids_0.y;
        float4  _S1944 = *(&(globalParams_0->state_0)[_S1943]);
        float4  _S1945 = *(&(globalParams_0->state_0)[_S1943 + 1U]);
        uint _S1946 = 4U * _S1942.ids_0.z;
        float4  _S1947 = *(&(globalParams_0->state_0)[_S1946]);
        float4  _S1948 = *(&(globalParams_0->state_0)[_S1946 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_28, float3 {_S1944.x, _S1944.y, _S1944.z}, float3 {_S1945.x, _S1945.y, _S1945.z}, float3 {_S1947.x, _S1947.y, _S1947.z}, float3 {_S1948.x, _S1948.y, _S1948.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S1949 = d_lin_7;
        float3  _S1950 = d_ang_6;
        float _S1951 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1952 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1953 = _S1952 != 0U;
        JointBond_0 _S1954 = _S1942;
        JointState_0 _S1955 = previous_3;
        JointResponse_0 _S1956 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1942.ids_0.x], &_S1954, &_S1955, _S1949, _S1950, _S1951, _S1953);
        if((_S1956.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S1938 = true;
        }
        else
        {
            _S1938 = (_S1956.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_2;
        if(_S1938)
        {
            flags_2 = 16U;
        }
        else
        {
            flags_2 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1956.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1956.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S1956.force_lin_1.x, _S1956.force_lin_1.y, _S1956.force_lin_1.z, _S1956.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S1956.force_ang_1.x, _S1956.force_ang_1.y, _S1956.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1956.state_1.utilization_0))));
        JointState_0 _S1957 = previous_3;
        bool _S1958 = is_damaged_0(&_S1957);
        bool _S1959;
        if(!_S1958)
        {
            JointState_0 _S1960 = _S1956.state_1;
            bool _S1961 = is_damaged_0(&_S1960);
            _S1959 = _S1961;
        }
        else
        {
            _S1959 = false;
        }
        bool _S1962;
        if(_S1959)
        {
            _S1962 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S1962 = false;
        }
        if(_S1962)
        {
            *&((&(&bd_2)->events_0)->x) = _S1940;
            *&((&(&bd_2)->events_0)->w) = _S1956.state_1.mode_0;
        }
        bool _S1963;
        if(((&bd_2)->events_0.y) == 0U)
        {
            float _S1964 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1942.ids_0.x], previous_3.fatigue_0);
            _S1963 = _S1964 > 0.99000000953674316f;
        }
        else
        {
            _S1963 = false;
        }
        bool _S1965;
        if(_S1963)
        {
            float _S1966 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1942.ids_0.x], _S1956.state_1.fatigue_0);
            _S1965 = _S1966 <= 0.99000000953674316f;
        }
        else
        {
            _S1965 = false;
        }
        if(_S1965)
        {
            *&((&(&bd_2)->events_0)->y) = _S1940;
        }
        uint flags_3;
        if(_S1956.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S1940;
            flags_3 = flags_2 | 32U;
        }
        else
        {
            flags_3 = flags_2;
        }
        (&bd_2)->js_0 = _S1956.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_28]) = bd_2;
        write_bond_loads_0(i_28, i_28, _S1956.force_lin_1, _S1956.force_ang_1, (F32_max((_S1956.measures_0.tension_0), (_S1956.measures_0.compression_0))));
        if((flags_3 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_3 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_28 = i_28 + 256U;
    }
    __syncthreads();
    if(_S1939)
    {
        _S1938 = ((*&g_halt_0) | (*&g_run_0)) != 0U;
    }
    else
    {
        _S1938 = false;
    }
    if(_S1938)
    {
        uint _S1967 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_28 = 16U;
        }
        else
        {
            i_28 = 0U;
        }
        uint _S1968 = _S1967 | i_28;
        if((*&g_run_0) != 0U)
        {
            i_28 = 32U;
        }
        else
        {
            i_28 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1936])->info_1)->z) = _S1968 | i_28;
    }
    return;
}

