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
    uint pair_lanes_0;
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
    float4  start_rot_0;
    float4  start_vel_0;
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

static __device__ float WaveActiveSum_1(float expr_1, uint _S12)
{
    float _S13 = (_waveSum((make_uint4 (WaveGetActiveMask_0(_S12), 0U, 0U, 0U)).x, (expr_1)));
    return _S13;
}

static __device__ float3  WaveActiveSum_2(float3  expr_2, uint _S14)
{
    float3  _S15 = (_waveSumMultiple((make_uint4 (WaveGetActiveMask_0(_S14), 0U, 0U, 0U)).x, (expr_2)));
    return _S15;
}

static __device__ uint WaveActiveSum_3(uint expr_3, uint _S16)
{
    uint _S17 = (_waveSum((make_uint4 (WaveGetActiveMask_0(_S16), 0U, 0U, 0U)).x, (expr_3)));
    return _S17;
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S18 = left_0.y;
    float _S19 = right_0.z;
    float _S20 = left_0.z;
    float _S21 = right_0.y;
    float _S22 = right_0.x;
    float _S23 = left_0.x;
    return make_float3 (_S18 * _S19 - _S20 * _S21, _S20 * _S22 - _S23 * _S19, _S23 * _S21 - _S18 * _S22);
}

static __device__ float length_0(float3  x_10)
{
    return (F32_sqrt((dot_0(x_10, x_10))));
}

static __device__ uint pair_lane_count_0()
{
    uint _S24 = __ldg(&globalParams_0->params_0->pair_lanes_0);
    return (U32_max((_S24), (1U)));
}

static __device__ bool stopped_0()
{
    uint _S25 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S26 = (&(globalParams_0->islands_0)[_S25])->info_1;
    bool _S27;
    if((((&(globalParams_0->islands_0)[_S25])->info_1.z) & 1U) != 0U)
    {
        _S27 = true;
    }
    else
    {
        _S27 = (_S26.y) != 0U;
    }
    return _S27;
}

static __device__ bool WaveActiveAnyTrue_0(bool condition_0, uint _S28)
{
    bool _S29 = ((__any_sync((WaveGetActiveMask_0(_S28)), (condition_0)) != 0));
    return _S29;
}

static __device__ bool pair_any_0(bool x_11, uint lanes_0, uint _S30)
{
    bool _S31 = lanes_0 > 1U;
    uint _S32 = __ballot_sync(_S30, _S31);
    bool _S33;
    if(_S31)
    {
        bool _S34 = WaveActiveAnyTrue_0(x_11, _S32);
        uint _S35 = __ballot_sync(_S30, true);
        _S33 = _S34;
    }
    else
    {
        _S33 = x_11;
    }
    return _S33;
}

struct Quat_0
{
    float w_1;
    float x_12;
    float y_4;
    float z_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_12 = q_0.x;
    (&r_0)->y_4 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_1 = q_0.w;
    return r_0;
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_12, q_1->y_4, q_1->z_0);
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
    ChunkStatic_0 * _S36 = (&(globalParams_0->chunks_0)[c_0]);
    uint4  _S37 = __ldg(&_S36->info_0);
    Island_0 * _S38 = (&(globalParams_0->islands_0)[_S37.y]);
    Quat_0 q_2 = quat_of_0(_S38->rotation_0);
    WorldPoint_0 w_2;
    float4  _S39 = _S38->position_0;
    (&w_2)->hi_0 = float3 {_S39.x, _S39.y, _S39.z};
    float4  _S40 = _S38->position_err_0;
    (&w_2)->lo_0 = float3 {_S40.x, _S40.y, _S40.z};
    float4  _S41 = __ldg(&_S36->center_0);
    float4  _S42 = *(&(globalParams_0->state_0)[4U * c_0]);
    float3  _S43 = float3 {_S41.x, _S41.y, _S41.z} + float3 {_S42.x, _S42.y, _S42.z};
    Quat_0 _S44 = q_2;
    float3  _S45 = rotate_0(&_S44, _S43);
    (&w_2)->rel_0 = _S45;
    return w_2;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_2, WorldPoint_0 * b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_1)
{
    float n_0 = length_0(v_1);
    float3  _S46;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S46 = v_1 / make_float3 (n_0);
    }
    else
    {
        _S46 = make_float3 (0.0f);
    }
    return _S46;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_0, float angle_0)
{
    float3  a_3 = safe_normalize_0(axis_0);
    float _S47 = 0.5f * angle_0;
    float s_0 = (F32_sin((_S47)));
    Quat_0 q_3;
    (&q_3)->w_1 = (F32_cos((_S47)));
    (&q_3)->x_12 = a_3.x * s_0;
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
    ChunkStatic_0 * _S48 = (&(globalParams_0->chunks_0)[c_1]);
    uint4  _S49 = __ldg(&_S48->info_0);
    Quat_0 q_4 = quat_of_0((&(globalParams_0->islands_0)[_S49.y])->rotation_0);
    float4  _S50 = *(&(globalParams_0->state_0)[4U * c_1 + 1U]);
    float3  th_0 = float3 {_S50.x, _S50.y, _S50.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length_0(th_0));
    Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4  _S51 = __ldg(&_S48->crot0_0);
    float _S52 = _S51.x;
    float4  _S53 = __ldg(&_S48->crot1_0);
    float _S54 = _S53.x;
    float4  _S55 = __ldg(&_S48->crot2_0);
    float3  _S56 = make_float3 (_S52, _S54, _S55.x);
    Quat_0 _S57 = hidden_0;
    float3  _S58 = rotate_0(&_S57, _S56);
    Quat_0 _S59 = q_4;
    float3  _S60 = rotate_0(&_S59, _S58);
    (&b_3)->axis0_0 = _S60;
    float3  _S61 = make_float3 (_S51.y, _S53.y, _S55.y);
    Quat_0 _S62 = hidden_0;
    float3  _S63 = rotate_0(&_S62, _S61);
    Quat_0 _S64 = q_4;
    float3  _S65 = rotate_0(&_S64, _S63);
    (&b_3)->axis1_0 = _S65;
    float3  _S66 = make_float3 (_S51.z, _S53.z, _S55.z);
    Quat_0 _S67 = hidden_0;
    float3  _S68 = rotate_0(&_S67, _S66);
    Quat_0 _S69 = q_4;
    float3  _S70 = rotate_0(&_S69, _S68);
    (&b_3)->axis2_0 = _S70;
    float4  _S71 = __ldg(&_S48->half_0);
    (&b_3)->half_2 = float3 {_S71.x, _S71.y, _S71.z};
    float4  _S72 = __ldg(&_S48->cmat_0);
    (&b_3)->hull_at_0 = (F32_asuint((_S72.z)));
    uint _S73 = (F32_asuint((_S72.w)));
    (&b_3)->hull_v_0 = _S73 & 255U;
    (&b_3)->hull_f_0 = _S73 >> int(8);
    return b_3;
}

static __device__ uint sample_count_0(Box_0 * b_4)
{
    uint _S74 = b_4->hull_v_0;
    uint _S75;
    if((b_4->hull_v_0) == 0U)
    {
        _S75 = 14U;
    }
    else
    {
        _S75 = _S74 + b_4->hull_f_0;
    }
    return _S75;
}

static __device__ bool may_overlap_0(Box_0 * a_4, Box_0 * b_5)
{
    float3  _S76 = b_5->center_1 - a_4->center_1;
    float3  _S77 = a_4->half_2;
    float3  _S78 = b_5->half_2;
    float _S79 = 0.00000999999974738f * (length_0(a_4->half_2) + length_0(b_5->half_2));
    float3  _S80 = a_4->axis0_0;
    float3  _S81 = a_4->axis1_0;
    float3  _S82 = a_4->axis2_0;
    float3  _S83 = b_5->axis0_0;
    float3  _S84 = b_5->axis1_0;
    float3  _S85 = b_5->axis2_0;
    FixedArray<float3 , 6>  _S86 = { {
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
            l_0 = _S86[i_6];
        }
        else
        {
            uint _S87 = i_6 - 6U;
            l_0 = cross_0(_S86[_S87 / 3U], _S86[3U + _S87 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_6 = i_6 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S76, l_0)))) > (_S77.x * (F32_abs((dot_0(_S80, l_0)))) + _S77.y * (F32_abs((dot_0(_S81, l_0)))) + _S77.z * (F32_abs((dot_0(_S82, l_0)))) + (_S78.x * (F32_abs((dot_0(_S83, l_0)))) + _S78.y * (F32_abs((dot_0(_S84, l_0)))) + _S78.z * (F32_abs((dot_0(_S85, l_0))))) + _S79 * len_0))
        {
            return false;
        }
        i_6 = i_6 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_2, float3  * v_2, float3  * w_3)
{
    ChunkStatic_0 * _S88 = (&(globalParams_0->chunks_0)[c_2]);
    uint4  _S89 = __ldg(&_S88->info_0);
    Island_0 * _S90 = (&(globalParams_0->islands_0)[_S89.y]);
    Quat_0 q_5 = quat_of_0(_S90->rotation_0);
    float4  _S91 = __ldg(&_S88->center_0);
    uint _S92 = 4U * c_2;
    float4  _S93 = *(&(globalParams_0->state_0)[_S92]);
    float4  _S94 = _S90->com_0;
    float3  _S95 = float3 {_S91.x, _S91.y, _S91.z} + float3 {_S93.x, _S93.y, _S93.z} - float3 {_S94.x, _S94.y, _S94.z};
    Quat_0 _S96 = q_5;
    float3  _S97 = rotate_0(&_S96, _S95);
    float4  _S98 = _S90->velocity_0;
    float4  _S99 = _S90->velocity_err_0;
    float4  _S100 = _S90->angular_velocity_0;
    float3  _S101 = float3 {_S100.x, _S100.y, _S100.z};
    float3  _S102 = float3 {_S98.x, _S98.y, _S98.z} + float3 {_S99.x, _S99.y, _S99.z} + cross_0(_S101, _S97);
    float4  _S103 = *(&(globalParams_0->state_0)[_S92 + 2U]);
    float3  _S104 = float3 {_S103.x, _S103.y, _S103.z};
    Quat_0 _S105 = q_5;
    float3  _S106 = rotate_0(&_S105, _S104);
    *v_2 = _S102 + _S106;
    float4  _S107 = *(&(globalParams_0->state_0)[_S92 + 3U]);
    float3  _S108 = float3 {_S107.x, _S107.y, _S107.z};
    Quat_0 _S109 = q_5;
    float3  _S110 = rotate_0(&_S109, _S108);
    *w_3 = _S101 + _S110;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_6, float3  local_0)
{
    return b_6->axis0_0 * make_float3 (local_0.x) + b_6->axis1_0 * make_float3 (local_0.y) + b_6->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_7, uint k_0)
{
    float3  _S111;
    if(k_0 == 0U)
    {
        _S111 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S111 = b_7->axis1_0;
        }
        else
        {
            _S111 = b_7->axis2_0;
        }
    }
    return _S111;
}

static __device__ float comp3_0(float3  v_3, uint k_1)
{
    float _S112;
    if(k_1 == 0U)
    {
        _S112 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S112 = v_3.y;
        }
        else
        {
            _S112 = v_3.z;
        }
    }
    return _S112;
}

static __device__ float3  sample_point_0(Box_0 * b_8, uint i_7)
{
    uint _S113 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_7 < _S113)
        {
            float4  _S114 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + i_7]));
            local_1 = float3 {_S114.x, _S114.y, _S114.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S115 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + _S113 + b_8->hull_f_0 + (i_7 - _S113)]));
            local_1 = float3 {_S115.x, _S115.y, _S115.z};
        }
        float3  _S116 = b_8->center_1;
        float3  _S117 = box_to_world_0(b_8, local_1);
        return _S116 + _S117;
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
        float _S118;
        if((i_7 & 2U) == 0U)
        {
            _S118 = - h_0.y;
        }
        else
        {
            _S118 = h_0.y;
        }
        float _S119;
        if((i_7 & 4U) == 0U)
        {
            _S119 = - h_0.z;
        }
        else
        {
            _S119 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * make_float3 (sign_0) + b_8->axis1_0 * make_float3 (_S118) + b_8->axis2_0 * make_float3 (_S119);
    }
    uint _S120 = i_7 - 8U;
    uint axis_1 = _S120 / 2U;
    if((_S120 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S121 = b_8->center_1;
    float3  _S122 = box_axis_0(b_8, axis_1);
    return _S121 + _S122 * make_float3 (sign_0 * comp3_0(b_8->half_2, axis_1));
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
        float4  _S123 = __ldg((&(globalParams_0->loads_0)[b_10->hull_at_0 + b_10->hull_v_0 + f_0]));
        float d_0 = dot_0(float3 {_S123.x, _S123.y, _S123.z}, local_2) - _S123.w;
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
    float3  _S124 = b_11->half_2;
    if((dot_0(r_2, r_2)) > (dot_0(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S125 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3  _S126 = box_to_local_0(b_11, r_2);
        uint face_1;
        float _S127 = hull_signed_distance_0(b_11, _S126, &face_1);
        if(!(_S127 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S127;
        float4  _S128 = __ldg((&(globalParams_0->loads_0)[b_11->hull_at_0 + _S125 + face_1]));
        float3  _S129 = box_to_world_0(b_11, float3 {_S128.x, _S128.y, _S128.z});
        *normal_1 = _S129;
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
        float3  _S130 = box_axis_0(b_11, k_2);
        float local_3 = dot_0(r_2, _S130);
        float d_1 = comp3_0(_S124, k_2) - (F32_abs((local_3)));
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S131;
            if(local_3 >= 0.0f)
            {
                _S131 = 1.0f;
            }
            else
            {
                _S131 = -1.0f;
            }
            best_1 = d_1;
            axis_2 = k_2;
            side_0 = _S131;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3  _S132 = box_axis_0(b_11, axis_2);
    *normal_1 = _S132 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_0, float3  * p_1, float3  * n_1, float * d_2)
{
    if(e_0 < na_0)
    {
        float3  _S133 = sample_point_0(ba_0, e_0);
        *p_1 = _S133;
        bool _S134 = penetration_0(bb_0, _S133, d_2, n_1);
        return _S134;
    }
    float3  _S135 = sample_point_0(bb_0, e_0 - na_0);
    *p_1 = _S135;
    bool _S136 = penetration_0(ba_0, _S135, d_2, n_1);
    if(!_S136)
    {
        return false;
    }
    *n_1 = - *n_1;
    return true;
}

static __device__ bool is_nan_0(float x_13)
{
    return ((F32_asuint((x_13))) & 2147483647U) > 2139095040U;
}

static __device__ uint pair_count_sum_0(uint x_14, uint lanes_1, uint _S137)
{
    bool _S138 = lanes_1 > 1U;
    uint _S139 = __ballot_sync(_S137, _S138);
    uint _S140;
    if(_S138)
    {
        uint _S141 = WaveActiveSum_3(x_14, _S139);
        uint _S142 = __ballot_sync(_S137, true);
        _S140 = _S141;
    }
    else
    {
        _S140 = x_14;
    }
    return _S140;
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
        float3  _S143 = box_axis_0(b_12, k_3);
        float c_3 = (F32_abs((dot_0(d_3, _S143))));
        float h_2 = h_1 + c_3 * comp3_0(b_12->half_2, k_3);
        uint _S144 = k_3 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S144 % 3U) * comp3_0(b_12->half_2, (k_3 + 2U) % 3U);
        k_3 = _S144;
        h_1 = h_2;
        area_0 = area_1;
    }
    return make_float2 (h_1, area_0);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_5, float eb_0, Box_0 * b_13, float3  dir_0)
{
    float3  d_4 = safe_normalize_0(dir_0);
    float2  _S145 = half_thickness_and_area_0(a_5, d_4);
    float2  _S146 = half_thickness_and_area_0(b_13, d_4);
    return (F32_min((_S145.y), (_S146.y))) / (_S145.x / ea_0 + _S146.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3  normal_2, float3  rel_velocity_0, float dt_1, uint points_0, float * stored_0, float * dissipated_1)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_1;
    float _S147 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_2);
    float _S148 = k_4 * depth_1;
    float _S149 = (F32_min((2.0f * _S147 * (F32_sqrt((k_4 * m_red_0)))), (c_max_0))) * vn_0;
    float _S150 = _S148 - _S149;
    float _S151 = (F32_max((_S150), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_2 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S152 = friction_0 * _S151;
    float _S153 = (F32_min((_S152), ((F32_min((c_max_0), (_S152 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S153 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S150 > 0.0f)
    {
        damping_power_0 = _S149 * vn_0;
    }
    else
    {
        damping_power_0 = _S148 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_1 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * make_float3 (_S151) + ft_0;
}

static __device__ float3  pair_sum3_0(float3  x_15, uint lanes_2, uint _S154)
{
    bool _S155 = lanes_2 > 1U;
    uint _S156 = __ballot_sync(_S154, _S155);
    float3  _S157;
    if(_S155)
    {
        float3  _S158 = WaveActiveSum_2(x_15, _S156);
        uint _S159 = __ballot_sync(_S154, true);
        _S157 = _S158;
    }
    else
    {
        _S157 = x_15;
    }
    return _S157;
}

static __device__ float pair_sum_0(float x_16, uint lanes_3, uint _S160)
{
    bool _S161 = lanes_3 > 1U;
    uint _S162 = __ballot_sync(_S160, _S161);
    float _S163;
    if(_S161)
    {
        float _S164 = WaveActiveSum_1(x_16, _S162);
        uint _S165 = __ballot_sync(_S160, true);
        _S163 = _S164;
    }
    else
    {
        _S163 = x_16;
    }
    return _S163;
}

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_17)
{
    float t_1 = *sum_0 + x_17;
    if((F32_abs((*sum_0))) >= (F32_abs((x_17))))
    {
        *err_0 = *err_0 + (*sum_0 - t_1 + x_17);
    }
    else
    {
        *err_0 = *err_0 + (x_17 - t_1 + *sum_0);
    }
    *sum_0 = t_1;
    return;
}

static __device__ void cov_or_0(uint island_0, uint bits_0)
{
    uint _S166 = atomicOr(&(&(globalParams_0->islands_0)[island_0])->coverage_0, bits_0);
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
    uint _S167 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S168 = __ldg(&globalParams_0->params_0->halt_index_0);
    cov_mark_0(_S167, (&(globalParams_0->islands_0)[_S168])->coverage_0, bits_2);
    return;
}

static __device__ void pair_contact_0(uint i_8, uint lane_0, uint lanes_4, uint _S169)
{
    uint _S170 = 0U;
    uint _S171;
    uint _S172;
    uint _S173 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S173 + 6U * i_8;
    uint _S174 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S175 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S176 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S177 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S178 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S179 = (U32_asfloat((_S178)));
    uint _S180 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S181 = (U32_asfloat((_S180)));
    float _S182 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S183 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S183 + 2U * _S176;
    WorldPoint_0 wa_0 = chunk_world_0(_S174);
    WorldPoint_0 _S184 = chunk_world_0(_S175);
    WorldPoint_0 _S185 = wa_0;
    float3  _S186 = world_diff_0(&_S184, &_S185);
    float _S187 = length_0(_S186);
    float4  _S188 = __ldg(&(&(globalParams_0->chunks_0)[_S174])->half_0);
    float _S189 = _S188.w;
    float4  _S190 = __ldg(&(&(globalParams_0->chunks_0)[_S175])->half_0);
    bool touching_0 = !(_S187 > (_S189 + _S190.w));
    uint _S191 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S192 = (&(globalParams_0->scratch_0)[_S191 + i_8]);
    float4  ledger_1 = *_S192;
    uint flags_0 = (F32_asuint(((*_S192).w)));
    float3  _S193 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S174, _S193);
    Box_0 bb_1 = chunk_box_0(_S175, _S186);
    Box_0 _S194 = ba_1;
    uint _S195 = sample_count_0(&_S194);
    Box_0 _S196 = bb_1;
    uint _S197 = sample_count_0(&_S196);
    uint _S198 = _S195 + _S197;
    bool _S199 = !touching_0;
    uint _S200 = __ballot_sync(_S169, _S199);
    uint e_1;
    bool has_state_0;
    if(_S199)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = lane_0;
            for(;;)
            {
                if(e_1 < _S198)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S177 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                e_1 = e_1 + lanes_4;
            }
        }
        if(lane_0 == 0U)
        {
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
                uint _S201 = __ldg(&globalParams_0->params_0->ledger_base_0);
                *(&(globalParams_0->scratch_0)[_S201 + i_8]) = ledger_1;
            }
        }
        return;
    }
    else
    {
        uint _S202 = __ballot_sync(_S169, true);
        _S170 = _S202;
    }
    Box_0 _S203 = ba_1;
    Box_0 _S204 = bb_1;
    bool _S205 = may_overlap_0(&_S203, &_S204);
    uint _S206 = __ballot_sync(_S170, _S205);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    float diss_sum_0;
    if(_S205)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S174, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S175, &vb0_0, &wb0_0);
        e_1 = lane_0;
        count_0 = 0U;
        uint engaged_0 = 0U;
        uint _S207 = _S206;
        for(;;)
        {
            uint _S208 = 0U;
            bool _S209 = e_1 < _S198;
            uint _S210 = __ballot_sync(_S207, _S209);
            if(_S209)
            {
                uint _S211 = __ballot_sync(_S207, true);
                _S208 = _S211;
            }
            else
            {
                uint _S212 = __ballot_sync(_S207, false);
                uint _S213 = __ballot_sync(_S207, false);
                uint _S214 = __ballot_sync(_S206, true);
                _S171 = _S214;
                break;
            }
            uint _S215 = 0U;
            Box_0 _S216 = ba_1;
            Box_0 _S217 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S218 = pair_point_0(&_S216, &_S217, _S195, e_1, &p_2, &n_2, &d_5);
            bool _S219 = !_S218;
            uint _S220 = __ballot_sync(_S208, _S219);
            if(_S219)
            {
                uint _S221 = _S177 + e_1;
                bool _S222 = !is_nan_0((*(&(globalParams_0->contact_state_0)[_S221])).x);
                uint _S223 = __ballot_sync(_S220, _S222);
                if(_S222)
                {
                    *(&(globalParams_0->contact_state_0)[_S221]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                    uint _S224 = __ballot_sync(_S220, true);
                }
                else
                {
                    uint _S225 = __ballot_sync(_S220, true);
                }
                uint _S226 = __ballot_sync(_S208, false);
                uint _S227 = __ballot_sync(_S207, true);
                _S207 = _S227;
                e_1 = e_1 + lanes_4;
                continue;
            }
            else
            {
                uint _S228 = __ballot_sync(_S208, true);
                _S215 = _S228;
            }
            uint _S229 = count_0 + 1U;
            uint _S230 = _S177 + e_1;
            float4  * _S231 = (&(globalParams_0->contact_state_0)[_S230]);
            float4  entry_0 = *_S231;
            bool _S232 = is_nan_0((*_S231).x);
            uint _S233 = __ballot_sync(_S215, _S232);
            uint _S234;
            if(_S232)
            {
                uint _S235 = __ballot_sync(_S215, true);
                has_state_0 = true;
                _S234 = _S235;
            }
            else
            {
                float4  _S236 = entry_0;
                bool _S237 = (dot_0(float3 {_S236.y, _S236.z, _S236.w}, n_2)) < 0.99000000953674316f;
                uint _S238 = __ballot_sync(_S215, true);
                has_state_0 = _S237;
                _S234 = _S238;
            }
            uint _S239 = __ballot_sync(_S234, has_state_0);
            uint _S240;
            if(has_state_0)
            {
                bool _S241 = d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S182 + 9.99999971718068537e-10f);
                uint _S242 = __ballot_sync(_S239, _S241);
                if(_S241)
                {
                    float _S243 = d_5;
                    uint _S244 = __ballot_sync(_S239, true);
                    stored_sum_0 = _S243;
                }
                else
                {
                    uint _S245 = __ballot_sync(_S239, true);
                    stored_sum_0 = 0.0f;
                }
                entry_0 = make_float4 (stored_sum_0, n_2.x, n_2.y, n_2.z);
                uint _S246 = __ballot_sync(_S234, true);
                _S240 = _S246;
            }
            else
            {
                uint _S247 = __ballot_sync(_S234, true);
                _S240 = _S247;
            }
            *&((&entry_0)->x) = (F32_min((entry_0.x), (d_5)));
            *(&(globalParams_0->contact_state_0)[_S230]) = entry_0;
            bool _S248 = (d_5 - entry_0.x) > 0.0f;
            uint _S249 = __ballot_sync(_S240, _S248);
            uint engaged_1;
            if(_S248)
            {
                uint _S250 = engaged_0 + 1U;
                uint _S251 = __ballot_sync(_S240, true);
                engaged_1 = _S250;
            }
            else
            {
                uint _S252 = __ballot_sync(_S240, true);
                engaged_1 = engaged_0;
            }
            uint _S253 = __ballot_sync(_S207, true);
            count_0 = _S229;
            engaged_0 = engaged_1;
            _S207 = _S253;
            e_1 = e_1 + lanes_4;
        }
        uint _S254 = pair_count_sum_0(count_0, lanes_4, _S171);
        uint _S255 = pair_count_sum_0(engaged_0, lanes_4, _S171);
        bool _S256 = _S254 > 0U;
        uint _S257 = __ballot_sync(_S171, _S256);
        if(_S256)
        {
            float4  _S258 = __ldg(&(&(globalParams_0->chunks_0)[_S174])->cmat_0);
            float _S259 = _S258.x;
            float4  _S260 = __ldg(&(&(globalParams_0->chunks_0)[_S175])->cmat_0);
            float _S261 = _S260.x;
            float3  _S262 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S263 = ba_1;
            Box_0 _S264 = bb_1;
            float _S265 = contact_stiffness_0(_S259, &_S263, _S261, &_S264, _S262);
            float _S266 = _S265 / (F32_max((float(_S255)), (10.0f)));
            e_1 = lane_0;
            fa_0 = _S193;
            ta_0 = _S193;
            fb_0 = _S193;
            tb_0 = _S193;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            count_0 = _S257;
            for(;;)
            {
                uint _S267 = 0U;
                bool _S268 = e_1 < _S198;
                uint _S269 = __ballot_sync(count_0, _S268);
                if(_S268)
                {
                    uint _S270 = __ballot_sync(count_0, true);
                    _S267 = _S270;
                }
                else
                {
                    uint _S271 = __ballot_sync(count_0, false);
                    uint _S272 = __ballot_sync(count_0, false);
                    uint _S273 = __ballot_sync(_S257, true);
                    _S172 = _S273;
                    break;
                }
                uint _S274 = 0U;
                Box_0 _S275 = ba_1;
                Box_0 _S276 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S277 = pair_point_0(&_S275, &_S276, _S195, e_1, &p_3, &n_3, &d_6);
                bool _S278 = !_S277;
                uint _S279 = __ballot_sync(_S267, _S278);
                if(_S278)
                {
                    uint _S280 = __ballot_sync(_S267, false);
                    uint _S281 = __ballot_sync(count_0, true);
                    count_0 = _S281;
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                else
                {
                    uint _S282 = __ballot_sync(_S267, true);
                    _S274 = _S282;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S177 + e_1])).x;
                bool _S283 = eff_0 <= 0.0f;
                uint _S284 = __ballot_sync(_S274, _S283);
                if(_S283)
                {
                    uint _S285 = __ballot_sync(_S274, false);
                    uint _S286 = __ballot_sync(count_0, true);
                    count_0 = _S286;
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                else
                {
                    uint _S287 = __ballot_sync(_S274, true);
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S266, _S179, _S181, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S182, _S255, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S288 = - f_1;
                float3  fb_1 = fb_0 + _S288;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S288);
                float stored_sum_1 = stored_sum_0 + stored_1;
                float diss_sum_1 = diss_sum_0 + diss_0;
                uint _S289 = __ballot_sync(count_0, true);
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                count_0 = _S289;
                e_1 = e_1 + lanes_4;
            }
            float3  _S290 = pair_sum3_0(fa_0, lanes_4, _S172);
            float3  _S291 = pair_sum3_0(ta_0, lanes_4, _S172);
            float3  _S292 = pair_sum3_0(fb_0, lanes_4, _S172);
            float3  _S293 = pair_sum3_0(tb_0, lanes_4, _S172);
            float _S294 = pair_sum_0(stored_sum_0, lanes_4, _S172);
            float _S295 = pair_sum_0(diss_sum_0, lanes_4, _S172);
            uint _S296 = __ballot_sync(_S171, true);
            has_state_0 = true;
            diss_sum_0 = _S295;
            fa_0 = _S290;
            ta_0 = _S291;
            fb_0 = _S292;
            tb_0 = _S293;
            stored_sum_0 = _S294;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_0 = _S193;
            ta_0 = _S193;
            fb_0 = _S193;
            tb_0 = _S193;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_0 = _S193;
        ta_0 = _S193;
        fb_0 = _S193;
        tb_0 = _S193;
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
        e_1 = lane_0;
        for(;;)
        {
            if(e_1 < _S198)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S177 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + lanes_4;
        }
    }
    if(lane_0 != 0U)
    {
        return;
    }
    if(has_state_0)
    {
        comp_add1_0(&((&ledger_1)->y), &((&ledger_1)->z), diss_sum_0);
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
    bool _S297;
    if(loaded_0)
    {
        _S297 = true;
    }
    else
    {
        _S297 = (flags_0 & 2U) != 0U;
    }
    if(_S297)
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
    uint _S298 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S298 + i_8]) = ledger_1;
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
    float3  _S299 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S300 = q_6;
    float3  _S301 = rotate_0(&_S300, _S299);
    (&b_14)->axis0_0 = _S301;
    float3  _S302 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S303 = q_6;
    float3  _S304 = rotate_0(&_S303, _S302);
    (&b_14)->axis1_0 = _S304;
    float3  _S305 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S306 = q_6;
    float3  _S307 = rotate_0(&_S306, _S305);
    (&b_14)->axis2_0 = _S307;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_15)
{
    uint _S308;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S308 = 1U;
    }
    else
    {
        uint _S309 = sample_count_0(b_15);
        _S308 = _S309 + 14U;
    }
    return _S308;
}

static __device__ bool sphere_contact_0(Box_0 * b_16, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S310 = make_float3 (0.0f);
    *point_0 = _S310;
    *normal_3 = _S310;
    *depth_2 = 0.0f;
    float3  _S311 = b_16->center_1;
    float3  r_3 = center_4 - b_16->center_1;
    float3  _S312 = b_16->axis0_0;
    float3  _S313 = b_16->axis1_0;
    float3  _S314 = b_16->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_16->axis0_0), dot_0(r_3, b_16->axis1_0), dot_0(r_3, b_16->axis2_0));
    uint _S315 = b_16->hull_v_0;
    if((b_16->hull_v_0) != 0U)
    {
        uint face_2;
        float _S316 = hull_signed_distance_0(b_16, local_4, &face_2);
        if(_S316 >= radius_0)
        {
            return false;
        }
        float4  _S317 = __ldg((&(globalParams_0->loads_0)[b_16->hull_at_0 + _S315 + face_2]));
        float3  _S318 = box_to_world_0(b_16, float3 {_S317.x, _S317.y, _S317.z});
        *normal_3 = _S318;
        *point_0 = center_4 - _S318 * make_float3 ((F32_max((_S316), (0.0f))));
        *depth_2 = radius_0 - _S316;
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
        *normal_3 = _S312 * make_float3 (dn_0.x) + _S313 * make_float3 (dn_0.y) + _S314 * make_float3 (dn_0.z);
        *point_0 = _S311 + _S312 * make_float3 (q_7.x) + _S313 * make_float3 (q_7.y) + _S314 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S319 = penetration_0(b_16, center_4, &inside_0, &n_4);
    if(!_S319)
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
    float3  _S320 = make_float3 (0.0f);
    *p_4 = _S320;
    *n_5 = _S320;
    *d_8 = 0.0f;
    float4  _S321 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S322 = sphere_contact_0(b_17, _S320, _S321.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S322)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S323 = sample_count_0(b_17);
    if(j_0 < _S323)
    {
        float3  _S324 = sample_point_0(b_17, j_0);
        *p_4 = _S324;
        bool _S325 = penetration_0(shrunk_0, _S324, d_8, n_5);
        return _S325;
    }
    float3  _S326 = sample_point_0(shrunk_0, j_0 - _S323);
    *p_4 = _S326;
    bool _S327 = penetration_0(b_17, _S326, d_8, n_5);
    if(!_S327)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S328)
{
    Impactor_0 * _S329 = (&(globalParams_0->impactors_0)[_S328]);
    WorldPoint_0 wi_0;
    float4  _S330 = _S329->position_1;
    (&wi_0)->hi_0 = float3 {_S330.x, _S330.y, _S330.z};
    float4  _S331 = _S329->position_err_1;
    (&wi_0)->lo_0 = float3 {_S331.x, _S331.y, _S331.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S332, float3  _S333, float3  _S334)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S332])->rotation_1);
    Box_0 b_18;
    (&b_18)->center_1 = _S333;
    float3  _S335 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S336 = q_8;
    float3  _S337 = rotate_0(&_S336, _S335);
    (&b_18)->axis0_0 = _S337;
    float3  _S338 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S339 = q_8;
    float3  _S340 = rotate_0(&_S339, _S338);
    (&b_18)->axis1_0 = _S340;
    float3  _S341 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S342 = q_8;
    float3  _S343 = rotate_0(&_S342, _S341);
    (&b_18)->axis2_0 = _S343;
    (&b_18)->half_2 = _S334;
    (&b_18)->hull_at_0 = 0U;
    (&b_18)->hull_v_0 = 0U;
    (&b_18)->hull_f_0 = 0U;
    return b_18;
}

static __device__ Box_0 impactor_shrunk_0(uint _S344, float _S345, Box_0 * _S346)
{
    Box_0 shrunk_1 = *_S346;
    (&shrunk_1)->half_2 = _S346->half_2 - min_0(make_float3 (_S345), _S346->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S347, float _S348, Box_0 * _S349, Box_0 * _S350, uint _S351, float3  * _S352, float3  * _S353, float * _S354)
{
    Impactor_0 _S355 = *(&(globalParams_0->impactors_0)[_S347]);
    float3  _S356 = make_float3 (0.0f);
    *_S352 = _S356;
    *_S353 = _S356;
    *_S354 = 0.0f;
    if((_S355.shape_0.x) == 0.0f)
    {
        bool _S357 = sphere_contact_0(_S350, _S356, _S355.shape_0.y - _S348, _S352, _S353, _S354);
        if(!_S357)
        {
            return false;
        }
        *_S353 = - *_S353;
        return true;
    }
    uint _S358 = sample_count_0(_S350);
    if(_S351 < _S358)
    {
        float3  _S359 = sample_point_0(_S350, _S351);
        *_S352 = _S359;
        bool _S360 = penetration_0(_S349, _S359, _S354, _S353);
        return _S360;
    }
    float3  _S361 = sample_point_0(_S349, _S351 - _S358);
    *_S352 = _S361;
    bool _S362 = penetration_0(_S350, _S361, _S354, _S353);
    if(!_S362)
    {
        return false;
    }
    *_S353 = - *_S353;
    return true;
}

static __device__ uint impactor_contact_count_0(uint _S363, float _S364, Box_0 * _S365, Box_0 * _S366)
{
    Impactor_0 _S367 = *(&(globalParams_0->impactors_0)[_S363]);
    uint j_1 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S368 = _S367;
        uint _S369 = impactor_slots_0(&_S368, _S366);
        if(j_1 < _S369)
        {
        }
        else
        {
            break;
        }
        float3  p_5;
        float3  n_6;
        float d_9;
        bool _S370 = impactor_contact_1(_S363, _S364, _S365, _S366, j_1, &p_5, &n_6, &d_9);
        if(_S370)
        {
            count_1 = count_1 + 1U;
        }
        j_1 = j_1 + 1U;
    }
    return count_1;
}

static __device__ void impactor_candidate_forces_0(uint k_5)
{
    uint _S371 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S372 = 3U * k_5;
    uint at_1 = _S371 + _S372;
    uint _S373 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S374 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S375 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S375]);
    float _S376 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S377 = make_float3 (0.0f);
    uint _S378 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S378 + _S372]);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if((imp_3.cand_0.z) == 0U)
    {
        WorldPoint_0 _S379 = impactor_point_0(_S375);
        WorldPoint_0 _S380 = chunk_world_0(_S373);
        WorldPoint_0 _S381 = _S379;
        float3  _S382 = world_diff_0(&_S380, &_S381);
        float _S383 = length_0(_S382);
        float _S384 = imp_3.half_1.w;
        float4  _S385 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->half_0);
        if(!(_S383 > (_S384 + _S385.w)))
        {
            float4  _S386 = imp_3.half_1;
            Box_0 _S387 = impactor_box_1(_S375, _S377, float3 {_S386.x, _S386.y, _S386.z});
            Box_0 b_19 = chunk_box_0(_S373, _S382);
            float _S388 = imp_3.mat_0.x;
            float4  _S389 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->cmat_0);
            float _S390 = _S389.x;
            float3  _S391 = b_19.center_1 - _S387.center_1;
            Box_0 _S392 = _S387;
            Box_0 _S393 = b_19;
            float _S394 = contact_stiffness_0(_S388, &_S392, _S390, &_S393, _S391);
            float _S395 = imp_3.geom_0.y;
            Box_0 _S396 = _S387;
            Box_0 _S397 = impactor_shrunk_0(_S375, _S395, &_S396);
            Box_0 _S398 = _S397;
            Box_0 _S399 = b_19;
            uint _S400 = impactor_contact_count_0(_S375, _S395, &_S398, &_S399);
            bool _S401 = (imp_3.shape_0.x) == 0.0f;
            float _S402;
            if(_S401)
            {
                _S402 = _S394;
            }
            else
            {
                _S402 = _S394 / (F32_max((float(_S400)), (10.0f)));
            }
            uint _S403;
            if(_S401)
            {
                _S403 = 1U;
            }
            else
            {
                _S403 = _S400;
            }
            float4  _S404 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->center_0);
            float m_1 = _S404.w;
            float _S405 = imp_3.mat_0.z;
            float _S406 = m_1 * _S405 / (m_1 + _S405);
            float _S407 = __ldg(&globalParams_0->params_0->pair_friction_0);
            float _S408;
            if(_S407 >= 0.0f)
            {
                float _S409 = __ldg(&globalParams_0->params_0->pair_friction_0);
                _S408 = _S409;
            }
            else
            {
                float _S410 = imp_3.mat_0.y;
                float4  _S411 = __ldg(&(&(globalParams_0->chunks_0)[_S373])->cmat_0);
                _S408 = (F32_min((_S410), (_S411.y)));
            }
            float4  _S412 = imp_3.velocity_1;
            float4  _S413 = imp_3.velocity_err_1;
            float3  _S414 = float3 {_S412.x, _S412.y, _S412.z} + float3 {_S413.x, _S413.y, _S413.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S373, &vc_0, &wc_0);
            hit_0 = false;
            uint j_2 = 0U;
            f_sum_0 = _S377;
            t_sum_0 = _S377;
            imp_f_0 = _S377;
            imp_t_0 = _S377;
            for(;;)
            {
                bool _S415;
                if(_S400 > 0U)
                {
                    Impactor_0 _S416 = imp_3;
                    Box_0 _S417 = b_19;
                    uint _S418 = impactor_slots_0(&_S416, &_S417);
                    _S415 = j_2 < _S418;
                }
                else
                {
                    _S415 = false;
                }
                if(_S415)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S419 = imp_3;
                Box_0 _S420 = _S397;
                Box_0 _S421 = b_19;
                float3  p_6;
                float3  nrm_0;
                float dep_0;
                bool _S422 = impactor_contact_0(&_S419, _S395, &_S420, &_S421, j_2, &p_6, &nrm_0, &dep_0);
                if(!_S422)
                {
                    j_2 = j_2 + 1U;
                    continue;
                }
                float4  _S423 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S402, _S406, _S408, dep_0 * imp_3.geom_0.x, nrm_0, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S414 + cross_0(float3 {_S423.x, _S423.y, _S423.z}, p_6)), _S376, _S403, &stored_2, &diss_1);
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
            f_sum_0 = _S377;
            t_sum_0 = _S377;
            imp_f_0 = _S377;
            imp_t_0 = _S377;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S377;
        t_sum_0 = _S377;
        imp_f_0 = _S377;
        imp_t_0 = _S377;
    }
    uint _S424 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S425 = 2U * _S374;
    *(&(globalParams_0->scratch_0)[_S424 + _S425]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S426 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S426 + _S425 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S427 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S427 + _S372]) = data_0;
    uint _S428 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S428 + _S372 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S429 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S429 + _S372 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(2U);
    }
    return;
}

static __device__ Quat_0 quat_mul_0(Quat_0 * a_6, Quat_0 * o_0)
{
    Quat_0 r_4;
    (&r_4)->w_1 = a_6->w_1 * o_0->w_1 - a_6->x_12 * o_0->x_12 - a_6->y_4 * o_0->y_4 - a_6->z_0 * o_0->z_0;
    (&r_4)->x_12 = a_6->w_1 * o_0->x_12 + a_6->x_12 * o_0->w_1 + a_6->y_4 * o_0->z_0 - a_6->z_0 * o_0->y_4;
    (&r_4)->y_4 = a_6->w_1 * o_0->y_4 - a_6->x_12 * o_0->z_0 + a_6->y_4 * o_0->w_1 + a_6->z_0 * o_0->x_12;
    (&r_4)->z_0 = a_6->w_1 * o_0->z_0 + a_6->x_12 * o_0->y_4 - a_6->y_4 * o_0->x_12 + a_6->z_0 * o_0->w_1;
    return r_4;
}

static __device__ void travel_check_0(uint c_4)
{
    ChunkStatic_0 * _S430 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S431 = __ldg(&_S430->cinfo_0);
    if((_S431.z) == 0U)
    {
        return;
    }
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S432 = __ldg(&_S430->start_hi_0);
    float3  _S433 = wp_0.hi_0 - float3 {_S432.x, _S432.y, _S432.z};
    float4  _S434 = __ldg(&_S430->start_lo_0);
    float3  moved_0 = _S433 + (wp_0.lo_0 - float3 {_S434.x, _S434.y, _S434.z}) + wp_0.rel_0;
    float _S435 = __ldg(&globalParams_0->params_0->t_hi_0);
    float4  _S436 = __ldg(&_S430->start_vel_0);
    float _S437 = _S435 - _S436.w;
    float _S438 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S439 = _S437 + (_S438 - _S434.w);
    uint4  _S440 = __ldg(&_S430->info_0);
    uint _S441 = _S440.y;
    uint _S442 = (&(globalParams_0->islands_0)[_S441])->info_1.w;
    uint _S443 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S444 = float(_S442 - _S443);
    float _S445 = __ldg(&globalParams_0->params_0->dt_0);
    float since_0 = _S439 + _S444 * _S445;
    float3  _S446 = float3 {_S436.x, _S436.y, _S436.z} * make_float3 (since_0);
    uint _S447 = _S431.w;
    float3  _S448;
    if((_S447 & 2U) != 0U)
    {
        float4  _S449 = __ldg(&globalParams_0->params_0->gravity_0);
        _S448 = make_float3 (0.5f) * float3 {_S449.x, _S449.y, _S449.z} * make_float3 (since_0) * make_float3 (since_0);
    }
    else
    {
        _S448 = make_float3 (0.0f);
    }
    float travel_0 = length_0(moved_0 - (_S446 + _S448));
    float travel_1;
    if((_S447 & 1U) != 0U)
    {
        float4  _S450 = *(&(globalParams_0->state_0)[4U * c_4 + 1U]);
        float3  th_1 = float3 {_S450.x, _S450.y, _S450.z};
        Quat_0 _S451 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S452 = quat_of_0((&(globalParams_0->islands_0)[_S441])->rotation_0);
        Quat_0 _S453 = _S451;
        Quat_0 _S454 = quat_mul_0(&_S452, &_S453);
        float4  _S455 = __ldg(&_S430->start_rot_0);
        Quat_0 _S456 = quat_of_0(make_float4 ((- float3 {_S455.x, _S455.y, _S455.z}).x, (- float3 {_S455.x, _S455.y, _S455.z}).y, (- float3 {_S455.x, _S455.y, _S455.z}).z, _S455.w));
        Quat_0 _S457 = _S454;
        Quat_0 _S458 = quat_mul_0(&_S456, &_S457);
        float _S459 = 2.0f * (F32_atan2((length_0(make_float3 (_S458.x_12, _S458.y_4, _S458.z_0))), ((F32_abs((_S458.w_1))))));
        float4  _S460 = __ldg(&_S430->half_0);
        travel_1 = travel_0 + _S459 * _S460.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S432.w))
    {
        uint _S461 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S462 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S461])->info_1)->z) = ((&(globalParams_0->islands_0)[_S462])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint3  _S463 = blockIdx * blockDim + threadIdx;
    uint _S464 = __ballot_sync(4294967295U, true);
    uint i_9 = _S463.x;
    uint lanes_5 = pair_lane_count_0();
    uint _S465 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S465 * lanes_5;
    bool _S466 = i_9 < pair_threads_0;
    uint _S467 = __ballot_sync(_S464, _S466);
    if(_S466)
    {
        bool _S468 = pair_any_0(stopped_0(), lanes_5, _S467);
        bool _S469 = !_S468;
        uint _S470 = __ballot_sync(_S467, _S469);
        if(_S469)
        {
            uint _S471 = i_9 / lanes_5;
            uint _S472 = i_9 % lanes_5;
            pair_contact_0(_S471, _S472, lanes_5, _S470);
            uint _S473 = __ballot_sync(_S467, true);
        }
        return;
    }
    if(stopped_0())
    {
        return;
    }
    uint j_3 = i_9 - pair_threads_0;
    uint _S474 = __ldg(&globalParams_0->params_0->cand_count_0);
    if(j_3 < _S474)
    {
        impactor_candidate_forces_0(j_3);
    }
    else
    {
        uint _S475 = __ldg(&globalParams_0->params_0->cand_count_0);
        uint _S476 = __ldg(&globalParams_0->params_0->chunk_count_0);
        if(j_3 < (_S475 + _S476))
        {
            uint _S477 = __ldg(&globalParams_0->params_0->cand_count_0);
            travel_check_0(j_3 - _S477);
        }
    }
    return;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S478 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S479;
    if(k_6 >= _S478)
    {
        _S479 = true;
    }
    else
    {
        _S479 = stopped_0();
    }
    if(_S479)
    {
        return;
    }
    uint _S480 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S481 = 3U * k_6;
    uint at_2 = _S480 + _S481;
    uint _S482 = __ldg((&(globalParams_0->index_0)[at_2]));
    uint _S483 = __ldg((&(globalParams_0->index_0)[at_2 + 2U]));
    Impactor_0 * _S484 = (&(globalParams_0->impactors_0)[_S483]);
    Impactor_0 imp_4 = *_S484;
    if(((*_S484).cand_0.z) == 0U)
    {
        _S479 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S479 = false;
    }
    float total_0;
    float ksum_0;
    if(_S479)
    {
        WorldPoint_0 _S485 = impactor_point_0(_S483);
        WorldPoint_0 _S486 = chunk_world_0(_S482);
        WorldPoint_0 _S487 = _S485;
        float3  _S488 = world_diff_0(&_S486, &_S487);
        float _S489 = length_0(_S488);
        float _S490 = imp_4.half_1.w;
        float4  _S491 = __ldg(&(&(globalParams_0->chunks_0)[_S482])->half_0);
        if(!(_S489 > (_S490 + _S491.w)))
        {
            float4  _S492 = imp_4.half_1;
            Box_0 _S493 = impactor_box_1(_S483, make_float3 (0.0f), float3 {_S492.x, _S492.y, _S492.z});
            Box_0 b_20 = chunk_box_0(_S482, _S488);
            float _S494 = imp_4.mat_0.x;
            float4  _S495 = __ldg(&(&(globalParams_0->chunks_0)[_S482])->cmat_0);
            float _S496 = _S495.x;
            float3  _S497 = b_20.center_1 - _S493.center_1;
            Box_0 _S498 = _S493;
            Box_0 _S499 = b_20;
            float _S500 = contact_stiffness_0(_S494, &_S498, _S496, &_S499, _S497);
            float _S501 = imp_4.crush_1.w;
            Box_0 _S502 = _S493;
            Box_0 _S503 = impactor_shrunk_0(_S483, _S501, &_S502);
            Box_0 _S504 = _S503;
            Box_0 _S505 = b_20;
            uint _S506 = impactor_contact_count_0(_S483, _S501, &_S504, &_S505);
            float _S507;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S507 = _S500;
            }
            else
            {
                _S507 = _S500 / (F32_max((float(_S506)), (10.0f)));
            }
            uint j_4 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S506 > 0U)
                {
                    Impactor_0 _S508 = imp_4;
                    Box_0 _S509 = b_20;
                    uint _S510 = impactor_slots_0(&_S508, &_S509);
                    _S479 = j_4 < _S510;
                }
                else
                {
                    _S479 = false;
                }
                if(_S479)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S511 = imp_4;
                Box_0 _S512 = _S503;
                Box_0 _S513 = b_20;
                float3  p_7;
                float3  nrm_1;
                float dep_1;
                bool _S514 = impactor_contact_0(&_S511, _S501, &_S512, &_S513, j_4, &p_7, &nrm_1, &dep_1);
                if(!_S514)
                {
                    j_4 = j_4 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S507;
                total_0 = total_0 + _S507 * dep_1;
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
    uint _S515 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S515 + _S481]);
    uint _S516 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S516 + _S481]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S517;
    uint _S518 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S519 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S520 = ii_0 >= _S519;
    uint _S521 = __ballot_sync(_S518, _S520);
    bool _S522;
    uint k_7;
    if(_S520)
    {
        uint _S523 = __ballot_sync(_S518, true);
        _S522 = true;
        k_7 = _S523;
    }
    else
    {
        bool _S524 = stopped_0();
        uint _S525 = __ballot_sync(_S518, true);
        _S522 = _S524;
        k_7 = _S525;
    }
    uint _S526 = 0U;
    uint _S527 = __ballot_sync(k_7, _S522);
    if(_S522)
    {
        return;
    }
    else
    {
        uint _S528 = __ballot_sync(k_7, true);
        _S526 = _S528;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S529 = make_float4 (0.0f);
    float4  shares_0 = _S529;
    float4  unused_0 = _S529;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S530;
    _S530 = _S526;
    for(;;)
    {
        bool _S531 = k_7 < ((&imp_5)->cand_0.y);
        uint _S532 = __ballot_sync(_S530, _S531);
        if(_S531)
        {
            uint _S533 = __ballot_sync(_S530, true);
        }
        else
        {
            uint _S534 = __ballot_sync(_S530, false);
            uint _S535 = __ballot_sync(_S530, false);
            uint _S536 = __ballot_sync(_S526, true);
            _S517 = _S536;
            break;
        }
        uint _S537 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S537 + 3U * k_7]);
        uint _S538 = __ballot_sync(_S530, true);
        k_7 = k_7 + 256U;
        _S530 = _S538;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S517);
    bool _S539 = tid_2 != 0U;
    uint _S540 = __ballot_sync(_S517, _S539);
    if(_S539)
    {
        _S522 = true;
    }
    else
    {
        _S522 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S522)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S522 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S522 = false;
    }
    if(_S522)
    {
        _S522 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S522 = false;
    }
    if(_S522)
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

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_18)
{
    float3  t_2 = *sum_1 + x_18;
    float3  _S541 = abs_1(x_18);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S541, *sum_1,x_18) - t_2 + _slang_select((abs_1(*sum_1)) >= _S541, x_18,*sum_1));
    *sum_1 = t_2;
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_4)
{
    Quat_0 c_5;
    (&c_5)->w_1 = q_9->w_1;
    (&c_5)->x_12 = - q_9->x_12;
    (&c_5)->y_4 = - q_9->y_4;
    (&c_5)->z_0 = - q_9->z_0;
    Quat_0 _S542 = c_5;
    float3  _S543 = rotate_0(&_S542, v_4);
    return _S543;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_5)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_5), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_5), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_5));
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S544 = inverse_rotate_0(q_10, v_6);
    float3  _S545 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S544));
    return _S545;
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_1)
{
    float s_1 = (F32_sin((0.25f * angle_1)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_1))))).z, -2.0f * s_1 * s_1);
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_12, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_19)
{
    float4  t_3 = *sum_2 + x_19;
    float4  _S546 = abs_0(x_19);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S546, *sum_2,x_19) - t_3 + _slang_select((abs_0(*sum_2)) >= _S546, x_19,*sum_2));
    *sum_2 = t_3;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_20)
{
    Quat_0 _S547 = *hi_1;
    float4  _S548 = quat_vec_0(&_S547);
    float4  sum_3 = _S548;
    comp_add4_0(&sum_3, lo_1, x_20);
    float4  t_4 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_4 - sum_3);
    *hi_1 = quat_of_0(t_4);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_0, float dt_2)
{
    float _S549 = length_0(omega_0);
    float angle_2 = _S549 * dt_2;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_0 / make_float3 (_S549), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_12 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S550 = dq_0;
    Quat_0 _S551 = *hi_2;
    Quat_0 _S552 = quat_mul_0(&_S550, &_S551);
    Quat_0 _S553 = _S552;
    float4  _S554 = quat_vec_0(&_S553);
    quat_accumulate_0(hi_2, lo_2, _S554);
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S555 = 0U;
    uint _S556;
    float3  p_8;
    uint _S557 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_3 = threadIdx.x;
    uint _S558 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S559 = ii_1 >= _S558;
    uint _S560 = __ballot_sync(_S557, _S559);
    if(_S559)
    {
        return;
    }
    else
    {
        uint _S561 = __ballot_sync(_S557, true);
        _S555 = _S561;
    }
    uint _S562 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S563 = (&(globalParams_0->islands_0)[_S562]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_1]);
    uint4  _S564 = _S563->info_1;
    bool _S565 = ((_S563->info_1.z) & 1U) != 0U;
    uint _S566 = __ballot_sync(_S555, _S565);
    bool _S567;
    uint k_8;
    if(_S565)
    {
        uint _S568 = __ballot_sync(_S555, true);
        _S567 = true;
        k_8 = _S568;
    }
    else
    {
        uint _S569 = _S555 & (~_S566);
        uint _S570 = _S564.y;
        bool _S571 = _S570 != 0U;
        uint _S572 = __ballot_sync(_S569, _S571);
        if(_S571)
        {
            bool _S573 = ((&imp_6)->cand_0.w) >= _S570;
            uint _S574 = __ballot_sync(_S569, true);
            _S567 = _S573;
        }
        else
        {
            uint _S575 = __ballot_sync(_S569, true);
            _S567 = false;
        }
        uint _S576 = __ballot_sync(_S555, true);
        k_8 = _S576;
    }
    uint _S577 = 0U;
    uint _S578 = __ballot_sync(k_8, _S567);
    if(_S567)
    {
        return;
    }
    else
    {
        uint _S579 = __ballot_sync(k_8, true);
        _S577 = _S579;
    }
    uint _S580 = 0U;
    bool _S581 = ((&imp_6)->cand_0.z) != 0U;
    uint _S582 = __ballot_sync(_S577, _S581);
    if(_S581)
    {
        if(tid_3 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_1])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S583 = __ballot_sync(_S577, true);
        _S580 = _S583;
    }
    float4  _S584 = make_float4 (0.0f);
    float4  rf_0 = _S584;
    float4  rt_0 = _S584;
    k_8 = (&imp_6)->cand_0.x + tid_3;
    uint total_points_0;
    total_points_0 = _S580;
    for(;;)
    {
        bool _S585 = k_8 < ((&imp_6)->cand_0.y);
        uint _S586 = __ballot_sync(total_points_0, _S585);
        if(_S585)
        {
            uint _S587 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S588 = __ballot_sync(total_points_0, false);
            uint _S589 = __ballot_sync(total_points_0, false);
            uint _S590 = __ballot_sync(_S580, true);
            _S556 = _S590;
            break;
        }
        uint _S591 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S592 = 3U * k_8;
        rf_0 = rf_0 + *(&(globalParams_0->scratch_0)[_S591 + _S592 + 1U]);
        uint _S593 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S593 + _S592 + 2U]);
        uint _S594 = __ballot_sync(total_points_0, true);
        k_8 = k_8 + 256U;
        total_points_0 = _S594;
    }
    group_sum2_0(tid_3, &rf_0, &rt_0, _S556);
    bool _S595 = tid_3 != 0U;
    uint _S596 = __ballot_sync(_S556, _S595);
    if(_S595)
    {
        return;
    }
    float _S597 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S598 = make_float3 (0.0f);
    uint _S599 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S599 != 0U)
    {
        float4  _S600 = (&imp_6)->half_1;
        float3  _S601 = float3 {_S600.x, _S600.y, _S600.z};
        Impactor_0 _S602 = imp_6;
        Box_0 _S603 = impactor_box_0(&_S602, _S598, _S601);
        float4  _S604 = (&imp_6)->velocity_1;
        float4  _S605 = (&imp_6)->velocity_err_1;
        float3  _S606 = float3 {_S604.x, _S604.y, _S604.z} + float3 {_S605.x, _S605.y, _S605.z};
        float _S607 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S608 = (&imp_6)->mat_0.x;
        float3  _S609 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S610 = _S603;
        Box_0 _S611 = _S603;
        float _S612 = contact_stiffness_0(_S607, &_S610, _S608, &_S611, _S609);
        float _S613 = (&imp_6)->position_1.z;
        float _S614 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S615 = _S613 - _S614;
        float _S616 = (&imp_6)->position_err_1.z;
        float _S617 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S618 = _S615 + (_S616 - _S617);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S619 = _S612 / float((U32_min((total_points_0), (5U))));
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
                Box_0 _S620 = _S603;
                float3  _S621 = sample_point_0(&_S620, s_2);
                p_8 = _S621;
            }
            if((_S618 + p_8.z) < 0.0f)
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
        load_f_0 = _S598;
        load_t_0 = _S598;
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
                Box_0 _S622 = _S603;
                float3  _S623 = sample_point_0(&_S622, s_2);
                p_8 = _S623;
            }
            float depth_3 = - (_S618 + p_8.z);
            if(depth_3 <= 0.0f)
            {
                s_2 = s_2 + 1U;
                continue;
            }
            float4  _S624 = (&imp_6)->angular_velocity_1;
            float3  v_7 = _S606 + cross_0(float3 {_S624.x, _S624.y, _S624.z}, p_8);
            float _S625 = (&imp_6)->mat_0.z;
            float _S626 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_3;
            float diss_2;
            float3  f_3 = penalty_force_0(_S619, _S625, _S626, depth_3, _S609, v_7, _S597, below_0, &stored_3, &diss_2);
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
        load_f_0 = _S598;
        load_t_0 = _S598;
    }
    float4  _S627 = rf_0;
    float3  load_f_2 = float3 {_S627.x, _S627.y, _S627.z} + load_f_0;
    float4  _S628 = rt_0;
    float3  load_t_2 = float3 {_S628.x, _S628.y, _S628.z} + load_t_0;
    float m_2 = (&imp_6)->mat_0.z;
    float4  _S629 = (&imp_6)->velocity_1;
    float3  vel_0 = float3 {_S629.x, _S629.y, _S629.z};
    float4  _S630 = (&imp_6)->velocity_err_1;
    float3  vel_err_0 = float3 {_S630.x, _S630.y, _S630.z};
    float3  _S631 = load_f_2 / make_float3 (m_2);
    float4  _S632 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_0, &vel_err_0, (_S631 + float3 {_S632.x, _S632.y, _S632.z}) * make_float3 (_S597));
    Quat_0 _S633 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_12 = _S633;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S634 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S634.x, _S634.y, _S634.z};
    float4  _S635 = (&imp_6)->momentum_err_1;
    float3  l_err_0 = float3 {_S635.x, _S635.y, _S635.z};
    comp_add_0(&l_hi_0, &l_err_0, load_t_2 * make_float3 (_S597));
    float3  l_1 = l_hi_0 + l_err_0;
    Quat_0 _S636 = _S633;
    float3  _S637 = world_mul_0(&_S636, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    float4  _S638 = (&imp_6)->position_1;
    float3  pos_0 = float3 {_S638.x, _S638.y, _S638.z};
    float4  _S639 = (&imp_6)->position_err_1;
    float3  pos_err_0 = float3 {_S639.x, _S639.y, _S639.z};
    comp_add_0(&pos_0, &pos_err_0, (vel_0 + vel_err_0) * make_float3 (_S597));
    turn_left_0(&q_12, &q_err_0, _S637, _S597);
    Quat_0 _S640 = q_12;
    float3  _S641 = world_mul_0(&_S640, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_1);
    (&imp_6)->angular_velocity_1 = make_float4 (_S641.x, _S641.y, _S641.z, 0.0f);
    Quat_0 _S642 = q_12;
    float4  _S643 = quat_vec_0(&_S642);
    (&imp_6)->rotation_1 = _S643;
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
    uint _S644 = (&imp_6)->cand_0.w - 1U;
    uint _S645 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_9 = _S644 - _S645;
    uint _S646 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_9 < _S646)
    {
        uint _S647 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S648 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_3 = _S647 + 2U * (ii_1 * _S648 + k_9);
        *(&(globalParams_0->scratch_0)[at_3]) = make_float4 ((vel_0 + vel_err_0).x, (vel_0 + vel_err_0).y, (vel_0 + vel_err_0).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_3 + 1U]) = make_float4 ((pos_0 + pos_err_0).x, (pos_0 + pos_err_0).y, (pos_0 + pos_err_0).z, 0.0f);
    }
    return;
}

static __device__ void ground_contact_0(uint c_6, bool account_0, float3  * f_4, float3  * t_5)
{
    ChunkStatic_0 * _S649 = (&(globalParams_0->chunks_0)[c_6]);
    WorldPoint_0 wp_1 = chunk_world_0(c_6);
    float _S650 = wp_1.hi_0.z;
    float _S651 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S652 = _S650 - _S651;
    float _S653 = wp_1.lo_0.z;
    float _S654 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S652 + (_S653 - _S654) + wp_1.rel_0.z;
    float4  _S655 = __ldg(&_S649->half_0);
    if((above_0 - _S655.w) > 0.0f)
    {
        return;
    }
    Box_0 b_21 = chunk_box_0(c_6, make_float3 (0.0f));
    float _S656 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S657 = __ldg(&_S649->cmat_0);
    float _S658 = _S657.x;
    float3  _S659 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S660 = b_21;
    Box_0 _S661 = b_21;
    float _S662 = contact_stiffness_0(_S656, &_S660, _S658, &_S661, _S659);
    Box_0 _S663 = b_21;
    uint _S664 = sample_count_0(&_S663);
    uint s_3 = 0U;
    uint n_7 = 0U;
    for(;;)
    {
        if(s_3 < _S664)
        {
        }
        else
        {
            break;
        }
        Box_0 _S665 = b_21;
        float3  _S666 = sample_point_0(&_S665, s_3);
        if((above_0 + _S666.z) < 0.0f)
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
    uint _S667 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S668 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S667 + _S668 + c_6]);
    s_3 = 0U;
    for(;;)
    {
        if(s_3 < _S664)
        {
        }
        else
        {
            break;
        }
        Box_0 _S669 = b_21;
        float3  _S670 = sample_point_0(&_S669, s_3);
        float _S671 = above_0 + _S670.z;
        if(!(_S671 < 0.0f))
        {
            s_3 = s_3 + 1U;
            continue;
        }
        float depth_4 = - _S671;
        float3  v_8 = vc_1 + cross_0(wc_1, _S670);
        float _S672 = _S662 / float((U32_max((n_7), (5U))));
        float4  _S673 = __ldg(&_S649->center_0);
        float _S674 = _S673.w;
        float _S675 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S676 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_4;
        float diss_3;
        float3  g_0 = penalty_force_0(_S672, _S674, _S675, depth_4, _S659, v_8, _S676, n_7, &stored_4, &diss_3);
        *f_4 = *f_4 + g_0;
        *t_5 = *t_5 + cross_0(_S670, g_0);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_3);
        s_3 = s_3 + 1U;
    }
    if(account_0)
    {
        uint _S677 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S678 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S677 + _S678 + c_6]) = ledger_2;
    }
    return;
}

extern "C" __global__ void contact_sums()
{
    uint g_1 = (blockIdx * blockDim + threadIdx).x;
    uint _S679 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S680;
    if(g_1 >= _S679)
    {
        _S680 = true;
    }
    else
    {
        _S680 = stopped_0();
    }
    if(_S680)
    {
        return;
    }
    uint _S681 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S682 = 3U * g_1;
    uint _S683 = __ldg((&(globalParams_0->index_0)[_S681 + _S682]));
    uint _S684 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S685 = __ldg((&(globalParams_0->index_0)[_S684 + _S682 + 1U]));
    uint _S686 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S687 = __ldg((&(globalParams_0->index_0)[_S686 + _S682 + 2U]));
    float3  _S688 = make_float3 (0.0f);
    float3  f_5 = _S688;
    float3  t_6 = _S688;
    uint e_2 = _S685;
    for(;;)
    {
        if(e_2 < _S687)
        {
        }
        else
        {
            break;
        }
        uint _S689 = __ldg((&(globalParams_0->index_0)[e_2]));
        if(_S689 == 2147483648U)
        {
            ground_contact_0(_S683, true, &f_5, &t_6);
            e_2 = e_2 + 1U;
            continue;
        }
        uint _S690 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S691 = 2U * _S689;
        float4  _S692 = *(&(globalParams_0->scratch_0)[_S690 + _S691]);
        f_5 = f_5 + float3 {_S692.x, _S692.y, _S692.z};
        uint _S693 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S694 = *(&(globalParams_0->scratch_0)[_S693 + _S691 + 1U]);
        t_6 = t_6 + float3 {_S694.x, _S694.y, _S694.z};
        e_2 = e_2 + 1U;
    }
    uint _S695 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S696 = 2U * g_1;
    *(&(globalParams_0->scratch_0)[_S695 + _S696]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S697 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S697 + _S696 + 1U]) = make_float4 (t_6.x, t_6.y, t_6.z, 0.0f);
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
    uint _S698 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S699 = (&(globalParams_0->islands_0)[_S698])->info_1;
    bool _S700;
    if((((&(globalParams_0->islands_0)[_S698])->info_1.z) & 1U) != 0U)
    {
        _S700 = true;
    }
    else
    {
        uint _S701 = _S699.y;
        if(_S701 != 0U)
        {
            _S700 = _S701 <= (isl_0->info_1.w);
        }
        else
        {
            _S700 = false;
        }
    }
    return _S700;
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
    float4  _S702 = isl_1->position_0;
    (&rg_0)->pos_1 = float3 {_S702.x, _S702.y, _S702.z};
    float4  _S703 = isl_1->position_err_0;
    (&rg_0)->pos_err_1 = float3 {_S703.x, _S703.y, _S703.z};
    float4  _S704 = isl_1->velocity_0;
    (&rg_0)->vel_1 = float3 {_S704.x, _S704.y, _S704.z};
    float4  _S705 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_1 = float3 {_S705.x, _S705.y, _S705.z};
    float4  _S706 = isl_1->angular_velocity_0;
    (&rg_0)->w_4 = float3 {_S706.x, _S706.y, _S706.z};
    float4  _S707 = isl_1->momentum_0;
    (&rg_0)->l_2 = float3 {_S707.x, _S707.y, _S707.z};
    float4  _S708 = isl_1->momentum_err_0;
    (&rg_0)->l_err_1 = float3 {_S708.x, _S708.y, _S708.z};
    float3  _S709 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S709;
    (&rg_0)->a_7 = _S709;
    (&rg_0)->alpha_0 = _S709;
    return rg_0;
}

static __device__ float time_since_0(float4  origin_0, uint k_10, float dt_3)
{
    float _S710 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S711 = _S710 - origin_0.x;
    float _S712 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S711 + (_S712 - origin_0.y) + float(k_10) * dt_3;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S713 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S713.x))
    {
        return _S713.y;
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
        uint _S714 = offset_0 + i_10;
        float4  _S715 = __ldg((&(globalParams_0->loads_0)[_S714]));
        float _S716 = _S715.x;
        if(tau_0 <= _S716)
        {
            float4  _S717 = __ldg((&(globalParams_0->loads_0)[_S714 - 1U]));
            float _S718 = _S717.x;
            float _S719 = _S717.y;
            return _S719 + (tau_0 - _S718) / (F32_max((_S716 - _S718), (1.00000000317107685e-30f))) * (_S715.y - _S719);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S720 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S720.y;
}

static __device__ float eval_function_0(uint term_0, uint k_11, float dt_4, float shift_0)
{
    uint _S721 = 5U * term_0;
    float4  _S722 = __ldg((&(globalParams_0->loads_0)[_S721]));
    uint4  info_2 = asuint_0(_S722);
    float4  _S723 = __ldg((&(globalParams_0->loads_0)[_S721 + 3U]));
    float4  _S724 = __ldg((&(globalParams_0->loads_0)[_S721 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S723.z;
    }
    float tau_1 = time_since_0(_S723, k_11, dt_4) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S725 = _S724.x;
            if(tau_1 >= _S725)
            {
                shape_1 = _S724.y;
            }
            else
            {
                shape_1 = _S724.y * tau_1 / _S725;
            }
        }
        return shape_1;
    }
    bool _S726;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S726 = true;
        }
        else
        {
            _S726 = tau_1 > (_S724.x);
        }
        if(_S726)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S724.y * (F32_sin((3.14159274101257324f * tau_1 / _S724.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S724.y;
        if(sn_0 < 0.0f)
        {
            _S726 = true;
        }
        else
        {
            _S726 = sn_0 > 1.0f;
        }
        if(_S726)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S724.x * (1.0f - sn_0) * (F32_exp((- _S724.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S724.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S724.x;
        if(sn_1 < 0.0f)
        {
            _S726 = true;
        }
        else
        {
            _S726 = sn_1 > 1.0f;
        }
        if(_S726)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S724.y * sn_1)));
        }
        float clearing_0 = _S723.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S727 = _S724.w;
        return (_S727 + (_S724.z - _S727) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S728 = _S724.y;
        if(tau_1 < _S728)
        {
            return _S724.x;
        }
        float s_4 = tau_1 - _S728;
        float _S729 = _S724.w;
        if(s_4 > _S729)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S724.z * (F32_sin((3.14159274101257324f * s_4 / _S729)));
        }
        return shape_1;
    }
    float _S730 = _S724.x;
    if(_S730 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S730, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_6, float3  t_7)
{
    uint _S731 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S731 == 0U)
    {
        return;
    }
    uint _S732 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S733 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S732 + _S733]) = make_float4 (f_6.x, f_6.y, f_6.z, 0.0f);
    uint _S734 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S734 + _S733 + 1U]) = make_float4 (t_7.x, t_7.y, t_7.z, 0.0f);
    uint _S735 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S736 = (&(globalParams_0->scratch_0)[_S735 + _S733]);
    uint _S737 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S738 = *(&(globalParams_0->scratch_0)[_S737 + _S733]);
    *_S736 = make_float4 ((float3 {_S738.x, _S738.y, _S738.z} + f_6).x, (float3 {_S738.x, _S738.y, _S738.z} + f_6).y, (float3 {_S738.x, _S738.y, _S738.z} + f_6).z, 0.0f);
    uint _S739 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S740 = (&(globalParams_0->scratch_0)[_S739 + _S733 + 1U]);
    uint _S741 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S742 = *(&(globalParams_0->scratch_0)[_S741 + _S733 + 1U]);
    *_S740 = make_float4 ((float3 {_S742.x, _S742.y, _S742.z} + t_7).x, (float3 {_S742.x, _S742.y, _S742.z} + t_7).y, (float3 {_S742.x, _S742.y, _S742.z} + t_7).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S743, uint _S744, Quat_0 * _S745, uint _S746, float _S747, bool _S748, float _S749, float3  * _S750, float3  * _S751, float3  * _S752, float3  * _S753)
{
    bool _S754;
    ChunkStatic_0 * _S755 = (&(globalParams_0->chunks_0)[_S744]);
    float3  _S756 = make_float3 (0.0f);
    *_S750 = _S756;
    *_S751 = _S756;
    *_S752 = _S756;
    *_S753 = _S756;
    uint4  _S757 = __ldg(&_S755->load_range_0);
    uint term_1 = _S757.x;
    for(;;)
    {
        if(term_1 < (_S757.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S758 = 5U * term_1;
        float4  _S759 = __ldg((&(globalParams_0->loads_0)[_S758]));
        uint _S760 = asuint_0(_S759).y;
        bool replacement_0 = _S760 == 2U;
        float4  _S761 = __ldg((&(globalParams_0->loads_0)[_S758 + 1U]));
        float4  _S762 = __ldg((&(globalParams_0->loads_0)[_S758 + 2U]));
        float _S763;
        if(replacement_0)
        {
            _S763 = _S749;
        }
        else
        {
            _S763 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S746, _S747, _S763);
        if(replacement_0)
        {
            *_S752 = *_S752 + float3 {_S761.x, _S761.y, _S761.z} * make_float3 (value_0);
            *_S753 = *_S753 + float3 {_S762.x, _S762.y, _S762.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S760 == 0U)
        {
            _S754 = true;
        }
        else
        {
            _S754 = _S760 == 3U;
        }
        float3  fw_0;
        if(_S754)
        {
            fw_0 = float3 {_S761.x, _S761.y, _S761.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S764 = rotate_0(_S745, float3 {_S761.x, _S761.y, _S761.z});
            fw_0 = _S764 * make_float3 (- value_0 * _S761.w);
        }
        float3  lever_0;
        if(_S760 == 3U)
        {
            float4  _S765 = *(&(globalParams_0->state_0)[4U * _S743]);
            lever_0 = float3 {_S762.x, _S762.y, _S762.z} - float3 {_S765.x, _S765.y, _S765.z};
        }
        else
        {
            lever_0 = float3 {_S762.x, _S762.y, _S762.z};
        }
        *_S750 = *_S750 + fw_0;
        float3  _S766 = rotate_0(_S745, lever_0);
        *_S751 = *_S751 + cross_0(_S766, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S748)
    {
        uint4  _S767 = __ldg(&_S755->cinfo_0);
        _S754 = (_S767.z) != 0U;
    }
    else
    {
        _S754 = false;
    }
    if(_S754)
    {
        uint4  _S768 = __ldg(&_S755->cinfo_0);
        uint g_2 = _S768.x;
        for(;;)
        {
            if(g_2 < (_S768.y))
            {
            }
            else
            {
                break;
            }
            uint _S769 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S770 = 2U * g_2;
            float4  _S771 = *(&(globalParams_0->scratch_0)[_S769 + _S770]);
            *_S750 = *_S750 + float3 {_S771.x, _S771.y, _S771.z};
            uint _S772 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S773 = *(&(globalParams_0->scratch_0)[_S772 + _S770 + 1U]);
            *_S751 = *_S751 + float3 {_S773.x, _S773.y, _S773.z};
            g_2 = g_2 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S774, uint _S775, Quat_0 * _S776, uint _S777, float _S778, bool _S779, float3  * _S780, float3  * _S781)
{
    float3  rf_1;
    float3  rm_0;
    chunk_loads_0(_S774, _S775, _S776, _S777, _S778, _S779, 0.0f, _S780, _S781, &rf_1, &rm_0);
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
    ChunkStatic_0 * _S782 = (&(globalParams_0->chunks_0)[c_9]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_9, c_9, &rg_1->rot_0, k_13, dt_6, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S783 = fl_0;
    float4  _S784 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S785 = float3 {_S784.x, _S784.y, _S784.z};
    float4  _S786 = __ldg(&_S782->center_0);
    float3  fc_0 = _S783 + _S785 * make_float3 (_S786.w);
    float3  _S787 = float3 {_S786.x, _S786.y, _S786.z};
    float4  _S788 = *(&(globalParams_0->state_0)[4U * c_9]);
    float4  _S789 = isl_2->com_0;
    float3  _S790 = float3 {_S789.x, _S789.y, _S789.z};
    float3  _S791 = rotate_0(&rg_1->rot_0, _S787 + float3 {_S788.x, _S788.y, _S788.z} - _S790);
    *f_8 = *f_8 + fc_0;
    *t_9 = *t_9 + (cross_0(_S791, fc_0) + tl_0);
    uint4  _S792 = __ldg(&_S782->load_range_0);
    if((_S792.y) > (_S792.x))
    {
        float3  _S793 = rotate_0(&rg_1->rot_0, rep_f_0);
        *f_8 = *f_8 + _S793;
        float3  _S794 = rotate_0(&rg_1->rot_0, _S787 - _S790);
        float3  _S795 = cross_0(_S794, _S793);
        float3  _S796 = rotate_0(&rg_1->rot_0, rep_m_0);
        *t_9 = *t_9 + (_S795 + _S796);
    }
    return;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_3, Rigid_0 * rg_2, float3  f_9, float3  t_10)
{
    Quat_0 _S797 = rg_2->rot_0;
    float3  _S798 = world_mul_0(&_S797, isl_3->inertia0_1, isl_3->inertia1_1, isl_3->inertia2_1, rg_2->w_4);
    rg_2->a_7 = f_9 / make_float3 (isl_3->com_0.w);
    float3  _S799 = t_10 - cross_0(rg_2->w_4, _S798);
    Quat_0 _S800 = rg_2->rot_0;
    float3  _S801 = world_mul_0(&_S800, isl_3->inv0_1, isl_3->inv1_1, isl_3->inv2_1, _S799);
    rg_2->alpha_0 = _S801;
    rg_2->torque_0 = t_10;
    return;
}

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S802 = __ldg(&ptr_0->geom0_0);
    float4  _S803 = __ldg(&ptr_0->geom1_0);
    float4  _S804 = __ldg(&ptr_0->stiff0_0);
    float4  _S805 = __ldg(&ptr_0->stiff1_0);
    float4  _S806 = __ldg(&ptr_0->rebar0_0);
    float4  _S807 = __ldg(&ptr_0->rebar1_0);
    uint4  _S808 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S809 = { _S802, _S803, _S804, _S805, _S806, _S807, _S808 };
    return _S809;
}

static __device__ bool is_damaged_0(JointState_0 * st_0)
{
    bool _S810;
    if((st_0->damage_0) > 0.0f)
    {
        _S810 = true;
    }
    else
    {
        _S810 = (st_0->crush_0) > 0.0f;
    }
    return _S810;
}

static __device__ bool connected_0(JointState_0 * st_1, bool has_rebar_0)
{
    bool _S811;
    if((st_1->damage_0) < 1.0f)
    {
        _S811 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S811 = (st_1->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S811 = false;
        }
    }
    return _S811;
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
    float _S812 = q_lin_0.z;
    float axial_0 = fdiv_0(_S812, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_23->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_23->geom1_0.y);
    float _S813 = q_lin_0.x;
    float _S814 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S813 * _S813 + _S814 * _S814), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_23->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S815 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S815), (0.0f)));
    (&m_3)->compression_0 = _S815 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S812), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_21)
{
    if((F32_abs((x_21))) < 0.00100000004749745f)
    {
        return x_21 * (1.0f + x_21 * (0.5f + x_21 * 0.1666666716337204f));
    }
    return (F32_exp((x_21))) - 1.0f;
}

static __device__ float fpow_0(float a_10, float b_24)
{
    return (F32_pow((a_10), (b_24)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_5 = (F32_abs((strain_rate_1)));
    float4  _S816 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_5 <= ref_0)
    {
        return 1.0f;
    }
    float _S817 = _S816.z;
    float f_10;
    if(r_5 <= _S817)
    {
        f_10 = fpow_0(fdiv_0(r_5, ref_0), _S816.y);
    }
    else
    {
        f_10 = fpow_0(fdiv_0(_S817, ref_0), _S816.y) * fpow_0(fdiv_0(r_5, _S817), _S816.w);
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
    float _S818 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S819;
    if(_S818 > 0.0f)
    {
        _S819 = fdiv_0(m_4->shear_0, _S818);
    }
    else
    {
        _S819 = infinity_0();
    }
    *&((&idx_0)->y) = _S819;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_1)), (0.0f)));
    float _S820 = b_25->stiff1_0.y;
    if(_S820 > 0.0f)
    {
        _S819 = fdiv_0(m_4->compressive_force_0, _S820);
    }
    else
    {
        _S819 = 0.0f;
    }
    *&((&idx_0)->w) = _S819;
    return idx_0;
}

static __device__ float sq_0(float x_22)
{
    return x_22 * x_22;
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
    float _S821 = (F32_max((damage_law_0(kind_2, lambda_0, r_7)), (d_old_0)));
    bool _S822;
    if(_S821 <= d_old_0)
    {
        _S822 = true;
    }
    else
    {
        _S822 = d_old_0 >= 1.0f;
    }
    if(_S822)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S823 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_2 == 0U)
    {
        if(r_7 > 1.0f)
        {
            return make_float2 (_S821, fdiv_0(u0_0 * r_7, r_7 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_7))) - (F32_min((_S823), (r_7)))), (0.0f))));
        }
        return make_float2 (_S821, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_7 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S823), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S821 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S821, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_3;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S824 = - h0_0;
    float _S825 = - h1_0;
    FixedArray<float2 , 4>  _S826 = { {
        float2 {
            _S824, _S825
        }, float2 {
            h0_0, _S825
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S824, h1_0
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
        uint _S827 = i_11;
        uint _S828 = i_11 + 1U;
        uint _S829 = _S828 % 4U;
        float _S830 = _S826[i_11].y;
        float _S831 = _S826[i_11].x;
        float fp_0 = dz_0 + ax_0 * _S830 - ay_0 * _S831;
        float _S832 = _S826[_S829].y;
        float _S833 = _S826[_S829].x;
        float fq_0 = dz_0 + ax_0 * _S832 - ay_0 * _S833;
        bool _S834 = fp_0 < 0.0f;
        if(_S834)
        {
            uint _S835 = count_4 + 1U;
            poly_0[count_4] = _S826[_S827];
            count_3 = _S835;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S834 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S836 = count_3 + 1U;
            poly_0[count_3] = make_float2 (_S831 + t_11 * (_S833 - _S831), _S830 + t_11 * (_S832 - _S830));
            count_4 = _S836;
        }
        else
        {
            count_4 = count_3;
        }
        i_11 = _S828;
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
        float _S837 = o_1.x;
        float x0_0 = poly_0[i_11].x - _S837;
        float _S838 = o_1.y;
        float y0_0 = poly_0[i_11].y - _S838;
        uint _S839 = i_11 + 1U;
        uint _S840 = _S839 % count_4;
        float x1_0 = poly_0[_S840].x - _S837;
        float y1_0 = poly_0[_S840].y - _S838;
        float _S841 = x0_0 * y1_0;
        float _S842 = x1_0 * y0_0;
        float cr_0 = _S841 - _S842;
        float a_12 = a_11 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S841 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S842) * cr_0 / 24.0f;
        i_11 = _S839;
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
    float _S843 = a_11 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S843 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_11 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S843 * cy_0;
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
    float _S844 = a_13 * fc_2;
    float _S845 = - ay_1;
    return make_float4 (k_14 * a_13 * fc_2, k_14 * (_S844 * r_8[int(2)] + (_S845 * r_8[int(5)] + ax_1 * r_8[int(4)])), - k_14 * (_S844 * r_8[int(1)] + (_S845 * r_8[int(3)] + ax_1 * r_8[int(5)])), 0.5f * k_14 * (_S844 * fc_2 + ay_1 * ay_1 * r_8[int(3)] + ax_1 * ax_1 * r_8[int(4)] - 2.0f * ax_1 * ay_1 * r_8[int(5)]));
}

static __device__ float signum_0(float x_23)
{
    float _S846;
    if(((F32_asuint((x_23))) & 2147483648U) != 0U)
    {
        _S846 = -1.0f;
    }
    else
    {
        _S846 = 1.0f;
    }
    return _S846;
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
    float3  _S847 = make_float3 (0.0f);
    (&c_10)->q_lin_1 = _S847;
    (&c_10)->q_ang_1 = _S847;
    (&c_10)->energy_2 = 0.0f;
    (&c_10)->diss_4 = 0.0f;
    (&c_10)->plastic_1 = plastic_2;
    uint _S848 = mat_4->kind_flags_0.y;
    if((_S848 & 2U) == 0U)
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
    if((_S848 & 4U) != 0U)
    {
        float4  p_9 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S849 = p_9.y;
        float _S850 = p_9.z;
        float _S851 = p_9.w;
        nc_sum_0 = p_9.x;
        m1_0 = _S849;
        m2_0 = _S850;
        energy_3 = _S851;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S852 = d_ang_0.x;
        float _S853 = d_ang_0.y;
        float spread_0 = (F32_abs((_S852))) * 0.4166666567325592f * w1_2 + (F32_abs((_S853))) * 0.4166666567325592f * w0_2;
        float _S854 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S854))) + spread_0);
        if((_S854 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S854 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S855 = ki_0 * _S852 * i2_0;
                float _S856 = ki_0 * _S853 * i1_0;
                float _S857 = 0.5f * ki_0 * (36.0f * _S854 * _S854 + _S852 * _S852 * i2_0 + _S853 * _S853 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S854;
                m1_0 = _S855;
                m2_0 = _S856;
                energy_3 = _S857;
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
                    float _S858 = SPRING_AT_0[i_12] * w0_2;
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
                        float s2_0 = SPRING_AT_0[j_5] * w1_2;
                        float di_0 = _S854 + _S852 * s2_0 - _S853 * _S858;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S858;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + 1U;
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
    float _S859 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S860 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S859 * _S859 + _S860 * _S860);
    bool _S861;
    if(tn_0 > slide_cap_0)
    {
        _S861 = tn_0 > 0.0f;
    }
    else
    {
        _S861 = false;
    }
    if(_S861)
    {
        float _S862 = fdiv_0(_S859, tn_0);
        float _S863 = fdiv_0(_S860, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_10)->x) = *&((&p_10)->x) + _S862 * dslip_0;
        *&((&p_10)->y) = *&((&p_10)->y) + _S863 * dslip_0;
        *&((&(&c_10)->q_lin_1)->x) = _S862 * slide_cap_0;
        *&((&(&c_10)->q_lin_1)->y) = _S863 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_10)->q_lin_1)->x) = _S859;
        *&((&(&c_10)->q_lin_1)->y) = _S860;
        diss_5 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_10.z, slide_cap_0 * b_26->geom1_0.z);
    float _S864 = tq_0.x;
    float _S865 = tq_0.y;
    float diss_6 = diss_5 + (F32_abs((_S864))) * (F32_abs((_S865)));
    *&((&p_10)->z) = *&((&p_10)->z) + _S865;
    *&((&(&c_10)->q_ang_1)->z) = _S864;
    (&c_10)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_10)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_10)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S864), kt_0));
    (&c_10)->diss_4 = diss_6;
    (&c_10)->plastic_1 = p_10;
    return c_10;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_27, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S866 = mat_5->kind_flags_0.y;
    if((_S866 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_27->stiff0_0.x;
    float ks_1 = b_27->stiff0_0.y;
    float kt_1 = b_27->stiff1_0.x;
    float w0_3 = b_27->geom0_0.y;
    float w1_3 = b_27->geom0_0.z;
    float nc_sum_1;
    if((_S866 & 4U) != 0U)
    {
        float4  _S867 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S867.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S868 = d_ang_1.x;
        float _S869 = d_ang_1.y;
        float spread_1 = (F32_abs((_S868))) * 0.4166666567325592f * w1_3 + (F32_abs((_S869))) * 0.4166666567325592f * w0_3;
        float _S870 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S870))) + spread_1);
        if((_S870 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S870 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S870;
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
                    float _S871 = SPRING_AT_0[i_13] * w0_3;
                    uint j_6 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_6 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S870 + _S868 * (SPRING_AT_0[j_6] * w1_3) - _S869 * _S871;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_6 = j_6 + 1U;
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
    float _S872 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S873 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S872 * _S872 + _S873 * _S873);
    bool _S874;
    if(tn_1 > slide_cap_1)
    {
        _S874 = tn_1 > 0.0f;
    }
    else
    {
        _S874 = false;
    }
    if(_S874)
    {
        float _S875 = fdiv_0(_S873, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_11)->x) = *&((&p_11)->x) + fdiv_0(_S872, tn_1) * dslip_1;
        *&((&p_11)->y) = *&((&p_11)->y) + _S875 * dslip_1;
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
    float _S876 = mat_6->misc_0.y;
    return fdiv_0((_S876 + 1.0f) * fpow_0(s_5, _S876), mat_6->misc_0.z);
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
    float4  _S877 = b_28->stiff1_0;
    float kt_2 = b_28->stiff1_0.x;
    bool has_rebar_1 = (b_28->stiff1_0.w) != 0.0f;
    uint kind_3 = mat_7->kind_flags_0.x;
    uint flags_1 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_1 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S878 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S879 = stress_measures_0(b_28, qe_lin_0, qe_ang_0);
    float _S880 = (F32_max(((F32_max((_S879.tension_0), (_S879.shear_0)))), (_S879.compression_0)));
    bool _S881 = dt_7 > 0.0f;
    float dif_1;
    if(_S881)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S880 - (&st_2)->governing_stress_0, dt_7)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S877.z;
        if((flags_1 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_7, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_7, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S880;
    }
    if((flags_1 & 32U) != 0U)
    {
        float _S882 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S882;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_28->geom1_0.w;
    float _S883 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S883;
    Measures_0 _S884 = _S879;
    float4  _S885 = failure_indices_0(mat_7, b_28, &_S884, multiplier_1);
    float _S886 = _S885.x;
    float _S887 = _S885.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S886), (_S887)))), ((F32_max((_S885.z), (_S885.w))))));
    float _S888 = d_lin_2.x;
    float _S889 = d_lin_2.y;
    float _S890 = ks_2 * (sq_0(_S888) + sq_0(_S889)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S891 = d_lin_2.z;
    bool _S892 = _S891 > 0.0f;
    if(_S892)
    {
        dif_1 = kn_3 * sq_0(_S891);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S890 + dif_1);
    float psi_c_0;
    if(_S891 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S891);
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
    bool _S893;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S894 = _S886 >= _S887;
        if(_S894)
        {
            diss_contact_0 = _S886;
        }
        else
        {
            diss_contact_0 = _S887;
        }
        uint mode_ts_0;
        if(_S894)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S893 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            _S893 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S893 = false;
        }
        uint mode_c_0;
        if(_S893)
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
            float _S895 = inc_0.x;
            if(_S895 > ((&st_2)->damage_0))
            {
                Contact_0 _S896 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S897 = (F32_max((_S896.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S898 = (F32_max((inc_0.y - _S897 * (_S895 - (&st_2)->damage_0)), (0.0f)));
                float _S899 = (F32_max(((psi_ts_0 - _S897) * (_S895 - (&st_2)->damage_0) - _S898), (0.0f)));
                (&st_2)->damage_0 = _S895;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_3 = _S898;
                overshoot_1 = _S899;
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
        float _S900 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S901 = contact_part_0(mat_7, b_28, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S900) + _S901.q_ang_1 * make_float3 (_S900);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S902 = stress_measures_0(b_28, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S903 = _S902;
        float4  _S904 = failure_indices_0(mat_7, b_28, &_S903, multiplier_1);
        float _S905 = _S904.z;
        float _S906 = _S904.w;
        bool _S907 = _S905 >= _S906;
        if(_S907)
        {
            psi_contact_0 = _S905;
        }
        else
        {
            psi_contact_0 = _S906;
        }
        if(_S907)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S893 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            _S893 = psi_c_0 > 0.0f;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
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
            float _S908 = inc_1.x;
            if(_S908 > ((&st_2)->crush_0))
            {
                float _S909 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S909;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S908 - (&st_2)->crush_0) - _S909), (0.0f)));
                (&st_2)->crush_0 = _S908;
                (&st_2)->mode_0 = mode_c_0;
                if(_S908 >= 1.0f)
                {
                    _S893 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S893 = false;
                }
                if(_S893)
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
    float3  _S910 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_1 & 8U) == 0U)
        {
            float3  _S911 = contact_offsets_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S911.x;
            (&st_2)->plastic_y_0 = _S911.y;
            (&st_2)->plastic_t_0 = _S911.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S910;
        qc_ang_0 = _S910;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S912 = contact_part_0(mat_7, b_28, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S912.plastic_1.x;
        (&st_2)->plastic_y_0 = _S912.plastic_1.y;
        (&st_2)->plastic_t_0 = _S912.plastic_1.z;
        diss_contact_0 = _S912.diss_4;
        qc_lin_0 = _S912.q_lin_1;
        qc_ang_0 = _S912.q_ang_1;
        psi_contact_0 = _S912.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S892)
    {
        intact_normal_0 = kn_3 * _S891;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S891;
    }
    float _S913 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S913 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S913 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S913 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S913) + qc_ang_0 * make_float3 (dmg_0);
    float stored_6 = _S913 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S893 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S893 = false;
    }
    float stored_7;
    float3  force_lin_3;
    if(_S893)
    {
        float k_axial_0 = b_28->rebar0_0.x;
        float k_dowel_0 = b_28->rebar0_0.y;
        float yield_force_0 = b_28->rebar0_0.z;
        float dowel_capacity_0 = b_28->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S891, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S888, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S889, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S914 = nr_0.y;
        float _S915 = v1_0.y;
        float _S916 = v2_0.y;
        float work_0 = yield_force_0 * (F32_abs((_S914))) + dowel_capacity_0 * ((F32_abs((_S915))) + (F32_abs((_S916))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S914;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S915;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S916;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_0;
        float dissipated_7 = dissipated_6 + work_0;
        float _S917 = nr_0.x;
        float _S918 = v1_0.x;
        float _S919 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S917), k_axial_0) + fdiv_0(sq_0(_S918) + sq_0(_S919), k_dowel_0));
        if(fracture_1)
        {
            _S893 = ((&st_2)->rebar_work_0) >= (b_28->rebar1_0.x);
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
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
            force_lin_3 = force_lin_2 + make_float3 (_S918, _S919, _S917);
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
        _S893 = _S881;
    }
    else
    {
        _S893 = false;
    }
    if(_S893)
    {
        _S893 = (flags_1 & 64U) != 0U;
    }
    else
    {
        _S893 = false;
    }
    if(_S893)
    {
        Measures_0 _S920 = stress_measures_0(b_28, force_lin_3, force_ang_2);
        Measures_0 _S921 = _S920;
        float4  _S922 = failure_indices_0(mat_7, b_28, &_S921, weibull_0);
        float _S923 = life_rate_0(mat_7, (F32_max(((F32_max((_S922.x), (_S922.y)))), (_S922.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S923 * dt_7), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_5 = stored_7;
    if(_S878)
    {
        JointState_0 _S924 = st_2;
        bool _S925 = connected_0(&_S924, has_rebar_1);
        _S893 = !_S925;
    }
    else
    {
        _S893 = false;
    }
    (&resp_0)->disconnected_0 = _S893;
    (&resp_0)->fatigue_before_0 = _S883;
    (&resp_0)->measures_0 = _S879;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_29, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S926 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_2;
    if(compressed_0)
    {
        contact_2 = _S926;
    }
    else
    {
        contact_2 = 0.0f;
    }
    float _S927 = 1.0f - _S926;
    float _S928 = (F32_max((_S927 + contact_2), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S927), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S928, _S928, normal_4);
    *f_ang_0 = make_float3 (_S928);
    bool _S929;
    if((b_29->stiff1_0.w) != 0.0f)
    {
        _S929 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S929 = false;
    }
    if(_S929)
    {
        float4  _S930 = b_29->rebar0_0;
        float4  _S931 = b_29->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_29->rebar0_0.x, b_29->stiff0_0.x);
        float _S932 = fdiv_0(_S930.y, _S931.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S932;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S932;
    }
    return;
}

static __device__ float3  to_local_0(uint _S933, float3  _S934)
{
    BondStatic_0 * _S935 = (&(globalParams_0->bonds_0)[_S933]);
    float4  _S936 = __ldg(&_S935->t1_0);
    float _S937 = dot_0(_S934, float3 {_S936.x, _S936.y, _S936.z});
    float4  _S938 = __ldg(&_S935->t2_0);
    float _S939 = dot_0(_S934, float3 {_S938.x, _S938.y, _S938.z});
    float4  _S940 = __ldg(&_S935->normal_0);
    return make_float3 (_S937, _S939, dot_0(_S934, float3 {_S940.x, _S940.y, _S940.z}));
}

static __device__ float3  to_body_0(uint _S941, float3  _S942)
{
    BondStatic_0 * _S943 = (&(globalParams_0->bonds_0)[_S941]);
    float4  _S944 = __ldg(&_S943->t1_0);
    float3  _S945 = float3 {_S944.x, _S944.y, _S944.z} * make_float3 (_S942.x);
    float4  _S946 = __ldg(&_S943->t2_0);
    float3  _S947 = _S945 + float3 {_S946.x, _S946.y, _S946.z} * make_float3 (_S942.y);
    float4  _S948 = __ldg(&_S943->normal_0);
    return _S947 + float3 {_S948.x, _S948.y, _S948.z} * make_float3 (_S942.z);
}

static __device__ bool bond_update_0(uint i_14, float dt_8, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S949 = (&(globalParams_0->bonds_0)[i_14]);
    JointBond_0 _S950 = slang_ldg_0(&_S949->law_0);
    uint ca_0 = _S950.ids_0.y;
    uint cb_0 = _S950.ids_0.z;
    float4  _S951 = __ldg(&_S949->ra_0);
    float3  ra_1 = float3 {_S951.x, _S951.y, _S951.z};
    float4  _S952 = __ldg(&_S949->rb_0);
    float3  rb_1 = float3 {_S952.x, _S952.y, _S952.z};
    uint _S953 = 4U * ca_0;
    float4  _S954 = *(&(globalParams_0->state_0)[_S953]);
    float4  _S955 = *(&(globalParams_0->state_0)[_S953 + 1U]);
    float3  ta_2 = float3 {_S955.x, _S955.y, _S955.z};
    float4  _S956 = *(&(globalParams_0->state_0)[_S953 + 2U]);
    float3  va_0 = float3 {_S956.x, _S956.y, _S956.z};
    float4  _S957 = *(&(globalParams_0->state_0)[_S953 + 3U]);
    float3  wa_1 = float3 {_S957.x, _S957.y, _S957.z};
    uint _S958 = 4U * cb_0;
    float4  _S959 = *(&(globalParams_0->state_0)[_S958]);
    float4  _S960 = *(&(globalParams_0->state_0)[_S958 + 1U]);
    float3  tb_2 = float3 {_S960.x, _S960.y, _S960.z};
    float4  _S961 = *(&(globalParams_0->state_0)[_S958 + 2U]);
    float3  vb_0 = float3 {_S961.x, _S961.y, _S961.z};
    float4  _S962 = *(&(globalParams_0->state_0)[_S958 + 3U]);
    float3  wb_0 = float3 {_S962.x, _S962.y, _S962.z};
    float3  _S963 = to_local_0(i_14, float3 {_S959.x, _S959.y, _S959.z} + cross_0(tb_2, rb_1) - (float3 {_S954.x, _S954.y, _S954.z} + cross_0(ta_2, ra_1)));
    float3  _S964 = to_local_0(i_14, tb_2 - ta_2);
    float3  _S965 = to_local_0(i_14, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S966 = to_local_0(i_14, wb_0 - wa_1);
    JointBond_0 _S967 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointState_0 previous_0 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointState_0 _S968 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    bool _S969 = is_damaged_0(&_S968);
    JointBond_0 _S970 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_14])->law_0);
    JointBond_0 _S971 = _S970;
    JointState_0 _S972 = (&(globalParams_0->bond_dyn_0)[i_14])->js_0;
    JointResponse_0 _S973 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S967.ids_0.x], &_S971, &_S972, _S963, _S964, dt_8, fracture_2);
    BondStatic_0 * _S974 = (&(globalParams_0->bonds_0)[i_14]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_14]);
    float4  _S975 = __ldg(&_S974->ra_0);
    float3  ra_2 = float3 {_S975.x, _S975.y, _S975.z};
    float4  _S976 = __ldg(&_S974->rb_0);
    float3  rb_2 = float3 {_S976.x, _S976.y, _S976.z};
    JointBond_0 _S977 = slang_ldg_0(&_S974->law_0);
    JointBond_0 _S978 = _S977;
    JointState_0 _S979 = _S973.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S978, &_S979, _S963, &f_lin_1, &f_ang_1);
    float4  _S980 = __ldg(&_S974->c_lin_0);
    float3  qd_lin_0 = _S965 * float3 {_S980.x, _S980.y, _S980.z} * f_lin_1;
    float4  _S981 = __ldg(&_S974->c_ang_0);
    float3  qd_ang_0 = _S966 * float3 {_S981.x, _S981.y, _S981.z} * f_ang_1;
    float3  q_lin_2 = _S973.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S973.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S965) + dot_0(qd_ang_0, _S966)) * dt_8;
    float3  _S982 = to_body_0(i_14, q_lin_2);
    float3  _S983 = to_body_0(i_14, q_ang_2);
    uint _S984 = 3U * i_14;
    *(&(globalParams_0->scratch_0)[_S984]) = make_float4 (_S982.x, _S982.y, _S982.z, (F32_max((_S973.measures_0.tension_0), (_S973.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S984 + 1U]) = make_float4 ((_S983 + cross_0(ra_2, _S982)).x, (_S983 + cross_0(ra_2, _S982)).y, (_S983 + cross_0(ra_2, _S982)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S984 + 2U]) = make_float4 ((- _S983 + cross_0(rb_2, - _S982)).x, (- _S983 + cross_0(rb_2, - _S982)).y, (- _S983 + cross_0(rb_2, - _S982)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S973.dissipated_2);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S973.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S973.stored_5);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S973.state_1.utilization_0))));
    bool _S985;
    if(!_S969)
    {
        JointState_0 _S986 = _S973.state_1;
        bool _S987 = is_damaged_0(&_S986);
        _S985 = _S987;
    }
    else
    {
        _S985 = false;
    }
    if(_S985)
    {
        _S985 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S985 = false;
    }
    if(_S985)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S973.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S977.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S985 = (_S973.state_1.life_0) != (previous_0.life_0);
    }
    else
    {
        _S985 = false;
    }
    if(_S985)
    {
        _S985 = (_S973.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S985 = false;
    }
    if(_S985)
    {
        float _S988 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S967.ids_0.x], _S973.state_1.life_0);
        _S985 = _S988 <= 0.99000000953674316f;
    }
    else
    {
        _S985 = false;
    }
    if(_S985)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S977.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S973.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S973.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_14]) = bd_0;
    return _S973.disconnected_0;
}

static __device__ void chunk_update_0(uint c_11, Island_0 * isl_4, Rigid_0 * rg_3, float dt_9, bool rml_0, uint step_0, bool contact_3, float * work_1, float * work_err_0)
{
    ChunkStatic_0 * _S989 = (&(globalParams_0->chunks_0)[c_11]);
    float3  _S990 = make_float3 (0.0f);
    uint _S991 = __ldg((&(globalParams_0->index_0)[c_11]));
    float peak_0 = 0.0f;
    uint e_3 = _S991;
    float3  fi_0 = _S990;
    float3  mi_0 = _S990;
    for(;;)
    {
        uint _S992 = __ldg((&(globalParams_0->index_0)[c_11 + 1U]));
        if(e_3 < _S992)
        {
        }
        else
        {
            break;
        }
        uint _S993 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint _S994 = 3U * (_S993 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S994]);
        if((_S993 & 1U) == 0U)
        {
            float4  _S995 = *(&(globalParams_0->scratch_0)[_S994 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S995.x, _S995.y, _S995.z};
            fi_0 = fi_0 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S996 = *(&(globalParams_0->scratch_0)[_S994 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S996.x, _S996.y, _S996.z};
            fi_0 = fi_0 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_0 = mi_2;
        }
        float _S997 = (F32_max((peak_0), (fa_2.w)));
        uint _S998 = e_3 + 1U;
        peak_0 = _S997;
        e_3 = _S998;
    }
    uint _S999 = 4U * c_11;
    float4  _S1000 = *(&(globalParams_0->state_0)[_S999]);
    float3  u_0 = float3 {_S1000.x, _S1000.y, _S1000.z};
    uint _S1001 = _S999 + 1U;
    float4  _S1002 = *(&(globalParams_0->state_0)[_S1001]);
    float3  th_2 = float3 {_S1002.x, _S1002.y, _S1002.z};
    uint _S1003 = _S999 + 2U;
    float4  _S1004 = *(&(globalParams_0->state_0)[_S1003]);
    float3  v_9 = float3 {_S1004.x, _S1004.y, _S1004.z};
    uint _S1005 = _S999 + 3U;
    float4  _S1006 = *(&(globalParams_0->state_0)[_S1005]);
    float3  w_5 = float3 {_S1006.x, _S1006.y, _S1006.z};
    float4  _S1007 = __ldg(&_S989->center_0);
    float mass_0 = _S1007.w;
    float3  _S1008 = float3 {_S1007.x, _S1007.y, _S1007.z};
    float4  _S1009 = isl_4->com_0;
    float3  _S1010 = float3 {_S1009.x, _S1009.y, _S1009.z};
    float3  _S1011 = rotate_0(&rg_3->rot_0, _S1008 + u_0 - _S1010);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_11, c_11, &rg_3->rot_0, step_0, dt_9, contact_3, dt_9, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_11, f_load_0, t_load_0);
    float3  _S1012 = f_load_0;
    float4  _S1013 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S1012 + float3 {_S1013.x, _S1013.y, _S1013.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S1014 = rg_3->alpha_0;
        float3  _S1015 = rg_3->w_4;
        float3  f_world_2 = f_world_0 - (rg_3->a_7 + cross_0(rg_3->alpha_0, _S1011) + cross_0(rg_3->w_4, cross_0(rg_3->w_4, _S1011))) * make_float3 (mass_0);
        float4  _S1016 = __ldg(&_S989->inertia0_0);
        float4  _S1017 = __ldg(&_S989->inertia1_0);
        float4  _S1018 = __ldg(&_S989->inertia2_0);
        float3  _S1019 = world_mul_0(&rg_3->rot_0, _S1016, _S1017, _S1018, _S1014);
        float3  _S1020 = world_mul_0(&rg_3->rot_0, _S1016, _S1017, _S1018, _S1015);
        float3  t_world_2 = t_world_0 - (_S1019 + cross_0(_S1015, _S1020));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S1021 = inverse_rotate_0(&rg_3->rot_0, f_world_1);
    float3  _S1022 = inverse_rotate_0(&rg_3->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S1023 = inverse_rotate_0(&rg_3->rot_0, rg_3->w_4);
        float3  f_ext_1 = _S1021 - cross_0(_S1023, v_9) * make_float3 (2.0f * mass_0);
        float4  _S1024 = __ldg(&_S989->inertia0_0);
        float4  _S1025 = __ldg(&_S989->inertia1_0);
        float4  _S1026 = __ldg(&_S989->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S1024, _S1025, _S1026, w_5);
        float3  m_ext_1 = _S1022 - (cross_0(_S1023, i_w_0) + cross_0(w_5, rows_mul_0(_S1024, _S1025, _S1026, _S1023)) + cross_0(w_5, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1021;
        m_ext_0 = _S1022;
    }
    float3  f_13 = f_ext_0 + rep_f_1 + fi_0;
    float3  m_5 = m_ext_0 + rep_m_1 + mi_0;
    uint4  _S1027 = __ldg(&_S989->info_0);
    uint support_0 = _S1027.x;
    float3  _S1028 = make_float3 ((*(&(globalParams_0->state_0)[_S1001])).w, (*(&(globalParams_0->state_0)[_S1003])).w, (*(&(globalParams_0->state_0)[_S1005])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_3;
    float3  v_10;
    float3  w_6;
    if(support_0 == 1U)
    {
        reaction_0 = - f_13;
        u_1 = u_0;
        th_3 = th_2;
        v_10 = _S990;
        w_6 = _S990;
    }
    else
    {
        float4  _S1029 = __ldg(&_S989->inv0_0);
        float4  _S1030 = __ldg(&_S989->inv1_0);
        float4  _S1031 = __ldg(&_S989->inv2_0);
        float3  _S1032 = rows_mul_0(_S1029, _S1030, _S1031, m_5);
        float4  _S1033 = __ldg(&_S989->scale_0);
        float3  w_7 = w_5 + _S1032 * make_float3 (dt_9 * _S1033.z);
        float3  th_4 = th_2 + w_7 * make_float3 (dt_9);
        if(support_0 == 2U)
        {
            reaction_0 = - f_13;
            u_1 = u_0;
            th_3 = _S990;
        }
        else
        {
            float3  v_11 = v_9 + f_13 * make_float3 (dt_9 * _S1033.y);
            float3  u_2 = u_0 + v_11 * make_float3 (dt_9);
            reaction_0 = _S1028;
            u_1 = u_2;
            th_3 = v_11;
        }
        float3  _S1034 = th_3;
        th_3 = th_4;
        v_10 = _S1034;
        w_6 = w_7;
    }
    *(&(globalParams_0->state_0)[_S999]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S1001]) = make_float4 (th_3.x, th_3.y, th_3.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S1003]) = make_float4 (v_10.x, v_10.y, v_10.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S1005]) = make_float4 (w_6.x, w_6.y, w_6.z, reaction_0.z);
    float3  _S1035 = rotate_0(&rg_3->rot_0, _S1008 + u_1 - _S1010);
    float3  _S1036 = rg_3->vel_1 + rg_3->vel_err_1 + cross_0(rg_3->w_4, _S1035);
    float3  _S1037 = rotate_0(&rg_3->rot_0, v_10);
    float3  v_world_0 = _S1036 + _S1037;
    float3  _S1038 = rotate_0(&rg_3->rot_0, w_6);
    comp_add1_0(work_1, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_3->w_4 + _S1038)) * dt_9);
    return;
}

static __device__ float3  turn_difference_0(float3  omega_1, float dt_10, float3  v_12)
{
    float _S1039 = length_0(omega_1);
    float angle_3 = _S1039 * dt_10;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_14 = omega_1 / make_float3 (_S1039);
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
    float4  _S1040 = isl_5->inv0_1;
    float4  _S1041 = isl_5->inv1_1;
    float4  _S1042 = isl_5->inv2_1;
    Quat_0 _S1043 = rg_4->rot_0;
    float3  _S1044 = world_mul_0(&_S1043, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_3);
    float3  _S1045 = vel_2 * make_float3 (dt_11);
    float4  _S1046 = isl_5->com_0;
    float3  _S1047 = float3 {_S1046.x, _S1046.y, _S1046.z};
    Quat_0 _S1048 = rg_4->rot_0;
    float3  _S1049 = rotate_0(&_S1048, _S1047);
    comp_add_0(&rg_4->pos_1, &rg_4->pos_err_1, _S1045 - turn_difference_0(_S1044, dt_11, _S1049));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S1044, dt_11);
    Quat_0 _S1050 = rg_4->rot_0;
    float3  _S1051 = world_mul_0(&_S1050, _S1040, _S1041, _S1042, l_3);
    rg_4->w_4 = _S1051;
    return;
}

static __device__ void drift_moments_0(uint c_12, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S1052 = (&(globalParams_0->chunks_0)[c_12]);
    float4  _S1053 = __ldg(&_S1052->center_0);
    float _S1054 = _S1053.w;
    float4  _S1055 = __ldg(&_S1052->scale_0);
    float m_6 = _S1054 * _S1055.x;
    uint _S1056 = 4U * c_12;
    float4  _S1057 = *(&(globalParams_0->state_0)[_S1056]);
    *tu_0 = *tu_0 + float3 {_S1057.x, _S1057.y, _S1057.z} * make_float3 (m_6);
    float4  _S1058 = *(&(globalParams_0->state_0)[_S1056 + 2U]);
    *pv_0 = *pv_0 + float3 {_S1058.x, _S1058.y, _S1058.z} * make_float3 (m_6);
    return;
}

static __device__ void drift_angular_0(uint c_13, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S1059 = (&(globalParams_0->chunks_0)[c_13]);
    float4  _S1060 = __ldg(&_S1059->center_0);
    float3  r_9 = float3 {_S1060.x, _S1060.y, _S1060.z} - wcom_1;
    float4  _S1061 = __ldg(&_S1059->scale_0);
    float kw_0 = _S1061.x;
    uint _S1062 = 4U * c_13;
    float4  _S1063 = *(&(globalParams_0->state_0)[_S1062]);
    float _S1064 = _S1060.w;
    float3  _S1065 = cross_0(r_9, float3 {_S1063.x, _S1063.y, _S1063.z} - tr_0) * make_float3 (_S1064);
    float4  _S1066 = __ldg(&_S1059->inertia0_0);
    float4  _S1067 = __ldg(&_S1059->inertia1_0);
    float4  _S1068 = __ldg(&_S1059->inertia2_0);
    float4  _S1069 = *(&(globalParams_0->state_0)[_S1062 + 1U]);
    *lu_0 = *lu_0 + (_S1065 + rows_mul_0(_S1066, _S1067, _S1068, float3 {_S1069.x, _S1069.y, _S1069.z})) * make_float3 (kw_0);
    float4  _S1070 = *(&(globalParams_0->state_0)[_S1062 + 2U]);
    float4  _S1071 = *(&(globalParams_0->state_0)[_S1062 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_9, float3 {_S1070.x, _S1070.y, _S1070.z} - dv_0) * make_float3 (_S1064) + rows_mul_0(_S1066, _S1067, _S1068, float3 {_S1071.x, _S1071.y, _S1071.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_14, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S1072 = __ldg(&(&(globalParams_0->chunks_0)[c_14])->center_0);
    float3  r_10 = float3 {_S1072.x, _S1072.y, _S1072.z} - wcom_2;
    uint _S1073 = 4U * c_14;
    float4  _S1074 = *(&(globalParams_0->state_0)[_S1073]);
    *(&(globalParams_0->state_0)[_S1073]) = make_float4 ((float3 {_S1074.x, _S1074.y, _S1074.z} - (tr_1 + cross_0(phi_0, r_10))).x, (float3 {_S1074.x, _S1074.y, _S1074.z} - (tr_1 + cross_0(phi_0, r_10))).y, (float3 {_S1074.x, _S1074.y, _S1074.z} - (tr_1 + cross_0(phi_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1073])).w);
    uint _S1075 = _S1073 + 1U;
    float4  _S1076 = *(&(globalParams_0->state_0)[_S1075]);
    *(&(globalParams_0->state_0)[_S1075]) = make_float4 ((float3 {_S1076.x, _S1076.y, _S1076.z} - phi_0).x, (float3 {_S1076.x, _S1076.y, _S1076.z} - phi_0).y, (float3 {_S1076.x, _S1076.y, _S1076.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S1075])).w);
    uint _S1077 = _S1073 + 2U;
    float4  _S1078 = *(&(globalParams_0->state_0)[_S1077]);
    *(&(globalParams_0->state_0)[_S1077]) = make_float4 ((float3 {_S1078.x, _S1078.y, _S1078.z} - (dv_1 + cross_0(dw_0, r_10))).x, (float3 {_S1078.x, _S1078.y, _S1078.z} - (dv_1 + cross_0(dw_0, r_10))).y, (float3 {_S1078.x, _S1078.y, _S1078.z} - (dv_1 + cross_0(dw_0, r_10))).z, (*(&(globalParams_0->state_0)[_S1077])).w);
    uint _S1079 = _S1073 + 3U;
    float4  _S1080 = *(&(globalParams_0->state_0)[_S1079]);
    *(&(globalParams_0->state_0)[_S1079]) = make_float4 ((float3 {_S1080.x, _S1080.y, _S1080.z} - dw_0).x, (float3 {_S1080.x, _S1080.y, _S1080.z} - dw_0).y, (float3 {_S1080.x, _S1080.y, _S1080.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S1079])).w);
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
    (&dq_1)->x_12 = d_11.x;
    (&dq_1)->y_4 = d_11.y;
    (&dq_1)->z_0 = d_11.z;
    (&dq_1)->w_1 = d_11.w;
    Quat_0 _S1081 = *hi_3;
    Quat_0 _S1082 = dq_1;
    Quat_0 _S1083 = quat_mul_0(&_S1081, &_S1082);
    Quat_0 _S1084 = _S1083;
    float4  _S1085 = quat_vec_0(&_S1084);
    quat_accumulate_0(hi_3, lo_3, _S1085);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_6, Rigid_0 * rg_5, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S1086 = isl_6->wcom_0;
    float3  wcom_3 = float3 {_S1086.x, _S1086.y, _S1086.z};
    Quat_0 rot_2 = rg_5->rot_0;
    float3  _S1087 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S1088 = rg_5->rot_0;
    float3  _S1089 = rotate_0(&_S1088, _S1087);
    comp_add_0(&rg_5->pos_1, &rg_5->pos_err_1, _S1089);
    Quat_0 _S1090 = rg_5->rot_0;
    float3  _S1091 = inverse_rotate_0(&_S1090, rg_5->w_4);
    float4  _S1092 = isl_6->inertia0_1;
    float4  _S1093 = isl_6->inertia1_1;
    float4  _S1094 = isl_6->inertia2_1;
    float3  _S1095 = cross_0(phi_2, rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, _S1091)) - rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, cross_0(phi_2, _S1091));
    Quat_0 _S1096 = rg_5->rot_0;
    float3  _S1097 = rotate_0(&_S1096, _S1095);
    turn_right_0(&rg_5->rot_0, &rg_5->rot_err_0, phi_2);
    float4  _S1098 = isl_6->com_0;
    float3  _S1099 = dv_2 + cross_0(dw_1, float3 {_S1098.x, _S1098.y, _S1098.z} - wcom_3);
    Quat_0 _S1100 = rot_2;
    float3  _S1101 = rotate_0(&_S1100, _S1099);
    comp_add_0(&rg_5->vel_1, &rg_5->vel_err_1, _S1101);
    Quat_0 _S1102 = rot_2;
    float3  _S1103 = rotate_0(&_S1102, dw_1);
    rg_5->w_4 = rg_5->w_4 + _S1103;
    Quat_0 _S1104 = rg_5->rot_0;
    float3  _S1105 = world_mul_0(&_S1104, _S1092, _S1093, _S1094, _S1103);
    comp_add_0(&rg_5->l_2, &rg_5->l_err_1, _S1097 + _S1105);
    return;
}

static __device__ void write_probe_0(uint slot_0, uint k_16, float value_1)
{
    uint _S1106 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S1107 = _S1106 * 4U;
    uint _S1108 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S1107 + slot_0 * _S1108 + k_16;
    float4  v_13 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_13, at_4 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_13;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_7, Rigid_0 * rg_6, uint k_17)
{
    uint4  _S1109 = isl_7->probes_0;
    uint at_5 = isl_7->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S1109.y))
        {
        }
        else
        {
            break;
        }
        float4  _S1110 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_3 = asuint_0(_S1110);
        float4  _S1111 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S1112 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S1113 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_4 = info_3.x;
        uint i_15 = info_3.y;
        float value_2;
        if(kind_4 == 0U)
        {
            float4  _S1114 = *(&(globalParams_0->state_0)[4U * i_15]);
            float3  small_0 = float3 {_S1114.x, _S1114.y, _S1114.z} + make_float3 (_S1111.w, _S1112.w, _S1113.w);
            float3  _S1115 = rg_6->pos_1 - float3 {_S1112.x, _S1112.y, _S1112.z};
            float4  _S1116 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
            float3  _S1117 = rotate_0(&rg_6->rot_0, float3 {_S1116.x, _S1116.y, _S1116.z});
            float3  _S1118 = _S1115 + _S1117;
            float3  _S1119 = rg_6->pos_err_1 - float3 {_S1113.x, _S1113.y, _S1113.z};
            float3  _S1120 = rotate_0(&rg_6->rot_0, small_0);
            value_2 = dot_0(_S1118 + (_S1119 + _S1120), float3 {_S1111.x, _S1111.y, _S1111.z});
        }
        else
        {
            if(kind_4 == 1U)
            {
                float4  _S1121 = __ldg(&(&(globalParams_0->chunks_0)[i_15])->center_0);
                uint _S1122 = 4U * i_15;
                float4  _S1123 = *(&(globalParams_0->state_0)[_S1122]);
                float4  _S1124 = isl_7->com_0;
                float3  _S1125 = rotate_0(&rg_6->rot_0, float3 {_S1121.x, _S1121.y, _S1121.z} + float3 {_S1123.x, _S1123.y, _S1123.z} - float3 {_S1124.x, _S1124.y, _S1124.z});
                float3  _S1126 = rg_6->vel_1 + rg_6->vel_err_1 + cross_0(rg_6->w_4, _S1125);
                float4  _S1127 = *(&(globalParams_0->state_0)[_S1122 + 2U]);
                float3  _S1128 = rotate_0(&rg_6->rot_0, float3 {_S1127.x, _S1127.y, _S1127.z});
                value_2 = dot_0(_S1126 + _S1128, float3 {_S1111.x, _S1111.y, _S1111.z});
            }
            else
            {
                if(kind_4 == 2U)
                {
                    uint _S1129 = 3U * i_15;
                    float4  _S1130 = *(&(globalParams_0->scratch_0)[_S1129]);
                    float3  f_14 = float3 {_S1130.x, _S1130.y, _S1130.z};
                    bool _S1131 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S1131)
                    {
                        float4  _S1132 = *(&(globalParams_0->scratch_0)[_S1129 + 1U]);
                        mc_0 = float3 {_S1132.x, _S1132.y, _S1132.z};
                    }
                    else
                    {
                        float4  _S1133 = *(&(globalParams_0->scratch_0)[_S1129 + 2U]);
                        mc_0 = float3 {_S1133.x, _S1133.y, _S1133.z};
                    }
                    float3  fc_3;
                    if(_S1131)
                    {
                        fc_3 = f_14;
                    }
                    else
                    {
                        fc_3 = - f_14;
                    }
                    value_2 = dot_0(fc_3, float3 {_S1111.x, _S1111.y, _S1111.z}) + dot_0(mc_0, float3 {_S1112.x, _S1112.y, _S1112.z});
                }
                else
                {
                    uint _S1134 = 4U * i_15;
                    float3  _S1135 = rotate_0(&rg_6->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S1134 + 1U])).w, (*(&(globalParams_0->state_0)[_S1134 + 2U])).w, (*(&(globalParams_0->state_0)[_S1134 + 3U])).w));
                    value_2 = dot_0(_S1135, float3 {_S1111.x, _S1111.y, _S1111.z});
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
    uint _S1136 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_1 = (&(globalParams_0->islands_0)[_S1136])->info_1.y;
    uint _S1137 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S1138;
    if(previous_1 == 0U)
    {
        _S1138 = at_6;
    }
    else
    {
        _S1138 = (U32_min((previous_1), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S1137])->info_1)->y) = _S1138;
    return;
}

static __device__ uint seen_bits_0()
{
    uint _S1139;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S1139 = 32768U;
    }
    else
    {
        _S1139 = 0U;
    }
    uint _S1140;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S1140 = 65536U;
    }
    else
    {
        _S1140 = 0U;
    }
    uint _S1141 = _S1139 | _S1140;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S1139 = 131072U;
    }
    else
    {
        _S1139 = 0U;
    }
    uint _S1142 = _S1141 | _S1139;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S1139 = 32U;
    }
    else
    {
        _S1139 = 0U;
    }
    uint _S1143 = _S1142 | _S1139;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S1139 = 64U;
    }
    else
    {
        _S1139 = 0U;
    }
    return _S1143 | _S1139;
}

extern "C" __global__ void island_frame()
{
    bool woke_0;
    uint _S1144;
    uint _S1145;
    uint _S1146;
    uint _S1147;
    uint _S1148;
    uint _S1149;
    uint _S1150 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S1151 = blockIdx.x;
    Island_0 isl_8 = *(&(globalParams_0->islands_0)[_S1151]);
    bool driven_0 = (((&isl_8)->info_1.x) & 2U) != 0U;
    bool _S1152 = !((((&isl_8)->info_1.x) & 1U) != 0U);
    uint _S1153 = __ballot_sync(_S1150, _S1152);
    bool _S1154;
    uint cov_0;
    if(_S1152)
    {
        bool _S1155 = !driven_0;
        uint _S1156 = __ballot_sync(_S1150, true);
        _S1154 = _S1155;
        cov_0 = _S1156;
    }
    else
    {
        uint _S1157 = __ballot_sync(_S1150, true);
        _S1154 = false;
        cov_0 = _S1157;
    }
    bool contact_island_0 = (((&isl_8)->info_1.x) & 4U) != 0U;
    bool _S1158 = (((&isl_8)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_5);
    bool _S1159 = tid_5 == 0U;
    uint _S1160 = __ballot_sync(cov_0, _S1159);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1159)
    {
        uint _S1161 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1162 = contact_island_0 != (_S1161 == 1U);
        uint _S1163 = __ballot_sync(_S1160, _S1162);
        if(_S1162)
        {
            uint _S1164 = __ballot_sync(_S1160, true);
            settled_0 = true;
            run_0 = _S1164;
        }
        else
        {
            bool _S1165 = (((&isl_8)->info_1.x) & 8U) != 0U;
            uint _S1166 = __ballot_sync(_S1160, true);
            settled_0 = _S1165;
            run_0 = _S1166;
        }
        uint _S1167 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1168 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1168;
        }
        else
        {
            uint _S1169 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1169;
        }
        uint _S1170 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1171 = isl_8;
            bool _S1172 = contact_stopped_0(&_S1171);
            uint _S1173 = __ballot_sync(done_1, true);
            settled_0 = _S1172;
            done_1 = _S1173;
        }
        else
        {
            uint _S1174 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1174;
        }
        uint _S1175 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1176 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1177 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1178 = __ballot_sync(cov_0, true);
        cov_0 = _S1178;
    }
    else
    {
        uint _S1179 = __ballot_sync(cov_0, true);
        cov_0 = _S1179;
    }
    __syncthreads();
    bool _S1180 = (((&isl_8)->info_1.z) & 1U) != 0U;
    uint _S1181 = __ballot_sync(cov_0, _S1180);
    if(_S1180)
    {
        uint _S1182 = __ballot_sync(cov_0, true);
        settled_0 = true;
        cov_0 = _S1182;
    }
    else
    {
        bool _S1183 = (*&g_run_0) == 0U;
        uint _S1184 = __ballot_sync(cov_0, true);
        settled_0 = _S1183;
        cov_0 = _S1184;
    }
    uint _S1185 = __ballot_sync(cov_0, settled_0);
    if(settled_0)
    {
        uint _S1186 = __ballot_sync(cov_0, true);
        cov_0 = 0U;
        run_0 = _S1186;
    }
    else
    {
        uint _S1187 = (&isl_8)->info_1.y;
        uint _S1188 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1189 = (U32_min((_S1187), (_S1188)));
        uint _S1190 = __ballot_sync(cov_0, true);
        cov_0 = _S1189;
        run_0 = _S1190;
    }
    float _S1191 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1192 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1193 = _S1192 != 0U;
    uint _S1194 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1195 = _S1194 != 0U;
    Island_0 _S1196 = isl_8;
    Rigid_0 _S1197 = rigid_of_0(&_S1196);
    Rigid_0 rg_7 = _S1197;
    float work_2 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1158;
    done_1 = 0U;
    bool woke_1 = false;
    uint _S1198 = run_0;
    for(;;)
    {
        uint _S1199 = 0U;
        bool _S1200 = done_1 < cov_0;
        uint _S1201 = __ballot_sync(_S1198, _S1200);
        if(_S1200)
        {
            uint _S1202 = __ballot_sync(_S1198, true);
            _S1199 = _S1202;
        }
        else
        {
            uint _S1203 = __ballot_sync(_S1198, false);
            uint _S1204 = __ballot_sync(_S1198, false);
            uint _S1205 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_0 = _S1205;
            break;
        }
        uint abs_step_1 = (&isl_8)->info_1.w + done_1 + 1U;
        uint _S1206 = abs_step_1 - 1U;
        uint _S1207 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_18 = _S1206 - _S1207;
        bool quiet_0 = (((&isl_8)->info_1.x) & 32U) != 0U;
        uint _S1208 = __ballot_sync(_S1199, settled_0);
        bool _S1209;
        uint _S1210;
        if(settled_0)
        {
            bool _S1211 = !quiet_0;
            uint _S1212 = __ballot_sync(_S1199, true);
            _S1209 = _S1211;
            _S1210 = _S1212;
        }
        else
        {
            uint _S1213 = __ballot_sync(_S1199, true);
            _S1209 = false;
            _S1210 = _S1213;
        }
        uint _S1214 = __ballot_sync(_S1210, _S1209);
        bool _S1215;
        bool explicit_step_0;
        uint c_15;
        uint _S1216;
        uint c_16;
        if(_S1209)
        {
            float3  _S1217 = make_float3 (0.0f);
            float3  norm_0 = _S1217;
            float3  unused0_0 = _S1217;
            c_15 = (&isl_8)->range_0.x + tid_5;
            _S1216 = _S1214;
            for(;;)
            {
                bool _S1218 = c_15 < ((&isl_8)->range_0.y);
                uint _S1219 = __ballot_sync(_S1216, _S1218);
                if(_S1218)
                {
                    uint _S1220 = __ballot_sync(_S1216, true);
                }
                else
                {
                    uint _S1221 = __ballot_sync(_S1216, false);
                    uint _S1222 = __ballot_sync(_S1216, false);
                    uint _S1223 = __ballot_sync(_S1214, true);
                    _S1144 = _S1223;
                    break;
                }
                Quat_0 _S1224 = (&rg_7)->rot_0;
                float _S1225 = settled_chunk_load_0(c_15, &_S1224, k_18, _S1191, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S1225;
                uint _S1226 = __ballot_sync(_S1216, true);
                c_15 = c_15 + 256U;
                _S1216 = _S1226;
            }
            group_sum3_0(tid_5, &norm_0, &unused0_0, _S1144);
            uint _S1227 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S1228 = _S1227 == 1U;
            uint _S1229 = __ballot_sync(_S1144, _S1228);
            if(_S1228)
            {
                bool _S1230 = (F32_abs((norm_0.x - (&isl_8)->energy_1.z))) > ((&isl_8)->energy_1.w);
                uint _S1231 = __ballot_sync(_S1144, true);
                _S1215 = _S1230;
                c_16 = _S1231;
            }
            else
            {
                uint _S1232 = __ballot_sync(_S1144, true);
                _S1215 = false;
                c_16 = _S1232;
            }
            uint _S1233 = __ballot_sync(c_16, _S1215);
            if(_S1215)
            {
                uint _S1234 = __ballot_sync(c_16, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S1235 = __ballot_sync(c_16, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S1236 = __ballot_sync(_S1210, true);
            settled_0 = explicit_step_0;
            c_15 = _S1236;
        }
        else
        {
            uint _S1237 = __ballot_sync(_S1210, true);
            woke_0 = woke_1;
            c_15 = _S1237;
        }
        uint _S1238 = __ballot_sync(c_15, _S1152);
        if(_S1152)
        {
            bool _S1239 = !quiet_0;
            uint _S1240 = __ballot_sync(c_15, true);
            _S1215 = _S1239;
            _S1216 = _S1240;
        }
        else
        {
            uint _S1241 = __ballot_sync(c_15, true);
            _S1215 = false;
            _S1216 = _S1241;
        }
        uint _S1242 = __ballot_sync(_S1216, _S1215);
        uint _S1243;
        if(_S1215)
        {
            float3  _S1244 = make_float3 (0.0f);
            float3  f_15 = _S1244;
            float3  t_12 = _S1244;
            c_16 = (&isl_8)->range_0.x + tid_5;
            _S1243 = _S1242;
            for(;;)
            {
                bool _S1245 = c_16 < ((&isl_8)->range_0.y);
                uint _S1246 = __ballot_sync(_S1243, _S1245);
                if(_S1245)
                {
                    uint _S1247 = __ballot_sync(_S1243, true);
                }
                else
                {
                    uint _S1248 = __ballot_sync(_S1243, false);
                    uint _S1249 = __ballot_sync(_S1243, false);
                    uint _S1250 = __ballot_sync(_S1242, true);
                    _S1145 = _S1250;
                    break;
                }
                Island_0 _S1251 = isl_8;
                Rigid_0 _S1252 = rg_7;
                net_load_0(c_16, &_S1251, &_S1252, k_18, _S1191, contact_island_0, &f_15, &t_12);
                uint _S1253 = __ballot_sync(_S1243, true);
                c_16 = c_16 + 256U;
                _S1243 = _S1253;
            }
            group_sum3_0(tid_5, &f_15, &t_12, _S1145);
            Island_0 _S1254 = isl_8;
            rigid_acceleration_0(&_S1254, &rg_7, f_15, t_12);
            uint _S1255 = __ballot_sync(_S1216, true);
            c_16 = _S1255;
        }
        else
        {
            uint _S1256 = __ballot_sync(_S1216, true);
            c_16 = _S1256;
        }
        bool _S1257 = !settled_0;
        uint _S1258 = __ballot_sync(c_16, _S1257);
        if(_S1257)
        {
            bool _S1259 = !quiet_0;
            uint _S1260 = __ballot_sync(c_16, true);
            explicit_step_0 = _S1259;
            _S1243 = _S1260;
        }
        else
        {
            uint _S1261 = __ballot_sync(c_16, true);
            explicit_step_0 = false;
            _S1243 = _S1261;
        }
        uint _S1262 = __ballot_sync(_S1243, explicit_step_0);
        uint i_16;
        uint _S1263;
        uint c_17;
        uint _S1264;
        if(explicit_step_0)
        {
            i_16 = (&isl_8)->range_0.z + tid_5;
            _S1263 = _S1262;
            for(;;)
            {
                uint _S1265 = 0U;
                bool _S1266 = i_16 < ((&isl_8)->range_0.w);
                uint _S1267 = __ballot_sync(_S1263, _S1266);
                if(_S1266)
                {
                    uint _S1268 = __ballot_sync(_S1263, true);
                    _S1265 = _S1268;
                }
                else
                {
                    uint _S1269 = __ballot_sync(_S1263, false);
                    uint _S1270 = __ballot_sync(_S1263, false);
                    uint _S1271 = __ballot_sync(_S1262, true);
                    _S1146 = _S1271;
                    break;
                }
                bool _S1272 = bond_update_0(i_16, _S1191, _S1193, abs_step_1, false);
                uint _S1273 = __ballot_sync(_S1265, _S1272);
                if(_S1272)
                {
                    *&g_halt_0 = 1U;
                    uint _S1274 = __ballot_sync(_S1265, true);
                }
                else
                {
                    uint _S1275 = __ballot_sync(_S1265, true);
                }
                uint _S1276 = __ballot_sync(_S1263, true);
                i_16 = i_16 + 256U;
                _S1263 = _S1276;
            }
            __syncthreads();
            c_17 = (&isl_8)->range_0.x + tid_5;
            _S1264 = _S1146;
            for(;;)
            {
                bool _S1277 = c_17 < ((&isl_8)->range_0.y);
                uint _S1278 = __ballot_sync(_S1264, _S1277);
                if(_S1277)
                {
                    uint _S1279 = __ballot_sync(_S1264, true);
                }
                else
                {
                    uint _S1280 = __ballot_sync(_S1264, false);
                    uint _S1281 = __ballot_sync(_S1264, false);
                    uint _S1282 = __ballot_sync(_S1146, true);
                    break;
                }
                Island_0 _S1283 = isl_8;
                Rigid_0 _S1284 = rg_7;
                chunk_update_0(c_17, &_S1283, &_S1284, _S1191, _S1195, k_18, contact_island_0, &work_2, &work_err_1);
                uint _S1285 = __ballot_sync(_S1264, true);
                c_17 = c_17 + 256U;
                _S1264 = _S1285;
            }
            __syncthreads();
            uint _S1286 = __ballot_sync(_S1243, true);
            i_16 = _S1286;
        }
        else
        {
            uint _S1287 = __ballot_sync(_S1243, true);
            i_16 = _S1287;
        }
        uint _S1288 = __ballot_sync(i_16, _S1154);
        bool _S1289;
        if(_S1154)
        {
            bool _S1290 = !quiet_0;
            uint _S1291 = __ballot_sync(i_16, true);
            _S1289 = _S1290;
            _S1263 = _S1291;
        }
        else
        {
            uint _S1292 = __ballot_sync(i_16, true);
            _S1289 = false;
            _S1263 = _S1292;
        }
        uint _S1293 = __ballot_sync(_S1263, _S1289);
        if(_S1289)
        {
            Island_0 _S1294 = isl_8;
            integrate_rigid_0(&_S1294, &rg_7, _S1191);
            uint _S1295 = __ballot_sync(_S1263, true);
            c_17 = _S1295;
        }
        else
        {
            uint _S1296 = __ballot_sync(_S1263, true);
            c_17 = _S1296;
        }
        uint _S1297 = __ballot_sync(c_17, _S1152);
        bool _S1298;
        if(_S1152)
        {
            uint _S1299 = __ballot_sync(c_17, true);
            _S1298 = explicit_step_0;
            _S1264 = _S1299;
        }
        else
        {
            uint _S1300 = __ballot_sync(c_17, true);
            _S1298 = false;
            _S1264 = _S1300;
        }
        uint _S1301 = __ballot_sync(_S1264, _S1298);
        uint c_18;
        uint _S1302;
        uint c_19;
        if(_S1298)
        {
            float4  _S1303 = (&isl_8)->wcom_0;
            float3  _S1304 = float3 {_S1303.x, _S1303.y, _S1303.z};
            float3  _S1305 = make_float3 (0.0f);
            float3  tu_1 = _S1305;
            float3  pv_1 = _S1305;
            c_18 = (&isl_8)->range_0.x + tid_5;
            _S1302 = _S1301;
            for(;;)
            {
                bool _S1306 = c_18 < ((&isl_8)->range_0.y);
                uint _S1307 = __ballot_sync(_S1302, _S1306);
                if(_S1306)
                {
                    uint _S1308 = __ballot_sync(_S1302, true);
                }
                else
                {
                    uint _S1309 = __ballot_sync(_S1302, false);
                    uint _S1310 = __ballot_sync(_S1302, false);
                    uint _S1311 = __ballot_sync(_S1301, true);
                    _S1147 = _S1311;
                    break;
                }
                drift_moments_0(c_18, &tu_1, &pv_1);
                uint _S1312 = __ballot_sync(_S1302, true);
                c_18 = c_18 + 256U;
                _S1302 = _S1312;
            }
            group_sum3_0(tid_5, &tu_1, &pv_1, _S1147);
            float3  tr_3 = tu_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_8)->wcom_0.w);
            float3  lu_1 = _S1305;
            float3  lv_1 = _S1305;
            c_19 = (&isl_8)->range_0.x + tid_5;
            uint _S1313 = _S1147;
            for(;;)
            {
                bool _S1314 = c_19 < ((&isl_8)->range_0.y);
                uint _S1315 = __ballot_sync(_S1313, _S1314);
                if(_S1314)
                {
                    uint _S1316 = __ballot_sync(_S1313, true);
                }
                else
                {
                    uint _S1317 = __ballot_sync(_S1313, false);
                    uint _S1318 = __ballot_sync(_S1313, false);
                    uint _S1319 = __ballot_sync(_S1147, true);
                    _S1148 = _S1319;
                    break;
                }
                drift_angular_0(c_19, _S1304, tr_3, dv_3, &lu_1, &lv_1);
                uint _S1320 = __ballot_sync(_S1313, true);
                c_19 = c_19 + 256U;
                _S1313 = _S1320;
            }
            group_sum3_0(tid_5, &lu_1, &lv_1, _S1148);
            float3  phi_3 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_8)->winv0_0, (&isl_8)->winv1_0, (&isl_8)->winv2_0, lv_1);
            uint c_20 = (&isl_8)->range_0.x + tid_5;
            uint _S1321 = _S1148;
            for(;;)
            {
                bool _S1322 = c_20 < ((&isl_8)->range_0.y);
                uint _S1323 = __ballot_sync(_S1321, _S1322);
                if(_S1322)
                {
                    uint _S1324 = __ballot_sync(_S1321, true);
                }
                else
                {
                    uint _S1325 = __ballot_sync(_S1321, false);
                    uint _S1326 = __ballot_sync(_S1321, false);
                    uint _S1327 = __ballot_sync(_S1148, true);
                    _S1149 = _S1327;
                    break;
                }
                drift_apply_0(c_20, _S1304, tr_3, phi_3, dv_3, dw_2);
                uint _S1328 = __ballot_sync(_S1321, true);
                c_20 = c_20 + 256U;
                _S1321 = _S1328;
            }
            bool _S1329 = !driven_0;
            uint _S1330 = __ballot_sync(_S1149, _S1329);
            if(_S1329)
            {
                Island_0 _S1331 = isl_8;
                drift_rigid_0(&_S1331, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S1332 = __ballot_sync(_S1149, true);
            }
            else
            {
                uint _S1333 = __ballot_sync(_S1149, true);
            }
            __syncthreads();
            uint _S1334 = __ballot_sync(_S1264, true);
            c_18 = _S1334;
        }
        else
        {
            uint _S1335 = __ballot_sync(_S1264, true);
            c_18 = _S1335;
        }
        uint _S1336 = __ballot_sync(c_18, _S1159);
        bool _S1337;
        if(_S1159)
        {
            bool _S1338 = ((&isl_8)->probes_0.y) > ((&isl_8)->probes_0.x);
            uint _S1339 = __ballot_sync(c_18, true);
            _S1337 = _S1338;
            _S1302 = _S1339;
        }
        else
        {
            uint _S1340 = __ballot_sync(c_18, true);
            _S1337 = false;
            _S1302 = _S1340;
        }
        uint _S1341 = __ballot_sync(_S1302, _S1337);
        if(_S1337)
        {
            Island_0 _S1342 = isl_8;
            Rigid_0 _S1343 = rg_7;
            record_probes_0(&_S1342, &_S1343, k_18);
            uint _S1344 = __ballot_sync(_S1302, true);
            c_19 = _S1344;
        }
        else
        {
            uint _S1345 = __ballot_sync(_S1302, true);
            c_19 = _S1345;
        }
        uint _S1346 = done_1 + 1U;
        bool _S1347 = (*&g_halt_0) != 0U;
        uint _S1348 = __ballot_sync(c_19, _S1347);
        if(_S1347)
        {
            uint _S1349 = __ballot_sync(c_19, false);
            uint _S1350 = __ballot_sync(_S1198, false);
            uint _S1351 = __ballot_sync(run_0, true);
            done_1 = _S1346;
            cov_0 = _S1351;
            break;
        }
        else
        {
            uint _S1352 = __ballot_sync(c_19, true);
        }
        uint _S1353 = __ballot_sync(_S1198, true);
        done_1 = _S1346;
        woke_1 = woke_0;
        _S1198 = _S1353;
    }
    float3  wsum_0 = make_float3 (work_2, work_err_1, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_5, &wsum_0, &unused_1, cov_0);
    uint _S1354 = __ballot_sync(cov_0, _S1159);
    if(_S1159)
    {
        Quat_0 _S1355 = (&rg_7)->rot_0;
        float4  _S1356 = quat_vec_0(&_S1355);
        (&isl_8)->rotation_0 = _S1356;
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
            _S1154 = contact_island_0;
        }
        else
        {
            _S1154 = false;
        }
        if(_S1154)
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
        uint _S1357 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S1358 = _S1357 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S1358 | cov_0;
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
                _S1154 = !quiet_1;
            }
            else
            {
                _S1154 = false;
            }
            if(_S1154)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            uint _S1359 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S1359 == 1U)
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
        *(&(globalParams_0->islands_0)[_S1151]) = isl_8;
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
    uint _S1360 = table_0 + 4U * g_3;
    uint _S1361 = __ldg((&(globalParams_0->index_0)[_S1360]));
    (&w_8)->island_2 = _S1361;
    uint _S1362 = __ldg((&(globalParams_0->index_0)[_S1360 + 1U]));
    (&w_8)->begin_0 = _S1362;
    uint _S1363 = __ldg((&(globalParams_0->index_0)[_S1360 + 2U]));
    (&w_8)->end_0 = _S1363;
    uint _S1364 = __ldg((&(globalParams_0->index_0)[_S1360 + 3U]));
    (&w_8)->first_0 = _S1364;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_9)
{
    uint4  _S1365 = isl_9->info_1;
    bool _S1366;
    if(((isl_9->info_1.z) & 1U) != 0U)
    {
        _S1366 = true;
    }
    else
    {
        _S1366 = (_S1365.y) == 0U;
    }
    if(_S1366)
    {
        return false;
    }
    if(((_S1365.x) & 4U) == 0U)
    {
        _S1366 = true;
    }
    else
    {
        bool _S1367 = contact_stopped_0(isl_9);
        _S1366 = !_S1367;
    }
    return _S1366;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_6, Island_0 * isl_10)
{
    seen_clear_0(tid_6);
    if(tid_6 == 0U)
    {
        bool _S1368 = wide_runs_0(isl_10);
        int _S1369;
        if(_S1368)
        {
            _S1369 = int(1);
        }
        else
        {
            _S1369 = int(0);
        }
        *&g_wide_run_0 = uint(_S1369);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_11)
{
    uint _S1370 = isl_11->info_1.w;
    uint _S1371 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1370 - _S1371;
}

static __device__ bool wide_enter_1(uint _S1372, uint _S1373)
{
    Island_0 _S1374 = *(&(globalParams_0->islands_0)[_S1373]);
    seen_clear_0(_S1372);
    if(_S1372 == 0U)
    {
        Island_0 _S1375 = _S1374;
        bool _S1376 = wide_runs_0(&_S1375);
        int _S1377;
        if(_S1376)
        {
            _S1377 = int(1);
        }
        else
        {
            _S1377 = int(0);
        }
        *&g_wide_run_0 = uint(_S1377);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1378 = 0U;
    uint _S1379;
    uint _S1380 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S1381 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1382 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1381, _S1382);
    bool _S1383 = _S1382 != (wg_0.first_0);
    uint _S1384 = __ballot_sync(_S1380, _S1383);
    if(_S1383)
    {
        return;
    }
    else
    {
        uint _S1385 = __ballot_sync(_S1380, true);
        _S1378 = _S1385;
    }
    Island_0 * _S1386 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_12 = *_S1386;
    uint _S1387 = (*_S1386).info_1.x;
    bool _S1388 = (_S1387 & 16U) == 0U;
    uint _S1389 = __ballot_sync(_S1378, _S1388);
    bool _S1390;
    uint c_21;
    if(_S1388)
    {
        uint _S1391 = __ballot_sync(_S1378, true);
        _S1390 = true;
        c_21 = _S1391;
    }
    else
    {
        bool _S1392 = wide_enter_1(tid_7, wg_0.island_2);
        bool _S1393 = !_S1392;
        uint _S1394 = __ballot_sync(_S1378, true);
        _S1390 = _S1393;
        c_21 = _S1394;
    }
    uint _S1395 = 0U;
    uint _S1396 = __ballot_sync(c_21, _S1390);
    if(_S1390)
    {
        return;
    }
    else
    {
        uint _S1397 = __ballot_sync(c_21, true);
        _S1395 = _S1397;
    }
    Quat_0 _S1398 = quat_of_0(isl_12.rotation_0);
    bool _S1399 = (_S1387 & 4U) != 0U;
    float3  _S1400 = make_float3 (0.0f);
    float3  norm_1 = _S1400;
    float3  unused_2 = _S1400;
    c_21 = isl_12.range_0.x + tid_7;
    uint cov_5;
    cov_5 = _S1395;
    for(;;)
    {
        bool _S1401 = c_21 < (isl_12.range_0.y);
        uint _S1402 = __ballot_sync(cov_5, _S1401);
        if(_S1401)
        {
            uint _S1403 = __ballot_sync(cov_5, true);
        }
        else
        {
            uint _S1404 = __ballot_sync(cov_5, false);
            uint _S1405 = __ballot_sync(cov_5, false);
            uint _S1406 = __ballot_sync(_S1395, true);
            _S1379 = _S1406;
            break;
        }
        Island_0 _S1407 = isl_12;
        uint _S1408 = wide_step_0(&_S1407);
        float _S1409 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1410 = _S1398;
        float _S1411 = settled_chunk_load_0(c_21, &_S1410, _S1408, _S1409, _S1399);
        *&((&norm_1)->x) = *&((&norm_1)->x) + _S1411;
        uint _S1412 = __ballot_sync(cov_5, true);
        c_21 = c_21 + 256U;
        cov_5 = _S1412;
    }
    group_sum3_0(tid_7, &norm_1, &unused_2, _S1379);
    bool _S1413 = tid_7 != 0U;
    uint _S1414 = __ballot_sync(_S1379, _S1413);
    if(_S1413)
    {
        return;
    }
    uint cov_6 = 1024U | (seen_bits_0());
    uint _S1415 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S1415 == 1U)
    {
        _S1390 = (F32_abs((norm_1.x - isl_12.energy_1.z))) > (isl_12.energy_1.w);
    }
    else
    {
        _S1390 = false;
    }
    if(_S1390)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S1387 & 4294967279U;
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
    uint _S1416 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1417 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1416 + _S1417 + p_12]) = make_float4 (a_15.x, a_15.y, a_15.z, 0.0f);
    uint _S1418 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1418 + _S1417 + p_12 + 1U]) = make_float4 (b_30.x, b_30.y, b_30.z, 0.0f);
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S1419 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1420 = blockIdx.x;
    uint _S1421 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = _S1420 < _S1421;
    uint _S1422 = __ballot_sync(_S1419, bond_group_0);
    WideGroup_0 wg_1;
    uint _S1423;
    if(bond_group_0)
    {
        uint _S1424 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S1425 = wide_group_0(_S1424, _S1420);
        uint _S1426 = __ballot_sync(_S1419, true);
        wg_1 = _S1425;
        _S1423 = _S1426;
    }
    else
    {
        uint _S1427 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S1428 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S1429 = wide_group_0(_S1427, _S1420 - _S1428);
        uint _S1430 = __ballot_sync(_S1419, true);
        wg_1 = _S1429;
        _S1423 = _S1430;
    }
    uint _S1431 = 0U;
    WideGroup_0 _S1432 = wg_1;
    Island_0 isl_13 = *(&(globalParams_0->islands_0)[wg_1.island_2]);
    bool _S1433 = wide_enter_1(tid_8, wg_1.island_2);
    bool _S1434 = !_S1433;
    uint _S1435 = __ballot_sync(_S1423, _S1434);
    if(_S1434)
    {
        return;
    }
    else
    {
        uint _S1436 = __ballot_sync(_S1423, true);
        _S1431 = _S1436;
    }
    uint _S1437 = 0U;
    Island_0 _S1438 = isl_13;
    uint _S1439 = wide_step_0(&_S1438);
    uint _S1440 = __ballot_sync(_S1431, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_13.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_17 = wg_1.begin_0 + tid_8;
        bool _S1441;
        if(i_17 < (wg_1.end_0))
        {
            float _S1442 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S1443 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S1444 = bond_update_0(i_17, _S1442, _S1443 != 0U, isl_13.info_1.w + 1U, true);
            _S1441 = _S1444;
        }
        else
        {
            _S1441 = false;
        }
        if(_S1441)
        {
            *&((&(&(globalParams_0->islands_0)[_S1432.island_2])->info_1)->z) = (isl_13.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S1445 = __ballot_sync(_S1431, true);
        _S1437 = _S1445;
    }
    uint _S1446 = 0U;
    uint _S1447 = isl_13.info_1.x;
    bool _S1448 = (_S1447 & 1U) != 0U;
    uint _S1449 = __ballot_sync(_S1437, _S1448);
    if(_S1448)
    {
        return;
    }
    else
    {
        uint _S1450 = __ballot_sync(_S1437, true);
        _S1446 = _S1450;
    }
    float3  _S1451 = make_float3 (0.0f);
    float3  f_16 = _S1451;
    float3  t_13 = _S1451;
    uint c_22 = wg_1.begin_0 + tid_8;
    bool _S1452 = c_22 < (wg_1.end_0);
    uint _S1453 = __ballot_sync(_S1446, _S1452);
    if(_S1452)
    {
        Island_0 _S1454 = isl_13;
        Rigid_0 _S1455 = rigid_of_0(&_S1454);
        float _S1456 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S1457 = (_S1447 & 4U) != 0U;
        Island_0 _S1458 = isl_13;
        Rigid_0 _S1459 = _S1455;
        net_load_0(c_22, &_S1458, &_S1459, _S1439, _S1456, _S1457, &f_16, &t_13);
        uint _S1460 = __ballot_sync(_S1446, true);
        _S1423 = _S1460;
    }
    else
    {
        uint _S1461 = __ballot_sync(_S1446, true);
        _S1423 = _S1461;
    }
    group_sum3_0(tid_8, &f_16, &t_13, _S1423);
    bool _S1462 = tid_8 == 0U;
    uint _S1463 = __ballot_sync(_S1423, _S1462);
    if(_S1462)
    {
        uint _S1464 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(_S1420 - _S1464, 0U, f_16, t_13);
    }
    return;
}

static __device__ void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_13, float3  * a_16, float3  * b_31, uint _S1465)
{
    uint _S1466;
    float4  _S1467 = make_float4 (0.0f);
    float4  x_24 = _S1467;
    float4  y_5 = _S1467;
    uint s_7 = tid_9;
    uint _S1468 = _S1465;
    for(;;)
    {
        bool _S1469 = s_7 < count_5;
        uint _S1470 = __ballot_sync(_S1468, _S1469);
        if(_S1469)
        {
            uint _S1471 = __ballot_sync(_S1468, true);
        }
        else
        {
            uint _S1472 = __ballot_sync(_S1468, false);
            uint _S1473 = __ballot_sync(_S1468, false);
            uint _S1474 = __ballot_sync(_S1465, true);
            _S1466 = _S1474;
            break;
        }
        uint _S1475 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1476 = 8U * (first_1 + s_7);
        x_24 = x_24 + *(&(globalParams_0->scratch_0)[_S1475 + _S1476 + p_13]);
        uint _S1477 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1477 + _S1476 + p_13 + 1U]);
        uint _S1478 = __ballot_sync(_S1468, true);
        s_7 = s_7 + 256U;
        _S1468 = _S1478;
    }
    group_sum2_0(tid_9, &x_24, &y_5, _S1466);
    float4  _S1479 = x_24;
    *a_16 = float3 {_S1479.x, _S1479.y, _S1479.z};
    float4  _S1480 = y_5;
    *b_31 = float3 {_S1480.x, _S1480.y, _S1480.z};
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_10, Island_0 * isl_14, WideGroup_0 * wg_2, uint _S1481)
{
    Rigid_0 _S1482 = rigid_of_0(isl_14);
    Rigid_0 rg_8 = _S1482;
    bool _S1483 = ((isl_14->info_1.x) & 1U) == 0U;
    uint _S1484 = __ballot_sync(_S1481, _S1483);
    if(_S1483)
    {
        float3  f_17;
        float3  t_14;
        wide_partials_0(tid_10, wg_2->first_0, isl_14->wide_groups_0, 0U, &f_17, &t_14, _S1484);
        rigid_acceleration_0(isl_14, &rg_8, f_17, t_14);
        uint _S1485 = __ballot_sync(_S1481, true);
    }
    return rg_8;
}

extern "C" __global__ void wide_chunks()
{
    uint _S1486 = 0U;
    uint _S1487 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S1488 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1489 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1488, _S1489);
    Island_0 isl_15 = *(&(globalParams_0->islands_0)[wg_3.island_2]);
    bool _S1490 = wide_enter_1(tid_11, wg_3.island_2);
    bool _S1491 = !_S1490;
    uint _S1492 = __ballot_sync(_S1487, _S1491);
    if(_S1491)
    {
        return;
    }
    else
    {
        uint _S1493 = __ballot_sync(_S1487, true);
        _S1486 = _S1493;
    }
    uint _S1494 = 0U;
    uint _S1495 = isl_15.info_1.x;
    bool anchored_0 = (_S1495 & 1U) != 0U;
    bool _S1496 = (_S1495 & 16U) != 0U;
    uint _S1497 = __ballot_sync(_S1486, _S1496);
    if(_S1496)
    {
        if(tid_11 == 0U)
        {
            uint _S1498 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S1498 + 8U * _S1489 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S1499 = __ballot_sync(_S1486, true);
        _S1494 = _S1499;
    }
    Island_0 _S1500 = isl_15;
    WideGroup_0 _S1501 = wg_3;
    Rigid_0 _S1502 = wide_rigid_frame_0(tid_11, &_S1500, &_S1501, _S1494);
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S1503 = make_float3 (0.0f);
    float3  tu_2 = _S1503;
    float3  pv_2 = _S1503;
    uint c_23 = wg_3.begin_0 + tid_11;
    bool _S1504 = c_23 < (wg_3.end_0);
    uint _S1505 = __ballot_sync(_S1494, _S1504);
    uint _S1506;
    if(_S1504)
    {
        float _S1507 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1508 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S1509 = _S1508 != 0U;
        Island_0 _S1510 = isl_15;
        uint _S1511 = wide_step_0(&_S1510);
        bool _S1512 = (_S1495 & 4U) != 0U;
        Island_0 _S1513 = isl_15;
        Rigid_0 _S1514 = _S1502;
        chunk_update_0(c_23, &_S1513, &_S1514, _S1507, _S1509, _S1511, _S1512, &work_3, &work_err_2);
        bool _S1515 = !anchored_0;
        uint _S1516 = __ballot_sync(_S1505, _S1515);
        if(_S1515)
        {
            drift_moments_0(c_23, &tu_2, &pv_2);
            uint _S1517 = __ballot_sync(_S1505, true);
        }
        else
        {
            uint _S1518 = __ballot_sync(_S1505, true);
        }
        uint _S1519 = __ballot_sync(_S1494, true);
        _S1506 = _S1519;
    }
    else
    {
        uint _S1520 = __ballot_sync(_S1494, true);
        _S1506 = _S1520;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_3 = _S1503;
    group_sum3_0(tid_11, &wsum_1, &unused_3, _S1506);
    bool _S1521 = !anchored_0;
    uint _S1522 = __ballot_sync(_S1506, _S1521);
    if(_S1521)
    {
        group_sum3_0(tid_11, &tu_2, &pv_2, _S1522);
        uint _S1523 = __ballot_sync(_S1506, true);
    }
    if(tid_11 == 0U)
    {
        uint _S1524 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1525 = 8U * _S1489;
        *(&(globalParams_0->scratch_0)[_S1524 + _S1525 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S1521)
        {
            wide_store_0(_S1489, 2U, tu_2, pv_2);
        }
        uint _S1526 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S1526 + _S1525 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1527 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1528 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1529 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1528, _S1529);
    Island_0 * _S1530 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_16 = *_S1530;
    bool _S1531 = (((*_S1530).info_1.x) & 17U) != 0U;
    uint _S1532 = __ballot_sync(_S1527, _S1531);
    bool _S1533;
    uint _S1534;
    if(_S1531)
    {
        uint _S1535 = __ballot_sync(_S1527, true);
        _S1533 = true;
        _S1534 = _S1535;
    }
    else
    {
        bool _S1536 = wide_enter_1(tid_12, wg_4.island_2);
        bool _S1537 = !_S1536;
        uint _S1538 = __ballot_sync(_S1527, true);
        _S1533 = _S1537;
        _S1534 = _S1538;
    }
    uint _S1539 = 0U;
    uint _S1540 = __ballot_sync(_S1534, _S1533);
    if(_S1533)
    {
        return;
    }
    else
    {
        uint _S1541 = __ballot_sync(_S1534, true);
        _S1539 = _S1541;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_12, wg_4.first_0, isl_16.wide_groups_0, 2U, &tu_3, &pv_3, _S1539);
    float _S1542 = isl_16.wcom_0.w;
    float3  tr_4 = tu_3 / make_float3 (_S1542);
    float3  dv_4 = pv_3 / make_float3 (_S1542);
    float3  _S1543 = make_float3 (0.0f);
    float3  lu_2 = _S1543;
    float3  lv_2 = _S1543;
    uint c_24 = wg_4.begin_0 + tid_12;
    bool _S1544 = c_24 < (wg_4.end_0);
    uint _S1545 = __ballot_sync(_S1539, _S1544);
    if(_S1544)
    {
        float4  _S1546 = isl_16.wcom_0;
        drift_angular_0(c_24, float3 {_S1546.x, _S1546.y, _S1546.z}, tr_4, dv_4, &lu_2, &lv_2);
        uint _S1547 = __ballot_sync(_S1539, true);
        _S1534 = _S1547;
    }
    else
    {
        uint _S1548 = __ballot_sync(_S1539, true);
        _S1534 = _S1548;
    }
    group_sum3_0(tid_12, &lu_2, &lv_2, _S1534);
    bool _S1549 = tid_12 == 0U;
    uint _S1550 = __ballot_sync(_S1534, _S1549);
    if(_S1549)
    {
        wide_store_0(_S1529, 4U, lu_2, lv_2);
    }
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1551 = __ballot_sync(4294967295U, true);
    uint tid_13 = threadIdx.x;
    uint _S1552 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1553 = blockIdx.x;
    WideGroup_0 wg_5 = wide_group_0(_S1552, _S1553);
    Island_0 * _S1554 = (&(globalParams_0->islands_0)[wg_5.island_2]);
    Island_0 isl_17 = *_S1554;
    uint _S1555 = (*_S1554).info_1.x;
    bool _S1556 = (_S1555 & 1U) != 0U;
    uint _S1557 = __ballot_sync(_S1551, _S1556);
    bool _S1558;
    uint _S1559;
    if(_S1556)
    {
        uint _S1560 = __ballot_sync(_S1551, true);
        _S1558 = true;
        _S1559 = _S1560;
    }
    else
    {
        bool _S1561 = wide_enter_1(tid_13, wg_5.island_2);
        bool _S1562 = !_S1561;
        uint _S1563 = __ballot_sync(_S1551, true);
        _S1558 = _S1562;
        _S1559 = _S1563;
    }
    uint _S1564 = 0U;
    uint _S1565 = __ballot_sync(_S1559, _S1558);
    if(_S1558)
    {
        return;
    }
    else
    {
        uint _S1566 = __ballot_sync(_S1559, true);
        _S1564 = _S1566;
    }
    uint _S1567 = 0U;
    bool _S1568 = (_S1555 & 16U) != 0U;
    uint _S1569 = __ballot_sync(_S1564, _S1568);
    if(_S1568)
    {
        uint _S1570 = 0U;
        bool _S1571 = _S1553 != (wg_5.first_0);
        uint _S1572 = __ballot_sync(_S1569, _S1571);
        if(_S1571)
        {
            return;
        }
        else
        {
            uint _S1573 = __ballot_sync(_S1569, true);
            _S1570 = _S1573;
        }
        Island_0 _S1574 = isl_17;
        WideGroup_0 _S1575 = wg_5;
        Rigid_0 _S1576 = wide_rigid_frame_0(tid_13, &_S1574, &_S1575, _S1570);
        Rigid_0 rs_0 = _S1576;
        bool _S1577 = tid_13 != 0U;
        uint _S1578 = __ballot_sync(_S1570, _S1577);
        if(_S1577)
        {
            _S1558 = true;
        }
        else
        {
            _S1558 = (_S1555 & 2U) != 0U;
        }
        if(_S1558)
        {
            return;
        }
        float _S1579 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1580 = isl_17;
        integrate_rigid_0(&_S1580, &rs_0, _S1579);
        Quat_0 _S1581 = (&rs_0)->rot_0;
        float4  _S1582 = quat_vec_0(&_S1581);
        (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1582;
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
        uint _S1583 = __ballot_sync(_S1564, true);
        _S1567 = _S1583;
    }
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 2U, &tu_4, &pv_4, _S1567);
    float3  lu_3;
    float3  lv_3;
    wide_partials_0(tid_13, wg_5.first_0, isl_17.wide_groups_0, 4U, &lu_3, &lv_3, _S1567);
    float _S1584 = isl_17.wcom_0.w;
    float3  tr_5 = tu_4 / make_float3 (_S1584);
    float3  dv_5 = pv_4 / make_float3 (_S1584);
    float3  phi_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_3);
    float3  dw_3 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_3);
    uint c_25 = wg_5.begin_0 + tid_13;
    bool _S1585 = c_25 < (wg_5.end_0);
    uint _S1586 = __ballot_sync(_S1567, _S1585);
    if(_S1585)
    {
        float4  _S1587 = isl_17.wcom_0;
        drift_apply_0(c_25, float3 {_S1587.x, _S1587.y, _S1587.z}, tr_5, phi_4, dv_5, dw_3);
        uint _S1588 = __ballot_sync(_S1567, true);
        _S1559 = _S1588;
    }
    else
    {
        uint _S1589 = __ballot_sync(_S1567, true);
        _S1559 = _S1589;
    }
    uint _S1590 = 0U;
    bool _S1591 = _S1553 != (wg_5.first_0);
    uint _S1592 = __ballot_sync(_S1559, _S1591);
    if(_S1591)
    {
        return;
    }
    else
    {
        uint _S1593 = __ballot_sync(_S1559, true);
        _S1590 = _S1593;
    }
    Island_0 _S1594 = isl_17;
    WideGroup_0 _S1595 = wg_5;
    Rigid_0 _S1596 = wide_rigid_frame_0(tid_13, &_S1594, &_S1595, _S1590);
    Rigid_0 rg_9 = _S1596;
    bool _S1597 = tid_13 != 0U;
    uint _S1598 = __ballot_sync(_S1590, _S1597);
    if(_S1597)
    {
        return;
    }
    if(!((_S1555 & 2U) != 0U))
    {
        float _S1599 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1600 = isl_17;
        integrate_rigid_0(&_S1600, &rg_9, _S1599);
        Island_0 _S1601 = isl_17;
        drift_rigid_0(&_S1601, &rg_9, tr_5, phi_4, dv_5, dw_3);
    }
    Quat_0 _S1602 = (&rg_9)->rot_0;
    float4  _S1603 = quat_vec_0(&_S1602);
    (&(globalParams_0->islands_0)[wg_5.island_2])->rotation_0 = _S1603;
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
    uint _S1604 = 0U;
    uint _S1605 = __ballot_sync(4294967295U, true);
    uint tid_14 = threadIdx.x;
    uint _S1606 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1607 = blockIdx.x;
    WideGroup_0 wg_6 = wide_group_0(_S1606, _S1607);
    bool _S1608 = _S1607 != (wg_6.first_0);
    uint _S1609 = __ballot_sync(_S1605, _S1608);
    if(_S1608)
    {
        return;
    }
    else
    {
        uint _S1610 = __ballot_sync(_S1605, true);
        _S1604 = _S1610;
    }
    uint _S1611 = 0U;
    Island_0 * _S1612 = (&(globalParams_0->islands_0)[wg_6.island_2]);
    Island_0 isl_18 = *_S1612;
    Island_0 _S1613 = *_S1612;
    bool _S1614 = wide_enter_0(tid_14, &_S1613);
    bool _S1615 = !_S1614;
    uint _S1616 = __ballot_sync(_S1604, _S1615);
    if(_S1615)
    {
        return;
    }
    else
    {
        uint _S1617 = __ballot_sync(_S1604, true);
        _S1611 = _S1617;
    }
    float3  work_4;
    float3  flags_2;
    wide_partials_0(tid_14, wg_6.first_0, (&isl_18)->wide_groups_0, 6U, &work_4, &flags_2, _S1611);
    bool _S1618 = tid_14 != 0U;
    uint _S1619 = __ballot_sync(_S1611, _S1618);
    if(_S1618)
    {
        return;
    }
    Island_0 _S1620 = isl_18;
    uint _S1621 = wide_step_0(&_S1620);
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        Island_0 _S1622 = isl_18;
        Rigid_0 _S1623 = rigid_of_0(&_S1622);
        Island_0 _S1624 = isl_18;
        Rigid_0 _S1625 = _S1623;
        record_probes_0(&_S1624, &_S1625, _S1621);
    }
    bool halt_0 = (((&isl_18)->info_1.z) & 2U) != 0U;
    bool _S1626;
    if(halt_0)
    {
        _S1626 = (((&isl_18)->info_1.x) & 4U) != 0U;
    }
    else
    {
        _S1626 = false;
    }
    if(_S1626)
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
    uint _S1627;
    if(halt_0)
    {
        _S1627 = 128U;
    }
    else
    {
        _S1627 = 0U;
    }
    uint _S1628 = 256U | _S1627;
    if(((&isl_18)->probes_0.y) > ((&isl_18)->probes_0.x))
    {
        _S1627 = 262144U;
    }
    else
    {
        _S1627 = 0U;
    }
    uint _S1629 = _S1628 | _S1627;
    if((((&isl_18)->info_1.x) & 4U) != 0U)
    {
        _S1627 = 524288U;
    }
    else
    {
        _S1627 = 0U;
    }
    uint _S1630 = _S1629 | _S1627;
    if((flags_2.x) > 0.0f)
    {
        _S1627 = 32768U;
    }
    else
    {
        _S1627 = 0U;
    }
    uint _S1631 = _S1630 | _S1627;
    if((flags_2.y) > 0.0f)
    {
        _S1627 = 65536U;
    }
    else
    {
        _S1627 = 0U;
    }
    uint _S1632 = _S1631 | _S1627;
    if((flags_2.z) > 0.0f)
    {
        _S1627 = 131072U;
    }
    else
    {
        _S1627 = 0U;
    }
    (&isl_18)->coverage_0 = ((&isl_18)->coverage_0) | (_S1632 | _S1627);
    *(&(globalParams_0->islands_0)[wg_6.island_2]) = isl_18;
    return;
}

static __device__ uint sv_0(uint c_26, uint slot_2)
{
    uint _S1633 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1633 + 23U * c_26 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_15, Island_0 * isl_19, uint slot_3, uint _S1634)
{
    uint _S1635;
    uint _S1636;
    float3  _S1637 = make_float3 (0.0f);
    float3  net_f_0 = _S1637;
    float3  net_m_0 = _S1637;
    uint4  _S1638 = isl_19->range_0;
    uint _S1639 = isl_19->range_0.x + tid_15;
    uint c_27 = _S1639;
    uint _S1640 = _S1634;
    for(;;)
    {
        uint _S1641 = _S1638.y;
        _S1635 = _S1641;
        bool _S1642 = c_27 < _S1641;
        uint _S1643 = __ballot_sync(_S1640, _S1642);
        if(_S1642)
        {
            uint _S1644 = __ballot_sync(_S1640, true);
        }
        else
        {
            uint _S1645 = __ballot_sync(_S1640, false);
            uint _S1646 = __ballot_sync(_S1640, false);
            uint _S1647 = __ballot_sync(_S1634, true);
            _S1636 = _S1647;
            break;
        }
        float4  _S1648 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3)]);
        float3  fi_1 = float3 {_S1648.x, _S1648.y, _S1648.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1649 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1650 = isl_19->com_0;
        float4  _S1651 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1649.x, _S1649.y, _S1649.z} - float3 {_S1650.x, _S1650.y, _S1650.z}, fi_1) + float3 {_S1651.x, _S1651.y, _S1651.z});
        uint _S1652 = __ballot_sync(_S1640, true);
        c_27 = c_27 + 256U;
        _S1640 = _S1652;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, _S1636);
    float4  _S1653 = isl_19->com_0;
    float3  _S1654 = net_f_0 / make_float3 (isl_19->com_0.w);
    float3  _S1655 = rows_mul_0(isl_19->inv0_1, isl_19->inv1_1, isl_19->inv2_1, net_m_0);
    c_27 = _S1639;
    for(;;)
    {
        if(c_27 < _S1635)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1656 = (&(globalParams_0->chunks_0)[c_27]);
        float4  _S1657 = __ldg(&_S1656->center_0);
        uint _S1658 = sv_0(c_27, slot_3);
        float4  _S1659 = *(&(globalParams_0->scratch_0)[_S1658]);
        *(&(globalParams_0->scratch_0)[_S1658]) = make_float4 ((float3 {_S1659.x, _S1659.y, _S1659.z} - (_S1654 + cross_0(_S1655, float3 {_S1657.x, _S1657.y, _S1657.z} - float3 {_S1653.x, _S1653.y, _S1653.z})) * make_float3 (_S1657.w)).x, (float3 {_S1659.x, _S1659.y, _S1659.z} - (_S1654 + cross_0(_S1655, float3 {_S1657.x, _S1657.y, _S1657.z} - float3 {_S1653.x, _S1653.y, _S1653.z})) * make_float3 (_S1657.w)).y, (float3 {_S1659.x, _S1659.y, _S1659.z} - (_S1654 + cross_0(_S1655, float3 {_S1657.x, _S1657.y, _S1657.z} - float3 {_S1653.x, _S1653.y, _S1653.z})) * make_float3 (_S1657.w)).z, 0.0f);
        uint _S1660 = sv_0(c_27, slot_3 + 1U);
        float4  * _S1661 = (&(globalParams_0->scratch_0)[_S1660]);
        float4  _S1662 = *(&(globalParams_0->scratch_0)[_S1660]);
        float3  _S1663 = float3 {_S1662.x, _S1662.y, _S1662.z};
        float4  _S1664 = __ldg(&_S1656->inertia0_0);
        float4  _S1665 = __ldg(&_S1656->inertia1_0);
        float4  _S1666 = __ldg(&_S1656->inertia2_0);
        *_S1661 = make_float4 ((_S1663 - rows_mul_0(_S1664, _S1665, _S1666, _S1655)).x, (_S1663 - rows_mul_0(_S1664, _S1665, _S1666, _S1655)).y, (_S1663 - rows_mul_0(_S1664, _S1665, _S1666, _S1655)).z, 0.0f);
        c_27 = c_27 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1667)
{
    uint _S1668;
    float4  _S1669 = make_float4 (0.0f);
    float4  acc_0 = _S1669;
    float4  unused_4 = _S1669;
    uint c_28 = c0_0 + tid_16;
    uint _S1670 = _S1667;
    for(;;)
    {
        bool _S1671 = c_28 < c1_0;
        uint _S1672 = __ballot_sync(_S1670, _S1671);
        if(_S1671)
        {
            uint _S1673 = __ballot_sync(_S1670, true);
        }
        else
        {
            uint _S1674 = __ballot_sync(_S1670, false);
            uint _S1675 = __ballot_sync(_S1670, false);
            uint _S1676 = __ballot_sync(_S1667, true);
            _S1668 = _S1676;
            break;
        }
        float4  _S1677 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2)]);
        float4  _S1678 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2)]);
        float4  _S1679 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sa_2 + 1U)]);
        float4  _S1680 = *(&(globalParams_0->scratch_0)[sv_0(c_28, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1677.x, _S1677.y, _S1677.z}, float3 {_S1678.x, _S1678.y, _S1678.z}) + dot_0(float3 {_S1679.x, _S1679.y, _S1679.z}, float3 {_S1680.x, _S1680.y, _S1680.z}));
        uint _S1681 = __ballot_sync(_S1670, true);
        c_28 = c_28 + 256U;
        _S1670 = _S1681;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, _S1668);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1682, float3  * _S1683, float3  * _S1684)
{
    BondStatic_0 * _S1685 = (&(globalParams_0->bonds_0)[_S1682]);
    JointBond_0 _S1686 = slang_ldg_0(&_S1685->law_0);
    uint ca_1 = _S1686.ids_0.y;
    uint cb_1 = _S1686.ids_0.z;
    uint _S1687 = 4U * cb_1;
    float4  _S1688 = *(&(globalParams_0->state_0)[_S1687]);
    uint _S1689 = 4U * ca_1;
    float4  _S1690 = *(&(globalParams_0->state_0)[_S1689]);
    float4  _S1691 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1692 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1688.x, _S1688.y, _S1688.z} - float3 {_S1690.x, _S1690.y, _S1690.z} + (float3 {_S1691.x, _S1691.y, _S1691.z} - float3 {_S1692.x, _S1692.y, _S1692.z});
    uint _S1693 = _S1687 + 1U;
    float4  _S1694 = *(&(globalParams_0->state_0)[_S1693]);
    uint _S1695 = _S1689 + 1U;
    float4  _S1696 = *(&(globalParams_0->state_0)[_S1695]);
    uint _S1697 = sv_0(cb_1, 22U);
    float4  _S1698 = *(&(globalParams_0->scratch_0)[_S1697]);
    uint _S1699 = sv_0(ca_1, 22U);
    float4  _S1700 = *(&(globalParams_0->scratch_0)[_S1699]);
    float3  dth_0 = float3 {_S1694.x, _S1694.y, _S1694.z} - float3 {_S1696.x, _S1696.y, _S1696.z} + (float3 {_S1698.x, _S1698.y, _S1698.z} - float3 {_S1700.x, _S1700.y, _S1700.z});
    float4  _S1701 = *(&(globalParams_0->state_0)[_S1695]);
    float4  _S1702 = *(&(globalParams_0->scratch_0)[_S1699]);
    float3  ta_3 = float3 {_S1701.x, _S1701.y, _S1701.z} + float3 {_S1702.x, _S1702.y, _S1702.z};
    float4  _S1703 = *(&(globalParams_0->state_0)[_S1693]);
    float4  _S1704 = *(&(globalParams_0->scratch_0)[_S1697]);
    float3  tb_3 = float3 {_S1703.x, _S1703.y, _S1703.z} + float3 {_S1704.x, _S1704.y, _S1704.z};
    float4  _S1705 = __ldg(&_S1685->rb_0);
    float3  _S1706 = cross_0(tb_3, float3 {_S1705.x, _S1705.y, _S1705.z});
    float4  _S1707 = __ldg(&_S1685->ra_0);
    float3  _S1708 = to_local_0(_S1682, du_0 + (_S1706 - cross_0(ta_3, float3 {_S1707.x, _S1707.y, _S1707.z})));
    *_S1683 = _S1708;
    float3  _S1709 = to_local_0(_S1682, dth_0);
    *_S1684 = _S1709;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1710 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1711 = slang_ldg_0(&_S1710->law_0);
    JointBond_0 _S1712 = _S1711;
    JointState_0 _S1713 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1714 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1711.ids_0.x], &_S1712, &_S1713, d_lin_4, d_ang_3, 0.0f, false);
    return _S1714;
}

static __device__ void gather_loads_0(uint c_29, float3  * fi_2, float3  * mi_3)
{
    float3  _S1715 = make_float3 (0.0f);
    *fi_2 = _S1715;
    *mi_3 = _S1715;
    uint _S1716 = __ldg((&(globalParams_0->index_0)[c_29]));
    uint e_4 = _S1716;
    for(;;)
    {
        uint _S1717 = __ldg((&(globalParams_0->index_0)[c_29 + 1U]));
        if(e_4 < _S1717)
        {
        }
        else
        {
            break;
        }
        uint _S1718 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint bond_0 = _S1718 >> int(1);
        if((_S1718 & 1U) == 0U)
        {
            uint _S1719 = 3U * bond_0;
            float4  _S1720 = *(&(globalParams_0->scratch_0)[_S1719]);
            *fi_2 = *fi_2 + float3 {_S1720.x, _S1720.y, _S1720.z};
            float4  _S1721 = *(&(globalParams_0->scratch_0)[_S1719 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1721.x, _S1721.y, _S1721.z};
        }
        else
        {
            uint _S1722 = 3U * bond_0;
            float4  _S1723 = *(&(globalParams_0->scratch_0)[_S1722]);
            *fi_2 = *fi_2 - float3 {_S1723.x, _S1723.y, _S1723.z};
            float4  _S1724 = *(&(globalParams_0->scratch_0)[_S1722 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1724.x, _S1724.y, _S1724.z};
        }
        e_4 = e_4 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_30)
{
    uint _S1725 = __ldg((&(globalParams_0->index_0)[c_30]));
    uint e_5 = _S1725;
    float m_7 = 0.0f;
    for(;;)
    {
        uint _S1726 = __ldg((&(globalParams_0->index_0)[c_30 + 1U]));
        if(e_5 < _S1726)
        {
        }
        else
        {
            break;
        }
        uint _S1727 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint _S1728 = 3U * (_S1727 >> int(1));
        float4  _S1729 = *(&(globalParams_0->scratch_0)[_S1728]);
        float3  f_18 = float3 {_S1729.x, _S1729.y, _S1729.z};
        float3  t_15;
        if((_S1727 & 1U) == 0U)
        {
            float4  _S1730 = *(&(globalParams_0->scratch_0)[_S1728 + 1U]);
            t_15 = float3 {_S1730.x, _S1730.y, _S1730.z};
        }
        else
        {
            float4  _S1731 = *(&(globalParams_0->scratch_0)[_S1728 + 2U]);
            t_15 = float3 {_S1731.x, _S1731.y, _S1731.z};
        }
        float m_8 = m_7 + (dot_0(f_18, f_18) + dot_0(t_15, t_15));
        e_5 = e_5 + 1U;
        m_7 = m_8;
    }
    return m_7;
}

static __device__ uint fixed_mask_0(uint c_31)
{
    uint4  _S1732 = __ldg(&(&(globalParams_0->chunks_0)[c_31])->info_0);
    uint support_1 = _S1732.x;
    uint _S1733;
    if(support_1 == 1U)
    {
        _S1733 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1733 = 7U;
        }
        else
        {
            _S1733 = 0U;
        }
    }
    return _S1733;
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
    uint _S1734 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1735 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1734 + 23U * _S1735 + 2U * i_19;
}

static __device__ void store_inverse_0(uint c_32, FixedArray<float, 36>  * a_17)
{
    uint j_7;
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
        bool _S1736;
        if(i_20 < 6U)
        {
            _S1736 = spd_0;
        }
        else
        {
            _S1736 = false;
        }
        if(_S1736)
        {
        }
        else
        {
            break;
        }
        j_7 = 0U;
        for(;;)
        {
            if(j_7 <= i_20)
            {
            }
            else
            {
                break;
            }
            uint _S1737 = i_20 * 6U;
            uint _S1738 = _S1737 + j_7;
            k_19 = 0U;
            sum_4 = (*a_17)[_S1738];
            for(;;)
            {
                if(k_19 < j_7)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1737 + k_19] * l_4[j_7 * 6U + k_19];
                k_19 = k_19 + 1U;
                sum_4 = sum_5;
            }
            if(i_20 == j_7)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1737 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1738] = sum_4 / l_4[j_7 * 6U + j_7];
            }
            j_7 = j_7 + 1U;
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
            uint _S1739 = k_19 * 6U + k_19;
            float _S1740 = (*a_17)[_S1739];
            if(((*a_17)[_S1739]) > 0.0f)
            {
                sum_4 = 1.0f / _S1740;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1739] = sum_4;
            k_19 = k_19 + 1U;
        }
    }
    else
    {
        j_7 = 0U;
        for(;;)
        {
            if(j_7 < 6U)
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
                if(i_20 == j_7)
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
            FixedArray<float, 6>  x_25;
            x_25[int(0)] = 0.0f;
            x_25[int(1)] = 0.0f;
            x_25[int(2)] = 0.0f;
            x_25[int(3)] = 0.0f;
            x_25[int(4)] = 0.0f;
            x_25[int(5)] = 0.0f;
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
                    float s_10 = sum_4 - l_4[k_19 * 6U + i_21] * x_25[k_19];
                    k_19 = k_19 + 1U;
                    sum_4 = s_10;
                }
                x_25[i_21] = sum_4 / l_4[i_21 * 6U + i_21];
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
                inv_0[i_22 * 6U + j_7] = x_25[i_22];
                i_22 = i_22 + 1U;
            }
            j_7 = j_7 + 1U;
        }
    }
    j_7 = 0U;
    for(;;)
    {
        if(j_7 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1741 = 4U * j_7;
        *(&(globalParams_0->scratch_0)[sv_0(c_32, 12U + j_7)]) = make_float4 (inv_0[_S1741], inv_0[_S1741 + 1U], inv_0[_S1741 + 2U], inv_0[_S1741 + 3U]);
        j_7 = j_7 + 1U;
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
    uint _S1742 = __ldg((&(globalParams_0->index_0)[c_33]));
    uint e_6 = _S1742;
    for(;;)
    {
        uint _S1743 = __ldg((&(globalParams_0->index_0)[c_33 + 1U]));
        if(e_6 < _S1743)
        {
        }
        else
        {
            break;
        }
        uint _S1744 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint i_23 = _S1744 >> int(1);
        bool _S1745 = (_S1744 & 1U) != 0U;
        BondStatic_0 * _S1746 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1747 = statics_bond_slot_0(i_23);
        float4  _S1748 = *(&(globalParams_0->scratch_0)[_S1747]);
        float4  _S1749 = *(&(globalParams_0->scratch_0)[_S1747 + 1U]);
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
            uint _S1750 = p_14 % 3U;
            float3  t_16;
            if(_S1750 == 0U)
            {
                float4  _S1751 = __ldg(&_S1746->t1_0);
                t_16 = float3 {_S1751.x, _S1751.y, _S1751.z};
            }
            else
            {
                if(_S1750 == 1U)
                {
                    float4  _S1752 = __ldg(&_S1746->t2_0);
                    t_16 = float3 {_S1752.x, _S1752.y, _S1752.z};
                }
                else
                {
                    float4  _S1753 = __ldg(&_S1746->normal_0);
                    t_16 = float3 {_S1753.x, _S1753.y, _S1753.z};
                }
            }
            bool _S1754 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1754)
            {
                if(_S1745)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                if(_S1745)
                {
                    float4  _S1755 = __ldg(&_S1746->rb_0);
                    row_t_0 = cross_0(float3 {_S1755.x, _S1755.y, _S1755.z}, t_16);
                }
                else
                {
                    float4  _S1756 = __ldg(&_S1746->ra_0);
                    row_t_0 = - cross_0(float3 {_S1756.x, _S1756.y, _S1756.z}, t_16);
                }
            }
            else
            {
                float3  _S1757 = make_float3 (0.0f);
                if(_S1745)
                {
                    row_u_0 = t_16;
                }
                else
                {
                    row_u_0 = - t_16;
                }
                float3  _S1758 = row_u_0;
                row_u_0 = _S1757;
                row_t_0 = _S1758;
            }
            float kp_0;
            if(_S1754)
            {
                kp_0 = _slang_vector_get_element(_S1748, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1749, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1759 = { {
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
                    a_18[r_11 * 6U + q_13] = a_18[r_11 * 6U + q_13] + kp_0 * _S1759[r_11] * _S1759[q_13];
                    q_13 = q_13 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_6 = e_6 + 1U;
    }
    uint _S1760 = fixed_mask_0(c_33);
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
        if((_S1760 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1761 = a_18;
    store_inverse_0(c_33, &_S1761);
    return;
}

static __device__ float block_get_0(uint c_34, uint i_24, uint j_8)
{
    uint k_21 = i_24 * 6U + j_8;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_34, 12U + k_21 / 4U)]), k_21 % 4U);
}

static __device__ void precondition_0(uint c_35)
{
    float4  * _S1762 = (&(globalParams_0->scratch_0)[sv_0(c_35, 4U)]);
    float4  * _S1763 = (&(globalParams_0->scratch_0)[sv_0(c_35, 5U)]);
    FixedArray<float, 6>  _S1764 = { {
        (*_S1762).x, (*_S1762).y, (*_S1762).z, (*_S1763).x, (*_S1763).y, (*_S1763).z
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
        uint j_9 = 0U;
        float s_11 = 0.0f;
        for(;;)
        {
            if(j_9 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_12 = s_11 + block_get_0(c_35, i_25, j_9) * _S1764[j_9];
            j_9 = j_9 + 1U;
            s_11 = s_12;
        }
        z_1[i_25] = s_11;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_35, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_17, Island_0 * isl_20, uint slot_4, uint _S1765)
{
    uint _S1766;
    uint _S1767;
    float3  _S1768 = make_float3 (0.0f);
    float3  p_15 = _S1768;
    float3  l_5 = _S1768;
    uint4  _S1769 = isl_20->range_0;
    uint _S1770 = isl_20->range_0.x + tid_17;
    uint c_36 = _S1770;
    uint _S1771 = _S1765;
    for(;;)
    {
        uint _S1772 = _S1769.y;
        _S1766 = _S1772;
        bool _S1773 = c_36 < _S1772;
        uint _S1774 = __ballot_sync(_S1771, _S1773);
        if(_S1773)
        {
            uint _S1775 = __ballot_sync(_S1771, true);
        }
        else
        {
            uint _S1776 = __ballot_sync(_S1771, false);
            uint _S1777 = __ballot_sync(_S1771, false);
            uint _S1778 = __ballot_sync(_S1765, true);
            _S1767 = _S1778;
            break;
        }
        ChunkStatic_0 * _S1779 = (&(globalParams_0->chunks_0)[c_36]);
        float4  _S1780 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4)]);
        float3  u_3 = float3 {_S1780.x, _S1780.y, _S1780.z};
        float4  _S1781 = *(&(globalParams_0->scratch_0)[sv_0(c_36, slot_4 + 1U)]);
        float3  th_5 = float3 {_S1781.x, _S1781.y, _S1781.z};
        float4  _S1782 = __ldg(&_S1779->center_0);
        float4  _S1783 = isl_20->com_0;
        float3  r_12 = float3 {_S1782.x, _S1782.y, _S1782.z} - float3 {_S1783.x, _S1783.y, _S1783.z};
        float _S1784 = _S1782.w;
        p_15 = p_15 + u_3 * make_float3 (_S1784);
        float3  _S1785 = cross_0(r_12, u_3) * make_float3 (_S1784);
        float4  _S1786 = __ldg(&_S1779->inertia0_0);
        float4  _S1787 = __ldg(&_S1779->inertia1_0);
        float4  _S1788 = __ldg(&_S1779->inertia2_0);
        l_5 = l_5 + (_S1785 + rows_mul_0(_S1786, _S1787, _S1788, th_5));
        uint _S1789 = __ballot_sync(_S1771, true);
        c_36 = c_36 + 256U;
        _S1771 = _S1789;
    }
    group_sum3_0(tid_17, &p_15, &l_5, _S1767);
    float4  _S1790 = isl_20->com_0;
    float3  _S1791 = p_15 / make_float3 (isl_20->com_0.w);
    float3  _S1792 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, l_5);
    c_36 = _S1770;
    for(;;)
    {
        if(c_36 < _S1766)
        {
        }
        else
        {
            break;
        }
        float4  _S1793 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->center_0);
        uint _S1794 = sv_0(c_36, slot_4);
        float4  _S1795 = *(&(globalParams_0->scratch_0)[_S1794]);
        *(&(globalParams_0->scratch_0)[_S1794]) = make_float4 ((float3 {_S1795.x, _S1795.y, _S1795.z} - _S1791 - cross_0(_S1792, float3 {_S1793.x, _S1793.y, _S1793.z} - float3 {_S1790.x, _S1790.y, _S1790.z})).x, (float3 {_S1795.x, _S1795.y, _S1795.z} - _S1791 - cross_0(_S1792, float3 {_S1793.x, _S1793.y, _S1793.z} - float3 {_S1790.x, _S1790.y, _S1790.z})).y, (float3 {_S1795.x, _S1795.y, _S1795.z} - _S1791 - cross_0(_S1792, float3 {_S1793.x, _S1793.y, _S1793.z} - float3 {_S1790.x, _S1790.y, _S1790.z})).z, 0.0f);
        uint _S1796 = sv_0(c_36, slot_4 + 1U);
        float4  _S1797 = *(&(globalParams_0->scratch_0)[_S1796]);
        *(&(globalParams_0->scratch_0)[_S1796]) = make_float4 ((float3 {_S1797.x, _S1797.y, _S1797.z} - _S1792).x, (float3 {_S1797.x, _S1797.y, _S1797.z} - _S1792).y, (float3 {_S1797.x, _S1797.y, _S1797.z} - _S1792).z, 0.0f);
        c_36 = c_36 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1798 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1799 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1800 = _S1798 + 23U * _S1799;
    uint _S1801 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1800 + 2U * _S1801 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1802, uint _S1803, float3  _S1804, float3  _S1805, float _S1806)
{
    BondStatic_0 * _S1807 = (&(globalParams_0->bonds_0)[_S1803]);
    float3  _S1808 = to_body_0(_S1803, _S1804);
    float3  _S1809 = to_body_0(_S1803, _S1805);
    uint _S1810 = 3U * _S1802;
    *(&(globalParams_0->scratch_0)[_S1810]) = make_float4 (_S1808.x, _S1808.y, _S1808.z, _S1806);
    float4  * _S1811 = (&(globalParams_0->scratch_0)[_S1810 + 1U]);
    float4  _S1812 = __ldg(&_S1807->ra_0);
    *_S1811 = make_float4 ((_S1809 + cross_0(float3 {_S1812.x, _S1812.y, _S1812.z}, _S1808)).x, (_S1809 + cross_0(float3 {_S1812.x, _S1812.y, _S1812.z}, _S1808)).y, (_S1809 + cross_0(float3 {_S1812.x, _S1812.y, _S1812.z}, _S1808)).z, 0.0f);
    float4  * _S1813 = (&(globalParams_0->scratch_0)[_S1810 + 2U]);
    float3  _S1814 = - _S1809;
    float4  _S1815 = __ldg(&_S1807->rb_0);
    *_S1813 = make_float4 ((_S1814 + cross_0(float3 {_S1815.x, _S1815.y, _S1815.z}, - _S1808)).x, (_S1814 + cross_0(float3 {_S1815.x, _S1815.y, _S1815.z}, - _S1808)).y, (_S1814 + cross_0(float3 {_S1815.x, _S1815.y, _S1815.z}, - _S1808)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1816, float3  _S1817, float3  _S1818, float3  _S1819, float3  _S1820, float3  * _S1821, float3  * _S1822)
{
    BondStatic_0 * _S1823 = (&(globalParams_0->bonds_0)[_S1816]);
    float4  _S1824 = __ldg(&_S1823->rb_0);
    float3  _S1825 = _S1819 + cross_0(_S1820, float3 {_S1824.x, _S1824.y, _S1824.z});
    float4  _S1826 = __ldg(&_S1823->ra_0);
    float3  _S1827 = to_local_0(_S1816, _S1825 - (_S1817 + cross_0(_S1818, float3 {_S1826.x, _S1826.y, _S1826.z})));
    *_S1821 = _S1827;
    float3  _S1828 = to_local_0(_S1816, _S1820 - _S1818);
    *_S1822 = _S1828;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1829 = 0U;
    uint _S1830;
    uint i_26;
    uint c_37;
    bool converged_0;
    uint _S1831;
    uint _S1832;
    uint _S1833;
    uint _S1834;
    uint _S1835;
    uint _S1836;
    uint i_27;
    uint _S1837;
    uint _S1838;
    uint _S1839;
    uint _S1840;
    uint _S1841;
    uint _S1842 = __ballot_sync(4294967295U, true);
    uint tid_18 = threadIdx.x;
    uint _S1843 = blockIdx.x;
    Island_0 * _S1844 = (&(globalParams_0->islands_0)[_S1843]);
    Island_0 isl_21 = *_S1844;
    uint _S1845 = (*_S1844).info_1.z;
    bool _S1846 = (_S1845 & 8U) == 0U;
    uint _S1847 = __ballot_sync(_S1842, _S1846);
    if(_S1846)
    {
        return;
    }
    else
    {
        uint _S1848 = __ballot_sync(_S1842, true);
        _S1829 = _S1848;
    }
    bool free_0 = ((isl_21.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_21.range_0.x;
    uint c1_1 = isl_21.range_0.y;
    uint b0_0 = isl_21.range_0.z;
    uint _S1849 = isl_21.range_0.w;
    uint _S1850 = c0_1 + tid_18;
    uint c_38 = _S1850;
    uint newton_0;
    newton_0 = _S1829;
    for(;;)
    {
        bool _S1851 = c_38 < c1_1;
        uint _S1852 = __ballot_sync(newton_0, _S1851);
        if(_S1851)
        {
            uint _S1853 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1854 = __ballot_sync(newton_0, false);
            uint _S1855 = __ballot_sync(newton_0, false);
            uint _S1856 = __ballot_sync(_S1829, true);
            _S1830 = _S1856;
            break;
        }
        float4  _S1857 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 21U)]) = _S1857;
        *(&(globalParams_0->scratch_0)[sv_0(c_38, 22U)]) = _S1857;
        uint _S1858 = __ballot_sync(newton_0, true);
        c_38 = c_38 + 256U;
        newton_0 = _S1858;
    }
    __syncthreads();
    uint _S1859 = __ballot_sync(_S1830, free_0);
    if(free_0)
    {
        Island_0 _S1860 = isl_21;
        project_load_slot_0(tid_18, &_S1860, 0U, _S1859);
        uint _S1861 = __ballot_sync(_S1830, true);
        c_38 = _S1861;
    }
    else
    {
        uint _S1862 = __ballot_sync(_S1830, true);
        c_38 = _S1862;
    }
    float _S1863 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, c_38);
    float _S1864 = (F32_max(((F32_sqrt((_S1863)))), (1.00000000317107685e-30f)));
    float _S1865 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1866 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1867 = (U32_min((_S1866), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1868 = 0U;
        uint _S1869 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1870 = newton_0 < _S1869;
        uint _S1871 = __ballot_sync(c_38, _S1870);
        if(_S1870)
        {
            uint _S1872 = __ballot_sync(c_38, true);
            _S1868 = _S1872;
        }
        else
        {
            converged_0 = false;
            break;
        }
        uint _S1873 = b0_0 + tid_18;
        i_26 = _S1873;
        uint _S1874;
        _S1874 = _S1868;
        for(;;)
        {
            bool _S1875 = i_26 < _S1849;
            uint _S1876 = __ballot_sync(_S1874, _S1875);
            if(_S1875)
            {
                uint _S1877 = __ballot_sync(_S1874, true);
            }
            else
            {
                uint _S1878 = __ballot_sync(_S1874, false);
                uint _S1879 = __ballot_sync(_S1874, false);
                uint _S1880 = __ballot_sync(_S1868, true);
                _S1831 = _S1880;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1881 = __ballot_sync(_S1874, true);
            i_26 = i_26 + 256U;
            _S1874 = _S1881;
        }
        __syncthreads();
        float4  _S1882 = make_float4 (0.0f);
        float4  magnitude_0 = _S1882;
        float4  unused_m_0 = _S1882;
        uint c_39 = _S1850;
        uint _S1883 = _S1831;
        for(;;)
        {
            bool _S1884 = c_39 < c1_1;
            uint _S1885 = __ballot_sync(_S1883, _S1884);
            if(_S1884)
            {
                uint _S1886 = __ballot_sync(_S1883, true);
            }
            else
            {
                uint _S1887 = __ballot_sync(_S1883, false);
                uint _S1888 = __ballot_sync(_S1883, false);
                uint _S1889 = __ballot_sync(_S1831, true);
                _S1832 = _S1889;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_39, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_39);
            float4  _S1890 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1890.x, _S1890.y, _S1890.z} + fi_3).x, (float3 {_S1890.x, _S1890.y, _S1890.z} + fi_3).y, (float3 {_S1890.x, _S1890.y, _S1890.z} + fi_3).z, 0.0f);
            float4  _S1891 = *(&(globalParams_0->scratch_0)[sv_0(c_39, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1891.x, _S1891.y, _S1891.z} + mi_4).x, (float3 {_S1891.x, _S1891.y, _S1891.z} + mi_4).y, (float3 {_S1891.x, _S1891.y, _S1891.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_39), &r_lin_0, &r_ang_0, _S1882, _S1882);
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_39, 5U)]) = r_ang_0;
            uint _S1892 = __ballot_sync(_S1883, true);
            c_39 = c_39 + 256U;
            _S1883 = _S1892;
        }
        __syncthreads();
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, _S1832);
        uint _S1893 = __ballot_sync(_S1832, free_0);
        uint _S1894;
        if(free_0)
        {
            Island_0 _S1895 = isl_21;
            project_load_slot_0(tid_18, &_S1895, 4U, _S1893);
            uint _S1896 = __ballot_sync(_S1832, true);
            _S1894 = _S1896;
        }
        else
        {
            uint _S1897 = __ballot_sync(_S1832, true);
            _S1894 = _S1897;
        }
        float _S1898 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1894);
        float residual_1 = (F32_sqrt((_S1898))) / _S1864;
        float _S1899 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1864)));
        bool _S1900 = residual_1 <= _S1865;
        uint _S1901 = __ballot_sync(_S1894, _S1900);
        uint _S1902;
        if(_S1900)
        {
            uint _S1903 = __ballot_sync(_S1894, true);
            converged_0 = true;
            _S1902 = _S1903;
        }
        else
        {
            uint _S1904 = _S1894 & (~_S1901);
            bool _S1905 = residual_1 <= _S1899;
            uint _S1906 = __ballot_sync(_S1904, _S1905);
            if(_S1905)
            {
                bool _S1907 = residual_1 > (0.5f * previous_2);
                uint _S1908 = __ballot_sync(_S1904, true);
                converged_0 = _S1907;
            }
            else
            {
                uint _S1909 = __ballot_sync(_S1904, true);
                converged_0 = false;
            }
            uint _S1910 = __ballot_sync(_S1894, true);
            _S1902 = _S1910;
        }
        uint _S1911 = 0U;
        uint _S1912 = __ballot_sync(_S1902, converged_0);
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        else
        {
            uint _S1913 = __ballot_sync(_S1902, true);
            _S1911 = _S1913;
        }
        uint i_28 = _S1873;
        uint _S1914;
        _S1914 = _S1911;
        for(;;)
        {
            bool _S1915 = i_28 < _S1849;
            uint _S1916 = __ballot_sync(_S1914, _S1915);
            if(_S1915)
            {
                uint _S1917 = __ballot_sync(_S1914, true);
            }
            else
            {
                uint _S1918 = __ballot_sync(_S1914, false);
                uint _S1919 = __ballot_sync(_S1914, false);
                uint _S1920 = __ballot_sync(_S1911, true);
                _S1833 = _S1920;
                break;
            }
            BondStatic_0 * _S1921 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S1922 = slang_ldg_0(&_S1921->law_0);
            JointBond_0 _S1923 = _S1922;
            JointState_0 _S1924 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S1923, &_S1924, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S1925 = statics_bond_slot_0(i_28);
            float _S1926 = _S1922.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1925]) = make_float4 (_S1926 * f_lin_2.x, _S1926 * f_lin_2.y, _S1922.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1925 + 1U]) = make_float4 (_S1922.stiff0_0.z * f_ang_2.x, _S1922.stiff0_0.w * f_ang_2.y, _S1922.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S1927 = __ballot_sync(_S1914, true);
            i_28 = i_28 + 256U;
            _S1914 = _S1927;
        }
        __syncthreads();
        uint c_40 = _S1850;
        uint _S1928 = _S1833;
        for(;;)
        {
            bool _S1929 = c_40 < c1_1;
            uint _S1930 = __ballot_sync(_S1928, _S1929);
            if(_S1929)
            {
                uint _S1931 = __ballot_sync(_S1928, true);
            }
            else
            {
                uint _S1932 = __ballot_sync(_S1928, false);
                uint _S1933 = __ballot_sync(_S1928, false);
                uint _S1934 = __ballot_sync(_S1833, true);
                _S1834 = _S1934;
                break;
            }
            assemble_block_0(c_40);
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 2U)]) = _S1882;
            *(&(globalParams_0->scratch_0)[sv_0(c_40, 3U)]) = _S1882;
            uint _S1935 = __ballot_sync(_S1928, true);
            c_40 = c_40 + 256U;
            _S1928 = _S1935;
        }
        __syncthreads();
        uint c_41 = _S1850;
        uint _S1936 = _S1834;
        for(;;)
        {
            bool _S1937 = c_41 < c1_1;
            uint _S1938 = __ballot_sync(_S1936, _S1937);
            if(_S1937)
            {
                uint _S1939 = __ballot_sync(_S1936, true);
            }
            else
            {
                uint _S1940 = __ballot_sync(_S1936, false);
                uint _S1941 = __ballot_sync(_S1936, false);
                uint _S1942 = __ballot_sync(_S1834, true);
                _S1835 = _S1942;
                break;
            }
            precondition_0(c_41);
            uint _S1943 = __ballot_sync(_S1936, true);
            c_41 = c_41 + 256U;
            _S1936 = _S1943;
        }
        __syncthreads();
        uint _S1944 = __ballot_sync(_S1835, free_0);
        uint _S1945;
        if(free_0)
        {
            Island_0 _S1946 = isl_21;
            project_displacement_slot_0(tid_18, &_S1946, 6U, _S1944);
            uint _S1947 = __ballot_sync(_S1835, true);
            _S1945 = _S1947;
        }
        else
        {
            uint _S1948 = __ballot_sync(_S1835, true);
            _S1945 = _S1948;
        }
        uint c_42 = _S1850;
        uint _S1949 = _S1945;
        for(;;)
        {
            bool _S1950 = c_42 < c1_1;
            uint _S1951 = __ballot_sync(_S1949, _S1950);
            if(_S1950)
            {
                uint _S1952 = __ballot_sync(_S1949, true);
            }
            else
            {
                uint _S1953 = __ballot_sync(_S1949, false);
                uint _S1954 = __ballot_sync(_S1949, false);
                uint _S1955 = __ballot_sync(_S1945, true);
                _S1836 = _S1955;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_42, 7U)]);
            uint _S1956 = __ballot_sync(_S1949, true);
            c_42 = c_42 + 256U;
            _S1949 = _S1956;
        }
        __syncthreads();
        float _S1957 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S1836);
        float _S1958 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1836);
        float _S1959 = (F32_sqrt((_S1958)));
        float rz_0 = _S1957;
        uint k_22 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1960 = _S1836;
        for(;;)
        {
            bool _S1961 = k_22 < _S1867;
            uint _S1962 = __ballot_sync(_S1960, _S1961);
            uint _S1963;
            bool _S1964;
            if(_S1961)
            {
                bool _S1965 = _S1959 > 0.0f;
                uint _S1966 = __ballot_sync(_S1960, true);
                _S1964 = _S1965;
                _S1963 = _S1966;
            }
            else
            {
                uint _S1967 = __ballot_sync(_S1960, true);
                _S1964 = false;
                _S1963 = _S1967;
            }
            uint _S1968 = 0U;
            uint _S1969 = __ballot_sync(_S1963, _S1964);
            if(_S1964)
            {
                uint _S1970 = __ballot_sync(_S1963, true);
                _S1968 = _S1970;
            }
            else
            {
                uint _S1971 = __ballot_sync(_S1963, false);
                uint _S1972 = __ballot_sync(_S1960, false);
                uint _S1973 = __ballot_sync(_S1836, true);
                cg_total_0 = cg_total_1;
                i_27 = _S1973;
                break;
            }
            i_27 = _S1873;
            _S1837 = _S1968;
            for(;;)
            {
                bool _S1974 = i_27 < _S1849;
                uint _S1975 = __ballot_sync(_S1837, _S1974);
                if(_S1974)
                {
                    uint _S1976 = __ballot_sync(_S1837, true);
                }
                else
                {
                    uint _S1977 = __ballot_sync(_S1837, false);
                    uint _S1978 = __ballot_sync(_S1837, false);
                    uint _S1979 = __ballot_sync(_S1968, true);
                    _S1838 = _S1979;
                    break;
                }
                JointBond_0 _S1980 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S1980.ids_0.y;
                uint cb_2 = _S1980.ids_0.z;
                float4  _S1981 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S1982 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S1983 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S1984 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S1981.x, _S1981.y, _S1981.z}, float3 {_S1982.x, _S1982.y, _S1982.z}, float3 {_S1983.x, _S1983.y, _S1983.z}, float3 {_S1984.x, _S1984.y, _S1984.z}, &d_lin_6, &d_ang_5);
                uint _S1985 = statics_bond_slot_0(i_27);
                float4  _S1986 = *(&(globalParams_0->scratch_0)[_S1985]);
                float4  _S1987 = *(&(globalParams_0->scratch_0)[_S1985 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S1986.x, _S1986.y, _S1986.z}, d_ang_5 * float3 {_S1987.x, _S1987.y, _S1987.z}, 0.0f);
                uint _S1988 = __ballot_sync(_S1837, true);
                i_27 = i_27 + 256U;
                _S1837 = _S1988;
            }
            __syncthreads();
            c_37 = _S1850;
            uint _S1989 = _S1838;
            for(;;)
            {
                bool _S1990 = c_37 < c1_1;
                uint _S1991 = __ballot_sync(_S1989, _S1990);
                if(_S1990)
                {
                    uint _S1992 = __ballot_sync(_S1989, true);
                }
                else
                {
                    uint _S1993 = __ballot_sync(_S1989, false);
                    uint _S1994 = __ballot_sync(_S1989, false);
                    uint _S1995 = __ballot_sync(_S1838, true);
                    _S1839 = _S1995;
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
                uint _S1996 = __ballot_sync(_S1989, true);
                c_37 = c_37 + 256U;
                _S1989 = _S1996;
            }
            uint _S1997 = 0U;
            __syncthreads();
            float _S1998 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, _S1839);
            uint _S1999 = cg_total_1 + 1U;
            bool _S2000 = _S1998 <= 0.0f;
            uint _S2001 = __ballot_sync(_S1839, _S2000);
            if(_S2000)
            {
                uint _S2002 = __ballot_sync(_S1839, false);
                uint _S2003 = __ballot_sync(_S1960, false);
                uint _S2004 = __ballot_sync(_S1836, true);
                cg_total_0 = _S1999;
                i_27 = _S2004;
                break;
            }
            else
            {
                uint _S2005 = __ballot_sync(_S1839, true);
                _S1997 = _S2005;
            }
            float _S2006 = rz_0 / _S1998;
            uint c_43 = _S1850;
            uint _S2007;
            _S2007 = _S1997;
            for(;;)
            {
                bool _S2008 = c_43 < c1_1;
                uint _S2009 = __ballot_sync(_S2007, _S2008);
                if(_S2008)
                {
                    uint _S2010 = __ballot_sync(_S2007, true);
                }
                else
                {
                    uint _S2011 = __ballot_sync(_S2007, false);
                    uint _S2012 = __ballot_sync(_S2007, false);
                    uint _S2013 = __ballot_sync(_S1997, true);
                    _S1840 = _S2013;
                    break;
                }
                uint _S2014 = sv_0(c_43, 2U);
                float4  _S2015 = *(&(globalParams_0->scratch_0)[_S2014]);
                float4  _S2016 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 8U)]);
                *(&(globalParams_0->scratch_0)[_S2014]) = make_float4 ((float3 {_S2015.x, _S2015.y, _S2015.z} + make_float3 (_S2006) * float3 {_S2016.x, _S2016.y, _S2016.z}).x, (float3 {_S2015.x, _S2015.y, _S2015.z} + make_float3 (_S2006) * float3 {_S2016.x, _S2016.y, _S2016.z}).y, (float3 {_S2015.x, _S2015.y, _S2015.z} + make_float3 (_S2006) * float3 {_S2016.x, _S2016.y, _S2016.z}).z, 0.0f);
                uint _S2017 = sv_0(c_43, 3U);
                float4  _S2018 = *(&(globalParams_0->scratch_0)[_S2017]);
                float4  _S2019 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 9U)]);
                *(&(globalParams_0->scratch_0)[_S2017]) = make_float4 ((float3 {_S2018.x, _S2018.y, _S2018.z} + make_float3 (_S2006) * float3 {_S2019.x, _S2019.y, _S2019.z}).x, (float3 {_S2018.x, _S2018.y, _S2018.z} + make_float3 (_S2006) * float3 {_S2019.x, _S2019.y, _S2019.z}).y, (float3 {_S2018.x, _S2018.y, _S2018.z} + make_float3 (_S2006) * float3 {_S2019.x, _S2019.y, _S2019.z}).z, 0.0f);
                uint _S2020 = sv_0(c_43, 4U);
                float4  _S2021 = *(&(globalParams_0->scratch_0)[_S2020]);
                float4  _S2022 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 10U)]);
                *(&(globalParams_0->scratch_0)[_S2020]) = make_float4 ((float3 {_S2021.x, _S2021.y, _S2021.z} - make_float3 (_S2006) * float3 {_S2022.x, _S2022.y, _S2022.z}).x, (float3 {_S2021.x, _S2021.y, _S2021.z} - make_float3 (_S2006) * float3 {_S2022.x, _S2022.y, _S2022.z}).y, (float3 {_S2021.x, _S2021.y, _S2021.z} - make_float3 (_S2006) * float3 {_S2022.x, _S2022.y, _S2022.z}).z, 0.0f);
                uint _S2023 = sv_0(c_43, 5U);
                float4  _S2024 = *(&(globalParams_0->scratch_0)[_S2023]);
                float4  _S2025 = *(&(globalParams_0->scratch_0)[sv_0(c_43, 11U)]);
                *(&(globalParams_0->scratch_0)[_S2023]) = make_float4 ((float3 {_S2024.x, _S2024.y, _S2024.z} - make_float3 (_S2006) * float3 {_S2025.x, _S2025.y, _S2025.z}).x, (float3 {_S2024.x, _S2024.y, _S2024.z} - make_float3 (_S2006) * float3 {_S2025.x, _S2025.y, _S2025.z}).y, (float3 {_S2024.x, _S2024.y, _S2024.z} - make_float3 (_S2006) * float3 {_S2025.x, _S2025.y, _S2025.z}).z, 0.0f);
                uint _S2026 = __ballot_sync(_S2007, true);
                c_43 = c_43 + 256U;
                _S2007 = _S2026;
            }
            uint _S2027 = 0U;
            __syncthreads();
            float _S2028 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S1840);
            bool _S2029 = (F32_sqrt((_S2028))) <= (0.00009999999747379f * _S1959);
            uint _S2030 = __ballot_sync(_S1840, _S2029);
            if(_S2029)
            {
                uint _S2031 = __ballot_sync(_S1840, false);
                uint _S2032 = __ballot_sync(_S1960, false);
                uint _S2033 = __ballot_sync(_S1836, true);
                cg_total_0 = _S1999;
                i_27 = _S2033;
                break;
            }
            else
            {
                uint _S2034 = __ballot_sync(_S1840, true);
                _S2027 = _S2034;
            }
            uint c_44 = _S1850;
            uint _S2035;
            _S2035 = _S2027;
            for(;;)
            {
                bool _S2036 = c_44 < c1_1;
                uint _S2037 = __ballot_sync(_S2035, _S2036);
                if(_S2036)
                {
                    uint _S2038 = __ballot_sync(_S2035, true);
                }
                else
                {
                    uint _S2039 = __ballot_sync(_S2035, false);
                    uint _S2040 = __ballot_sync(_S2035, false);
                    uint _S2041 = __ballot_sync(_S2027, true);
                    _S1841 = _S2041;
                    break;
                }
                precondition_0(c_44);
                uint _S2042 = __ballot_sync(_S2035, true);
                c_44 = c_44 + 256U;
                _S2035 = _S2042;
            }
            __syncthreads();
            uint _S2043 = __ballot_sync(_S1841, free_0);
            uint _S2044;
            if(free_0)
            {
                Island_0 _S2045 = isl_21;
                project_displacement_slot_0(tid_18, &_S2045, 6U, _S2043);
                uint _S2046 = __ballot_sync(_S1841, true);
                _S2044 = _S2046;
            }
            else
            {
                uint _S2047 = __ballot_sync(_S1841, true);
                _S2044 = _S2047;
            }
            float _S2048 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S2044);
            float _S2049 = _S2048 / rz_0;
            uint c_45 = _S1850;
            uint _S2050 = _S2044;
            for(;;)
            {
                bool _S2051 = c_45 < c1_1;
                uint _S2052 = __ballot_sync(_S2050, _S2051);
                if(_S2051)
                {
                    uint _S2053 = __ballot_sync(_S2050, true);
                }
                else
                {
                    uint _S2054 = __ballot_sync(_S2050, false);
                    uint _S2055 = __ballot_sync(_S2050, false);
                    uint _S2056 = __ballot_sync(_S2044, true);
                    break;
                }
                uint _S2057 = sv_0(c_45, 8U);
                float4  _S2058 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 6U)]);
                float4  _S2059 = *(&(globalParams_0->scratch_0)[_S2057]);
                *(&(globalParams_0->scratch_0)[_S2057]) = make_float4 ((float3 {_S2058.x, _S2058.y, _S2058.z} + make_float3 (_S2049) * float3 {_S2059.x, _S2059.y, _S2059.z}).x, (float3 {_S2058.x, _S2058.y, _S2058.z} + make_float3 (_S2049) * float3 {_S2059.x, _S2059.y, _S2059.z}).y, (float3 {_S2058.x, _S2058.y, _S2058.z} + make_float3 (_S2049) * float3 {_S2059.x, _S2059.y, _S2059.z}).z, 0.0f);
                uint _S2060 = sv_0(c_45, 9U);
                float4  _S2061 = *(&(globalParams_0->scratch_0)[sv_0(c_45, 7U)]);
                float4  _S2062 = *(&(globalParams_0->scratch_0)[_S2060]);
                *(&(globalParams_0->scratch_0)[_S2060]) = make_float4 ((float3 {_S2061.x, _S2061.y, _S2061.z} + make_float3 (_S2049) * float3 {_S2062.x, _S2062.y, _S2062.z}).x, (float3 {_S2061.x, _S2061.y, _S2061.z} + make_float3 (_S2049) * float3 {_S2062.x, _S2062.y, _S2062.z}).y, (float3 {_S2061.x, _S2061.y, _S2061.z} + make_float3 (_S2049) * float3 {_S2062.x, _S2062.y, _S2062.z}).z, 0.0f);
                uint _S2063 = __ballot_sync(_S2050, true);
                c_45 = c_45 + 256U;
                _S2050 = _S2063;
            }
            __syncthreads();
            uint _S2064 = __ballot_sync(_S1960, true);
            uint _S2065 = k_22 + 1U;
            rz_0 = _S2048;
            k_22 = _S2065;
            cg_total_1 = _S1999;
            _S1960 = _S2064;
        }
        c_37 = _S1850;
        _S1837 = i_27;
        for(;;)
        {
            bool _S2066 = c_37 < c1_1;
            uint _S2067 = __ballot_sync(_S1837, _S2066);
            if(_S2066)
            {
                uint _S2068 = __ballot_sync(_S1837, true);
            }
            else
            {
                uint _S2069 = __ballot_sync(_S1837, false);
                uint _S2070 = __ballot_sync(_S1837, false);
                uint _S2071 = __ballot_sync(i_27, true);
                break;
            }
            uint _S2072 = 4U * c_37;
            float4  _S2073 = *(&(globalParams_0->state_0)[_S2072]);
            float3  u_4 = float3 {_S2073.x, _S2073.y, _S2073.z};
            uint _S2074 = sv_0(c_37, 21U);
            float4  _S2075 = *(&(globalParams_0->scratch_0)[_S2074]);
            float3  u_lo_0 = float3 {_S2075.x, _S2075.y, _S2075.z};
            uint _S2076 = _S2072 + 1U;
            float4  _S2077 = *(&(globalParams_0->state_0)[_S2076]);
            float3  th_6 = float3 {_S2077.x, _S2077.y, _S2077.z};
            uint _S2078 = sv_0(c_37, 22U);
            float4  _S2079 = *(&(globalParams_0->scratch_0)[_S2078]);
            float3  th_lo_0 = float3 {_S2079.x, _S2079.y, _S2079.z};
            float4  _S2080 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S2080.x, _S2080.y, _S2080.z});
            float4  _S2081 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 3U)]);
            comp_add_0(&th_6, &th_lo_0, float3 {_S2081.x, _S2081.y, _S2081.z});
            *(&(globalParams_0->state_0)[_S2072]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S2072])).w);
            *(&(globalParams_0->state_0)[_S2076]) = make_float4 (th_6.x, th_6.y, th_6.z, (*(&(globalParams_0->state_0)[_S2076])).w);
            *(&(globalParams_0->scratch_0)[_S2074]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S2078]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S2082 = __ballot_sync(_S1837, true);
            c_37 = c_37 + 256U;
            _S1837 = _S2082;
        }
        __syncthreads();
        uint _S2083 = newton_0 + 1U;
        uint _S2084 = __ballot_sync(c_38, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S2083;
        c_38 = _S2084;
    }
    i_26 = b0_0 + tid_18;
    for(;;)
    {
        if(i_26 < _S1849)
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
    c_37 = _S1850;
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
            float4  _S2085 = *(&(globalParams_0->scratch_0)[sv_0(c_37, 0U)]);
            reaction_1 = - (float3 {_S2085.x, _S2085.y, _S2085.z} + fi_5);
        }
        else
        {
            uint _S2086 = 4U * c_37;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S2086 + 1U])).w, (*(&(globalParams_0->state_0)[_S2086 + 2U])).w, (*(&(globalParams_0->state_0)[_S2086 + 3U])).w);
        }
        uint _S2087 = 4U * c_37;
        uint _S2088 = _S2087 + 1U;
        float4  _S2089 = *(&(globalParams_0->state_0)[_S2088]);
        *(&(globalParams_0->state_0)[_S2088]) = make_float4 (float3 {_S2089.x, _S2089.y, _S2089.z}.x, float3 {_S2089.x, _S2089.y, _S2089.z}.y, float3 {_S2089.x, _S2089.y, _S2089.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S2087 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S2087 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_37 = c_37 + 256U;
    }
    if(tid_18 == 0U)
    {
        float4  * _S2090 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1843)]);
        float _S2091 = (U32_asfloat((newton_0)));
        float _S2092 = (U32_asfloat((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S2090 = make_float4 (residual_0, _S2091, _S2092, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S1843])->info_1)->z) = _S1845 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_19 = threadIdx.x;
    uint _S2093 = blockIdx.x;
    Island_0 * _S2094 = (&(globalParams_0->islands_0)[_S2093]);
    Island_0 isl_22 = *_S2094;
    bool _S2095;
    if((((*_S2094).info_1.x) & 16U) == 0U)
    {
        _S2095 = true;
    }
    else
    {
        _S2095 = (isl_22.range_0.w) == (isl_22.range_0.z);
    }
    if(_S2095)
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
    uint _S2096 = isl_22.info_1.w;
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
        BondStatic_0 * _S2097 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S2098 = slang_ldg_0(&_S2097->law_0);
        uint _S2099 = 4U * _S2098.ids_0.y;
        float4  _S2100 = *(&(globalParams_0->state_0)[_S2099]);
        float4  _S2101 = *(&(globalParams_0->state_0)[_S2099 + 1U]);
        uint _S2102 = 4U * _S2098.ids_0.z;
        float4  _S2103 = *(&(globalParams_0->state_0)[_S2102]);
        float4  _S2104 = *(&(globalParams_0->state_0)[_S2102 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S2100.x, _S2100.y, _S2100.z}, float3 {_S2101.x, _S2101.y, _S2101.z}, float3 {_S2103.x, _S2103.y, _S2103.z}, float3 {_S2104.x, _S2104.y, _S2104.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S2105 = d_lin_7;
        float3  _S2106 = d_ang_6;
        float _S2107 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2108 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S2109 = _S2108 != 0U;
        JointBond_0 _S2110 = _S2098;
        JointState_0 _S2111 = previous_3;
        JointResponse_0 _S2112 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S2098.ids_0.x], &_S2110, &_S2111, _S2105, _S2106, _S2107, _S2109);
        if((_S2112.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S2095 = true;
        }
        else
        {
            _S2095 = (_S2112.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S2095)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S2112.dissipated_2);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S2112.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S2112.force_lin_1.x, _S2112.force_lin_1.y, _S2112.force_lin_1.z, _S2112.stored_5);
        (&bd_2)->force_ang_0 = make_float4 (_S2112.force_ang_1.x, _S2112.force_ang_1.y, _S2112.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S2112.state_1.utilization_0))));
        JointState_0 _S2113 = previous_3;
        bool _S2114 = is_damaged_0(&_S2113);
        bool _S2115;
        if(!_S2114)
        {
            JointState_0 _S2116 = _S2112.state_1;
            bool _S2117 = is_damaged_0(&_S2116);
            _S2115 = _S2117;
        }
        else
        {
            _S2115 = false;
        }
        bool _S2118;
        if(_S2115)
        {
            _S2118 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S2118 = false;
        }
        if(_S2118)
        {
            *&((&(&bd_2)->events_0)->x) = _S2096;
            *&((&(&bd_2)->events_0)->w) = _S2112.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S2119;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S2119 = (_S2112.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S2119 = false;
        }
        bool _S2120;
        if(_S2119)
        {
            _S2120 = (_S2112.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S2120 = false;
        }
        bool _S2121;
        if(_S2120)
        {
            float _S2122 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S2098.ids_0.x], _S2112.state_1.life_0);
            _S2121 = _S2122 <= 0.99000000953674316f;
        }
        else
        {
            _S2121 = false;
        }
        if(_S2121)
        {
            *&((&(&bd_2)->events_0)->y) = _S2096;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S2112.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S2096;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S2112.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S2112.force_lin_1, _S2112.force_ang_1, (F32_max((_S2112.measures_0.tension_0), (_S2112.measures_0.compression_0))));
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
        uint _S2123 = isl_22.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S2124 = _S2123 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S2093])->info_1)->z) = _S2124 | i_29;
    }
    uint _S2125 = ((isl_22.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_29 = 128U;
    }
    else
    {
        i_29 = 0U;
    }
    (&(globalParams_0->islands_0)[_S2093])->coverage_0 = _S2125 | i_29;
    return;
}

