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
    uint device_connect_0;
    uint cplan_base_0;
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

static __device__ float4  abs_0(float4  x_2)
{
    float4  result_1;
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
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_abs((_slang_vector_get_element(x_2, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float3  abs_1(float3  x_3)
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
        *_slang_vector_get_element_ptr(&result_2, i_2) = (F32_abs((_slang_vector_get_element(x_3, i_2))));
        i_2 = i_2 + int(1);
    }
    return result_2;
}

static __device__ float dot_0(float3  x_4, float3  y_1)
{
    return x_4.x * y_1.x + x_4.y * y_1.y + x_4.z * y_1.z;
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
    float4  x_5 = make_float4 ((*a_1).x, (*a_1).y, (*a_1).z, 0.0f);
    float4  y_2 = make_float4 ((*b_1).x, (*b_1).y, (*b_1).z, 0.0f);
    group_sum2_0(tid_1, &x_5, &y_2, _S9);
    float4  _S10 = x_5;
    *a_1 = float3 {_S10.x, _S10.y, _S10.z};
    float4  _S11 = y_2;
    *b_1 = float3 {_S11.x, _S11.y, _S11.z};
    return;
}

static __device__ uint4  asuint_0(float4  x_6)
{
    uint4  result_3;
    int i_3 = int(0);
    for(;;)
    {
        if(i_3 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_3) = (F32_asuint((_slang_vector_get_element(x_6, i_3))));
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

static __device__ void impactor_candidate_forces_0(uint k_5, uint lane_1, uint lanes_5, uint _S363)
{
    uint _S364;
    uint _S365;
    bool _S366;
    uint _S367;
    uint _S368 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S369 = 3U * k_5;
    uint at_1 = _S368 + _S369;
    uint _S370 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S371 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S372 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S372]);
    float _S373 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S374 = make_float3 (0.0f);
    uint _S375 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S375 + _S369]);
    bool _S376 = (imp_3.cand_0.z) == 0U;
    uint _S377 = __ballot_sync(_S363, _S376);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if(_S376)
    {
        WorldPoint_0 _S378 = impactor_point_0(_S372);
        WorldPoint_0 _S379 = chunk_world_0(_S370);
        WorldPoint_0 _S380 = _S378;
        float3  _S381 = world_diff_0(&_S379, &_S380);
        float _S382 = length_0(_S381);
        float _S383 = imp_3.half_1.w;
        float4  _S384 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->half_0);
        bool _S385 = !(_S382 > (_S383 + _S384.w));
        uint _S386 = __ballot_sync(_S377, _S385);
        if(_S385)
        {
            float4  _S387 = imp_3.half_1;
            Box_0 _S388 = impactor_box_1(_S372, _S374, float3 {_S387.x, _S387.y, _S387.z});
            Box_0 b_19 = chunk_box_0(_S370, _S381);
            float _S389 = imp_3.mat_0.x;
            float4  _S390 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->cmat_0);
            float _S391 = _S390.x;
            float3  _S392 = b_19.center_1 - _S388.center_1;
            Box_0 _S393 = _S388;
            Box_0 _S394 = b_19;
            float _S395 = contact_stiffness_0(_S389, &_S393, _S391, &_S394, _S392);
            float _S396 = imp_3.geom_0.y;
            Box_0 _S397 = _S388;
            Box_0 _S398 = impactor_shrunk_0(_S372, _S396, &_S397);
            uint j_1 = lane_1;
            uint n_6 = 0U;
            uint j_2 = _S386;
            for(;;)
            {
                uint _S399 = 0U;
                Impactor_0 _S400 = imp_3;
                Box_0 _S401 = b_19;
                uint _S402 = impactor_slots_0(&_S400, &_S401);
                _S364 = _S402;
                bool _S403 = j_1 < _S402;
                uint _S404 = __ballot_sync(j_2, _S403);
                if(_S403)
                {
                    uint _S405 = __ballot_sync(j_2, true);
                    _S399 = _S405;
                }
                else
                {
                    uint _S406 = __ballot_sync(j_2, false);
                    uint _S407 = __ballot_sync(j_2, false);
                    uint _S408 = __ballot_sync(_S386, true);
                    _S365 = _S408;
                    break;
                }
                Box_0 _S409 = _S398;
                Box_0 _S410 = b_19;
                float3  p_5;
                float3  nrm_0;
                float dep_0;
                bool _S411 = impactor_contact_1(_S372, _S396, &_S409, &_S410, j_1, &p_5, &nrm_0, &dep_0);
                uint _S412 = __ballot_sync(_S399, _S411);
                if(_S411)
                {
                    uint _S413 = n_6 + 1U;
                    uint _S414 = __ballot_sync(_S399, true);
                    n_6 = _S413;
                }
                else
                {
                    uint _S415 = __ballot_sync(_S399, true);
                }
                uint _S416 = __ballot_sync(j_2, true);
                j_1 = j_1 + lanes_5;
                j_2 = _S416;
            }
            uint _S417 = pair_count_sum_0(n_6, lanes_5, _S365);
            bool _S418 = (imp_3.shape_0.x) == 0.0f;
            uint _S419 = __ballot_sync(_S365, _S418);
            float _S420;
            if(_S418)
            {
                uint _S421 = __ballot_sync(_S365, true);
                _S420 = _S395;
                j_1 = _S421;
            }
            else
            {
                float _S422 = _S395 / (F32_max((float(_S417)), (10.0f)));
                uint _S423 = __ballot_sync(_S365, true);
                _S420 = _S422;
                j_1 = _S423;
            }
            uint _S424 = __ballot_sync(j_1, _S418);
            if(_S418)
            {
                uint _S425 = __ballot_sync(j_1, true);
                j_1 = 1U;
                n_6 = _S425;
            }
            else
            {
                uint _S426 = __ballot_sync(j_1, true);
                j_1 = _S417;
                n_6 = _S426;
            }
            float4  _S427 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->center_0);
            float m_1 = _S427.w;
            float _S428 = imp_3.mat_0.z;
            float _S429 = m_1 * _S428 / (m_1 + _S428);
            float _S430 = __ldg(&globalParams_0->params_0->pair_friction_0);
            bool _S431 = _S430 >= 0.0f;
            uint _S432 = __ballot_sync(n_6, _S431);
            float _S433;
            if(_S431)
            {
                float _S434 = __ldg(&globalParams_0->params_0->pair_friction_0);
                uint _S435 = __ballot_sync(n_6, true);
                _S433 = _S434;
                n_6 = _S435;
            }
            else
            {
                float _S436 = imp_3.mat_0.y;
                float4  _S437 = __ldg(&(&(globalParams_0->chunks_0)[_S370])->cmat_0);
                float _S438 = (F32_min((_S436), (_S437.y)));
                uint _S439 = __ballot_sync(n_6, true);
                _S433 = _S438;
                n_6 = _S439;
            }
            float4  _S440 = imp_3.velocity_1;
            float4  _S441 = imp_3.velocity_err_1;
            float3  _S442 = float3 {_S440.x, _S440.y, _S440.z} + float3 {_S441.x, _S441.y, _S441.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S370, &vc_0, &wc_0);
            hit_0 = false;
            j_2 = lane_1;
            f_sum_0 = _S374;
            t_sum_0 = _S374;
            imp_f_0 = _S374;
            imp_t_0 = _S374;
            float diss_sum_2 = 0.0f;
            uint _S443 = n_6;
            for(;;)
            {
                bool _S444 = _S417 > 0U;
                _S366 = _S444;
                uint _S445 = __ballot_sync(_S443, _S444);
                uint _S446;
                bool _S447;
                if(_S444)
                {
                    bool _S448 = j_2 < _S364;
                    uint _S449 = __ballot_sync(_S443, true);
                    _S447 = _S448;
                    _S446 = _S449;
                }
                else
                {
                    uint _S450 = __ballot_sync(_S443, true);
                    _S447 = false;
                    _S446 = _S450;
                }
                uint _S451 = 0U;
                uint _S452 = __ballot_sync(_S446, _S447);
                if(_S447)
                {
                    uint _S453 = __ballot_sync(_S446, true);
                    _S451 = _S453;
                }
                else
                {
                    uint _S454 = __ballot_sync(_S446, false);
                    uint _S455 = __ballot_sync(_S443, false);
                    uint _S456 = __ballot_sync(n_6, true);
                    _S367 = _S456;
                    break;
                }
                Impactor_0 _S457 = imp_3;
                Box_0 _S458 = _S398;
                Box_0 _S459 = b_19;
                float3  p_6;
                float3  nrm_1;
                float dep_1;
                bool _S460 = impactor_contact_0(&_S457, _S396, &_S458, &_S459, j_2, &p_6, &nrm_1, &dep_1);
                bool _S461 = !_S460;
                uint _S462 = __ballot_sync(_S451, _S461);
                if(_S461)
                {
                    uint _S463 = __ballot_sync(_S451, false);
                    uint _S464 = __ballot_sync(_S443, true);
                    _S443 = _S464;
                    j_2 = j_2 + lanes_5;
                    continue;
                }
                else
                {
                    uint _S465 = __ballot_sync(_S451, true);
                }
                float4  _S466 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S420, _S429, _S433, dep_1 * imp_3.geom_0.x, nrm_1, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S442 + cross_0(float3 {_S466.x, _S466.y, _S466.z}, p_6)), _S373, j_1, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_19.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                float diss_sum_3 = diss_sum_2 + diss_1;
                uint _S467 = __ballot_sync(_S443, true);
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                _S443 = _S467;
                j_2 = j_2 + lanes_5;
            }
            float3  _S468 = pair_sum3_0(f_sum_0, lanes_5, _S367);
            float3  _S469 = pair_sum3_0(t_sum_0, lanes_5, _S367);
            float3  _S470 = pair_sum3_0(imp_f_0, lanes_5, _S367);
            float3  _S471 = pair_sum3_0(imp_t_0, lanes_5, _S367);
            float _S472 = pair_sum_0(diss_sum_2, lanes_5, _S367);
            bool _S473 = pair_any_0(hit_0, lanes_5, _S367);
            uint _S474 = __ballot_sync(_S367, _S366);
            if(_S366)
            {
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), _S472);
            }
            hit_0 = _S473;
            f_sum_0 = _S468;
            t_sum_0 = _S469;
            imp_f_0 = _S470;
            imp_t_0 = _S471;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S374;
            t_sum_0 = _S374;
            imp_f_0 = _S374;
            imp_t_0 = _S374;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S374;
        t_sum_0 = _S374;
        imp_f_0 = _S374;
        imp_t_0 = _S374;
    }
    if(lane_1 != 0U)
    {
        return;
    }
    uint _S475 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S476 = 2U * _S371;
    *(&(globalParams_0->scratch_0)[_S475 + _S476]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S477 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S477 + _S476 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S478 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S478 + _S369]) = data_0;
    uint _S479 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S479 + _S369 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S480 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S480 + _S369 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
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
    ChunkStatic_0 * _S481 = (&(globalParams_0->chunks_0)[c_4]);
    uint4  _S482 = __ldg(&_S481->cinfo_0);
    if((_S482.z) == 0U)
    {
        return;
    }
    uint _S483 = __ldg(&globalParams_0->params_0->cplan_base_0);
    uint _S484 = 4U * c_4;
    uint at_2 = _S483 + _S484;
    float4  * _S485 = (&(globalParams_0->scratch_0)[at_2]);
    float4  start_hi_0 = *_S485;
    float4  * _S486 = (&(globalParams_0->scratch_0)[at_2 + 1U]);
    float4  start_lo_0 = *_S486;
    float4  start_rot_0 = *(&(globalParams_0->scratch_0)[at_2 + 2U]);
    float4  start_vel_0 = *(&(globalParams_0->scratch_0)[at_2 + 3U]);
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S487 = *_S485;
    float4  _S488 = *_S486;
    float3  moved_0 = wp_0.hi_0 - float3 {_S487.x, _S487.y, _S487.z} + (wp_0.lo_0 - float3 {_S488.x, _S488.y, _S488.z}) + wp_0.rel_0;
    float _S489 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S490 = _S489 - start_vel_0.w;
    float _S491 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S492 = _S490 + (_S491 - start_lo_0.w);
    uint4  _S493 = __ldg(&_S481->info_0);
    uint _S494 = _S493.y;
    uint _S495 = (&(globalParams_0->islands_0)[_S494])->info_1.w;
    uint _S496 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S497 = float(_S495 - _S496);
    float _S498 = __ldg(&globalParams_0->params_0->dt_0);
    float since_0 = _S492 + _S497 * _S498;
    float3  _S499 = float3 {start_vel_0.x, start_vel_0.y, start_vel_0.z} * make_float3 (since_0);
    uint _S500 = _S482.w;
    float3  _S501;
    if((_S500 & 2U) != 0U)
    {
        float4  _S502 = __ldg(&globalParams_0->params_0->gravity_0);
        _S501 = make_float3 (0.5f) * float3 {_S502.x, _S502.y, _S502.z} * make_float3 (since_0) * make_float3 (since_0);
    }
    else
    {
        _S501 = make_float3 (0.0f);
    }
    float travel_0 = length_0(moved_0 - (_S499 + _S501));
    float travel_1;
    if((_S500 & 1U) != 0U)
    {
        float4  _S503 = *(&(globalParams_0->state_0)[_S484 + 1U]);
        float3  th_1 = float3 {_S503.x, _S503.y, _S503.z};
        Quat_0 _S504 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S505 = quat_of_0((&(globalParams_0->islands_0)[_S494])->rotation_0);
        Quat_0 _S506 = _S504;
        Quat_0 _S507 = quat_mul_0(&_S505, &_S506);
        Quat_0 _S508 = quat_of_0(make_float4 ((- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).x, (- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).y, (- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).z, start_rot_0.w));
        Quat_0 _S509 = _S507;
        Quat_0 _S510 = quat_mul_0(&_S508, &_S509);
        float _S511 = 2.0f * (F32_atan2((length_0(make_float3 (_S510.x_12, _S510.y_4, _S510.z_0))), ((F32_abs((_S510.w_1))))));
        float4  _S512 = __ldg(&_S481->half_0);
        travel_1 = travel_0 + _S511 * _S512.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (start_hi_0.w))
    {
        uint _S513 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S514 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S513])->info_1)->z) = ((&(globalParams_0->islands_0)[_S514])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint _S515 = 0U;
    uint3  _S516 = blockIdx * blockDim + threadIdx;
    uint _S517 = __ballot_sync(4294967295U, true);
    uint i_9 = _S516.x;
    uint lanes_6 = pair_lane_count_0();
    uint _S518 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S518 * lanes_6;
    bool _S519 = i_9 < pair_threads_0;
    uint _S520 = __ballot_sync(_S517, _S519);
    if(_S519)
    {
        bool _S521 = pair_any_0(stopped_0(), lanes_6, _S520);
        bool _S522 = !_S521;
        uint _S523 = __ballot_sync(_S520, _S522);
        if(_S522)
        {
            uint _S524 = i_9 / lanes_6;
            uint _S525 = i_9 % lanes_6;
            pair_contact_0(_S524, _S525, lanes_6, _S523);
            uint _S526 = __ballot_sync(_S520, true);
        }
        return;
    }
    else
    {
        uint _S527 = __ballot_sync(_S517, true);
        _S515 = _S527;
    }
    uint j_3 = i_9 - pair_threads_0;
    uint _S528 = __ldg(&globalParams_0->params_0->cand_count_0);
    uint cand_threads_0 = _S528 * lanes_6;
    bool _S529 = j_3 < cand_threads_0;
    uint _S530 = __ballot_sync(_S515, _S529);
    if(_S529)
    {
        bool _S531 = pair_any_0(stopped_0(), lanes_6, _S530);
        bool _S532 = !_S531;
        uint _S533 = __ballot_sync(_S530, _S532);
        if(_S532)
        {
            uint _S534 = j_3 / lanes_6;
            uint _S535 = j_3 % lanes_6;
            impactor_candidate_forces_0(_S534, _S535, lanes_6, _S533);
            uint _S536 = __ballot_sync(_S530, true);
        }
        return;
    }
    uint _S537 = j_3 - cand_threads_0;
    uint _S538 = __ldg(&globalParams_0->params_0->chunk_count_0);
    bool _S539;
    if(_S537 < _S538)
    {
        _S539 = !stopped_0();
    }
    else
    {
        _S539 = false;
    }
    if(_S539)
    {
        travel_check_0(_S537);
    }
    return;
}

static __device__ uint impactor_contact_count_0(uint _S540, float _S541, Box_0 * _S542, Box_0 * _S543)
{
    Impactor_0 _S544 = *(&(globalParams_0->impactors_0)[_S540]);
    uint j_4 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S545 = _S544;
        uint _S546 = impactor_slots_0(&_S545, _S543);
        if(j_4 < _S546)
        {
        }
        else
        {
            break;
        }
        float3  p_7;
        float3  n_7;
        float d_9;
        bool _S547 = impactor_contact_1(_S540, _S541, _S542, _S543, j_4, &p_7, &n_7, &d_9);
        if(_S547)
        {
            count_1 = count_1 + 1U;
        }
        j_4 = j_4 + 1U;
    }
    return count_1;
}

extern "C" __global__ void impactor_shares()
{
    uint k_6 = (blockIdx * blockDim + threadIdx).x;
    uint _S548 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S549;
    if(k_6 >= _S548)
    {
        _S549 = true;
    }
    else
    {
        _S549 = stopped_0();
    }
    if(_S549)
    {
        return;
    }
    uint _S550 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S551 = 3U * k_6;
    uint at_3 = _S550 + _S551;
    uint _S552 = __ldg((&(globalParams_0->index_0)[at_3]));
    uint _S553 = __ldg((&(globalParams_0->index_0)[at_3 + 2U]));
    Impactor_0 * _S554 = (&(globalParams_0->impactors_0)[_S553]);
    Impactor_0 imp_4 = *_S554;
    if(((*_S554).cand_0.z) == 0U)
    {
        _S549 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S549 = false;
    }
    float total_0;
    float ksum_0;
    if(_S549)
    {
        WorldPoint_0 _S555 = impactor_point_0(_S553);
        WorldPoint_0 _S556 = chunk_world_0(_S552);
        WorldPoint_0 _S557 = _S555;
        float3  _S558 = world_diff_0(&_S556, &_S557);
        float _S559 = length_0(_S558);
        float _S560 = imp_4.half_1.w;
        float4  _S561 = __ldg(&(&(globalParams_0->chunks_0)[_S552])->half_0);
        if(!(_S559 > (_S560 + _S561.w)))
        {
            float4  _S562 = imp_4.half_1;
            Box_0 _S563 = impactor_box_1(_S553, make_float3 (0.0f), float3 {_S562.x, _S562.y, _S562.z});
            Box_0 b_20 = chunk_box_0(_S552, _S558);
            float _S564 = imp_4.mat_0.x;
            float4  _S565 = __ldg(&(&(globalParams_0->chunks_0)[_S552])->cmat_0);
            float _S566 = _S565.x;
            float3  _S567 = b_20.center_1 - _S563.center_1;
            Box_0 _S568 = _S563;
            Box_0 _S569 = b_20;
            float _S570 = contact_stiffness_0(_S564, &_S568, _S566, &_S569, _S567);
            float _S571 = imp_4.crush_1.w;
            Box_0 _S572 = _S563;
            Box_0 _S573 = impactor_shrunk_0(_S553, _S571, &_S572);
            Box_0 _S574 = _S573;
            Box_0 _S575 = b_20;
            uint _S576 = impactor_contact_count_0(_S553, _S571, &_S574, &_S575);
            float _S577;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S577 = _S570;
            }
            else
            {
                _S577 = _S570 / (F32_max((float(_S576)), (10.0f)));
            }
            uint j_5 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S576 > 0U)
                {
                    Impactor_0 _S578 = imp_4;
                    Box_0 _S579 = b_20;
                    uint _S580 = impactor_slots_0(&_S578, &_S579);
                    _S549 = j_5 < _S580;
                }
                else
                {
                    _S549 = false;
                }
                if(_S549)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S581 = imp_4;
                Box_0 _S582 = _S573;
                Box_0 _S583 = b_20;
                float3  p_8;
                float3  nrm_2;
                float dep_2;
                bool _S584 = impactor_contact_0(&_S581, _S571, &_S582, &_S583, j_5, &p_8, &nrm_2, &dep_2);
                if(!_S584)
                {
                    j_5 = j_5 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S577;
                total_0 = total_0 + _S577 * dep_2;
                ksum_0 = ksum_1;
                j_5 = j_5 + 1U;
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
    uint _S585 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S585 + _S551]);
    uint _S586 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S586 + _S551]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S587;
    uint _S588 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S589 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S590 = ii_0 >= _S589;
    uint _S591 = __ballot_sync(_S588, _S590);
    bool _S592;
    uint k_7;
    if(_S590)
    {
        uint _S593 = __ballot_sync(_S588, true);
        _S592 = true;
        k_7 = _S593;
    }
    else
    {
        bool _S594 = stopped_0();
        uint _S595 = __ballot_sync(_S588, true);
        _S592 = _S594;
        k_7 = _S595;
    }
    uint _S596 = 0U;
    uint _S597 = __ballot_sync(k_7, _S592);
    if(_S592)
    {
        return;
    }
    else
    {
        uint _S598 = __ballot_sync(k_7, true);
        _S596 = _S598;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S599 = make_float4 (0.0f);
    float4  shares_0 = _S599;
    float4  unused_0 = _S599;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S600;
    _S600 = _S596;
    for(;;)
    {
        bool _S601 = k_7 < ((&imp_5)->cand_0.y);
        uint _S602 = __ballot_sync(_S600, _S601);
        if(_S601)
        {
            uint _S603 = __ballot_sync(_S600, true);
        }
        else
        {
            uint _S604 = __ballot_sync(_S600, false);
            uint _S605 = __ballot_sync(_S600, false);
            uint _S606 = __ballot_sync(_S596, true);
            _S587 = _S606;
            break;
        }
        uint _S607 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S607 + 3U * k_7]);
        uint _S608 = __ballot_sync(_S600, true);
        k_7 = k_7 + 256U;
        _S600 = _S608;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S587);
    bool _S609 = tid_2 != 0U;
    uint _S610 = __ballot_sync(_S587, _S609);
    if(_S609)
    {
        _S592 = true;
    }
    else
    {
        _S592 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S592)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S592 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S592 = false;
    }
    if(_S592)
    {
        _S592 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S592 = false;
    }
    if(_S592)
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

struct WideGroup_0
{
    uint island_2;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_0)
{
    WideGroup_0 w_4;
    uint _S611 = table_0 + 4U * g_0;
    uint _S612 = __ldg((&(globalParams_0->index_0)[_S611]));
    (&w_4)->island_2 = _S612;
    uint _S613 = __ldg((&(globalParams_0->index_0)[_S611 + 1U]));
    (&w_4)->begin_0 = _S613;
    uint _S614 = __ldg((&(globalParams_0->index_0)[_S611 + 2U]));
    (&w_4)->end_0 = _S614;
    uint _S615 = __ldg((&(globalParams_0->index_0)[_S611 + 3U]));
    (&w_4)->first_0 = _S615;
    return w_4;
}

__device__ __shared__ FixedArray<uint, 5>  g_seen_0;

static __device__ void seen_clear_0(uint tid_3)
{
    if(tid_3 < 5U)
    {
        (*&g_seen_0)[tid_3] = 0U;
    }
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S616 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S617 = (&(globalParams_0->islands_0)[_S616])->info_1;
    bool _S618;
    if((((&(globalParams_0->islands_0)[_S616])->info_1.z) & 1U) != 0U)
    {
        _S618 = true;
    }
    else
    {
        uint _S619 = _S617.y;
        if(_S619 != 0U)
        {
            _S618 = _S619 <= (isl_0->info_1.w);
        }
        else
        {
            _S618 = false;
        }
    }
    return _S618;
}

static __device__ bool wide_runs_0(Island_0 * isl_1)
{
    uint4  _S620 = isl_1->info_1;
    bool _S621;
    if(((isl_1->info_1.z) & 1U) != 0U)
    {
        _S621 = true;
    }
    else
    {
        _S621 = (_S620.y) == 0U;
    }
    if(_S621)
    {
        return false;
    }
    if(((_S620.x) & 4U) == 0U)
    {
        _S621 = true;
    }
    else
    {
        bool _S622 = contact_stopped_0(isl_1);
        _S621 = !_S622;
    }
    return _S621;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_4, Island_0 * isl_2)
{
    seen_clear_0(tid_4);
    if(tid_4 == 0U)
    {
        bool _S623 = wide_runs_0(isl_2);
        int _S624;
        if(_S623)
        {
            _S624 = int(1);
        }
        else
        {
            _S624 = int(0);
        }
        *&g_wide_run_0 = uint(_S624);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_3)
{
    uint _S625 = isl_3->info_1.w;
    uint _S626 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S625 - _S626;
}

static __device__ float time_since_0(float4  origin_0, uint k_8, float dt_2)
{
    float _S627 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S628 = _S627 - origin_0.x;
    float _S629 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S628 + (_S629 - origin_0.y) + float(k_8) * dt_2;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S630 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S630.x))
    {
        return _S630.y;
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
        uint _S631 = offset_0 + i_10;
        float4  _S632 = __ldg((&(globalParams_0->loads_0)[_S631]));
        float _S633 = _S632.x;
        if(tau_0 <= _S633)
        {
            float4  _S634 = __ldg((&(globalParams_0->loads_0)[_S631 - 1U]));
            float _S635 = _S634.x;
            float _S636 = _S634.y;
            return _S636 + (tau_0 - _S635) / (F32_max((_S633 - _S635), (1.00000000317107685e-30f))) * (_S632.y - _S636);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S637 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S637.y;
}

static __device__ float eval_function_0(uint term_0, uint k_9, float dt_3, float shift_0)
{
    uint _S638 = 5U * term_0;
    float4  _S639 = __ldg((&(globalParams_0->loads_0)[_S638]));
    uint4  info_2 = asuint_0(_S639);
    float4  _S640 = __ldg((&(globalParams_0->loads_0)[_S638 + 3U]));
    float4  _S641 = __ldg((&(globalParams_0->loads_0)[_S638 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S640.z;
    }
    float tau_1 = time_since_0(_S640, k_9, dt_3) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S642 = _S641.x;
            if(tau_1 >= _S642)
            {
                shape_1 = _S641.y;
            }
            else
            {
                shape_1 = _S641.y * tau_1 / _S642;
            }
        }
        return shape_1;
    }
    bool _S643;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S643 = true;
        }
        else
        {
            _S643 = tau_1 > (_S641.x);
        }
        if(_S643)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S641.y * (F32_sin((3.14159274101257324f * tau_1 / _S641.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S641.y;
        if(sn_0 < 0.0f)
        {
            _S643 = true;
        }
        else
        {
            _S643 = sn_0 > 1.0f;
        }
        if(_S643)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S641.x * (1.0f - sn_0) * (F32_exp((- _S641.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S641.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S641.x;
        if(sn_1 < 0.0f)
        {
            _S643 = true;
        }
        else
        {
            _S643 = sn_1 > 1.0f;
        }
        if(_S643)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S641.y * sn_1)));
        }
        float clearing_0 = _S640.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S644 = _S641.w;
        return (_S644 + (_S641.z - _S644) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S645 = _S641.y;
        if(tau_1 < _S645)
        {
            return _S641.x;
        }
        float s_1 = tau_1 - _S645;
        float _S646 = _S641.w;
        if(s_1 > _S646)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S641.z * (F32_sin((3.14159274101257324f * s_1 / _S646)));
        }
        return shape_1;
    }
    float _S647 = _S641.x;
    if(_S647 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S647, 0.0f, 1.0f);
}

static __device__ void record_chunk_load_0(uint c_5, float3  f_3, float3  t_2)
{
    uint _S648 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S648 == 0U)
    {
        return;
    }
    uint _S649 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S650 = 2U * c_5;
    *(&(globalParams_0->scratch_0)[_S649 + _S650]) = make_float4 (f_3.x, f_3.y, f_3.z, 0.0f);
    uint _S651 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S651 + _S650 + 1U]) = make_float4 (t_2.x, t_2.y, t_2.z, 0.0f);
    uint _S652 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S653 = (&(globalParams_0->scratch_0)[_S652 + _S650]);
    uint _S654 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S655 = *(&(globalParams_0->scratch_0)[_S654 + _S650]);
    *_S653 = make_float4 ((float3 {_S655.x, _S655.y, _S655.z} + f_3).x, (float3 {_S655.x, _S655.y, _S655.z} + f_3).y, (float3 {_S655.x, _S655.y, _S655.z} + f_3).z, 0.0f);
    uint _S656 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S657 = (&(globalParams_0->scratch_0)[_S656 + _S650 + 1U]);
    uint _S658 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S659 = *(&(globalParams_0->scratch_0)[_S658 + _S650 + 1U]);
    *_S657 = make_float4 ((float3 {_S659.x, _S659.y, _S659.z} + t_2).x, (float3 {_S659.x, _S659.y, _S659.z} + t_2).y, (float3 {_S659.x, _S659.y, _S659.z} + t_2).z, 0.0f);
    return;
}

static __device__ void chunk_loads_0(uint _S660, uint _S661, Quat_0 * _S662, uint _S663, float _S664, bool _S665, float _S666, float3  * _S667, float3  * _S668, float3  * _S669, float3  * _S670)
{
    bool _S671;
    ChunkStatic_0 * _S672 = (&(globalParams_0->chunks_0)[_S661]);
    float3  _S673 = make_float3 (0.0f);
    *_S667 = _S673;
    *_S668 = _S673;
    *_S669 = _S673;
    *_S670 = _S673;
    uint4  _S674 = __ldg(&_S672->load_range_0);
    uint term_1 = _S674.x;
    for(;;)
    {
        if(term_1 < (_S674.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S675 = 5U * term_1;
        float4  _S676 = __ldg((&(globalParams_0->loads_0)[_S675]));
        uint _S677 = asuint_0(_S676).y;
        bool replacement_0 = _S677 == 2U;
        float4  _S678 = __ldg((&(globalParams_0->loads_0)[_S675 + 1U]));
        float4  _S679 = __ldg((&(globalParams_0->loads_0)[_S675 + 2U]));
        float _S680;
        if(replacement_0)
        {
            _S680 = _S666;
        }
        else
        {
            _S680 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S663, _S664, _S680);
        if(replacement_0)
        {
            *_S669 = *_S669 + float3 {_S678.x, _S678.y, _S678.z} * make_float3 (value_0);
            *_S670 = *_S670 + float3 {_S679.x, _S679.y, _S679.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S677 == 0U)
        {
            _S671 = true;
        }
        else
        {
            _S671 = _S677 == 3U;
        }
        float3  fw_0;
        if(_S671)
        {
            fw_0 = float3 {_S678.x, _S678.y, _S678.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S681 = rotate_0(_S662, float3 {_S678.x, _S678.y, _S678.z});
            fw_0 = _S681 * make_float3 (- value_0 * _S678.w);
        }
        float3  lever_0;
        if(_S677 == 3U)
        {
            float4  _S682 = *(&(globalParams_0->state_0)[4U * _S660]);
            lever_0 = float3 {_S679.x, _S679.y, _S679.z} - float3 {_S682.x, _S682.y, _S682.z};
        }
        else
        {
            lever_0 = float3 {_S679.x, _S679.y, _S679.z};
        }
        *_S667 = *_S667 + fw_0;
        float3  _S683 = rotate_0(_S662, lever_0);
        *_S668 = *_S668 + cross_0(_S683, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S665)
    {
        uint4  _S684 = __ldg(&_S672->cinfo_0);
        _S671 = (_S684.z) != 0U;
    }
    else
    {
        _S671 = false;
    }
    if(_S671)
    {
        uint4  _S685 = __ldg(&_S672->cinfo_0);
        uint g_1 = _S685.x;
        for(;;)
        {
            if(g_1 < (_S685.y))
            {
            }
            else
            {
                break;
            }
            uint _S686 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S687 = 2U * g_1;
            float4  _S688 = *(&(globalParams_0->scratch_0)[_S686 + _S687]);
            *_S667 = *_S667 + float3 {_S688.x, _S688.y, _S688.z};
            uint _S689 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S690 = *(&(globalParams_0->scratch_0)[_S689 + _S687 + 1U]);
            *_S668 = *_S668 + float3 {_S690.x, _S690.y, _S690.z};
            g_1 = g_1 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S691, uint _S692, Quat_0 * _S693, uint _S694, float _S695, bool _S696, float3  * _S697, float3  * _S698)
{
    float3  rf_0;
    float3  rm_0;
    chunk_loads_0(_S691, _S692, _S693, _S694, _S695, _S696, 0.0f, _S697, _S698, &rf_0, &rm_0);
    return;
}

static __device__ float settled_chunk_load_0(uint c_6, Quat_0 * rot_0, uint k_10, float dt_4, bool contact_0)
{
    float3  f_4;
    float3  t_3;
    chunk_external_0(c_6, c_6, rot_0, k_10, dt_4, contact_0, &f_4, &t_3);
    record_chunk_load_0(c_6, f_4, t_3);
    return length_0(f_4);
}

static __device__ uint seen_bits_0()
{
    uint _S699;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S699 = 32768U;
    }
    else
    {
        _S699 = 0U;
    }
    uint _S700;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S700 = 65536U;
    }
    else
    {
        _S700 = 0U;
    }
    uint _S701 = _S699 | _S700;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S699 = 131072U;
    }
    else
    {
        _S699 = 0U;
    }
    uint _S702 = _S701 | _S699;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S699 = 32U;
    }
    else
    {
        _S699 = 0U;
    }
    uint _S703 = _S702 | _S699;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S699 = 64U;
    }
    else
    {
        _S699 = 0U;
    }
    return _S703 | _S699;
}

static __device__ bool wide_enter_1(uint _S704, uint _S705)
{
    Island_0 _S706 = *(&(globalParams_0->islands_0)[_S705]);
    seen_clear_0(_S704);
    if(_S704 == 0U)
    {
        Island_0 _S707 = _S706;
        bool _S708 = wide_runs_0(&_S707);
        int _S709;
        if(_S708)
        {
            _S709 = int(1);
        }
        else
        {
            _S709 = int(0);
        }
        *&g_wide_run_0 = uint(_S709);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S710 = 0U;
    uint _S711;
    uint _S712 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S713 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S714 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S713, _S714);
    bool _S715 = _S714 != (wg_0.first_0);
    uint _S716 = __ballot_sync(_S712, _S715);
    if(_S715)
    {
        return;
    }
    else
    {
        uint _S717 = __ballot_sync(_S712, true);
        _S710 = _S717;
    }
    Island_0 * _S718 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_4 = *_S718;
    uint _S719 = (*_S718).info_1.x;
    bool _S720 = (_S719 & 16U) == 0U;
    uint _S721 = __ballot_sync(_S710, _S720);
    bool _S722;
    uint c_7;
    if(_S720)
    {
        uint _S723 = __ballot_sync(_S710, true);
        _S722 = true;
        c_7 = _S723;
    }
    else
    {
        bool _S724 = wide_enter_1(tid_5, wg_0.island_2);
        bool _S725 = !_S724;
        uint _S726 = __ballot_sync(_S710, true);
        _S722 = _S725;
        c_7 = _S726;
    }
    uint _S727 = 0U;
    uint _S728 = __ballot_sync(c_7, _S722);
    if(_S722)
    {
        return;
    }
    else
    {
        uint _S729 = __ballot_sync(c_7, true);
        _S727 = _S729;
    }
    Quat_0 _S730 = quat_of_0(isl_4.rotation_0);
    bool _S731 = (_S719 & 4U) != 0U;
    float3  _S732 = make_float3 (0.0f);
    float3  norm_0 = _S732;
    float3  unused_1 = _S732;
    c_7 = isl_4.range_0.x + tid_5;
    uint cov_0;
    cov_0 = _S727;
    for(;;)
    {
        bool _S733 = c_7 < (isl_4.range_0.y);
        uint _S734 = __ballot_sync(cov_0, _S733);
        if(_S733)
        {
            uint _S735 = __ballot_sync(cov_0, true);
        }
        else
        {
            uint _S736 = __ballot_sync(cov_0, false);
            uint _S737 = __ballot_sync(cov_0, false);
            uint _S738 = __ballot_sync(_S727, true);
            _S711 = _S738;
            break;
        }
        Island_0 _S739 = isl_4;
        uint _S740 = wide_step_0(&_S739);
        float _S741 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S742 = _S730;
        float _S743 = settled_chunk_load_0(c_7, &_S742, _S740, _S741, _S731);
        *&((&norm_0)->x) = *&((&norm_0)->x) + _S743;
        uint _S744 = __ballot_sync(cov_0, true);
        c_7 = c_7 + 256U;
        cov_0 = _S744;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, _S711);
    bool _S745 = tid_5 != 0U;
    uint _S746 = __ballot_sync(_S711, _S745);
    if(_S745)
    {
        return;
    }
    uint cov_1 = 1024U | (seen_bits_0());
    uint _S747 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S747 == 1U)
    {
        _S722 = (F32_abs((norm_0.x - isl_4.energy_1.z))) > (isl_4.energy_1.w);
    }
    else
    {
        _S722 = false;
    }
    if(_S722)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S719 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->z) = (isl_4.info_1.z) | 4U;
        cov_0 = cov_1 | 2048U;
    }
    else
    {
        cov_0 = cov_1;
    }
    cov_mark_0(wg_0.island_2, isl_4.coverage_0, cov_0);
    return;
}

static __device__ void wide_partials_0(uint tid_6, uint first_1, uint count_3, uint p_9, float3  * a_7, float3  * b_21, uint _S748)
{
    uint _S749;
    float4  _S750 = make_float4 (0.0f);
    float4  x_18 = _S750;
    float4  y_5 = _S750;
    uint s_2 = tid_6;
    uint _S751 = _S748;
    for(;;)
    {
        bool _S752 = s_2 < count_3;
        uint _S753 = __ballot_sync(_S751, _S752);
        if(_S752)
        {
            uint _S754 = __ballot_sync(_S751, true);
        }
        else
        {
            uint _S755 = __ballot_sync(_S751, false);
            uint _S756 = __ballot_sync(_S751, false);
            uint _S757 = __ballot_sync(_S748, true);
            _S749 = _S757;
            break;
        }
        uint _S758 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S759 = 8U * (first_1 + s_2);
        x_18 = x_18 + *(&(globalParams_0->scratch_0)[_S758 + _S759 + p_9]);
        uint _S760 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S760 + _S759 + p_9 + 1U]);
        uint _S761 = __ballot_sync(_S751, true);
        s_2 = s_2 + 256U;
        _S751 = _S761;
    }
    group_sum2_0(tid_6, &x_18, &y_5, _S749);
    float4  _S762 = x_18;
    *a_7 = float3 {_S762.x, _S762.y, _S762.z};
    float4  _S763 = y_5;
    *b_21 = float3 {_S763.x, _S763.y, _S763.z};
    return;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_4)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_4), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_4), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_4));
}

static __device__ void drift_angular_0(uint c_8, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S764 = (&(globalParams_0->chunks_0)[c_8]);
    float4  _S765 = __ldg(&_S764->center_0);
    float3  r_5 = float3 {_S765.x, _S765.y, _S765.z} - wcom_1;
    float4  _S766 = __ldg(&_S764->scale_0);
    float kw_0 = _S766.x;
    uint _S767 = 4U * c_8;
    float4  _S768 = *(&(globalParams_0->state_0)[_S767]);
    float _S769 = _S765.w;
    float3  _S770 = cross_0(r_5, float3 {_S768.x, _S768.y, _S768.z} - tr_0) * make_float3 (_S769);
    float4  _S771 = __ldg(&_S764->inertia0_0);
    float4  _S772 = __ldg(&_S764->inertia1_0);
    float4  _S773 = __ldg(&_S764->inertia2_0);
    float4  _S774 = *(&(globalParams_0->state_0)[_S767 + 1U]);
    *lu_0 = *lu_0 + (_S770 + rows_mul_0(_S771, _S772, _S773, float3 {_S774.x, _S774.y, _S774.z})) * make_float3 (kw_0);
    float4  _S775 = *(&(globalParams_0->state_0)[_S767 + 2U]);
    float4  _S776 = *(&(globalParams_0->state_0)[_S767 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_5, float3 {_S775.x, _S775.y, _S775.z} - dv_0) * make_float3 (_S769) + rows_mul_0(_S771, _S772, _S773, float3 {_S776.x, _S776.y, _S776.z})) * make_float3 (kw_0);
    return;
}

static __device__ void wide_store_0(uint slot_0, uint p_10, float3  a_8, float3  b_22)
{
    uint _S777 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S778 = 8U * slot_0;
    *(&(globalParams_0->scratch_0)[_S777 + _S778 + p_10]) = make_float4 (a_8.x, a_8.y, a_8.z, 0.0f);
    uint _S779 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S779 + _S778 + p_10 + 1U]) = make_float4 (b_22.x, b_22.y, b_22.z, 0.0f);
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S780 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S781 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S782 = blockIdx.x;
    WideGroup_0 wg_1 = wide_group_0(_S781, _S782);
    Island_0 * _S783 = (&(globalParams_0->islands_0)[wg_1.island_2]);
    Island_0 isl_5 = *_S783;
    bool _S784 = (((*_S783).info_1.x) & 17U) != 0U;
    uint _S785 = __ballot_sync(_S780, _S784);
    bool _S786;
    uint _S787;
    if(_S784)
    {
        uint _S788 = __ballot_sync(_S780, true);
        _S786 = true;
        _S787 = _S788;
    }
    else
    {
        bool _S789 = wide_enter_1(tid_7, wg_1.island_2);
        bool _S790 = !_S789;
        uint _S791 = __ballot_sync(_S780, true);
        _S786 = _S790;
        _S787 = _S791;
    }
    uint _S792 = 0U;
    uint _S793 = __ballot_sync(_S787, _S786);
    if(_S786)
    {
        return;
    }
    else
    {
        uint _S794 = __ballot_sync(_S787, true);
        _S792 = _S794;
    }
    float3  tu_0;
    float3  pv_0;
    wide_partials_0(tid_7, wg_1.first_0, isl_5.wide_groups_0, 2U, &tu_0, &pv_0, _S792);
    float _S795 = isl_5.wcom_0.w;
    float3  tr_1 = tu_0 / make_float3 (_S795);
    float3  dv_1 = pv_0 / make_float3 (_S795);
    float3  _S796 = make_float3 (0.0f);
    float3  lu_1 = _S796;
    float3  lv_1 = _S796;
    uint c_9 = wg_1.begin_0 + tid_7;
    bool _S797 = c_9 < (wg_1.end_0);
    uint _S798 = __ballot_sync(_S792, _S797);
    if(_S797)
    {
        float4  _S799 = isl_5.wcom_0;
        drift_angular_0(c_9, float3 {_S799.x, _S799.y, _S799.z}, tr_1, dv_1, &lu_1, &lv_1);
        uint _S800 = __ballot_sync(_S792, true);
        _S787 = _S800;
    }
    else
    {
        uint _S801 = __ballot_sync(_S792, true);
        _S787 = _S801;
    }
    group_sum3_0(tid_7, &lu_1, &lv_1, _S787);
    bool _S802 = tid_7 == 0U;
    uint _S803 = __ballot_sync(_S787, _S802);
    if(_S802)
    {
        wide_store_0(_S782, 4U, lu_1, lv_1);
    }
    return;
}

struct Rigid_0
{
    Quat_0 rot_1;
    float4  rot_err_0;
    float3  pos_0;
    float3  pos_err_0;
    float3  vel_0;
    float3  vel_err_0;
    float3  w_5;
    float3  l_1;
    float3  l_err_0;
    float3  torque_0;
    float3  a_9;
    float3  alpha_0;
};

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_6)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_1 = quat_of_0(isl_6->rotation_0);
    (&rg_0)->rot_err_0 = isl_6->rotation_err_0;
    float4  _S804 = isl_6->position_0;
    (&rg_0)->pos_0 = float3 {_S804.x, _S804.y, _S804.z};
    float4  _S805 = isl_6->position_err_0;
    (&rg_0)->pos_err_0 = float3 {_S805.x, _S805.y, _S805.z};
    float4  _S806 = isl_6->velocity_0;
    (&rg_0)->vel_0 = float3 {_S806.x, _S806.y, _S806.z};
    float4  _S807 = isl_6->velocity_err_0;
    (&rg_0)->vel_err_0 = float3 {_S807.x, _S807.y, _S807.z};
    float4  _S808 = isl_6->angular_velocity_0;
    (&rg_0)->w_5 = float3 {_S808.x, _S808.y, _S808.z};
    float4  _S809 = isl_6->momentum_0;
    (&rg_0)->l_1 = float3 {_S809.x, _S809.y, _S809.z};
    float4  _S810 = isl_6->momentum_err_0;
    (&rg_0)->l_err_0 = float3 {_S810.x, _S810.y, _S810.z};
    float3  _S811 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S811;
    (&rg_0)->a_9 = _S811;
    (&rg_0)->alpha_0 = _S811;
    return rg_0;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_5)
{
    Quat_0 c_10;
    (&c_10)->w_1 = q_9->w_1;
    (&c_10)->x_12 = - q_9->x_12;
    (&c_10)->y_4 = - q_9->y_4;
    (&c_10)->z_0 = - q_9->z_0;
    Quat_0 _S812 = c_10;
    float3  _S813 = rotate_0(&_S812, v_5);
    return _S813;
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S814 = inverse_rotate_0(q_10, v_6);
    float3  _S815 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S814));
    return _S815;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_7, Rigid_0 * rg_1, float3  f_5, float3  t_4)
{
    Quat_0 _S816 = rg_1->rot_1;
    float3  _S817 = world_mul_0(&_S816, isl_7->inertia0_1, isl_7->inertia1_1, isl_7->inertia2_1, rg_1->w_5);
    rg_1->a_9 = f_5 / make_float3 (isl_7->com_0.w);
    float3  _S818 = t_4 - cross_0(rg_1->w_5, _S817);
    Quat_0 _S819 = rg_1->rot_1;
    float3  _S820 = world_mul_0(&_S819, isl_7->inv0_1, isl_7->inv1_1, isl_7->inv2_1, _S818);
    rg_1->alpha_0 = _S820;
    rg_1->torque_0 = t_4;
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_8, Island_0 * isl_8, WideGroup_0 * wg_2, uint _S821)
{
    Rigid_0 _S822 = rigid_of_0(isl_8);
    Rigid_0 rg_2 = _S822;
    bool _S823 = ((isl_8->info_1.x) & 1U) == 0U;
    uint _S824 = __ballot_sync(_S821, _S823);
    if(_S823)
    {
        float3  f_6;
        float3  t_5;
        wide_partials_0(tid_8, wg_2->first_0, isl_8->wide_groups_0, 0U, &f_6, &t_5, _S824);
        rigid_acceleration_0(isl_8, &rg_2, f_6, t_5);
        uint _S825 = __ballot_sync(_S821, true);
    }
    return rg_2;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_19)
{
    float3  t_6 = *sum_1 + x_19;
    float3  _S826 = abs_1(x_19);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S826, *sum_1,x_19) - t_6 + _slang_select((abs_1(*sum_1)) >= _S826, x_19,*sum_1));
    *sum_1 = t_6;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_0, float dt_5, float3  v_7)
{
    float _S827 = length_0(omega_0);
    float angle_1 = _S827 * dt_5;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_10 = omega_0 / make_float3 (_S827);
    float s_3 = (F32_sin((0.5f * angle_1)));
    float3  av_0 = cross_0(a_10, v_7);
    return av_0 * make_float3 ((F32_sin((angle_1)))) + cross_0(a_10, av_0) * make_float3 (2.0f * s_3 * s_3);
}

static __device__ float4  turn_minus_one_0(float3  axis_3, float angle_2)
{
    float s_4 = (F32_sin((0.25f * angle_2)));
    return make_float4 ((axis_3 * make_float3 ((F32_sin((0.5f * angle_2))))).x, (axis_3 * make_float3 ((F32_sin((0.5f * angle_2))))).y, (axis_3 * make_float3 ((F32_sin((0.5f * angle_2))))).z, -2.0f * s_4 * s_4);
}

static __device__ float4  quat_vec_0(Quat_0 * q_11)
{
    return make_float4 (q_11->x_12, q_11->y_4, q_11->z_0, q_11->w_1);
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_20)
{
    float4  t_7 = *sum_2 + x_20;
    float4  _S828 = abs_0(x_20);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S828, *sum_2,x_20) - t_7 + _slang_select((abs_0(*sum_2)) >= _S828, x_20,*sum_2));
    *sum_2 = t_7;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_21)
{
    Quat_0 _S829 = *hi_1;
    float4  _S830 = quat_vec_0(&_S829);
    float4  sum_3 = _S830;
    comp_add4_0(&sum_3, lo_1, x_21);
    float4  t_8 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_8 - sum_3);
    *hi_1 = quat_of_0(t_8);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_1, float dt_6)
{
    float _S831 = length_0(omega_1);
    float angle_3 = _S831 * dt_6;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_1 / make_float3 (_S831), angle_3);
    Quat_0 dq_0;
    (&dq_0)->x_12 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S832 = dq_0;
    Quat_0 _S833 = *hi_2;
    Quat_0 _S834 = quat_mul_0(&_S832, &_S833);
    Quat_0 _S835 = _S834;
    float4  _S836 = quat_vec_0(&_S835);
    quat_accumulate_0(hi_2, lo_2, _S836);
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_9, Rigid_0 * rg_3, float dt_7)
{
    comp_add_0(&rg_3->l_1, &rg_3->l_err_0, rg_3->torque_0 * make_float3 (dt_7));
    float3  l_2 = rg_3->l_1 + rg_3->l_err_0;
    comp_add_0(&rg_3->vel_0, &rg_3->vel_err_0, rg_3->a_9 * make_float3 (dt_7));
    float3  vel_1 = rg_3->vel_0 + rg_3->vel_err_0;
    float4  _S837 = isl_9->inv0_1;
    float4  _S838 = isl_9->inv1_1;
    float4  _S839 = isl_9->inv2_1;
    Quat_0 _S840 = rg_3->rot_1;
    float3  _S841 = world_mul_0(&_S840, isl_9->inv0_1, isl_9->inv1_1, isl_9->inv2_1, l_2);
    float3  _S842 = vel_1 * make_float3 (dt_7);
    float4  _S843 = isl_9->com_0;
    float3  _S844 = float3 {_S843.x, _S843.y, _S843.z};
    Quat_0 _S845 = rg_3->rot_1;
    float3  _S846 = rotate_0(&_S845, _S844);
    comp_add_0(&rg_3->pos_0, &rg_3->pos_err_0, _S842 - turn_difference_0(_S841, dt_7, _S846));
    turn_left_0(&rg_3->rot_1, &rg_3->rot_err_0, _S841, dt_7);
    Quat_0 _S847 = rg_3->rot_1;
    float3  _S848 = world_mul_0(&_S847, _S837, _S838, _S839, l_2);
    rg_3->w_5 = _S848;
    return;
}

static __device__ void drift_apply_0(uint c_11, float3  wcom_2, float3  tr_2, float3  phi_0, float3  dv_2, float3  dw_0)
{
    float4  _S849 = __ldg(&(&(globalParams_0->chunks_0)[c_11])->center_0);
    float3  r_6 = float3 {_S849.x, _S849.y, _S849.z} - wcom_2;
    uint _S850 = 4U * c_11;
    float4  _S851 = *(&(globalParams_0->state_0)[_S850]);
    *(&(globalParams_0->state_0)[_S850]) = make_float4 ((float3 {_S851.x, _S851.y, _S851.z} - (tr_2 + cross_0(phi_0, r_6))).x, (float3 {_S851.x, _S851.y, _S851.z} - (tr_2 + cross_0(phi_0, r_6))).y, (float3 {_S851.x, _S851.y, _S851.z} - (tr_2 + cross_0(phi_0, r_6))).z, (*(&(globalParams_0->state_0)[_S850])).w);
    uint _S852 = _S850 + 1U;
    float4  _S853 = *(&(globalParams_0->state_0)[_S852]);
    *(&(globalParams_0->state_0)[_S852]) = make_float4 ((float3 {_S853.x, _S853.y, _S853.z} - phi_0).x, (float3 {_S853.x, _S853.y, _S853.z} - phi_0).y, (float3 {_S853.x, _S853.y, _S853.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S852])).w);
    uint _S854 = _S850 + 2U;
    float4  _S855 = *(&(globalParams_0->state_0)[_S854]);
    *(&(globalParams_0->state_0)[_S854]) = make_float4 ((float3 {_S855.x, _S855.y, _S855.z} - (dv_2 + cross_0(dw_0, r_6))).x, (float3 {_S855.x, _S855.y, _S855.z} - (dv_2 + cross_0(dw_0, r_6))).y, (float3 {_S855.x, _S855.y, _S855.z} - (dv_2 + cross_0(dw_0, r_6))).z, (*(&(globalParams_0->state_0)[_S854])).w);
    uint _S856 = _S850 + 3U;
    float4  _S857 = *(&(globalParams_0->state_0)[_S856]);
    *(&(globalParams_0->state_0)[_S856]) = make_float4 ((float3 {_S857.x, _S857.y, _S857.z} - dw_0).x, (float3 {_S857.x, _S857.y, _S857.z} - dw_0).y, (float3 {_S857.x, _S857.y, _S857.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S856])).w);
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
    Quat_0 _S858 = *hi_3;
    Quat_0 _S859 = dq_1;
    Quat_0 _S860 = quat_mul_0(&_S858, &_S859);
    Quat_0 _S861 = _S860;
    float4  _S862 = quat_vec_0(&_S861);
    quat_accumulate_0(hi_3, lo_3, _S862);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_10, Rigid_0 * rg_4, float3  tr_3, float3  phi_2, float3  dv_3, float3  dw_1)
{
    float4  _S863 = isl_10->wcom_0;
    float3  wcom_3 = float3 {_S863.x, _S863.y, _S863.z};
    Quat_0 rot_2 = rg_4->rot_1;
    float3  _S864 = tr_3 - cross_0(phi_2, wcom_3);
    Quat_0 _S865 = rg_4->rot_1;
    float3  _S866 = rotate_0(&_S865, _S864);
    comp_add_0(&rg_4->pos_0, &rg_4->pos_err_0, _S866);
    Quat_0 _S867 = rg_4->rot_1;
    float3  _S868 = inverse_rotate_0(&_S867, rg_4->w_5);
    float4  _S869 = isl_10->inertia0_1;
    float4  _S870 = isl_10->inertia1_1;
    float4  _S871 = isl_10->inertia2_1;
    float3  _S872 = cross_0(phi_2, rows_mul_0(isl_10->inertia0_1, isl_10->inertia1_1, isl_10->inertia2_1, _S868)) - rows_mul_0(isl_10->inertia0_1, isl_10->inertia1_1, isl_10->inertia2_1, cross_0(phi_2, _S868));
    Quat_0 _S873 = rg_4->rot_1;
    float3  _S874 = rotate_0(&_S873, _S872);
    turn_right_0(&rg_4->rot_1, &rg_4->rot_err_0, phi_2);
    float4  _S875 = isl_10->com_0;
    float3  _S876 = dv_3 + cross_0(dw_1, float3 {_S875.x, _S875.y, _S875.z} - wcom_3);
    Quat_0 _S877 = rot_2;
    float3  _S878 = rotate_0(&_S877, _S876);
    comp_add_0(&rg_4->vel_0, &rg_4->vel_err_0, _S878);
    Quat_0 _S879 = rot_2;
    float3  _S880 = rotate_0(&_S879, dw_1);
    rg_4->w_5 = rg_4->w_5 + _S880;
    Quat_0 _S881 = rg_4->rot_1;
    float3  _S882 = world_mul_0(&_S881, _S869, _S870, _S871, _S880);
    comp_add_0(&rg_4->l_1, &rg_4->l_err_0, _S874 + _S882);
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S883 = __ballot_sync(4294967295U, true);
    uint tid_9 = threadIdx.x;
    uint _S884 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S885 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S884, _S885);
    Island_0 * _S886 = (&(globalParams_0->islands_0)[wg_3.island_2]);
    Island_0 isl_11 = *_S886;
    uint _S887 = (*_S886).info_1.x;
    bool _S888 = (_S887 & 1U) != 0U;
    uint _S889 = __ballot_sync(_S883, _S888);
    bool _S890;
    uint _S891;
    if(_S888)
    {
        uint _S892 = __ballot_sync(_S883, true);
        _S890 = true;
        _S891 = _S892;
    }
    else
    {
        bool _S893 = wide_enter_1(tid_9, wg_3.island_2);
        bool _S894 = !_S893;
        uint _S895 = __ballot_sync(_S883, true);
        _S890 = _S894;
        _S891 = _S895;
    }
    uint _S896 = 0U;
    uint _S897 = __ballot_sync(_S891, _S890);
    if(_S890)
    {
        return;
    }
    else
    {
        uint _S898 = __ballot_sync(_S891, true);
        _S896 = _S898;
    }
    uint _S899 = 0U;
    bool _S900 = (_S887 & 16U) != 0U;
    uint _S901 = __ballot_sync(_S896, _S900);
    if(_S900)
    {
        uint _S902 = 0U;
        bool _S903 = _S885 != (wg_3.first_0);
        uint _S904 = __ballot_sync(_S901, _S903);
        if(_S903)
        {
            return;
        }
        else
        {
            uint _S905 = __ballot_sync(_S901, true);
            _S902 = _S905;
        }
        Island_0 _S906 = isl_11;
        WideGroup_0 _S907 = wg_3;
        Rigid_0 _S908 = wide_rigid_frame_0(tid_9, &_S906, &_S907, _S902);
        Rigid_0 rs_0 = _S908;
        bool _S909 = tid_9 != 0U;
        uint _S910 = __ballot_sync(_S902, _S909);
        if(_S909)
        {
            _S890 = true;
        }
        else
        {
            _S890 = (_S887 & 2U) != 0U;
        }
        if(_S890)
        {
            return;
        }
        float _S911 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S912 = isl_11;
        integrate_rigid_0(&_S912, &rs_0, _S911);
        Quat_0 _S913 = (&rs_0)->rot_1;
        float4  _S914 = quat_vec_0(&_S913);
        (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_0 = _S914;
        (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_err_0 = (&rs_0)->rot_err_0;
        (&(globalParams_0->islands_0)[wg_3.island_2])->position_0 = make_float4 ((&rs_0)->pos_0.x, (&rs_0)->pos_0.y, (&rs_0)->pos_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->position_err_0 = make_float4 ((&rs_0)->pos_err_0.x, (&rs_0)->pos_err_0.y, (&rs_0)->pos_err_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_0 = make_float4 ((&rs_0)->vel_0.x, (&rs_0)->vel_0.y, (&rs_0)->vel_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_0.x, (&rs_0)->vel_err_0.y, (&rs_0)->vel_err_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->angular_velocity_0 = make_float4 ((&rs_0)->w_5.x, (&rs_0)->w_5.y, (&rs_0)->w_5.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_0 = make_float4 ((&rs_0)->l_1.x, (&rs_0)->l_1.y, (&rs_0)->l_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_err_0 = make_float4 ((&rs_0)->l_err_0.x, (&rs_0)->l_err_0.y, (&rs_0)->l_err_0.z, 0.0f);
        return;
    }
    else
    {
        uint _S915 = __ballot_sync(_S896, true);
        _S899 = _S915;
    }
    float3  tu_1;
    float3  pv_1;
    wide_partials_0(tid_9, wg_3.first_0, isl_11.wide_groups_0, 2U, &tu_1, &pv_1, _S899);
    float3  lu_2;
    float3  lv_2;
    wide_partials_0(tid_9, wg_3.first_0, isl_11.wide_groups_0, 4U, &lu_2, &lv_2, _S899);
    float _S916 = isl_11.wcom_0.w;
    float3  tr_4 = tu_1 / make_float3 (_S916);
    float3  dv_4 = pv_1 / make_float3 (_S916);
    float3  phi_3 = rows_mul_0(isl_11.winv0_0, isl_11.winv1_0, isl_11.winv2_0, lu_2);
    float3  dw_2 = rows_mul_0(isl_11.winv0_0, isl_11.winv1_0, isl_11.winv2_0, lv_2);
    uint c_12 = wg_3.begin_0 + tid_9;
    bool _S917 = c_12 < (wg_3.end_0);
    uint _S918 = __ballot_sync(_S899, _S917);
    if(_S917)
    {
        float4  _S919 = isl_11.wcom_0;
        drift_apply_0(c_12, float3 {_S919.x, _S919.y, _S919.z}, tr_4, phi_3, dv_4, dw_2);
        uint _S920 = __ballot_sync(_S899, true);
        _S891 = _S920;
    }
    else
    {
        uint _S921 = __ballot_sync(_S899, true);
        _S891 = _S921;
    }
    uint _S922 = 0U;
    bool _S923 = _S885 != (wg_3.first_0);
    uint _S924 = __ballot_sync(_S891, _S923);
    if(_S923)
    {
        return;
    }
    else
    {
        uint _S925 = __ballot_sync(_S891, true);
        _S922 = _S925;
    }
    Island_0 _S926 = isl_11;
    WideGroup_0 _S927 = wg_3;
    Rigid_0 _S928 = wide_rigid_frame_0(tid_9, &_S926, &_S927, _S922);
    Rigid_0 rg_5 = _S928;
    bool _S929 = tid_9 != 0U;
    uint _S930 = __ballot_sync(_S922, _S929);
    if(_S929)
    {
        return;
    }
    if(!((_S887 & 2U) != 0U))
    {
        float _S931 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S932 = isl_11;
        integrate_rigid_0(&_S932, &rg_5, _S931);
        Island_0 _S933 = isl_11;
        drift_rigid_0(&_S933, &rg_5, tr_4, phi_3, dv_4, dw_2);
    }
    Quat_0 _S934 = (&rg_5)->rot_1;
    float4  _S935 = quat_vec_0(&_S934);
    (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_0 = _S935;
    (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_err_0 = (&rg_5)->rot_err_0;
    (&(globalParams_0->islands_0)[wg_3.island_2])->position_0 = make_float4 ((&rg_5)->pos_0.x, (&rg_5)->pos_0.y, (&rg_5)->pos_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->position_err_0 = make_float4 ((&rg_5)->pos_err_0.x, (&rg_5)->pos_err_0.y, (&rg_5)->pos_err_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_0 = make_float4 ((&rg_5)->vel_0.x, (&rg_5)->vel_0.y, (&rg_5)->vel_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_err_0 = make_float4 ((&rg_5)->vel_err_0.x, (&rg_5)->vel_err_0.y, (&rg_5)->vel_err_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->angular_velocity_0 = make_float4 ((&rg_5)->w_5.x, (&rg_5)->w_5.y, (&rg_5)->w_5.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_0 = make_float4 ((&rg_5)->l_1.x, (&rg_5)->l_1.y, (&rg_5)->l_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_err_0 = make_float4 ((&rg_5)->l_err_0.x, (&rg_5)->l_err_0.y, (&rg_5)->l_err_0.z, 0.0f);
    return;
}

__device__ __shared__ FixedArray<uint, 4096>  g_label_0;

__device__ __shared__ uint g_changed_0;

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S936 = __ldg(&ptr_0->geom0_0);
    float4  _S937 = __ldg(&ptr_0->geom1_0);
    float4  _S938 = __ldg(&ptr_0->stiff0_0);
    float4  _S939 = __ldg(&ptr_0->stiff1_0);
    float4  _S940 = __ldg(&ptr_0->rebar0_0);
    float4  _S941 = __ldg(&ptr_0->rebar1_0);
    uint4  _S942 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S943 = { _S936, _S937, _S938, _S939, _S940, _S941, _S942 };
    return _S943;
}

static __device__ bool connected_0(JointState_0 * st_0, bool has_rebar_0)
{
    bool _S944;
    if((st_0->damage_0) < 1.0f)
    {
        _S944 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S944 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S944 = false;
        }
    }
    return _S944;
}

static __device__ bool island_connected_0(uint tid_10, Island_0 * isl_12)
{
    uint _S945 = isl_12->range_0.x;
    uint n_8 = isl_12->range_0.y - _S945;
    bool converged_0;
    if(n_8 > 4096U)
    {
        converged_0 = true;
    }
    else
    {
        uint _S946 = __ldg(&globalParams_0->params_0->device_connect_0);
        converged_0 = _S946 == 0U;
    }
    if(converged_0)
    {
        return false;
    }
    uint c_13 = tid_10;
    for(;;)
    {
        if(c_13 < n_8)
        {
        }
        else
        {
            break;
        }
        (*&g_label_0)[c_13] = c_13;
        c_13 = c_13 + 256U;
    }
    __syncthreads();
    converged_0 = false;
    uint pass_0 = 0U;
    for(;;)
    {
        if(pass_0 <= n_8)
        {
        }
        else
        {
            break;
        }
        if(tid_10 == 0U)
        {
            *&g_changed_0 = 0U;
        }
        __syncthreads();
        c_13 = tid_10;
        for(;;)
        {
            if(c_13 < n_8)
            {
            }
            else
            {
                break;
            }
            uint _S947 = (*&g_label_0)[c_13];
            uint gc_0 = _S945 + c_13;
            uint _S948 = __ldg((&(globalParams_0->index_0)[gc_0]));
            uint l_3 = _S947;
            uint e_2 = _S948;
            for(;;)
            {
                uint _S949 = __ldg((&(globalParams_0->index_0)[gc_0 + 1U]));
                if(e_2 < _S949)
                {
                }
                else
                {
                    break;
                }
                uint _S950 = __ldg((&(globalParams_0->index_0)[e_2]));
                uint bond_0 = _S950 >> int(1);
                JointBond_0 _S951 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                bool _S952 = (_S951.stiff1_0.w) != 0.0f;
                JointState_0 _S953 = (&(globalParams_0->bond_dyn_0)[bond_0])->js_0;
                bool _S954 = connected_0(&_S953, _S952);
                if(!_S954)
                {
                    e_2 = e_2 + 1U;
                    continue;
                }
                uint other_0;
                if((_S950 & 1U) == 0U)
                {
                    JointBond_0 _S955 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S955.ids_0.z;
                }
                else
                {
                    JointBond_0 _S956 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S956.ids_0.y;
                }
                l_3 = (U32_min((l_3), ((*&g_label_0)[other_0 - _S945])));
                e_2 = e_2 + 1U;
            }
            uint _S957 = (U32_min((l_3), ((*&g_label_0)[l_3])));
            if(_S957 < (*&g_label_0)[c_13])
            {
                (*&g_label_0)[c_13] = _S957;
                *&g_changed_0 = 1U;
            }
            c_13 = c_13 + 256U;
        }
        __syncthreads();
        bool converged_1 = (*&g_changed_0) == 0U;
        __syncthreads();
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S958 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S958;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_10 == 0U)
    {
        *&g_changed_0 = 0U;
    }
    __syncthreads();
    c_13 = tid_10;
    for(;;)
    {
        if(c_13 < n_8)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_0)[c_13]) != 0U)
        {
            *&g_changed_0 = 1U;
        }
        c_13 = c_13 + 256U;
    }
    __syncthreads();
    return (*&g_changed_0) == 0U;
}

static __device__ void write_probe_0(uint slot_1, uint k_11, float value_1)
{
    uint _S959 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S960 = _S959 * 4U;
    uint _S961 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S960 + slot_1 * _S961 + k_11;
    float4  v_8 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_8, at_4 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_8;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_13, Rigid_0 * rg_6, uint k_12)
{
    uint4  _S962 = isl_13->probes_0;
    uint at_5 = isl_13->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S962.y))
        {
        }
        else
        {
            break;
        }
        float4  _S963 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_3 = asuint_0(_S963);
        float4  _S964 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S965 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S966 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_1 = info_3.x;
        uint i_11 = info_3.y;
        float value_2;
        if(kind_1 == 0U)
        {
            float4  _S967 = *(&(globalParams_0->state_0)[4U * i_11]);
            float3  small_0 = float3 {_S967.x, _S967.y, _S967.z} + make_float3 (_S964.w, _S965.w, _S966.w);
            float3  _S968 = rg_6->pos_0 - float3 {_S965.x, _S965.y, _S965.z};
            float4  _S969 = __ldg(&(&(globalParams_0->chunks_0)[i_11])->center_0);
            float3  _S970 = rotate_0(&rg_6->rot_1, float3 {_S969.x, _S969.y, _S969.z});
            float3  _S971 = _S968 + _S970;
            float3  _S972 = rg_6->pos_err_0 - float3 {_S966.x, _S966.y, _S966.z};
            float3  _S973 = rotate_0(&rg_6->rot_1, small_0);
            value_2 = dot_0(_S971 + (_S972 + _S973), float3 {_S964.x, _S964.y, _S964.z});
        }
        else
        {
            if(kind_1 == 1U)
            {
                float4  _S974 = __ldg(&(&(globalParams_0->chunks_0)[i_11])->center_0);
                uint _S975 = 4U * i_11;
                float4  _S976 = *(&(globalParams_0->state_0)[_S975]);
                float4  _S977 = isl_13->com_0;
                float3  _S978 = rotate_0(&rg_6->rot_1, float3 {_S974.x, _S974.y, _S974.z} + float3 {_S976.x, _S976.y, _S976.z} - float3 {_S977.x, _S977.y, _S977.z});
                float3  _S979 = rg_6->vel_0 + rg_6->vel_err_0 + cross_0(rg_6->w_5, _S978);
                float4  _S980 = *(&(globalParams_0->state_0)[_S975 + 2U]);
                float3  _S981 = rotate_0(&rg_6->rot_1, float3 {_S980.x, _S980.y, _S980.z});
                value_2 = dot_0(_S979 + _S981, float3 {_S964.x, _S964.y, _S964.z});
            }
            else
            {
                if(kind_1 == 2U)
                {
                    uint _S982 = 3U * i_11;
                    float4  _S983 = *(&(globalParams_0->scratch_0)[_S982]);
                    float3  f_7 = float3 {_S983.x, _S983.y, _S983.z};
                    bool _S984 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S984)
                    {
                        float4  _S985 = *(&(globalParams_0->scratch_0)[_S982 + 1U]);
                        mc_0 = float3 {_S985.x, _S985.y, _S985.z};
                    }
                    else
                    {
                        float4  _S986 = *(&(globalParams_0->scratch_0)[_S982 + 2U]);
                        mc_0 = float3 {_S986.x, _S986.y, _S986.z};
                    }
                    float3  fc_0;
                    if(_S984)
                    {
                        fc_0 = f_7;
                    }
                    else
                    {
                        fc_0 = - f_7;
                    }
                    value_2 = dot_0(fc_0, float3 {_S964.x, _S964.y, _S964.z}) + dot_0(mc_0, float3 {_S965.x, _S965.y, _S965.z});
                }
                else
                {
                    uint _S987 = 4U * i_11;
                    float3  _S988 = rotate_0(&rg_6->rot_1, make_float3 ((*(&(globalParams_0->state_0)[_S987 + 1U])).w, (*(&(globalParams_0->state_0)[_S987 + 2U])).w, (*(&(globalParams_0->state_0)[_S987 + 3U])).w));
                    value_2 = dot_0(_S988, float3 {_S964.x, _S964.y, _S964.z});
                }
            }
        }
        write_probe_0(info_3.w, k_12, value_2);
        at_5 = at_5 + 4U;
    }
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S989 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_0 = (&(globalParams_0->islands_0)[_S989])->info_1.y;
    uint _S990 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S991;
    if(previous_0 == 0U)
    {
        _S991 = at_6;
    }
    else
    {
        _S991 = (U32_min((previous_0), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S990])->info_1)->y) = _S991;
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S992 = 0U;
    uint _S993 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S994 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S995 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S994, _S995);
    bool _S996 = _S995 != (wg_4.first_0);
    uint _S997 = __ballot_sync(_S993, _S996);
    if(_S996)
    {
        return;
    }
    else
    {
        uint _S998 = __ballot_sync(_S993, true);
        _S992 = _S998;
    }
    uint _S999 = 0U;
    Island_0 * _S1000 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_14 = *_S1000;
    Island_0 _S1001 = *_S1000;
    bool _S1002 = wide_enter_0(tid_11, &_S1001);
    bool _S1003 = !_S1002;
    uint _S1004 = __ballot_sync(_S992, _S1003);
    if(_S1003)
    {
        return;
    }
    else
    {
        uint _S1005 = __ballot_sync(_S992, true);
        _S999 = _S1005;
    }
    float3  work_0;
    float3  flags_1;
    wide_partials_0(tid_11, wg_4.first_0, (&isl_14)->wide_groups_0, 6U, &work_0, &flags_1, _S999);
    bool halt_0 = (((&isl_14)->info_1.z) & 2U) != 0U;
    uint _S1006 = __ballot_sync(_S999, halt_0);
    bool whole_0;
    if(halt_0)
    {
        Island_0 _S1007 = isl_14;
        bool _S1008 = island_connected_0(tid_11, &_S1007);
        whole_0 = _S1008;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_11 != 0U)
    {
        return;
    }
    bool halt_1;
    if(whole_0)
    {
        *&((&(&isl_14)->info_1)->z) = (*&((&(&isl_14)->info_1)->z)) & 4294967293U;
        (&isl_14)->coverage_0 = ((&isl_14)->coverage_0) | 2097280U;
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    Island_0 _S1009 = isl_14;
    uint _S1010 = wide_step_0(&_S1009);
    if(((&isl_14)->probes_0.y) > ((&isl_14)->probes_0.x))
    {
        Island_0 _S1011 = isl_14;
        Rigid_0 _S1012 = rigid_of_0(&_S1011);
        Island_0 _S1013 = isl_14;
        Rigid_0 _S1014 = _S1012;
        record_probes_0(&_S1013, &_S1014, _S1010);
    }
    if(halt_1)
    {
        whole_0 = (((&isl_14)->info_1.x) & 4U) != 0U;
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0((&isl_14)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_14)->energy_1)->x), &((&(&isl_14)->energy_1)->y), work_0.x);
    *&((&(&isl_14)->energy_1)->y) = *&((&(&isl_14)->energy_1)->y) + work_0.y;
    (&isl_14)->done_0 = (&isl_14)->done_0 + 1U;
    *&((&(&isl_14)->info_1)->y) = *&((&(&isl_14)->info_1)->y) - 1U;
    *&((&(&isl_14)->info_1)->w) = *&((&(&isl_14)->info_1)->w) + 1U;
    if(halt_1)
    {
        *&((&(&isl_14)->info_1)->z) = (((&isl_14)->info_1.z) & 4294967293U) | 1U;
    }
    uint _S1015;
    if(halt_1)
    {
        _S1015 = 128U;
    }
    else
    {
        _S1015 = 0U;
    }
    uint _S1016 = 256U | _S1015;
    if(((&isl_14)->probes_0.y) > ((&isl_14)->probes_0.x))
    {
        _S1015 = 262144U;
    }
    else
    {
        _S1015 = 0U;
    }
    uint _S1017 = _S1016 | _S1015;
    if((((&isl_14)->info_1.x) & 4U) != 0U)
    {
        _S1015 = 524288U;
    }
    else
    {
        _S1015 = 0U;
    }
    uint _S1018 = _S1017 | _S1015;
    if((flags_1.x) > 0.0f)
    {
        _S1015 = 32768U;
    }
    else
    {
        _S1015 = 0U;
    }
    uint _S1019 = _S1018 | _S1015;
    if((flags_1.y) > 0.0f)
    {
        _S1015 = 65536U;
    }
    else
    {
        _S1015 = 0U;
    }
    uint _S1020 = _S1019 | _S1015;
    if((flags_1.z) > 0.0f)
    {
        _S1015 = 131072U;
    }
    else
    {
        _S1015 = 0U;
    }
    (&isl_14)->coverage_0 = ((&isl_14)->coverage_0) | (_S1020 | _S1015);
    *(&(globalParams_0->islands_0)[wg_4.island_2]) = isl_14;
    return;
}

static __device__ uint sv_0(uint c_14, uint slot_2)
{
    uint _S1021 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1021 + 23U * c_14 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_12, Island_0 * isl_15, uint slot_3, uint _S1022)
{
    uint _S1023;
    uint _S1024;
    float3  _S1025 = make_float3 (0.0f);
    float3  net_f_0 = _S1025;
    float3  net_m_0 = _S1025;
    uint4  _S1026 = isl_15->range_0;
    uint _S1027 = isl_15->range_0.x + tid_12;
    uint c_15 = _S1027;
    uint _S1028 = _S1022;
    for(;;)
    {
        uint _S1029 = _S1026.y;
        _S1023 = _S1029;
        bool _S1030 = c_15 < _S1029;
        uint _S1031 = __ballot_sync(_S1028, _S1030);
        if(_S1030)
        {
            uint _S1032 = __ballot_sync(_S1028, true);
        }
        else
        {
            uint _S1033 = __ballot_sync(_S1028, false);
            uint _S1034 = __ballot_sync(_S1028, false);
            uint _S1035 = __ballot_sync(_S1022, true);
            _S1024 = _S1035;
            break;
        }
        float4  _S1036 = *(&(globalParams_0->scratch_0)[sv_0(c_15, slot_3)]);
        float3  fi_0 = float3 {_S1036.x, _S1036.y, _S1036.z};
        net_f_0 = net_f_0 + fi_0;
        float4  _S1037 = __ldg(&(&(globalParams_0->chunks_0)[c_15])->center_0);
        float4  _S1038 = isl_15->com_0;
        float4  _S1039 = *(&(globalParams_0->scratch_0)[sv_0(c_15, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1037.x, _S1037.y, _S1037.z} - float3 {_S1038.x, _S1038.y, _S1038.z}, fi_0) + float3 {_S1039.x, _S1039.y, _S1039.z});
        uint _S1040 = __ballot_sync(_S1028, true);
        c_15 = c_15 + 256U;
        _S1028 = _S1040;
    }
    group_sum3_0(tid_12, &net_f_0, &net_m_0, _S1024);
    float4  _S1041 = isl_15->com_0;
    float3  _S1042 = net_f_0 / make_float3 (isl_15->com_0.w);
    float3  _S1043 = rows_mul_0(isl_15->inv0_1, isl_15->inv1_1, isl_15->inv2_1, net_m_0);
    c_15 = _S1027;
    for(;;)
    {
        if(c_15 < _S1023)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1044 = (&(globalParams_0->chunks_0)[c_15]);
        float4  _S1045 = __ldg(&_S1044->center_0);
        uint _S1046 = sv_0(c_15, slot_3);
        float4  _S1047 = *(&(globalParams_0->scratch_0)[_S1046]);
        *(&(globalParams_0->scratch_0)[_S1046]) = make_float4 ((float3 {_S1047.x, _S1047.y, _S1047.z} - (_S1042 + cross_0(_S1043, float3 {_S1045.x, _S1045.y, _S1045.z} - float3 {_S1041.x, _S1041.y, _S1041.z})) * make_float3 (_S1045.w)).x, (float3 {_S1047.x, _S1047.y, _S1047.z} - (_S1042 + cross_0(_S1043, float3 {_S1045.x, _S1045.y, _S1045.z} - float3 {_S1041.x, _S1041.y, _S1041.z})) * make_float3 (_S1045.w)).y, (float3 {_S1047.x, _S1047.y, _S1047.z} - (_S1042 + cross_0(_S1043, float3 {_S1045.x, _S1045.y, _S1045.z} - float3 {_S1041.x, _S1041.y, _S1041.z})) * make_float3 (_S1045.w)).z, 0.0f);
        uint _S1048 = sv_0(c_15, slot_3 + 1U);
        float4  * _S1049 = (&(globalParams_0->scratch_0)[_S1048]);
        float4  _S1050 = *(&(globalParams_0->scratch_0)[_S1048]);
        float3  _S1051 = float3 {_S1050.x, _S1050.y, _S1050.z};
        float4  _S1052 = __ldg(&_S1044->inertia0_0);
        float4  _S1053 = __ldg(&_S1044->inertia1_0);
        float4  _S1054 = __ldg(&_S1044->inertia2_0);
        *_S1049 = make_float4 ((_S1051 - rows_mul_0(_S1052, _S1053, _S1054, _S1043)).x, (_S1051 - rows_mul_0(_S1052, _S1053, _S1054, _S1043)).y, (_S1051 - rows_mul_0(_S1052, _S1053, _S1054, _S1043)).z, 0.0f);
        c_15 = c_15 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_13, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1055)
{
    uint _S1056;
    float4  _S1057 = make_float4 (0.0f);
    float4  acc_0 = _S1057;
    float4  unused_2 = _S1057;
    uint c_16 = c0_0 + tid_13;
    uint _S1058 = _S1055;
    for(;;)
    {
        bool _S1059 = c_16 < c1_0;
        uint _S1060 = __ballot_sync(_S1058, _S1059);
        if(_S1059)
        {
            uint _S1061 = __ballot_sync(_S1058, true);
        }
        else
        {
            uint _S1062 = __ballot_sync(_S1058, false);
            uint _S1063 = __ballot_sync(_S1058, false);
            uint _S1064 = __ballot_sync(_S1055, true);
            _S1056 = _S1064;
            break;
        }
        float4  _S1065 = *(&(globalParams_0->scratch_0)[sv_0(c_16, sa_2)]);
        float4  _S1066 = *(&(globalParams_0->scratch_0)[sv_0(c_16, sb_2)]);
        float4  _S1067 = *(&(globalParams_0->scratch_0)[sv_0(c_16, sa_2 + 1U)]);
        float4  _S1068 = *(&(globalParams_0->scratch_0)[sv_0(c_16, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1065.x, _S1065.y, _S1065.z}, float3 {_S1066.x, _S1066.y, _S1066.z}) + dot_0(float3 {_S1067.x, _S1067.y, _S1067.z}, float3 {_S1068.x, _S1068.y, _S1068.z}));
        uint _S1069 = __ballot_sync(_S1058, true);
        c_16 = c_16 + 256U;
        _S1058 = _S1069;
    }
    group_sum2_0(tid_13, &acc_0, &unused_2, _S1056);
    return acc_0.x;
}

static __device__ float fdiv_0(float a_11, float b_23)
{
    return a_11 / b_23;
}

static __device__ float fsqrt_0(float a_12)
{
    return (F32_sqrt((a_12)));
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

static __device__ Measures_0 stress_measures_0(JointBond_0 * b_24, float3  q_lin_0, float3  q_ang_0)
{
    float area_2 = b_24->geom0_0.x;
    float _S1070 = q_lin_0.z;
    float axial_0 = fdiv_0(_S1070, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_24->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_24->geom1_0.y);
    float _S1071 = q_lin_0.x;
    float _S1072 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S1071 * _S1071 + _S1072 * _S1072), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_24->geom0_0.w);
    Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S1073 = - axial_0;
    (&m_2)->normal_compression_0 = (F32_max((_S1073), (0.0f)));
    (&m_2)->compression_0 = _S1073 + bending_0;
    (&m_2)->compressive_force_0 = (F32_max((- _S1070), (0.0f)));
    return m_2;
}

static __device__ float expm1_accurate_0(float x_22)
{
    if((F32_abs((x_22))) < 0.00100000004749745f)
    {
        return x_22 * (1.0f + x_22 * (0.5f + x_22 * 0.1666666716337204f));
    }
    return (F32_exp((x_22))) - 1.0f;
}

static __device__ float fpow_0(float a_13, float b_25)
{
    return (F32_pow((a_13), (b_25)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_7 = (F32_abs((strain_rate_1)));
    float4  _S1074 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_7 <= ref_0)
    {
        return 1.0f;
    }
    float _S1075 = _S1074.z;
    float f_8;
    if(r_7 <= _S1075)
    {
        f_8 = fpow_0(fdiv_0(r_7, ref_0), _S1074.y);
    }
    else
    {
        f_8 = fpow_0(fdiv_0(_S1075, ref_0), _S1074.y) * fpow_0(fdiv_0(r_7, _S1075), _S1074.w);
    }
    return clamp_0(f_8, 1.0f, mat_1->misc_0.x);
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

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_26, Measures_0 * m_3, float multiplier_0)
{
    float fc_1 = mat_3->strength_0.y * multiplier_0;
    float _S1076 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_3->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S1077;
    if(_S1076 > 0.0f)
    {
        _S1077 = fdiv_0(m_3->shear_0, _S1076);
    }
    else
    {
        _S1077 = infinity_0();
    }
    *&((&idx_0)->y) = _S1077;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_3->compression_0, fc_1)), (0.0f)));
    float _S1078 = b_26->stiff1_0.y;
    if(_S1078 > 0.0f)
    {
        _S1077 = fdiv_0(m_3->compressive_force_0, _S1078);
    }
    else
    {
        _S1077 = 0.0f;
    }
    *&((&idx_0)->w) = _S1077;
    return idx_0;
}

static __device__ float sq_0(float x_23)
{
    return x_23 * x_23;
}

static __device__ float damage_law_0(uint kind_2, float kappa_1, float r_8)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_8 <= 1.0f)
        {
            return 1.0f;
        }
        return (F32_min((fdiv_0(r_8 * (kappa_1 - 1.0f), kappa_1 * (r_8 - 1.0f))), (1.0f)));
    }
    if(kappa_1 >= (0.5f * (r_8 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

static __device__ __noinline__ float2  damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_9, float d_old_0, float psi_0)
{
    float _S1079 = (F32_max((damage_law_0(kind_3, lambda_0, r_9)), (d_old_0)));
    bool _S1080;
    if(_S1079 <= d_old_0)
    {
        _S1080 = true;
    }
    else
    {
        _S1080 = d_old_0 >= 1.0f;
    }
    if(_S1080)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S1081 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_9 > 1.0f)
        {
            return make_float2 (_S1079, fdiv_0(u0_0 * r_9, r_9 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_9))) - (F32_min((_S1081), (r_9)))), (0.0f))));
        }
        return make_float2 (_S1079, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_9 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S1081), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S1079 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S1079, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_4;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S1082 = - h0_0;
    float _S1083 = - h1_0;
    FixedArray<float2 , 4>  _S1084 = { {
        float2 {
            _S1082, _S1083
        }, float2 {
            h0_0, _S1083
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S1082, h1_0
        }
    } };
    FixedArray<float2 , 8>  poly_0;
    uint i_12 = 0U;
    uint count_5 = 0U;
    for(;;)
    {
        if(i_12 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S1085 = i_12;
        uint _S1086 = i_12 + 1U;
        uint _S1087 = _S1086 % 4U;
        float _S1088 = _S1084[i_12].y;
        float _S1089 = _S1084[i_12].x;
        float fp_0 = dz_0 + ax_0 * _S1088 - ay_0 * _S1089;
        float _S1090 = _S1084[_S1087].y;
        float _S1091 = _S1084[_S1087].x;
        float fq_0 = dz_0 + ax_0 * _S1090 - ay_0 * _S1091;
        bool _S1092 = fp_0 < 0.0f;
        if(_S1092)
        {
            uint _S1093 = count_5 + 1U;
            poly_0[count_5] = _S1084[_S1085];
            count_4 = _S1093;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S1092 != (fq_0 < 0.0f))
        {
            float t_9 = fp_0 / (fp_0 - fq_0);
            uint _S1094 = count_4 + 1U;
            poly_0[count_4] = make_float2 (_S1089 + t_9 * (_S1091 - _S1089), _S1088 + t_9 * (_S1090 - _S1088));
            count_5 = _S1094;
        }
        else
        {
            count_5 = count_4;
        }
        i_12 = _S1086;
    }
    count_4 = 0U;
    for(;;)
    {
        if(count_4 < 6U)
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_4] = 0.0f;
        count_4 = count_4 + 1U;
    }
    if(count_5 < 3U)
    {
        return;
    }
    float2  o_1 = poly_0[int(0)];
    i_12 = 0U;
    float a_14 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_12 < count_5)
        {
        }
        else
        {
            break;
        }
        float _S1095 = o_1.x;
        float x0_0 = poly_0[i_12].x - _S1095;
        float _S1096 = o_1.y;
        float y0_0 = poly_0[i_12].y - _S1096;
        uint _S1097 = i_12 + 1U;
        uint _S1098 = _S1097 % count_5;
        float x1_0 = poly_0[_S1098].x - _S1095;
        float y1_0 = poly_0[_S1098].y - _S1096;
        float _S1099 = x0_0 * y1_0;
        float _S1100 = x1_0 * y0_0;
        float cr_0 = _S1099 - _S1100;
        float a_15 = a_14 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S1099 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S1100) * cr_0 / 24.0f;
        i_12 = _S1097;
        a_14 = a_15;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_14 <= 0.0f)
    {
        return;
    }
    float cx_0 = sx_0 / a_14;
    float cy_0 = sy_0 / a_14;
    (*region_0)[int(0)] = a_14;
    (*region_0)[int(1)] = o_1.x + cx_0;
    (*region_0)[int(2)] = o_1.y + cy_0;
    float _S1101 = a_14 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S1101 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_14 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S1101 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_10;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_10);
    float a_16 = r_10[int(0)];
    if((r_10[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_13 = kn_0 / (w0_1 * w1_1);
    float fc_2 = dz_1 + ax_1 * r_10[int(2)] - ay_1 * r_10[int(1)];
    float _S1102 = a_16 * fc_2;
    float _S1103 = - ay_1;
    return make_float4 (k_13 * a_16 * fc_2, k_13 * (_S1102 * r_10[int(2)] + (_S1103 * r_10[int(5)] + ax_1 * r_10[int(4)])), - k_13 * (_S1102 * r_10[int(1)] + (_S1103 * r_10[int(3)] + ax_1 * r_10[int(5)])), 0.5f * k_13 * (_S1102 * fc_2 + ay_1 * ay_1 * r_10[int(3)] + ax_1 * ax_1 * r_10[int(4)] - 2.0f * ax_1 * ay_1 * r_10[int(5)]));
}

static __device__ float signum_0(float x_24)
{
    float _S1104;
    if(((F32_asuint((x_24))) & 2147483648U) != 0U)
    {
        _S1104 = -1.0f;
    }
    else
    {
        _S1104 = 1.0f;
    }
    return _S1104;
}

static __device__ float2  return_map_0(float k_14, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_14 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_9 = cap_0 * signum_0(trial_0);
    return make_float2 (f_9, fdiv_0(trial_0 - f_9, k_14));
}

struct Contact_0
{
    float3  q_lin_1;
    float3  q_ang_1;
    float energy_2;
    float diss_2;
    float3  plastic_1;
};

static __device__ __noinline__ Contact_0 contact_part_0(JointMaterial_0 * mat_4, JointBond_0 * b_27, float crush_2, float3  plastic_2, float3  d_lin_0, float3  d_ang_0)
{
    Contact_0 c_17;
    float3  _S1105 = make_float3 (0.0f);
    (&c_17)->q_lin_1 = _S1105;
    (&c_17)->q_ang_1 = _S1105;
    (&c_17)->energy_2 = 0.0f;
    (&c_17)->diss_2 = 0.0f;
    (&c_17)->plastic_1 = plastic_2;
    uint _S1106 = mat_4->kind_flags_0.y;
    if((_S1106 & 2U) == 0U)
    {
        return c_17;
    }
    float kn_1 = b_27->stiff0_0.x;
    float ks_0 = b_27->stiff0_0.y;
    float kt_0 = b_27->stiff1_0.x;
    float w0_2 = b_27->geom0_0.y;
    float w1_2 = b_27->geom0_0.z;
    float diss_3;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S1106 & 4U) != 0U)
    {
        float4  p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S1107 = p_11.y;
        float _S1108 = p_11.z;
        float _S1109 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S1107;
        m2_0 = _S1108;
        energy_3 = _S1109;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S1110 = d_ang_0.x;
        float _S1111 = d_ang_0.y;
        float spread_0 = (F32_abs((_S1110))) * 0.4166666567325592f * w1_2 + (F32_abs((_S1111))) * 0.4166666567325592f * w0_2;
        float _S1112 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S1112))) + spread_0);
        if((_S1112 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S1112 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S1113 = ki_0 * _S1110 * i2_0;
                float _S1114 = ki_0 * _S1111 * i1_0;
                float _S1115 = 0.5f * ki_0 * (36.0f * _S1112 * _S1112 + _S1110 * _S1110 * i2_0 + _S1111 * _S1111 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S1112;
                m1_0 = _S1113;
                m2_0 = _S1114;
                energy_3 = _S1115;
            }
            else
            {
                uint i_13 = 0U;
                diss_3 = 0.0f;
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
                    float _S1116 = SPRING_AT_0[i_13] * w0_2;
                    uint j_6 = 0U;
                    nc_sum_0 = diss_3;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    for(;;)
                    {
                        if(j_6 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float s2_0 = SPRING_AT_0[j_6] * w1_2;
                        float di_0 = _S1112 + _S1110 * s2_0 - _S1111 * _S1116;
                        if(di_0 < 0.0f)
                        {
                            float f_10 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_10 * s2_0;
                            float m2_2 = m2_0 - f_10 * _S1116;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_10;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_6 = j_6 + 1U;
                    }
                    i_13 = i_13 + 1U;
                    diss_3 = nc_sum_0;
                    m1_1 = m1_0;
                    m2_1 = m2_0;
                    energy_4 = energy_3;
                }
                nc_sum_0 = diss_3;
                m1_0 = m1_1;
                m2_0 = m2_1;
                energy_3 = energy_4;
            }
        }
    }
    float nc_0 = - nc_sum_0;
    float3  p_12 = plastic_2;
    (&c_17)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_17)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S1117 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S1118 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S1117 * _S1117 + _S1118 * _S1118);
    bool _S1119;
    if(tn_0 > slide_cap_0)
    {
        _S1119 = tn_0 > 0.0f;
    }
    else
    {
        _S1119 = false;
    }
    if(_S1119)
    {
        float _S1120 = fdiv_0(_S1117, tn_0);
        float _S1121 = fdiv_0(_S1118, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_12)->x) = *&((&p_12)->x) + _S1120 * dslip_0;
        *&((&p_12)->y) = *&((&p_12)->y) + _S1121 * dslip_0;
        *&((&(&c_17)->q_lin_1)->x) = _S1120 * slide_cap_0;
        *&((&(&c_17)->q_lin_1)->y) = _S1121 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_17)->q_lin_1)->x) = _S1117;
        *&((&(&c_17)->q_lin_1)->y) = _S1118;
        diss_3 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * b_27->geom1_0.z);
    float _S1122 = tq_0.x;
    float _S1123 = tq_0.y;
    float diss_4 = diss_3 + (F32_abs((_S1122))) * (F32_abs((_S1123)));
    *&((&p_12)->z) = *&((&p_12)->z) + _S1123;
    *&((&(&c_17)->q_ang_1)->z) = _S1122;
    (&c_17)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_17)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_17)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S1122), kt_0));
    (&c_17)->diss_2 = diss_4;
    (&c_17)->plastic_1 = p_12;
    return c_17;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_28, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S1124 = mat_5->kind_flags_0.y;
    if((_S1124 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_28->stiff0_0.x;
    float ks_1 = b_28->stiff0_0.y;
    float kt_1 = b_28->stiff1_0.x;
    float w0_3 = b_28->geom0_0.y;
    float w1_3 = b_28->geom0_0.z;
    float nc_sum_1;
    if((_S1124 & 4U) != 0U)
    {
        float4  _S1125 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S1125.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S1126 = d_ang_1.x;
        float _S1127 = d_ang_1.y;
        float spread_1 = (F32_abs((_S1126))) * 0.4166666567325592f * w1_3 + (F32_abs((_S1127))) * 0.4166666567325592f * w0_3;
        float _S1128 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S1128))) + spread_1);
        if((_S1128 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S1128 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S1128;
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
                    float _S1129 = SPRING_AT_0[i_14] * w0_3;
                    uint j_7 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_7 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S1128 + _S1126 * (SPRING_AT_0[j_7] * w1_3) - _S1127 * _S1129;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_7 = j_7 + 1U;
                    }
                    i_14 = i_14 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    float3  p_13 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S1130 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S1131 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S1130 * _S1130 + _S1131 * _S1131);
    bool _S1132;
    if(tn_1 > slide_cap_1)
    {
        _S1132 = tn_1 > 0.0f;
    }
    else
    {
        _S1132 = false;
    }
    if(_S1132)
    {
        float _S1133 = fdiv_0(_S1131, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_13)->x) = *&((&p_13)->x) + fdiv_0(_S1130, tn_1) * dslip_1;
        *&((&p_13)->y) = *&((&p_13)->y) + _S1133 * dslip_1;
    }
    *&((&p_13)->z) = *&((&p_13)->z) + return_map_0(kt_1, d_ang_1.z, p_13.z, slide_cap_1 * b_28->geom1_0.z).y;
    return p_13;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_5)
{
    if(s_5 <= 0.0f)
    {
        return 0.0f;
    }
    float _S1134 = mat_6->misc_0.y;
    return fdiv_0((_S1134 + 1.0f) * fpow_0(s_5, _S1134), mat_6->misc_0.z);
}

struct JointResponse_0
{
    float3  force_lin_1;
    float3  force_ang_1;
    JointState_0 state_1;
    float dissipated_2;
    float overshoot_0;
    float stored_3;
    bool disconnected_0;
    float fatigue_before_0;
    Measures_0 measures_0;
};

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_29, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_8, bool fracture_1)
{
    float kn_3 = b_29->stiff0_0.x;
    float ks_2 = b_29->stiff0_0.y;
    float kb1_0 = b_29->stiff0_0.z;
    float kb2_0 = b_29->stiff0_0.w;
    float4  _S1135 = b_29->stiff1_0;
    float kt_2 = b_29->stiff1_0.x;
    bool has_rebar_1 = (b_29->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_2 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_2 & 1U) != 0U;
    JointState_0 st_1 = *state_2;
    bool _S1136 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S1137 = stress_measures_0(b_29, qe_lin_0, qe_ang_0);
    float _S1138 = (F32_max(((F32_max((_S1137.tension_0), (_S1137.shear_0)))), (_S1137.compression_0)));
    bool _S1139 = dt_8 > 0.0f;
    float dif_1;
    if(_S1139)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S1138 - (&st_1)->governing_stress_0, dt_8)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S1135.z;
        if((flags_2 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_8, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_8, tau_2)), (1.0f)));
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S1138;
    }
    if((flags_2 & 32U) != 0U)
    {
        float _S1140 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S1140;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_29->geom1_0.w;
    float _S1141 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S1141;
    Measures_0 _S1142 = _S1137;
    float4  _S1143 = failure_indices_0(mat_7, b_29, &_S1142, multiplier_1);
    float _S1144 = _S1143.x;
    float _S1145 = _S1143.y;
    (&st_1)->utilization_0 = (F32_max(((F32_max((_S1144), (_S1145)))), ((F32_max((_S1143.z), (_S1143.w))))));
    float _S1146 = d_lin_2.x;
    float _S1147 = d_lin_2.y;
    float _S1148 = ks_2 * (sq_0(_S1146) + sq_0(_S1147)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S1149 = d_lin_2.z;
    bool _S1150 = _S1149 > 0.0f;
    if(_S1150)
    {
        dif_1 = kn_3 * sq_0(_S1149);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S1148 + dif_1);
    float psi_c_0;
    if(_S1149 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S1149);
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
    bool _S1151;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S1152 = _S1144 >= _S1145;
        if(_S1152)
        {
            diss_contact_0 = _S1144;
        }
        else
        {
            diss_contact_0 = _S1145;
        }
        uint mode_ts_0;
        if(_S1152)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S1151 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S1151 = false;
        }
        if(_S1151)
        {
            _S1151 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S1151 = false;
        }
        uint mode_c_0;
        if(_S1151)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * b_29->geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
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
            float _S1153 = inc_0.x;
            if(_S1153 > ((&st_1)->damage_0))
            {
                Contact_0 _S1154 = contact_part_0(mat_7, b_29, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S1155 = (F32_max((_S1154.energy_2 - (1.0f - (&st_1)->crush_0) * psi_c_0), (0.0f)));
                float _S1156 = (F32_max((inc_0.y - _S1155 * (_S1153 - (&st_1)->damage_0)), (0.0f)));
                float _S1157 = (F32_max(((psi_ts_0 - _S1155) * (_S1153 - (&st_1)->damage_0) - _S1156), (0.0f)));
                (&st_1)->damage_0 = _S1153;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S1156;
                overshoot_1 = _S1157;
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
        float _S1158 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S1159 = contact_part_0(mat_7, b_29, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S1158) + _S1159.q_ang_1 * make_float3 (_S1158);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S1160 = stress_measures_0(b_29, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S1161 = _S1160;
        float4  _S1162 = failure_indices_0(mat_7, b_29, &_S1161, multiplier_1);
        float _S1163 = _S1162.z;
        float _S1164 = _S1162.w;
        bool _S1165 = _S1163 >= _S1164;
        if(_S1165)
        {
            psi_contact_0 = _S1163;
        }
        else
        {
            psi_contact_0 = _S1164;
        }
        if(_S1165)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S1151 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S1151 = false;
        }
        if(_S1151)
        {
            _S1151 = psi_c_0 > 0.0f;
        }
        else
        {
            _S1151 = false;
        }
        if(_S1151)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_7->energy_0.w * b_29->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
            float _S1166 = inc_1.x;
            if(_S1166 > ((&st_1)->crush_0))
            {
                float _S1167 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S1167;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S1166 - (&st_1)->crush_0) - _S1167), (0.0f)));
                (&st_1)->crush_0 = _S1166;
                (&st_1)->mode_0 = mode_c_0;
                if(_S1166 >= 1.0f)
                {
                    _S1151 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S1151 = false;
                }
                if(_S1151)
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
    float3  _S1168 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_2 & 8U) == 0U)
        {
            float3  _S1169 = contact_offsets_0(mat_7, b_29, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S1169.x;
            (&st_1)->plastic_y_0 = _S1169.y;
            (&st_1)->plastic_t_0 = _S1169.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S1168;
        qc_ang_0 = _S1168;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S1170 = contact_part_0(mat_7, b_29, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S1170.plastic_1.x;
        (&st_1)->plastic_y_0 = _S1170.plastic_1.y;
        (&st_1)->plastic_t_0 = _S1170.plastic_1.z;
        diss_contact_0 = _S1170.diss_2;
        qc_lin_0 = _S1170.q_lin_1;
        qc_ang_0 = _S1170.q_ang_1;
        psi_contact_0 = _S1170.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S1150)
    {
        intact_normal_0 = kn_3 * _S1149;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_3 * _S1149;
    }
    float _S1171 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S1171 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S1171 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S1171 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S1171) + qc_ang_0 * make_float3 (dmg_0);
    float stored_4 = _S1171 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S1151 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S1151 = false;
    }
    float stored_5;
    float3  force_lin_3;
    if(_S1151)
    {
        float k_axial_0 = b_29->rebar0_0.x;
        float k_dowel_0 = b_29->rebar0_0.y;
        float yield_force_0 = b_29->rebar0_0.z;
        float dowel_capacity_0 = b_29->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S1149, (&st_1)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S1146, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S1147, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S1172 = nr_0.y;
        float _S1173 = v1_0.y;
        float _S1174 = v2_0.y;
        float work_1 = yield_force_0 * (F32_abs((_S1172))) + dowel_capacity_0 * ((F32_abs((_S1173))) + (F32_abs((_S1174))));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S1172;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S1173;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S1174;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_1;
        float dissipated_7 = dissipated_6 + work_1;
        float _S1175 = nr_0.x;
        float _S1176 = v1_0.x;
        float _S1177 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S1175), k_axial_0) + fdiv_0(sq_0(_S1176) + sq_0(_S1177), k_dowel_0));
        if(fracture_1)
        {
            _S1151 = ((&st_1)->rebar_work_0) >= (b_29->rebar1_0.x);
        }
        else
        {
            _S1151 = false;
        }
        if(_S1151)
        {
            (&st_1)->rebar_broken_0 = 1.0f;
            float dissipated_8 = dissipated_7 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_3 = dissipated_8;
            stored_5 = stored_4;
        }
        else
        {
            float stored_6 = stored_4 + elastic_0;
            force_lin_3 = force_lin_2 + make_float3 (_S1176, _S1177, _S1175);
            dissipated_3 = dissipated_7;
            stored_5 = stored_6;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_3 = dissipated_6;
        stored_5 = stored_4;
    }
    if(fracture_1)
    {
        _S1151 = _S1139;
    }
    else
    {
        _S1151 = false;
    }
    if(_S1151)
    {
        _S1151 = (flags_2 & 64U) != 0U;
    }
    else
    {
        _S1151 = false;
    }
    if(_S1151)
    {
        Measures_0 _S1178 = stress_measures_0(b_29, force_lin_3, force_ang_2);
        Measures_0 _S1179 = _S1178;
        float4  _S1180 = failure_indices_0(mat_7, b_29, &_S1179, weibull_0);
        float _S1181 = life_rate_0(mat_7, (F32_max(((F32_max((_S1180.x), (_S1180.y)))), (_S1180.z))));
        (&st_1)->life_0 = (F32_max(((&st_1)->life_0 - _S1181 * dt_8), (0.0f)));
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S1136)
    {
        JointState_0 _S1182 = st_1;
        bool _S1183 = connected_0(&_S1182, has_rebar_1);
        _S1151 = !_S1183;
    }
    else
    {
        _S1151 = false;
    }
    (&resp_0)->disconnected_0 = _S1151;
    (&resp_0)->fatigue_before_0 = _S1141;
    (&resp_0)->measures_0 = _S1137;
    return resp_0;
}

static __device__ float3  to_local_0(uint _S1184, float3  _S1185)
{
    BondStatic_0 * _S1186 = (&(globalParams_0->bonds_0)[_S1184]);
    float4  _S1187 = __ldg(&_S1186->t1_0);
    float _S1188 = dot_0(_S1185, float3 {_S1187.x, _S1187.y, _S1187.z});
    float4  _S1189 = __ldg(&_S1186->t2_0);
    float _S1190 = dot_0(_S1185, float3 {_S1189.x, _S1189.y, _S1189.z});
    float4  _S1191 = __ldg(&_S1186->normal_0);
    return make_float3 (_S1188, _S1190, dot_0(_S1185, float3 {_S1191.x, _S1191.y, _S1191.z}));
}

static __device__ void static_kinematics_0(uint _S1192, float3  * _S1193, float3  * _S1194)
{
    BondStatic_0 * _S1195 = (&(globalParams_0->bonds_0)[_S1192]);
    JointBond_0 _S1196 = slang_ldg_0(&_S1195->law_0);
    uint ca_0 = _S1196.ids_0.y;
    uint cb_0 = _S1196.ids_0.z;
    uint _S1197 = 4U * cb_0;
    float4  _S1198 = *(&(globalParams_0->state_0)[_S1197]);
    uint _S1199 = 4U * ca_0;
    float4  _S1200 = *(&(globalParams_0->state_0)[_S1199]);
    float4  _S1201 = *(&(globalParams_0->scratch_0)[sv_0(cb_0, 21U)]);
    float4  _S1202 = *(&(globalParams_0->scratch_0)[sv_0(ca_0, 21U)]);
    float3  du_0 = float3 {_S1198.x, _S1198.y, _S1198.z} - float3 {_S1200.x, _S1200.y, _S1200.z} + (float3 {_S1201.x, _S1201.y, _S1201.z} - float3 {_S1202.x, _S1202.y, _S1202.z});
    uint _S1203 = _S1197 + 1U;
    float4  _S1204 = *(&(globalParams_0->state_0)[_S1203]);
    uint _S1205 = _S1199 + 1U;
    float4  _S1206 = *(&(globalParams_0->state_0)[_S1205]);
    uint _S1207 = sv_0(cb_0, 22U);
    float4  _S1208 = *(&(globalParams_0->scratch_0)[_S1207]);
    uint _S1209 = sv_0(ca_0, 22U);
    float4  _S1210 = *(&(globalParams_0->scratch_0)[_S1209]);
    float3  dth_0 = float3 {_S1204.x, _S1204.y, _S1204.z} - float3 {_S1206.x, _S1206.y, _S1206.z} + (float3 {_S1208.x, _S1208.y, _S1208.z} - float3 {_S1210.x, _S1210.y, _S1210.z});
    float4  _S1211 = *(&(globalParams_0->state_0)[_S1205]);
    float4  _S1212 = *(&(globalParams_0->scratch_0)[_S1209]);
    float3  ta_2 = float3 {_S1211.x, _S1211.y, _S1211.z} + float3 {_S1212.x, _S1212.y, _S1212.z};
    float4  _S1213 = *(&(globalParams_0->state_0)[_S1203]);
    float4  _S1214 = *(&(globalParams_0->scratch_0)[_S1207]);
    float3  tb_2 = float3 {_S1213.x, _S1213.y, _S1213.z} + float3 {_S1214.x, _S1214.y, _S1214.z};
    float4  _S1215 = __ldg(&_S1195->rb_0);
    float3  _S1216 = cross_0(tb_2, float3 {_S1215.x, _S1215.y, _S1215.z});
    float4  _S1217 = __ldg(&_S1195->ra_0);
    float3  _S1218 = to_local_0(_S1192, du_0 + (_S1216 - cross_0(ta_2, float3 {_S1217.x, _S1217.y, _S1217.z})));
    *_S1193 = _S1218;
    float3  _S1219 = to_local_0(_S1192, dth_0);
    *_S1194 = _S1219;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_15)
{
    BondStatic_0 * _S1220 = (&(globalParams_0->bonds_0)[i_15]);
    float3  d_lin_3;
    float3  d_ang_3;
    static_kinematics_0(i_15, &d_lin_3, &d_ang_3);
    JointBond_0 _S1221 = slang_ldg_0(&_S1220->law_0);
    JointBond_0 _S1222 = _S1221;
    JointState_0 _S1223 = (&(globalParams_0->bond_dyn_0)[i_15])->js_0;
    JointResponse_0 _S1224 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1221.ids_0.x], &_S1222, &_S1223, d_lin_3, d_ang_3, 0.0f, false);
    return _S1224;
}

static __device__ void gather_loads_0(uint c_18, float3  * fi_1, float3  * mi_0)
{
    float3  _S1225 = make_float3 (0.0f);
    *fi_1 = _S1225;
    *mi_0 = _S1225;
    uint _S1226 = __ldg((&(globalParams_0->index_0)[c_18]));
    uint e_3 = _S1226;
    for(;;)
    {
        uint _S1227 = __ldg((&(globalParams_0->index_0)[c_18 + 1U]));
        if(e_3 < _S1227)
        {
        }
        else
        {
            break;
        }
        uint _S1228 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint bond_1 = _S1228 >> int(1);
        if((_S1228 & 1U) == 0U)
        {
            uint _S1229 = 3U * bond_1;
            float4  _S1230 = *(&(globalParams_0->scratch_0)[_S1229]);
            *fi_1 = *fi_1 + float3 {_S1230.x, _S1230.y, _S1230.z};
            float4  _S1231 = *(&(globalParams_0->scratch_0)[_S1229 + 1U]);
            *mi_0 = *mi_0 + float3 {_S1231.x, _S1231.y, _S1231.z};
        }
        else
        {
            uint _S1232 = 3U * bond_1;
            float4  _S1233 = *(&(globalParams_0->scratch_0)[_S1232]);
            *fi_1 = *fi_1 - float3 {_S1233.x, _S1233.y, _S1233.z};
            float4  _S1234 = *(&(globalParams_0->scratch_0)[_S1232 + 2U]);
            *mi_0 = *mi_0 + float3 {_S1234.x, _S1234.y, _S1234.z};
        }
        e_3 = e_3 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_19)
{
    uint _S1235 = __ldg((&(globalParams_0->index_0)[c_19]));
    uint e_4 = _S1235;
    float m_4 = 0.0f;
    for(;;)
    {
        uint _S1236 = __ldg((&(globalParams_0->index_0)[c_19 + 1U]));
        if(e_4 < _S1236)
        {
        }
        else
        {
            break;
        }
        uint _S1237 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint _S1238 = 3U * (_S1237 >> int(1));
        float4  _S1239 = *(&(globalParams_0->scratch_0)[_S1238]);
        float3  f_11 = float3 {_S1239.x, _S1239.y, _S1239.z};
        float3  t_10;
        if((_S1237 & 1U) == 0U)
        {
            float4  _S1240 = *(&(globalParams_0->scratch_0)[_S1238 + 1U]);
            t_10 = float3 {_S1240.x, _S1240.y, _S1240.z};
        }
        else
        {
            float4  _S1241 = *(&(globalParams_0->scratch_0)[_S1238 + 2U]);
            t_10 = float3 {_S1241.x, _S1241.y, _S1241.z};
        }
        float m_5 = m_4 + (dot_0(f_11, f_11) + dot_0(t_10, t_10));
        e_4 = e_4 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

static __device__ uint fixed_mask_0(uint c_20)
{
    uint4  _S1242 = __ldg(&(&(globalParams_0->chunks_0)[c_20])->info_0);
    uint support_0 = _S1242.x;
    uint _S1243;
    if(support_0 == 1U)
    {
        _S1243 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S1243 = 7U;
        }
        else
        {
            _S1243 = 0U;
        }
    }
    return _S1243;
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

static __device__ void secant_factors_0(JointBond_0 * b_30, JointState_0 * st_2, float3  d_lin_4, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S1244 = st_2->damage_0;
    bool compressed_0 = (d_lin_4.z) < 0.0f;
    float contact_1;
    if(compressed_0)
    {
        contact_1 = _S1244;
    }
    else
    {
        contact_1 = 0.0f;
    }
    float _S1245 = 1.0f - _S1244;
    float _S1246 = (F32_max((_S1245 + contact_1), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_2->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S1245), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S1246, _S1246, normal_4);
    *f_ang_0 = make_float3 (_S1246);
    bool _S1247;
    if((b_30->stiff1_0.w) != 0.0f)
    {
        _S1247 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S1247 = false;
    }
    if(_S1247)
    {
        float4  _S1248 = b_30->rebar0_0;
        float4  _S1249 = b_30->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_30->rebar0_0.x, b_30->stiff0_0.x);
        float _S1250 = fdiv_0(_S1248.y, _S1249.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S1250;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S1250;
    }
    return;
}

static __device__ uint statics_bond_slot_0(uint i_16)
{
    uint _S1251 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1252 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1251 + 23U * _S1252 + 2U * i_16;
}

static __device__ void store_inverse_0(uint c_21, FixedArray<float, 36>  * a_17)
{
    uint j_8;
    float sum_4;
    FixedArray<float, 36>  l_4;
    uint k_15 = 0U;
    for(;;)
    {
        if(k_15 < 36U)
        {
        }
        else
        {
            break;
        }
        l_4[k_15] = 0.0f;
        k_15 = k_15 + 1U;
    }
    bool spd_0 = true;
    uint i_17 = 0U;
    for(;;)
    {
        bool _S1253;
        if(i_17 < 6U)
        {
            _S1253 = spd_0;
        }
        else
        {
            _S1253 = false;
        }
        if(_S1253)
        {
        }
        else
        {
            break;
        }
        j_8 = 0U;
        for(;;)
        {
            if(j_8 <= i_17)
            {
            }
            else
            {
                break;
            }
            uint _S1254 = i_17 * 6U;
            uint _S1255 = _S1254 + j_8;
            k_15 = 0U;
            sum_4 = (*a_17)[_S1255];
            for(;;)
            {
                if(k_15 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1254 + k_15] * l_4[j_8 * 6U + k_15];
                k_15 = k_15 + 1U;
                sum_4 = sum_5;
            }
            if(i_17 == j_8)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1254 + i_17] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1255] = sum_4 / l_4[j_8 * 6U + j_8];
            }
            j_8 = j_8 + 1U;
        }
        i_17 = i_17 + 1U;
    }
    FixedArray<float, 36>  inv_0;
    if(!spd_0)
    {
        k_15 = 0U;
        for(;;)
        {
            if(k_15 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_15] = 0.0f;
            k_15 = k_15 + 1U;
        }
        k_15 = 0U;
        for(;;)
        {
            if(k_15 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1256 = k_15 * 6U + k_15;
            float _S1257 = (*a_17)[_S1256];
            if(((*a_17)[_S1256]) > 0.0f)
            {
                sum_4 = 1.0f / _S1257;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1256] = sum_4;
            k_15 = k_15 + 1U;
        }
    }
    else
    {
        j_8 = 0U;
        for(;;)
        {
            if(j_8 < 6U)
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
            i_17 = 0U;
            for(;;)
            {
                if(i_17 < 6U)
                {
                }
                else
                {
                    break;
                }
                if(i_17 == j_8)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_15 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_15 < i_17)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_4[i_17 * 6U + k_15] * y_6[k_15];
                    k_15 = k_15 + 1U;
                    s_6 = s_7;
                }
                y_6[i_17] = s_6 / l_4[i_17 * 6U + i_17];
                i_17 = i_17 + 1U;
            }
            FixedArray<float, 6>  x_25;
            x_25[int(0)] = 0.0f;
            x_25[int(1)] = 0.0f;
            x_25[int(2)] = 0.0f;
            x_25[int(3)] = 0.0f;
            x_25[int(4)] = 0.0f;
            x_25[int(5)] = 0.0f;
            uint ii_1 = 0U;
            for(;;)
            {
                if(ii_1 < 6U)
                {
                }
                else
                {
                    break;
                }
                uint i_18 = 5U - ii_1;
                k_15 = i_18 + 1U;
                sum_4 = y_6[i_18];
                for(;;)
                {
                    if(k_15 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_4[k_15 * 6U + i_18] * x_25[k_15];
                    k_15 = k_15 + 1U;
                    sum_4 = s_8;
                }
                x_25[i_18] = sum_4 / l_4[i_18 * 6U + i_18];
                ii_1 = ii_1 + 1U;
            }
            uint i_19 = 0U;
            for(;;)
            {
                if(i_19 < 6U)
                {
                }
                else
                {
                    break;
                }
                inv_0[i_19 * 6U + j_8] = x_25[i_19];
                i_19 = i_19 + 1U;
            }
            j_8 = j_8 + 1U;
        }
    }
    j_8 = 0U;
    for(;;)
    {
        if(j_8 < 9U)
        {
        }
        else
        {
            break;
        }
        uint _S1258 = 4U * j_8;
        *(&(globalParams_0->scratch_0)[sv_0(c_21, 12U + j_8)]) = make_float4 (inv_0[_S1258], inv_0[_S1258 + 1U], inv_0[_S1258 + 2U], inv_0[_S1258 + 3U]);
        j_8 = j_8 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_22)
{
    uint p_14;
    uint r_11;
    FixedArray<float, 36>  a_18;
    uint k_16 = 0U;
    for(;;)
    {
        if(k_16 < 36U)
        {
        }
        else
        {
            break;
        }
        a_18[k_16] = 0.0f;
        k_16 = k_16 + 1U;
    }
    uint _S1259 = __ldg((&(globalParams_0->index_0)[c_22]));
    uint e_5 = _S1259;
    for(;;)
    {
        uint _S1260 = __ldg((&(globalParams_0->index_0)[c_22 + 1U]));
        if(e_5 < _S1260)
        {
        }
        else
        {
            break;
        }
        uint _S1261 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint i_20 = _S1261 >> int(1);
        bool _S1262 = (_S1261 & 1U) != 0U;
        BondStatic_0 * _S1263 = (&(globalParams_0->bonds_0)[i_20]);
        uint _S1264 = statics_bond_slot_0(i_20);
        float4  _S1265 = *(&(globalParams_0->scratch_0)[_S1264]);
        float4  _S1266 = *(&(globalParams_0->scratch_0)[_S1264 + 1U]);
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
            uint _S1267 = p_14 % 3U;
            float3  t_11;
            if(_S1267 == 0U)
            {
                float4  _S1268 = __ldg(&_S1263->t1_0);
                t_11 = float3 {_S1268.x, _S1268.y, _S1268.z};
            }
            else
            {
                if(_S1267 == 1U)
                {
                    float4  _S1269 = __ldg(&_S1263->t2_0);
                    t_11 = float3 {_S1269.x, _S1269.y, _S1269.z};
                }
                else
                {
                    float4  _S1270 = __ldg(&_S1263->normal_0);
                    t_11 = float3 {_S1270.x, _S1270.y, _S1270.z};
                }
            }
            bool _S1271 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1271)
            {
                if(_S1262)
                {
                    row_u_0 = t_11;
                }
                else
                {
                    row_u_0 = - t_11;
                }
                if(_S1262)
                {
                    float4  _S1272 = __ldg(&_S1263->rb_0);
                    row_t_0 = cross_0(float3 {_S1272.x, _S1272.y, _S1272.z}, t_11);
                }
                else
                {
                    float4  _S1273 = __ldg(&_S1263->ra_0);
                    row_t_0 = - cross_0(float3 {_S1273.x, _S1273.y, _S1273.z}, t_11);
                }
            }
            else
            {
                float3  _S1274 = make_float3 (0.0f);
                if(_S1262)
                {
                    row_u_0 = t_11;
                }
                else
                {
                    row_u_0 = - t_11;
                }
                float3  _S1275 = row_u_0;
                row_u_0 = _S1274;
                row_t_0 = _S1275;
            }
            float kp_0;
            if(_S1271)
            {
                kp_0 = _slang_vector_get_element(_S1265, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1266, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1276 = { {
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
                uint q_12 = 0U;
                for(;;)
                {
                    if(q_12 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_18[r_11 * 6U + q_12] = a_18[r_11 * 6U + q_12] + kp_0 * _S1276[r_11] * _S1276[q_12];
                    q_12 = q_12 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_5 = e_5 + 1U;
    }
    uint _S1277 = fixed_mask_0(c_22);
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
        if((_S1277 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1278 = a_18;
    store_inverse_0(c_22, &_S1278);
    return;
}

static __device__ float block_get_0(uint c_23, uint i_21, uint j_9)
{
    uint k_17 = i_21 * 6U + j_9;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_23, 12U + k_17 / 4U)]), k_17 % 4U);
}

static __device__ void precondition_0(uint c_24)
{
    float4  * _S1279 = (&(globalParams_0->scratch_0)[sv_0(c_24, 4U)]);
    float4  * _S1280 = (&(globalParams_0->scratch_0)[sv_0(c_24, 5U)]);
    FixedArray<float, 6>  _S1281 = { {
        (*_S1279).x, (*_S1279).y, (*_S1279).z, (*_S1280).x, (*_S1280).y, (*_S1280).z
    } };
    FixedArray<float, 6>  z_1;
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
        uint j_10 = 0U;
        float s_9 = 0.0f;
        for(;;)
        {
            if(j_10 < 6U)
            {
            }
            else
            {
                break;
            }
            float s_10 = s_9 + block_get_0(c_24, i_22, j_10) * _S1281[j_10];
            j_10 = j_10 + 1U;
            s_9 = s_10;
        }
        z_1[i_22] = s_9;
        i_22 = i_22 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_24, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_24, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_14, Island_0 * isl_16, uint slot_4, uint _S1282)
{
    uint _S1283;
    uint _S1284;
    float3  _S1285 = make_float3 (0.0f);
    float3  p_15 = _S1285;
    float3  l_5 = _S1285;
    uint4  _S1286 = isl_16->range_0;
    uint _S1287 = isl_16->range_0.x + tid_14;
    uint c_25 = _S1287;
    uint _S1288 = _S1282;
    for(;;)
    {
        uint _S1289 = _S1286.y;
        _S1283 = _S1289;
        bool _S1290 = c_25 < _S1289;
        uint _S1291 = __ballot_sync(_S1288, _S1290);
        if(_S1290)
        {
            uint _S1292 = __ballot_sync(_S1288, true);
        }
        else
        {
            uint _S1293 = __ballot_sync(_S1288, false);
            uint _S1294 = __ballot_sync(_S1288, false);
            uint _S1295 = __ballot_sync(_S1282, true);
            _S1284 = _S1295;
            break;
        }
        ChunkStatic_0 * _S1296 = (&(globalParams_0->chunks_0)[c_25]);
        float4  _S1297 = *(&(globalParams_0->scratch_0)[sv_0(c_25, slot_4)]);
        float3  u_0 = float3 {_S1297.x, _S1297.y, _S1297.z};
        float4  _S1298 = *(&(globalParams_0->scratch_0)[sv_0(c_25, slot_4 + 1U)]);
        float3  th_2 = float3 {_S1298.x, _S1298.y, _S1298.z};
        float4  _S1299 = __ldg(&_S1296->center_0);
        float4  _S1300 = isl_16->com_0;
        float3  r_12 = float3 {_S1299.x, _S1299.y, _S1299.z} - float3 {_S1300.x, _S1300.y, _S1300.z};
        float _S1301 = _S1299.w;
        p_15 = p_15 + u_0 * make_float3 (_S1301);
        float3  _S1302 = cross_0(r_12, u_0) * make_float3 (_S1301);
        float4  _S1303 = __ldg(&_S1296->inertia0_0);
        float4  _S1304 = __ldg(&_S1296->inertia1_0);
        float4  _S1305 = __ldg(&_S1296->inertia2_0);
        l_5 = l_5 + (_S1302 + rows_mul_0(_S1303, _S1304, _S1305, th_2));
        uint _S1306 = __ballot_sync(_S1288, true);
        c_25 = c_25 + 256U;
        _S1288 = _S1306;
    }
    group_sum3_0(tid_14, &p_15, &l_5, _S1284);
    float4  _S1307 = isl_16->com_0;
    float3  _S1308 = p_15 / make_float3 (isl_16->com_0.w);
    float3  _S1309 = rows_mul_0(isl_16->inv0_1, isl_16->inv1_1, isl_16->inv2_1, l_5);
    c_25 = _S1287;
    for(;;)
    {
        if(c_25 < _S1283)
        {
        }
        else
        {
            break;
        }
        float4  _S1310 = __ldg(&(&(globalParams_0->chunks_0)[c_25])->center_0);
        uint _S1311 = sv_0(c_25, slot_4);
        float4  _S1312 = *(&(globalParams_0->scratch_0)[_S1311]);
        *(&(globalParams_0->scratch_0)[_S1311]) = make_float4 ((float3 {_S1312.x, _S1312.y, _S1312.z} - _S1308 - cross_0(_S1309, float3 {_S1310.x, _S1310.y, _S1310.z} - float3 {_S1307.x, _S1307.y, _S1307.z})).x, (float3 {_S1312.x, _S1312.y, _S1312.z} - _S1308 - cross_0(_S1309, float3 {_S1310.x, _S1310.y, _S1310.z} - float3 {_S1307.x, _S1307.y, _S1307.z})).y, (float3 {_S1312.x, _S1312.y, _S1312.z} - _S1308 - cross_0(_S1309, float3 {_S1310.x, _S1310.y, _S1310.z} - float3 {_S1307.x, _S1307.y, _S1307.z})).z, 0.0f);
        uint _S1313 = sv_0(c_25, slot_4 + 1U);
        float4  _S1314 = *(&(globalParams_0->scratch_0)[_S1313]);
        *(&(globalParams_0->scratch_0)[_S1313]) = make_float4 ((float3 {_S1314.x, _S1314.y, _S1314.z} - _S1309).x, (float3 {_S1314.x, _S1314.y, _S1314.z} - _S1309).y, (float3 {_S1314.x, _S1314.y, _S1314.z} - _S1309).z, 0.0f);
        c_25 = c_25 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1315 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1316 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1317 = _S1315 + 23U * _S1316;
    uint _S1318 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1317 + 2U * _S1318 + island_3;
}

static __device__ float3  to_body_0(uint _S1319, float3  _S1320)
{
    BondStatic_0 * _S1321 = (&(globalParams_0->bonds_0)[_S1319]);
    float4  _S1322 = __ldg(&_S1321->t1_0);
    float3  _S1323 = float3 {_S1322.x, _S1322.y, _S1322.z} * make_float3 (_S1320.x);
    float4  _S1324 = __ldg(&_S1321->t2_0);
    float3  _S1325 = _S1323 + float3 {_S1324.x, _S1324.y, _S1324.z} * make_float3 (_S1320.y);
    float4  _S1326 = __ldg(&_S1321->normal_0);
    return _S1325 + float3 {_S1326.x, _S1326.y, _S1326.z} * make_float3 (_S1320.z);
}

static __device__ void write_bond_loads_0(uint _S1327, uint _S1328, float3  _S1329, float3  _S1330, float _S1331)
{
    BondStatic_0 * _S1332 = (&(globalParams_0->bonds_0)[_S1328]);
    float3  _S1333 = to_body_0(_S1328, _S1329);
    float3  _S1334 = to_body_0(_S1328, _S1330);
    uint _S1335 = 3U * _S1327;
    *(&(globalParams_0->scratch_0)[_S1335]) = make_float4 (_S1333.x, _S1333.y, _S1333.z, _S1331);
    float4  * _S1336 = (&(globalParams_0->scratch_0)[_S1335 + 1U]);
    float4  _S1337 = __ldg(&_S1332->ra_0);
    *_S1336 = make_float4 ((_S1334 + cross_0(float3 {_S1337.x, _S1337.y, _S1337.z}, _S1333)).x, (_S1334 + cross_0(float3 {_S1337.x, _S1337.y, _S1337.z}, _S1333)).y, (_S1334 + cross_0(float3 {_S1337.x, _S1337.y, _S1337.z}, _S1333)).z, 0.0f);
    float4  * _S1338 = (&(globalParams_0->scratch_0)[_S1335 + 2U]);
    float3  _S1339 = - _S1334;
    float4  _S1340 = __ldg(&_S1332->rb_0);
    *_S1338 = make_float4 ((_S1339 + cross_0(float3 {_S1340.x, _S1340.y, _S1340.z}, - _S1333)).x, (_S1339 + cross_0(float3 {_S1340.x, _S1340.y, _S1340.z}, - _S1333)).y, (_S1339 + cross_0(float3 {_S1340.x, _S1340.y, _S1340.z}, - _S1333)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1341, float3  _S1342, float3  _S1343, float3  _S1344, float3  _S1345, float3  * _S1346, float3  * _S1347)
{
    BondStatic_0 * _S1348 = (&(globalParams_0->bonds_0)[_S1341]);
    float4  _S1349 = __ldg(&_S1348->rb_0);
    float3  _S1350 = _S1344 + cross_0(_S1345, float3 {_S1349.x, _S1349.y, _S1349.z});
    float4  _S1351 = __ldg(&_S1348->ra_0);
    float3  _S1352 = to_local_0(_S1341, _S1350 - (_S1342 + cross_0(_S1343, float3 {_S1351.x, _S1351.y, _S1351.z})));
    *_S1346 = _S1352;
    float3  _S1353 = to_local_0(_S1341, _S1345 - _S1343);
    *_S1347 = _S1353;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S1354 = 0U;
    uint _S1355;
    uint i_23;
    uint c_26;
    bool converged_2;
    uint _S1356;
    uint _S1357;
    uint _S1358;
    uint _S1359;
    uint _S1360;
    uint _S1361;
    uint i_24;
    uint _S1362;
    uint _S1363;
    uint _S1364;
    uint _S1365;
    uint _S1366;
    uint _S1367 = __ballot_sync(4294967295U, true);
    uint tid_15 = threadIdx.x;
    uint _S1368 = blockIdx.x;
    Island_0 * _S1369 = (&(globalParams_0->islands_0)[_S1368]);
    Island_0 isl_17 = *_S1369;
    uint _S1370 = (*_S1369).info_1.z;
    bool _S1371 = (_S1370 & 8U) == 0U;
    uint _S1372 = __ballot_sync(_S1367, _S1371);
    if(_S1371)
    {
        return;
    }
    else
    {
        uint _S1373 = __ballot_sync(_S1367, true);
        _S1354 = _S1373;
    }
    bool free_0 = ((isl_17.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_17.range_0.x;
    uint c1_1 = isl_17.range_0.y;
    uint b0_0 = isl_17.range_0.z;
    uint _S1374 = isl_17.range_0.w;
    uint _S1375 = c0_1 + tid_15;
    uint c_27 = _S1375;
    uint newton_0;
    newton_0 = _S1354;
    for(;;)
    {
        bool _S1376 = c_27 < c1_1;
        uint _S1377 = __ballot_sync(newton_0, _S1376);
        if(_S1376)
        {
            uint _S1378 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S1379 = __ballot_sync(newton_0, false);
            uint _S1380 = __ballot_sync(newton_0, false);
            uint _S1381 = __ballot_sync(_S1354, true);
            _S1355 = _S1381;
            break;
        }
        float4  _S1382 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_27, 21U)]) = _S1382;
        *(&(globalParams_0->scratch_0)[sv_0(c_27, 22U)]) = _S1382;
        uint _S1383 = __ballot_sync(newton_0, true);
        c_27 = c_27 + 256U;
        newton_0 = _S1383;
    }
    __syncthreads();
    uint _S1384 = __ballot_sync(_S1355, free_0);
    if(free_0)
    {
        Island_0 _S1385 = isl_17;
        project_load_slot_0(tid_15, &_S1385, 0U, _S1384);
        uint _S1386 = __ballot_sync(_S1355, true);
        c_27 = _S1386;
    }
    else
    {
        uint _S1387 = __ballot_sync(_S1355, true);
        c_27 = _S1387;
    }
    float _S1388 = island_dot_0(tid_15, c0_1, c1_1, 0U, 0U, c_27);
    float _S1389 = (F32_max(((F32_sqrt((_S1388)))), (1.00000000317107685e-30f)));
    float _S1390 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S1391 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S1392 = (U32_min((_S1391), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_1 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S1393 = 0U;
        uint _S1394 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S1395 = newton_0 < _S1394;
        uint _S1396 = __ballot_sync(c_27, _S1395);
        if(_S1395)
        {
            uint _S1397 = __ballot_sync(c_27, true);
            _S1393 = _S1397;
        }
        else
        {
            converged_2 = false;
            break;
        }
        uint _S1398 = b0_0 + tid_15;
        i_23 = _S1398;
        uint _S1399;
        _S1399 = _S1393;
        for(;;)
        {
            bool _S1400 = i_23 < _S1374;
            uint _S1401 = __ballot_sync(_S1399, _S1400);
            if(_S1400)
            {
                uint _S1402 = __ballot_sync(_S1399, true);
            }
            else
            {
                uint _S1403 = __ballot_sync(_S1399, false);
                uint _S1404 = __ballot_sync(_S1399, false);
                uint _S1405 = __ballot_sync(_S1393, true);
                _S1356 = _S1405;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_23);
            write_bond_loads_0(i_23, i_23, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S1406 = __ballot_sync(_S1399, true);
            i_23 = i_23 + 256U;
            _S1399 = _S1406;
        }
        __syncthreads();
        float4  _S1407 = make_float4 (0.0f);
        float4  magnitude_0 = _S1407;
        float4  unused_m_0 = _S1407;
        uint c_28 = _S1375;
        uint _S1408 = _S1356;
        for(;;)
        {
            bool _S1409 = c_28 < c1_1;
            uint _S1410 = __ballot_sync(_S1408, _S1409);
            if(_S1409)
            {
                uint _S1411 = __ballot_sync(_S1408, true);
            }
            else
            {
                uint _S1412 = __ballot_sync(_S1408, false);
                uint _S1413 = __ballot_sync(_S1408, false);
                uint _S1414 = __ballot_sync(_S1356, true);
                _S1357 = _S1414;
                break;
            }
            float3  fi_2;
            float3  mi_1;
            gather_loads_0(c_28, &fi_2, &mi_1);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_28);
            float4  _S1415 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1415.x, _S1415.y, _S1415.z} + fi_2).x, (float3 {_S1415.x, _S1415.y, _S1415.z} + fi_2).y, (float3 {_S1415.x, _S1415.y, _S1415.z} + fi_2).z, 0.0f);
            float4  _S1416 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1416.x, _S1416.y, _S1416.z} + mi_1).x, (float3 {_S1416.x, _S1416.y, _S1416.z} + mi_1).y, (float3 {_S1416.x, _S1416.y, _S1416.z} + mi_1).z, 0.0f);
            hold_0(fixed_mask_0(c_28), &r_lin_0, &r_ang_0, _S1407, _S1407);
            *(&(globalParams_0->scratch_0)[sv_0(c_28, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_28, 5U)]) = r_ang_0;
            uint _S1417 = __ballot_sync(_S1408, true);
            c_28 = c_28 + 256U;
            _S1408 = _S1417;
        }
        __syncthreads();
        group_sum2_0(tid_15, &magnitude_0, &unused_m_0, _S1357);
        uint _S1418 = __ballot_sync(_S1357, free_0);
        uint _S1419;
        if(free_0)
        {
            Island_0 _S1420 = isl_17;
            project_load_slot_0(tid_15, &_S1420, 4U, _S1418);
            uint _S1421 = __ballot_sync(_S1357, true);
            _S1419 = _S1421;
        }
        else
        {
            uint _S1422 = __ballot_sync(_S1357, true);
            _S1419 = _S1422;
        }
        float _S1423 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1419);
        float residual_1 = (F32_sqrt((_S1423))) / _S1389;
        float _S1424 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S1389)));
        bool _S1425 = residual_1 <= _S1390;
        uint _S1426 = __ballot_sync(_S1419, _S1425);
        uint _S1427;
        if(_S1425)
        {
            uint _S1428 = __ballot_sync(_S1419, true);
            converged_2 = true;
            _S1427 = _S1428;
        }
        else
        {
            uint _S1429 = _S1419 & (~_S1426);
            bool _S1430 = residual_1 <= _S1424;
            uint _S1431 = __ballot_sync(_S1429, _S1430);
            if(_S1430)
            {
                bool _S1432 = residual_1 > (0.5f * previous_1);
                uint _S1433 = __ballot_sync(_S1429, true);
                converged_2 = _S1432;
            }
            else
            {
                uint _S1434 = __ballot_sync(_S1429, true);
                converged_2 = false;
            }
            uint _S1435 = __ballot_sync(_S1419, true);
            _S1427 = _S1435;
        }
        uint _S1436 = 0U;
        uint _S1437 = __ballot_sync(_S1427, converged_2);
        if(converged_2)
        {
            residual_0 = residual_1;
            converged_2 = true;
            break;
        }
        else
        {
            uint _S1438 = __ballot_sync(_S1427, true);
            _S1436 = _S1438;
        }
        uint i_25 = _S1398;
        uint _S1439;
        _S1439 = _S1436;
        for(;;)
        {
            bool _S1440 = i_25 < _S1374;
            uint _S1441 = __ballot_sync(_S1439, _S1440);
            if(_S1440)
            {
                uint _S1442 = __ballot_sync(_S1439, true);
            }
            else
            {
                uint _S1443 = __ballot_sync(_S1439, false);
                uint _S1444 = __ballot_sync(_S1439, false);
                uint _S1445 = __ballot_sync(_S1436, true);
                _S1358 = _S1445;
                break;
            }
            BondStatic_0 * _S1446 = (&(globalParams_0->bonds_0)[i_25]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_25, &d_lin_5, &d_ang_4);
            JointBond_0 _S1447 = slang_ldg_0(&_S1446->law_0);
            JointBond_0 _S1448 = _S1447;
            JointState_0 _S1449 = (&(globalParams_0->bond_dyn_0)[i_25])->js_0;
            float3  f_lin_1;
            float3  f_ang_1;
            secant_factors_0(&_S1448, &_S1449, d_lin_5, &f_lin_1, &f_ang_1);
            uint _S1450 = statics_bond_slot_0(i_25);
            float _S1451 = _S1447.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S1450]) = make_float4 (_S1451 * f_lin_1.x, _S1451 * f_lin_1.y, _S1447.stiff0_0.x * f_lin_1.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1450 + 1U]) = make_float4 (_S1447.stiff0_0.z * f_ang_1.x, _S1447.stiff0_0.w * f_ang_1.y, _S1447.stiff1_0.x * f_ang_1.z, 0.0f);
            uint _S1452 = __ballot_sync(_S1439, true);
            i_25 = i_25 + 256U;
            _S1439 = _S1452;
        }
        __syncthreads();
        uint c_29 = _S1375;
        uint _S1453 = _S1358;
        for(;;)
        {
            bool _S1454 = c_29 < c1_1;
            uint _S1455 = __ballot_sync(_S1453, _S1454);
            if(_S1454)
            {
                uint _S1456 = __ballot_sync(_S1453, true);
            }
            else
            {
                uint _S1457 = __ballot_sync(_S1453, false);
                uint _S1458 = __ballot_sync(_S1453, false);
                uint _S1459 = __ballot_sync(_S1358, true);
                _S1359 = _S1459;
                break;
            }
            assemble_block_0(c_29);
            *(&(globalParams_0->scratch_0)[sv_0(c_29, 2U)]) = _S1407;
            *(&(globalParams_0->scratch_0)[sv_0(c_29, 3U)]) = _S1407;
            uint _S1460 = __ballot_sync(_S1453, true);
            c_29 = c_29 + 256U;
            _S1453 = _S1460;
        }
        __syncthreads();
        uint c_30 = _S1375;
        uint _S1461 = _S1359;
        for(;;)
        {
            bool _S1462 = c_30 < c1_1;
            uint _S1463 = __ballot_sync(_S1461, _S1462);
            if(_S1462)
            {
                uint _S1464 = __ballot_sync(_S1461, true);
            }
            else
            {
                uint _S1465 = __ballot_sync(_S1461, false);
                uint _S1466 = __ballot_sync(_S1461, false);
                uint _S1467 = __ballot_sync(_S1359, true);
                _S1360 = _S1467;
                break;
            }
            precondition_0(c_30);
            uint _S1468 = __ballot_sync(_S1461, true);
            c_30 = c_30 + 256U;
            _S1461 = _S1468;
        }
        __syncthreads();
        uint _S1469 = __ballot_sync(_S1360, free_0);
        uint _S1470;
        if(free_0)
        {
            Island_0 _S1471 = isl_17;
            project_displacement_slot_0(tid_15, &_S1471, 6U, _S1469);
            uint _S1472 = __ballot_sync(_S1360, true);
            _S1470 = _S1472;
        }
        else
        {
            uint _S1473 = __ballot_sync(_S1360, true);
            _S1470 = _S1473;
        }
        uint c_31 = _S1375;
        uint _S1474 = _S1470;
        for(;;)
        {
            bool _S1475 = c_31 < c1_1;
            uint _S1476 = __ballot_sync(_S1474, _S1475);
            if(_S1475)
            {
                uint _S1477 = __ballot_sync(_S1474, true);
            }
            else
            {
                uint _S1478 = __ballot_sync(_S1474, false);
                uint _S1479 = __ballot_sync(_S1474, false);
                uint _S1480 = __ballot_sync(_S1470, true);
                _S1361 = _S1480;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_31, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_31, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_31, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_31, 7U)]);
            uint _S1481 = __ballot_sync(_S1474, true);
            c_31 = c_31 + 256U;
            _S1474 = _S1481;
        }
        __syncthreads();
        float _S1482 = island_dot_0(tid_15, c0_1, c1_1, 4U, 6U, _S1361);
        float _S1483 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1361);
        float _S1484 = (F32_sqrt((_S1483)));
        float rz_0 = _S1482;
        uint k_18 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1485 = _S1361;
        for(;;)
        {
            bool _S1486 = k_18 < _S1392;
            uint _S1487 = __ballot_sync(_S1485, _S1486);
            uint _S1488;
            bool _S1489;
            if(_S1486)
            {
                bool _S1490 = _S1484 > 0.0f;
                uint _S1491 = __ballot_sync(_S1485, true);
                _S1489 = _S1490;
                _S1488 = _S1491;
            }
            else
            {
                uint _S1492 = __ballot_sync(_S1485, true);
                _S1489 = false;
                _S1488 = _S1492;
            }
            uint _S1493 = 0U;
            uint _S1494 = __ballot_sync(_S1488, _S1489);
            if(_S1489)
            {
                uint _S1495 = __ballot_sync(_S1488, true);
                _S1493 = _S1495;
            }
            else
            {
                uint _S1496 = __ballot_sync(_S1488, false);
                uint _S1497 = __ballot_sync(_S1485, false);
                uint _S1498 = __ballot_sync(_S1361, true);
                cg_total_0 = cg_total_1;
                i_24 = _S1498;
                break;
            }
            i_24 = _S1398;
            _S1362 = _S1493;
            for(;;)
            {
                bool _S1499 = i_24 < _S1374;
                uint _S1500 = __ballot_sync(_S1362, _S1499);
                if(_S1499)
                {
                    uint _S1501 = __ballot_sync(_S1362, true);
                }
                else
                {
                    uint _S1502 = __ballot_sync(_S1362, false);
                    uint _S1503 = __ballot_sync(_S1362, false);
                    uint _S1504 = __ballot_sync(_S1493, true);
                    _S1363 = _S1504;
                    break;
                }
                JointBond_0 _S1505 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_24])->law_0);
                uint ca_1 = _S1505.ids_0.y;
                uint cb_1 = _S1505.ids_0.z;
                float4  _S1506 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 8U)]);
                float4  _S1507 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 9U)]);
                float4  _S1508 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 8U)]);
                float4  _S1509 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_24, float3 {_S1506.x, _S1506.y, _S1506.z}, float3 {_S1507.x, _S1507.y, _S1507.z}, float3 {_S1508.x, _S1508.y, _S1508.z}, float3 {_S1509.x, _S1509.y, _S1509.z}, &d_lin_6, &d_ang_5);
                uint _S1510 = statics_bond_slot_0(i_24);
                float4  _S1511 = *(&(globalParams_0->scratch_0)[_S1510]);
                float4  _S1512 = *(&(globalParams_0->scratch_0)[_S1510 + 1U]);
                write_bond_loads_0(i_24, i_24, d_lin_6 * float3 {_S1511.x, _S1511.y, _S1511.z}, d_ang_5 * float3 {_S1512.x, _S1512.y, _S1512.z}, 0.0f);
                uint _S1513 = __ballot_sync(_S1362, true);
                i_24 = i_24 + 256U;
                _S1362 = _S1513;
            }
            __syncthreads();
            c_26 = _S1375;
            uint _S1514 = _S1363;
            for(;;)
            {
                bool _S1515 = c_26 < c1_1;
                uint _S1516 = __ballot_sync(_S1514, _S1515);
                if(_S1515)
                {
                    uint _S1517 = __ballot_sync(_S1514, true);
                }
                else
                {
                    uint _S1518 = __ballot_sync(_S1514, false);
                    uint _S1519 = __ballot_sync(_S1514, false);
                    uint _S1520 = __ballot_sync(_S1363, true);
                    _S1364 = _S1520;
                    break;
                }
                float3  fi_3;
                float3  mi_2;
                gather_loads_0(c_26, &fi_3, &mi_2);
                float4  ap_lin_0 = make_float4 ((- fi_3).x, (- fi_3).y, (- fi_3).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_2).x, (- mi_2).y, (- mi_2).z, 0.0f);
                hold_0(fixed_mask_0(c_26), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_26, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_26, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_26, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_26, 11U)]) = ap_ang_0;
                uint _S1521 = __ballot_sync(_S1514, true);
                c_26 = c_26 + 256U;
                _S1514 = _S1521;
            }
            uint _S1522 = 0U;
            __syncthreads();
            float _S1523 = island_dot_0(tid_15, c0_1, c1_1, 8U, 10U, _S1364);
            uint _S1524 = cg_total_1 + 1U;
            bool _S1525 = _S1523 <= 0.0f;
            uint _S1526 = __ballot_sync(_S1364, _S1525);
            if(_S1525)
            {
                uint _S1527 = __ballot_sync(_S1364, false);
                uint _S1528 = __ballot_sync(_S1485, false);
                uint _S1529 = __ballot_sync(_S1361, true);
                cg_total_0 = _S1524;
                i_24 = _S1529;
                break;
            }
            else
            {
                uint _S1530 = __ballot_sync(_S1364, true);
                _S1522 = _S1530;
            }
            float _S1531 = rz_0 / _S1523;
            uint c_32 = _S1375;
            uint _S1532;
            _S1532 = _S1522;
            for(;;)
            {
                bool _S1533 = c_32 < c1_1;
                uint _S1534 = __ballot_sync(_S1532, _S1533);
                if(_S1533)
                {
                    uint _S1535 = __ballot_sync(_S1532, true);
                }
                else
                {
                    uint _S1536 = __ballot_sync(_S1532, false);
                    uint _S1537 = __ballot_sync(_S1532, false);
                    uint _S1538 = __ballot_sync(_S1522, true);
                    _S1365 = _S1538;
                    break;
                }
                uint _S1539 = sv_0(c_32, 2U);
                float4  _S1540 = *(&(globalParams_0->scratch_0)[_S1539]);
                float4  _S1541 = *(&(globalParams_0->scratch_0)[sv_0(c_32, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1539]) = make_float4 ((float3 {_S1540.x, _S1540.y, _S1540.z} + make_float3 (_S1531) * float3 {_S1541.x, _S1541.y, _S1541.z}).x, (float3 {_S1540.x, _S1540.y, _S1540.z} + make_float3 (_S1531) * float3 {_S1541.x, _S1541.y, _S1541.z}).y, (float3 {_S1540.x, _S1540.y, _S1540.z} + make_float3 (_S1531) * float3 {_S1541.x, _S1541.y, _S1541.z}).z, 0.0f);
                uint _S1542 = sv_0(c_32, 3U);
                float4  _S1543 = *(&(globalParams_0->scratch_0)[_S1542]);
                float4  _S1544 = *(&(globalParams_0->scratch_0)[sv_0(c_32, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1542]) = make_float4 ((float3 {_S1543.x, _S1543.y, _S1543.z} + make_float3 (_S1531) * float3 {_S1544.x, _S1544.y, _S1544.z}).x, (float3 {_S1543.x, _S1543.y, _S1543.z} + make_float3 (_S1531) * float3 {_S1544.x, _S1544.y, _S1544.z}).y, (float3 {_S1543.x, _S1543.y, _S1543.z} + make_float3 (_S1531) * float3 {_S1544.x, _S1544.y, _S1544.z}).z, 0.0f);
                uint _S1545 = sv_0(c_32, 4U);
                float4  _S1546 = *(&(globalParams_0->scratch_0)[_S1545]);
                float4  _S1547 = *(&(globalParams_0->scratch_0)[sv_0(c_32, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1545]) = make_float4 ((float3 {_S1546.x, _S1546.y, _S1546.z} - make_float3 (_S1531) * float3 {_S1547.x, _S1547.y, _S1547.z}).x, (float3 {_S1546.x, _S1546.y, _S1546.z} - make_float3 (_S1531) * float3 {_S1547.x, _S1547.y, _S1547.z}).y, (float3 {_S1546.x, _S1546.y, _S1546.z} - make_float3 (_S1531) * float3 {_S1547.x, _S1547.y, _S1547.z}).z, 0.0f);
                uint _S1548 = sv_0(c_32, 5U);
                float4  _S1549 = *(&(globalParams_0->scratch_0)[_S1548]);
                float4  _S1550 = *(&(globalParams_0->scratch_0)[sv_0(c_32, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1548]) = make_float4 ((float3 {_S1549.x, _S1549.y, _S1549.z} - make_float3 (_S1531) * float3 {_S1550.x, _S1550.y, _S1550.z}).x, (float3 {_S1549.x, _S1549.y, _S1549.z} - make_float3 (_S1531) * float3 {_S1550.x, _S1550.y, _S1550.z}).y, (float3 {_S1549.x, _S1549.y, _S1549.z} - make_float3 (_S1531) * float3 {_S1550.x, _S1550.y, _S1550.z}).z, 0.0f);
                uint _S1551 = __ballot_sync(_S1532, true);
                c_32 = c_32 + 256U;
                _S1532 = _S1551;
            }
            uint _S1552 = 0U;
            __syncthreads();
            float _S1553 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1365);
            bool _S1554 = (F32_sqrt((_S1553))) <= (0.00009999999747379f * _S1484);
            uint _S1555 = __ballot_sync(_S1365, _S1554);
            if(_S1554)
            {
                uint _S1556 = __ballot_sync(_S1365, false);
                uint _S1557 = __ballot_sync(_S1485, false);
                uint _S1558 = __ballot_sync(_S1361, true);
                cg_total_0 = _S1524;
                i_24 = _S1558;
                break;
            }
            else
            {
                uint _S1559 = __ballot_sync(_S1365, true);
                _S1552 = _S1559;
            }
            uint c_33 = _S1375;
            uint _S1560;
            _S1560 = _S1552;
            for(;;)
            {
                bool _S1561 = c_33 < c1_1;
                uint _S1562 = __ballot_sync(_S1560, _S1561);
                if(_S1561)
                {
                    uint _S1563 = __ballot_sync(_S1560, true);
                }
                else
                {
                    uint _S1564 = __ballot_sync(_S1560, false);
                    uint _S1565 = __ballot_sync(_S1560, false);
                    uint _S1566 = __ballot_sync(_S1552, true);
                    _S1366 = _S1566;
                    break;
                }
                precondition_0(c_33);
                uint _S1567 = __ballot_sync(_S1560, true);
                c_33 = c_33 + 256U;
                _S1560 = _S1567;
            }
            __syncthreads();
            uint _S1568 = __ballot_sync(_S1366, free_0);
            uint _S1569;
            if(free_0)
            {
                Island_0 _S1570 = isl_17;
                project_displacement_slot_0(tid_15, &_S1570, 6U, _S1568);
                uint _S1571 = __ballot_sync(_S1366, true);
                _S1569 = _S1571;
            }
            else
            {
                uint _S1572 = __ballot_sync(_S1366, true);
                _S1569 = _S1572;
            }
            float _S1573 = island_dot_0(tid_15, c0_1, c1_1, 4U, 6U, _S1569);
            float _S1574 = _S1573 / rz_0;
            uint c_34 = _S1375;
            uint _S1575 = _S1569;
            for(;;)
            {
                bool _S1576 = c_34 < c1_1;
                uint _S1577 = __ballot_sync(_S1575, _S1576);
                if(_S1576)
                {
                    uint _S1578 = __ballot_sync(_S1575, true);
                }
                else
                {
                    uint _S1579 = __ballot_sync(_S1575, false);
                    uint _S1580 = __ballot_sync(_S1575, false);
                    uint _S1581 = __ballot_sync(_S1569, true);
                    break;
                }
                uint _S1582 = sv_0(c_34, 8U);
                float4  _S1583 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 6U)]);
                float4  _S1584 = *(&(globalParams_0->scratch_0)[_S1582]);
                *(&(globalParams_0->scratch_0)[_S1582]) = make_float4 ((float3 {_S1583.x, _S1583.y, _S1583.z} + make_float3 (_S1574) * float3 {_S1584.x, _S1584.y, _S1584.z}).x, (float3 {_S1583.x, _S1583.y, _S1583.z} + make_float3 (_S1574) * float3 {_S1584.x, _S1584.y, _S1584.z}).y, (float3 {_S1583.x, _S1583.y, _S1583.z} + make_float3 (_S1574) * float3 {_S1584.x, _S1584.y, _S1584.z}).z, 0.0f);
                uint _S1585 = sv_0(c_34, 9U);
                float4  _S1586 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 7U)]);
                float4  _S1587 = *(&(globalParams_0->scratch_0)[_S1585]);
                *(&(globalParams_0->scratch_0)[_S1585]) = make_float4 ((float3 {_S1586.x, _S1586.y, _S1586.z} + make_float3 (_S1574) * float3 {_S1587.x, _S1587.y, _S1587.z}).x, (float3 {_S1586.x, _S1586.y, _S1586.z} + make_float3 (_S1574) * float3 {_S1587.x, _S1587.y, _S1587.z}).y, (float3 {_S1586.x, _S1586.y, _S1586.z} + make_float3 (_S1574) * float3 {_S1587.x, _S1587.y, _S1587.z}).z, 0.0f);
                uint _S1588 = __ballot_sync(_S1575, true);
                c_34 = c_34 + 256U;
                _S1575 = _S1588;
            }
            __syncthreads();
            uint _S1589 = __ballot_sync(_S1485, true);
            uint _S1590 = k_18 + 1U;
            rz_0 = _S1573;
            k_18 = _S1590;
            cg_total_1 = _S1524;
            _S1485 = _S1589;
        }
        c_26 = _S1375;
        _S1362 = i_24;
        for(;;)
        {
            bool _S1591 = c_26 < c1_1;
            uint _S1592 = __ballot_sync(_S1362, _S1591);
            if(_S1591)
            {
                uint _S1593 = __ballot_sync(_S1362, true);
            }
            else
            {
                uint _S1594 = __ballot_sync(_S1362, false);
                uint _S1595 = __ballot_sync(_S1362, false);
                uint _S1596 = __ballot_sync(i_24, true);
                break;
            }
            uint _S1597 = 4U * c_26;
            float4  _S1598 = *(&(globalParams_0->state_0)[_S1597]);
            float3  u_1 = float3 {_S1598.x, _S1598.y, _S1598.z};
            uint _S1599 = sv_0(c_26, 21U);
            float4  _S1600 = *(&(globalParams_0->scratch_0)[_S1599]);
            float3  u_lo_0 = float3 {_S1600.x, _S1600.y, _S1600.z};
            uint _S1601 = _S1597 + 1U;
            float4  _S1602 = *(&(globalParams_0->state_0)[_S1601]);
            float3  th_3 = float3 {_S1602.x, _S1602.y, _S1602.z};
            uint _S1603 = sv_0(c_26, 22U);
            float4  _S1604 = *(&(globalParams_0->scratch_0)[_S1603]);
            float3  th_lo_0 = float3 {_S1604.x, _S1604.y, _S1604.z};
            float4  _S1605 = *(&(globalParams_0->scratch_0)[sv_0(c_26, 2U)]);
            comp_add_0(&u_1, &u_lo_0, float3 {_S1605.x, _S1605.y, _S1605.z});
            float4  _S1606 = *(&(globalParams_0->scratch_0)[sv_0(c_26, 3U)]);
            comp_add_0(&th_3, &th_lo_0, float3 {_S1606.x, _S1606.y, _S1606.z});
            *(&(globalParams_0->state_0)[_S1597]) = make_float4 (u_1.x, u_1.y, u_1.z, (*(&(globalParams_0->state_0)[_S1597])).w);
            *(&(globalParams_0->state_0)[_S1601]) = make_float4 (th_3.x, th_3.y, th_3.z, (*(&(globalParams_0->state_0)[_S1601])).w);
            *(&(globalParams_0->scratch_0)[_S1599]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1603]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1607 = __ballot_sync(_S1362, true);
            c_26 = c_26 + 256U;
            _S1362 = _S1607;
        }
        __syncthreads();
        uint _S1608 = newton_0 + 1U;
        uint _S1609 = __ballot_sync(c_27, true);
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1608;
        c_27 = _S1609;
    }
    i_23 = b0_0 + tid_15;
    for(;;)
    {
        if(i_23 < _S1374)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_23);
        BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_23]);
        (&bd_0)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_3);
        (&bd_0)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_0)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_23]) = bd_0;
        write_bond_loads_0(i_23, i_23, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_23 = i_23 + 256U;
    }
    __syncthreads();
    c_26 = _S1375;
    for(;;)
    {
        if(c_26 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_4;
        float3  mi_3;
        gather_loads_0(c_26, &fi_4, &mi_3);
        float3  reaction_0;
        if((fixed_mask_0(c_26)) != 0U)
        {
            float4  _S1610 = *(&(globalParams_0->scratch_0)[sv_0(c_26, 0U)]);
            reaction_0 = - (float3 {_S1610.x, _S1610.y, _S1610.z} + fi_4);
        }
        else
        {
            uint _S1611 = 4U * c_26;
            reaction_0 = make_float3 ((*(&(globalParams_0->state_0)[_S1611 + 1U])).w, (*(&(globalParams_0->state_0)[_S1611 + 2U])).w, (*(&(globalParams_0->state_0)[_S1611 + 3U])).w);
        }
        uint _S1612 = 4U * c_26;
        uint _S1613 = _S1612 + 1U;
        float4  _S1614 = *(&(globalParams_0->state_0)[_S1613]);
        *(&(globalParams_0->state_0)[_S1613]) = make_float4 (float3 {_S1614.x, _S1614.y, _S1614.z}.x, float3 {_S1614.x, _S1614.y, _S1614.z}.y, float3 {_S1614.x, _S1614.y, _S1614.z}.z, reaction_0.x);
        *(&(globalParams_0->state_0)[_S1612 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.y);
        *(&(globalParams_0->state_0)[_S1612 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.z);
        c_26 = c_26 + 256U;
    }
    if(tid_15 == 0U)
    {
        float4  * _S1615 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S1368)]);
        float _S1616 = (U32_asfloat((newton_0)));
        float _S1617 = (U32_asfloat((cg_total_0)));
        if(converged_2)
        {
            previous_1 = 1.0f;
        }
        else
        {
            previous_1 = 0.0f;
        }
        *_S1615 = make_float4 (residual_0, _S1616, _S1617, previous_1);
        *&((&(&(globalParams_0->islands_0)[_S1368])->info_1)->z) = _S1370 & 4294967287U;
    }
    return;
}

__device__ __shared__ uint g_halt_0;

__device__ __shared__ uint g_run_0;

static __device__ bool is_damaged_0(JointState_0 * st_3)
{
    bool _S1618;
    if((st_3->damage_0) > 0.0f)
    {
        _S1618 = true;
    }
    else
    {
        _S1618 = (st_3->crush_0) > 0.0f;
    }
    return _S1618;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_16 = threadIdx.x;
    uint _S1619 = blockIdx.x;
    Island_0 * _S1620 = (&(globalParams_0->islands_0)[_S1619]);
    Island_0 isl_18 = *_S1620;
    bool _S1621;
    if((((*_S1620).info_1.x) & 16U) == 0U)
    {
        _S1621 = true;
    }
    else
    {
        _S1621 = (isl_18.range_0.w) == (isl_18.range_0.z);
    }
    if(_S1621)
    {
        return;
    }
    seen_clear_0(tid_16);
    if(tid_16 == 0U)
    {
        *&g_halt_0 = 0U;
        *&g_run_0 = 0U;
    }
    __syncthreads();
    uint _S1622 = isl_18.info_1.w;
    uint i_26 = isl_18.range_0.z + tid_16;
    for(;;)
    {
        if(i_26 < (isl_18.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S1623 = (&(globalParams_0->bonds_0)[i_26]);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_26]);
        JointBond_0 _S1624 = slang_ldg_0(&_S1623->law_0);
        uint _S1625 = 4U * _S1624.ids_0.y;
        float4  _S1626 = *(&(globalParams_0->state_0)[_S1625]);
        float4  _S1627 = *(&(globalParams_0->state_0)[_S1625 + 1U]);
        uint _S1628 = 4U * _S1624.ids_0.z;
        float4  _S1629 = *(&(globalParams_0->state_0)[_S1628]);
        float4  _S1630 = *(&(globalParams_0->state_0)[_S1628 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_26, float3 {_S1626.x, _S1626.y, _S1626.z}, float3 {_S1627.x, _S1627.y, _S1627.z}, float3 {_S1629.x, _S1629.y, _S1629.z}, float3 {_S1630.x, _S1630.y, _S1630.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_2 = (&bd_1)->js_0;
        float3  _S1631 = d_lin_7;
        float3  _S1632 = d_ang_6;
        float _S1633 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S1634 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S1635 = _S1634 != 0U;
        JointBond_0 _S1636 = _S1624;
        JointState_0 _S1637 = previous_2;
        JointResponse_0 _S1638 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1624.ids_0.x], &_S1636, &_S1637, _S1631, _S1632, _S1633, _S1635);
        if((_S1638.state_1.damage_0) > (previous_2.damage_0 + 9.99999971718068537e-10f))
        {
            _S1621 = true;
        }
        else
        {
            _S1621 = (_S1638.state_1.crush_0) > (previous_2.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S1621)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_1)->sums_0)->x), &((&(&bd_1)->comps_0)->x), _S1638.dissipated_2);
        comp_add1_0(&((&(&bd_1)->sums_0)->y), &((&(&bd_1)->comps_0)->y), _S1638.overshoot_0);
        (&bd_1)->force_lin_0 = make_float4 (_S1638.force_lin_1.x, _S1638.force_lin_1.y, _S1638.force_lin_1.z, _S1638.stored_3);
        (&bd_1)->force_ang_0 = make_float4 (_S1638.force_ang_1.x, _S1638.force_ang_1.y, _S1638.force_ang_1.z, (F32_max(((&bd_1)->force_ang_0.w), (_S1638.state_1.utilization_0))));
        JointState_0 _S1639 = previous_2;
        bool _S1640 = is_damaged_0(&_S1639);
        bool _S1641;
        if(!_S1640)
        {
            JointState_0 _S1642 = _S1638.state_1;
            bool _S1643 = is_damaged_0(&_S1642);
            _S1641 = _S1643;
        }
        else
        {
            _S1641 = false;
        }
        bool _S1644;
        if(_S1641)
        {
            _S1644 = ((&bd_1)->events_0.x) == 0U;
        }
        else
        {
            _S1644 = false;
        }
        if(_S1644)
        {
            *&((&(&bd_1)->events_0)->x) = _S1622;
            *&((&(&bd_1)->events_0)->w) = _S1638.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S1645;
        if(((&bd_1)->events_0.y) == 0U)
        {
            _S1645 = (_S1638.state_1.life_0) != (previous_2.life_0);
        }
        else
        {
            _S1645 = false;
        }
        bool _S1646;
        if(_S1645)
        {
            _S1646 = (_S1638.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S1646 = false;
        }
        bool _S1647;
        if(_S1646)
        {
            float _S1648 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1624.ids_0.x], _S1638.state_1.life_0);
            _S1647 = _S1648 <= 0.99000000953674316f;
        }
        else
        {
            _S1647 = false;
        }
        if(_S1647)
        {
            *&((&(&bd_1)->events_0)->y) = _S1622;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S1638.disconnected_0)
        {
            *&((&(&bd_1)->events_0)->z) = _S1622;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_1)->js_0 = _S1638.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_26]) = bd_1;
        write_bond_loads_0(i_26, i_26, _S1638.force_lin_1, _S1638.force_ang_1, (F32_max((_S1638.measures_0.tension_0), (_S1638.measures_0.compression_0))));
        if((flags_4 & 16U) != 0U)
        {
            *&g_halt_0 = 1U;
        }
        if((flags_4 & 32U) != 0U)
        {
            *&g_run_0 = 1U;
        }
        i_26 = i_26 + 256U;
    }
    __syncthreads();
    if(tid_16 != 0U)
    {
        return;
    }
    if(((*&g_halt_0) | (*&g_run_0)) != 0U)
    {
        uint _S1649 = isl_18.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_26 = 16U;
        }
        else
        {
            i_26 = 0U;
        }
        uint _S1650 = _S1649 | i_26;
        if((*&g_run_0) != 0U)
        {
            i_26 = 32U;
        }
        else
        {
            i_26 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S1619])->info_1)->z) = _S1650 | i_26;
    }
    uint _S1651 = ((isl_18.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_26 = 128U;
    }
    else
    {
        i_26 = 0U;
    }
    (&(globalParams_0->islands_0)[_S1619])->coverage_0 = _S1651 | i_26;
    return;
}

static __device__ void impactor_integrate_at_0(uint ii_2, uint tid_17, uint _S1652)
{
    uint _S1653 = 0U;
    uint _S1654;
    float3  p_16;
    uint _S1655 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S1656 = ii_2 >= _S1655;
    uint _S1657 = __ballot_sync(_S1652, _S1656);
    if(_S1656)
    {
        return;
    }
    else
    {
        uint _S1658 = __ballot_sync(_S1652, true);
        _S1653 = _S1658;
    }
    uint _S1659 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S1660 = (&(globalParams_0->islands_0)[_S1659]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_2]);
    uint4  _S1661 = _S1660->info_1;
    bool _S1662 = ((_S1660->info_1.z) & 1U) != 0U;
    uint _S1663 = __ballot_sync(_S1653, _S1662);
    bool _S1664;
    uint k_19;
    if(_S1662)
    {
        uint _S1665 = __ballot_sync(_S1653, true);
        _S1664 = true;
        k_19 = _S1665;
    }
    else
    {
        uint _S1666 = _S1653 & (~_S1663);
        uint _S1667 = _S1661.y;
        bool _S1668 = _S1667 != 0U;
        uint _S1669 = __ballot_sync(_S1666, _S1668);
        if(_S1668)
        {
            bool _S1670 = ((&imp_6)->cand_0.w) >= _S1667;
            uint _S1671 = __ballot_sync(_S1666, true);
            _S1664 = _S1670;
        }
        else
        {
            uint _S1672 = __ballot_sync(_S1666, true);
            _S1664 = false;
        }
        uint _S1673 = __ballot_sync(_S1653, true);
        k_19 = _S1673;
    }
    uint _S1674 = 0U;
    uint _S1675 = __ballot_sync(k_19, _S1664);
    if(_S1664)
    {
        return;
    }
    else
    {
        uint _S1676 = __ballot_sync(k_19, true);
        _S1674 = _S1676;
    }
    uint _S1677 = 0U;
    bool _S1678 = ((&imp_6)->cand_0.z) != 0U;
    uint _S1679 = __ballot_sync(_S1674, _S1678);
    if(_S1678)
    {
        if(tid_17 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_2])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S1680 = __ballot_sync(_S1674, true);
        _S1677 = _S1680;
    }
    float4  _S1681 = make_float4 (0.0f);
    float4  rf_1 = _S1681;
    float4  rt_0 = _S1681;
    k_19 = (&imp_6)->cand_0.x + tid_17;
    uint total_points_0;
    total_points_0 = _S1677;
    for(;;)
    {
        bool _S1682 = k_19 < ((&imp_6)->cand_0.y);
        uint _S1683 = __ballot_sync(total_points_0, _S1682);
        if(_S1682)
        {
            uint _S1684 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S1685 = __ballot_sync(total_points_0, false);
            uint _S1686 = __ballot_sync(total_points_0, false);
            uint _S1687 = __ballot_sync(_S1677, true);
            _S1654 = _S1687;
            break;
        }
        uint _S1688 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S1689 = 3U * k_19;
        rf_1 = rf_1 + *(&(globalParams_0->scratch_0)[_S1688 + _S1689 + 1U]);
        uint _S1690 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S1690 + _S1689 + 2U]);
        uint _S1691 = __ballot_sync(total_points_0, true);
        k_19 = k_19 + 256U;
        total_points_0 = _S1691;
    }
    group_sum2_0(tid_17, &rf_1, &rt_0, _S1654);
    bool _S1692 = tid_17 != 0U;
    uint _S1693 = __ballot_sync(_S1654, _S1692);
    if(_S1692)
    {
        return;
    }
    float _S1694 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S1695 = make_float3 (0.0f);
    uint _S1696 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S1696 != 0U)
    {
        float4  _S1697 = (&imp_6)->half_1;
        float3  _S1698 = float3 {_S1697.x, _S1697.y, _S1697.z};
        Impactor_0 _S1699 = imp_6;
        Box_0 _S1700 = impactor_box_0(&_S1699, _S1695, _S1698);
        float4  _S1701 = (&imp_6)->velocity_1;
        float4  _S1702 = (&imp_6)->velocity_err_1;
        float3  _S1703 = float3 {_S1701.x, _S1701.y, _S1701.z} + float3 {_S1702.x, _S1702.y, _S1702.z};
        float _S1704 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S1705 = (&imp_6)->mat_0.x;
        float3  _S1706 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S1707 = _S1700;
        Box_0 _S1708 = _S1700;
        float _S1709 = contact_stiffness_0(_S1704, &_S1707, _S1705, &_S1708, _S1706);
        float _S1710 = (&imp_6)->position_1.z;
        float _S1711 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S1712 = _S1710 - _S1711;
        float _S1713 = (&imp_6)->position_err_1.z;
        float _S1714 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S1715 = _S1712 + (_S1713 - _S1714);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S1716 = _S1709 / float((U32_min((total_points_0), (5U))));
        uint s_11 = 0U;
        uint below_0 = 0U;
        for(;;)
        {
            if(s_11 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_16 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S1717 = _S1700;
                float3  _S1718 = sample_point_0(&_S1717, s_11);
                p_16 = _S1718;
            }
            if((_S1715 + p_16.z) < 0.0f)
            {
                below_0 = below_0 + 1U;
            }
            s_11 = s_11 + 1U;
        }
        if(below_0 > 0U)
        {
            sentinel_mark_0(8U);
        }
        s_11 = 0U;
        load_f_0 = _S1695;
        load_t_0 = _S1695;
        for(;;)
        {
            if(s_11 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if(((&imp_6)->shape_0.x) == 0.0f)
            {
                p_16 = make_float3 (0.0f, 0.0f, - (&imp_6)->shape_0.y);
            }
            else
            {
                Box_0 _S1719 = _S1700;
                float3  _S1720 = sample_point_0(&_S1719, s_11);
                p_16 = _S1720;
            }
            float depth_3 = - (_S1715 + p_16.z);
            if(depth_3 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            float4  _S1721 = (&imp_6)->angular_velocity_1;
            float3  v_9 = _S1703 + cross_0(float3 {_S1721.x, _S1721.y, _S1721.z}, p_16);
            float _S1722 = (&imp_6)->mat_0.z;
            float _S1723 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_7;
            float diss_5;
            float3  f_12 = penalty_force_0(_S1716, _S1722, _S1723, depth_3, _S1706, v_9, _S1694, below_0, &stored_7, &diss_5);
            float3  load_f_1 = load_f_0 + f_12;
            float3  load_t_1 = load_t_0 + cross_0(p_16, f_12);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_5);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S1695;
        load_t_0 = _S1695;
    }
    float4  _S1724 = rf_1;
    float3  load_f_2 = float3 {_S1724.x, _S1724.y, _S1724.z} + load_f_0;
    float4  _S1725 = rt_0;
    float3  load_t_2 = float3 {_S1725.x, _S1725.y, _S1725.z} + load_t_0;
    float m_6 = (&imp_6)->mat_0.z;
    float4  _S1726 = (&imp_6)->velocity_1;
    float3  vel_2 = float3 {_S1726.x, _S1726.y, _S1726.z};
    float4  _S1727 = (&imp_6)->velocity_err_1;
    float3  vel_err_1 = float3 {_S1727.x, _S1727.y, _S1727.z};
    float3  _S1728 = load_f_2 / make_float3 (m_6);
    float4  _S1729 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_2, &vel_err_1, (_S1728 + float3 {_S1729.x, _S1729.y, _S1729.z}) * make_float3 (_S1694));
    Quat_0 _S1730 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_13 = _S1730;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S1731 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S1731.x, _S1731.y, _S1731.z};
    float4  _S1732 = (&imp_6)->momentum_err_1;
    float3  l_err_1 = float3 {_S1732.x, _S1732.y, _S1732.z};
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * make_float3 (_S1694));
    float3  l_6 = l_hi_0 + l_err_1;
    Quat_0 _S1733 = _S1730;
    float3  _S1734 = world_mul_0(&_S1733, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_6);
    float4  _S1735 = (&imp_6)->position_1;
    float3  pos_1 = float3 {_S1735.x, _S1735.y, _S1735.z};
    float4  _S1736 = (&imp_6)->position_err_1;
    float3  pos_err_1 = float3 {_S1736.x, _S1736.y, _S1736.z};
    comp_add_0(&pos_1, &pos_err_1, (vel_2 + vel_err_1) * make_float3 (_S1694));
    turn_left_0(&q_13, &q_err_0, _S1734, _S1694);
    Quat_0 _S1737 = q_13;
    float3  _S1738 = world_mul_0(&_S1737, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_6);
    (&imp_6)->angular_velocity_1 = make_float4 (_S1738.x, _S1738.y, _S1738.z, 0.0f);
    Quat_0 _S1739 = q_13;
    float4  _S1740 = quat_vec_0(&_S1739);
    (&imp_6)->rotation_1 = _S1740;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = make_float4 (l_hi_0.x, l_hi_0.y, l_hi_0.z, 0.0f);
    (&imp_6)->momentum_err_1 = make_float4 (l_err_1.x, l_err_1.y, l_err_1.z, 0.0f);
    (&imp_6)->position_1 = make_float4 (pos_1.x, pos_1.y, pos_1.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_1.x, pos_err_1.y, pos_err_1.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_2.x, vel_2.y, vel_2.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_1.x, vel_err_1.y, vel_err_1.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_2]) = imp_6;
    uint _S1741 = (&imp_6)->cand_0.w - 1U;
    uint _S1742 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_20 = _S1741 - _S1742;
    uint _S1743 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_20 < _S1743)
    {
        uint _S1744 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S1745 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_7 = _S1744 + 2U * (ii_2 * _S1745 + k_20);
        *(&(globalParams_0->scratch_0)[at_7]) = make_float4 ((vel_2 + vel_err_1).x, (vel_2 + vel_err_1).y, (vel_2 + vel_err_1).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_7 + 1U]) = make_float4 ((pos_1 + pos_err_1).x, (pos_1 + pos_err_1).y, (pos_1 + pos_err_1).z, 0.0f);
    }
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S1746 = __ballot_sync(4294967295U, true);
    impactor_integrate_at_0(blockIdx.x, threadIdx.x, _S1746);
    return;
}

static __device__ void ground_contact_0(uint c_35, bool account_0, float3  * f_13, float3  * t_12)
{
    ChunkStatic_0 * _S1747 = (&(globalParams_0->chunks_0)[c_35]);
    WorldPoint_0 wp_1 = chunk_world_0(c_35);
    float _S1748 = wp_1.hi_0.z;
    float _S1749 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S1750 = _S1748 - _S1749;
    float _S1751 = wp_1.lo_0.z;
    float _S1752 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S1750 + (_S1751 - _S1752) + wp_1.rel_0.z;
    float4  _S1753 = __ldg(&_S1747->half_0);
    if((above_0 - _S1753.w) > 0.0f)
    {
        return;
    }
    Box_0 b_31 = chunk_box_0(c_35, make_float3 (0.0f));
    float _S1754 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S1755 = __ldg(&_S1747->cmat_0);
    float _S1756 = _S1755.x;
    float3  _S1757 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S1758 = b_31;
    Box_0 _S1759 = b_31;
    float _S1760 = contact_stiffness_0(_S1754, &_S1758, _S1756, &_S1759, _S1757);
    Box_0 _S1761 = b_31;
    uint _S1762 = sample_count_0(&_S1761);
    uint s_12 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_12 < _S1762)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1763 = b_31;
        float3  _S1764 = sample_point_0(&_S1763, s_12);
        if((above_0 + _S1764.z) < 0.0f)
        {
            n_9 = n_9 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_9 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U);
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_35, &vc_1, &wc_1);
    uint _S1765 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S1766 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S1765 + _S1766 + c_35]);
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1762)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1767 = b_31;
        float3  _S1768 = sample_point_0(&_S1767, s_12);
        float _S1769 = above_0 + _S1768.z;
        if(!(_S1769 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        float depth_4 = - _S1769;
        float3  v_10 = vc_1 + cross_0(wc_1, _S1768);
        float _S1770 = _S1760 / float((U32_max((n_9), (5U))));
        float4  _S1771 = __ldg(&_S1747->center_0);
        float _S1772 = _S1771.w;
        float _S1773 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S1774 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_8;
        float diss_6;
        float3  g_2 = penalty_force_0(_S1770, _S1772, _S1773, depth_4, _S1757, v_10, _S1774, n_9, &stored_8, &diss_6);
        *f_13 = *f_13 + g_2;
        *t_12 = *t_12 + cross_0(_S1768, g_2);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_6);
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        uint _S1775 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S1776 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S1775 + _S1776 + c_35]) = ledger_2;
    }
    return;
}

static __device__ void contact_sum_at_0(uint g_3)
{
    uint _S1777 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S1778;
    if(g_3 >= _S1777)
    {
        _S1778 = true;
    }
    else
    {
        _S1778 = stopped_0();
    }
    if(_S1778)
    {
        return;
    }
    uint _S1779 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1780 = 3U * g_3;
    uint _S1781 = __ldg((&(globalParams_0->index_0)[_S1779 + _S1780]));
    uint _S1782 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1783 = __ldg((&(globalParams_0->index_0)[_S1782 + _S1780 + 1U]));
    uint _S1784 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1785 = __ldg((&(globalParams_0->index_0)[_S1784 + _S1780 + 2U]));
    float3  _S1786 = make_float3 (0.0f);
    float3  f_14 = _S1786;
    float3  t_13 = _S1786;
    uint e_6 = _S1783;
    for(;;)
    {
        if(e_6 < _S1785)
        {
        }
        else
        {
            break;
        }
        uint _S1787 = __ldg((&(globalParams_0->index_0)[e_6]));
        if(_S1787 == 2147483648U)
        {
            ground_contact_0(_S1781, true, &f_14, &t_13);
            e_6 = e_6 + 1U;
            continue;
        }
        uint _S1788 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S1789 = 2U * _S1787;
        float4  _S1790 = *(&(globalParams_0->scratch_0)[_S1788 + _S1789]);
        f_14 = f_14 + float3 {_S1790.x, _S1790.y, _S1790.z};
        uint _S1791 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S1792 = *(&(globalParams_0->scratch_0)[_S1791 + _S1789 + 1U]);
        t_13 = t_13 + float3 {_S1792.x, _S1792.y, _S1792.z};
        e_6 = e_6 + 1U;
    }
    uint _S1793 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S1794 = 2U * g_3;
    *(&(globalParams_0->scratch_0)[_S1793 + _S1794]) = make_float4 (f_14.x, f_14.y, f_14.z, 0.0f);
    uint _S1795 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S1795 + _S1794 + 1U]) = make_float4 (t_13.x, t_13.y, t_13.z, 0.0f);
    return;
}

extern "C" __global__ void contact_sums()
{
    contact_sum_at_0((blockIdx * blockDim + threadIdx).x);
    return;
}

static __device__ void net_load_0(uint c_36, Island_0 * isl_19, Rigid_0 * rg_7, uint k_21, float dt_9, bool contact_2, float3  * f_15, float3  * t_14)
{
    ChunkStatic_0 * _S1796 = (&(globalParams_0->chunks_0)[c_36]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_36, c_36, &rg_7->rot_1, k_21, dt_9, contact_2, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S1797 = fl_0;
    float4  _S1798 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S1799 = float3 {_S1798.x, _S1798.y, _S1798.z};
    float4  _S1800 = __ldg(&_S1796->center_0);
    float3  fc_3 = _S1797 + _S1799 * make_float3 (_S1800.w);
    float3  _S1801 = float3 {_S1800.x, _S1800.y, _S1800.z};
    float4  _S1802 = *(&(globalParams_0->state_0)[4U * c_36]);
    float4  _S1803 = isl_19->com_0;
    float3  _S1804 = float3 {_S1803.x, _S1803.y, _S1803.z};
    float3  _S1805 = rotate_0(&rg_7->rot_1, _S1801 + float3 {_S1802.x, _S1802.y, _S1802.z} - _S1804);
    *f_15 = *f_15 + fc_3;
    *t_14 = *t_14 + (cross_0(_S1805, fc_3) + tl_0);
    uint4  _S1806 = __ldg(&_S1796->load_range_0);
    if((_S1806.y) > (_S1806.x))
    {
        float3  _S1807 = rotate_0(&rg_7->rot_1, rep_f_0);
        *f_15 = *f_15 + _S1807;
        float3  _S1808 = rotate_0(&rg_7->rot_1, _S1801 - _S1804);
        float3  _S1809 = cross_0(_S1808, _S1807);
        float3  _S1810 = rotate_0(&rg_7->rot_1, rep_m_0);
        *t_14 = *t_14 + (_S1809 + _S1810);
    }
    return;
}

static __device__ bool bond_update_0(uint i_27, float dt_10, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S1811 = (&(globalParams_0->bonds_0)[i_27]);
    JointBond_0 _S1812 = slang_ldg_0(&_S1811->law_0);
    uint ca_2 = _S1812.ids_0.y;
    uint cb_2 = _S1812.ids_0.z;
    float4  _S1813 = __ldg(&_S1811->ra_0);
    float3  ra_1 = float3 {_S1813.x, _S1813.y, _S1813.z};
    float4  _S1814 = __ldg(&_S1811->rb_0);
    float3  rb_1 = float3 {_S1814.x, _S1814.y, _S1814.z};
    uint _S1815 = 4U * ca_2;
    float4  _S1816 = *(&(globalParams_0->state_0)[_S1815]);
    float4  _S1817 = *(&(globalParams_0->state_0)[_S1815 + 1U]);
    float3  ta_3 = float3 {_S1817.x, _S1817.y, _S1817.z};
    float4  _S1818 = *(&(globalParams_0->state_0)[_S1815 + 2U]);
    float3  va_0 = float3 {_S1818.x, _S1818.y, _S1818.z};
    float4  _S1819 = *(&(globalParams_0->state_0)[_S1815 + 3U]);
    float3  wa_1 = float3 {_S1819.x, _S1819.y, _S1819.z};
    uint _S1820 = 4U * cb_2;
    float4  _S1821 = *(&(globalParams_0->state_0)[_S1820]);
    float4  _S1822 = *(&(globalParams_0->state_0)[_S1820 + 1U]);
    float3  tb_3 = float3 {_S1822.x, _S1822.y, _S1822.z};
    float4  _S1823 = *(&(globalParams_0->state_0)[_S1820 + 2U]);
    float3  vb_0 = float3 {_S1823.x, _S1823.y, _S1823.z};
    float4  _S1824 = *(&(globalParams_0->state_0)[_S1820 + 3U]);
    float3  wb_0 = float3 {_S1824.x, _S1824.y, _S1824.z};
    float3  _S1825 = to_local_0(i_27, float3 {_S1821.x, _S1821.y, _S1821.z} + cross_0(tb_3, rb_1) - (float3 {_S1816.x, _S1816.y, _S1816.z} + cross_0(ta_3, ra_1)));
    float3  _S1826 = to_local_0(i_27, tb_3 - ta_3);
    float3  _S1827 = to_local_0(i_27, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S1828 = to_local_0(i_27, wb_0 - wa_1);
    JointBond_0 _S1829 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
    JointState_0 previous_3 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
    JointState_0 _S1830 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
    bool _S1831 = is_damaged_0(&_S1830);
    JointBond_0 _S1832 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
    JointBond_0 _S1833 = _S1832;
    JointState_0 _S1834 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
    JointResponse_0 _S1835 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1829.ids_0.x], &_S1833, &_S1834, _S1825, _S1826, dt_10, fracture_2);
    BondStatic_0 * _S1836 = (&(globalParams_0->bonds_0)[i_27]);
    BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_27]);
    float4  _S1837 = __ldg(&_S1836->ra_0);
    float3  ra_2 = float3 {_S1837.x, _S1837.y, _S1837.z};
    float4  _S1838 = __ldg(&_S1836->rb_0);
    float3  rb_2 = float3 {_S1838.x, _S1838.y, _S1838.z};
    JointBond_0 _S1839 = slang_ldg_0(&_S1836->law_0);
    JointBond_0 _S1840 = _S1839;
    JointState_0 _S1841 = _S1835.state_1;
    float3  f_lin_2;
    float3  f_ang_2;
    secant_factors_0(&_S1840, &_S1841, _S1825, &f_lin_2, &f_ang_2);
    float4  _S1842 = __ldg(&_S1836->c_lin_0);
    float3  qd_lin_0 = _S1827 * float3 {_S1842.x, _S1842.y, _S1842.z} * f_lin_2;
    float4  _S1843 = __ldg(&_S1836->c_ang_0);
    float3  qd_ang_0 = _S1828 * float3 {_S1843.x, _S1843.y, _S1843.z} * f_ang_2;
    float3  q_lin_2 = _S1835.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S1835.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S1827) + dot_0(qd_ang_0, _S1828)) * dt_10;
    float3  _S1844 = to_body_0(i_27, q_lin_2);
    float3  _S1845 = to_body_0(i_27, q_ang_2);
    uint _S1846 = 3U * i_27;
    *(&(globalParams_0->scratch_0)[_S1846]) = make_float4 (_S1844.x, _S1844.y, _S1844.z, (F32_max((_S1835.measures_0.tension_0), (_S1835.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S1846 + 1U]) = make_float4 ((_S1845 + cross_0(ra_2, _S1844)).x, (_S1845 + cross_0(ra_2, _S1844)).y, (_S1845 + cross_0(ra_2, _S1844)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S1846 + 2U]) = make_float4 ((- _S1845 + cross_0(rb_2, - _S1844)).x, (- _S1845 + cross_0(rb_2, - _S1844)).y, (- _S1845 + cross_0(rb_2, - _S1844)).z, 0.0f);
    comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1835.dissipated_2);
    comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1835.overshoot_0);
    comp_add1_0(&((&(&bd_2)->sums_0)->z), &((&(&bd_2)->comps_0)->z), damped_0);
    (&bd_2)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S1835.stored_3);
    (&bd_2)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1835.state_1.utilization_0))));
    bool _S1847;
    if(!_S1831)
    {
        JointState_0 _S1848 = _S1835.state_1;
        bool _S1849 = is_damaged_0(&_S1848);
        _S1847 = _S1849;
    }
    else
    {
        _S1847 = false;
    }
    if(_S1847)
    {
        _S1847 = ((&bd_2)->events_0.x) == 0U;
    }
    else
    {
        _S1847 = false;
    }
    if(_S1847)
    {
        *&((&(&bd_2)->events_0)->x) = abs_step_0;
        *&((&(&bd_2)->events_0)->w) = _S1835.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S1839.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_2)->events_0.y) == 0U)
    {
        _S1847 = (_S1835.state_1.life_0) != (previous_3.life_0);
    }
    else
    {
        _S1847 = false;
    }
    if(_S1847)
    {
        _S1847 = (_S1835.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S1847 = false;
    }
    if(_S1847)
    {
        float _S1850 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1829.ids_0.x], _S1835.state_1.life_0);
        _S1847 = _S1850 <= 0.99000000953674316f;
    }
    else
    {
        _S1847 = false;
    }
    if(_S1847)
    {
        *&((&(&bd_2)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S1839.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S1835.disconnected_0)
    {
        *&((&(&bd_2)->events_0)->z) = abs_step_0;
    }
    (&bd_2)->js_0 = _S1835.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_27]) = bd_2;
    return _S1835.disconnected_0;
}

static __device__ void chunk_update_0(uint c_37, Island_0 * isl_20, Rigid_0 * rg_8, float dt_11, bool rml_0, uint step_0, bool contact_3, float * work_2, float * work_err_0)
{
    ChunkStatic_0 * _S1851 = (&(globalParams_0->chunks_0)[c_37]);
    float3  _S1852 = make_float3 (0.0f);
    uint _S1853 = __ldg((&(globalParams_0->index_0)[c_37]));
    float peak_0 = 0.0f;
    uint e_7 = _S1853;
    float3  fi_5 = _S1852;
    float3  mi_4 = _S1852;
    for(;;)
    {
        uint _S1854 = __ldg((&(globalParams_0->index_0)[c_37 + 1U]));
        if(e_7 < _S1854)
        {
        }
        else
        {
            break;
        }
        uint _S1855 = __ldg((&(globalParams_0->index_0)[e_7]));
        uint _S1856 = 3U * (_S1855 >> int(1));
        float4  fa_2 = *(&(globalParams_0->scratch_0)[_S1856]);
        if((_S1855 & 1U) == 0U)
        {
            float4  _S1857 = *(&(globalParams_0->scratch_0)[_S1856 + 1U]);
            float3  mi_5 = mi_4 + float3 {_S1857.x, _S1857.y, _S1857.z};
            fi_5 = fi_5 + float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_4 = mi_5;
        }
        else
        {
            float4  _S1858 = *(&(globalParams_0->scratch_0)[_S1856 + 2U]);
            float3  mi_6 = mi_4 + float3 {_S1858.x, _S1858.y, _S1858.z};
            fi_5 = fi_5 + - float3 {fa_2.x, fa_2.y, fa_2.z};
            mi_4 = mi_6;
        }
        float _S1859 = (F32_max((peak_0), (fa_2.w)));
        uint _S1860 = e_7 + 1U;
        peak_0 = _S1859;
        e_7 = _S1860;
    }
    uint _S1861 = 4U * c_37;
    float4  _S1862 = *(&(globalParams_0->state_0)[_S1861]);
    float3  u_2 = float3 {_S1862.x, _S1862.y, _S1862.z};
    uint _S1863 = _S1861 + 1U;
    float4  _S1864 = *(&(globalParams_0->state_0)[_S1863]);
    float3  th_4 = float3 {_S1864.x, _S1864.y, _S1864.z};
    uint _S1865 = _S1861 + 2U;
    float4  _S1866 = *(&(globalParams_0->state_0)[_S1865]);
    float3  v_11 = float3 {_S1866.x, _S1866.y, _S1866.z};
    uint _S1867 = _S1861 + 3U;
    float4  _S1868 = *(&(globalParams_0->state_0)[_S1867]);
    float3  w_6 = float3 {_S1868.x, _S1868.y, _S1868.z};
    float4  _S1869 = __ldg(&_S1851->center_0);
    float mass_0 = _S1869.w;
    float3  _S1870 = float3 {_S1869.x, _S1869.y, _S1869.z};
    float4  _S1871 = isl_20->com_0;
    float3  _S1872 = float3 {_S1871.x, _S1871.y, _S1871.z};
    float3  _S1873 = rotate_0(&rg_8->rot_1, _S1870 + u_2 - _S1872);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_37, c_37, &rg_8->rot_1, step_0, dt_11, contact_3, dt_11, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_37, f_load_0, t_load_0);
    float3  _S1874 = f_load_0;
    float4  _S1875 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S1874 + float3 {_S1875.x, _S1875.y, _S1875.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S1876 = rg_8->alpha_0;
        float3  _S1877 = rg_8->w_5;
        float3  f_world_2 = f_world_0 - (rg_8->a_9 + cross_0(rg_8->alpha_0, _S1873) + cross_0(rg_8->w_5, cross_0(rg_8->w_5, _S1873))) * make_float3 (mass_0);
        float4  _S1878 = __ldg(&_S1851->inertia0_0);
        float4  _S1879 = __ldg(&_S1851->inertia1_0);
        float4  _S1880 = __ldg(&_S1851->inertia2_0);
        float3  _S1881 = world_mul_0(&rg_8->rot_1, _S1878, _S1879, _S1880, _S1876);
        float3  _S1882 = world_mul_0(&rg_8->rot_1, _S1878, _S1879, _S1880, _S1877);
        float3  t_world_2 = t_world_0 - (_S1881 + cross_0(_S1877, _S1882));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S1883 = inverse_rotate_0(&rg_8->rot_1, f_world_1);
    float3  _S1884 = inverse_rotate_0(&rg_8->rot_1, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S1885 = inverse_rotate_0(&rg_8->rot_1, rg_8->w_5);
        float3  f_ext_1 = _S1883 - cross_0(_S1885, v_11) * make_float3 (2.0f * mass_0);
        float4  _S1886 = __ldg(&_S1851->inertia0_0);
        float4  _S1887 = __ldg(&_S1851->inertia1_0);
        float4  _S1888 = __ldg(&_S1851->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S1886, _S1887, _S1888, w_6);
        float3  m_ext_1 = _S1884 - (cross_0(_S1885, i_w_0) + cross_0(w_6, rows_mul_0(_S1886, _S1887, _S1888, _S1885)) + cross_0(w_6, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1883;
        m_ext_0 = _S1884;
    }
    float3  f_16 = f_ext_0 + rep_f_1 + fi_5;
    float3  m_7 = m_ext_0 + rep_m_1 + mi_4;
    uint4  _S1889 = __ldg(&_S1851->info_0);
    uint support_1 = _S1889.x;
    float3  _S1890 = make_float3 ((*(&(globalParams_0->state_0)[_S1863])).w, (*(&(globalParams_0->state_0)[_S1865])).w, (*(&(globalParams_0->state_0)[_S1867])).w);
    float3  reaction_1;
    float3  u_3;
    float3  th_5;
    float3  v_12;
    float3  w_7;
    if(support_1 == 1U)
    {
        reaction_1 = - f_16;
        u_3 = u_2;
        th_5 = th_4;
        v_12 = _S1852;
        w_7 = _S1852;
    }
    else
    {
        float4  _S1891 = __ldg(&_S1851->inv0_0);
        float4  _S1892 = __ldg(&_S1851->inv1_0);
        float4  _S1893 = __ldg(&_S1851->inv2_0);
        float3  _S1894 = rows_mul_0(_S1891, _S1892, _S1893, m_7);
        float4  _S1895 = __ldg(&_S1851->scale_0);
        float3  w_8 = w_6 + _S1894 * make_float3 (dt_11 * _S1895.z);
        float3  th_6 = th_4 + w_8 * make_float3 (dt_11);
        if(support_1 == 2U)
        {
            reaction_1 = - f_16;
            u_3 = u_2;
            th_5 = _S1852;
        }
        else
        {
            float3  v_13 = v_11 + f_16 * make_float3 (dt_11 * _S1895.y);
            float3  u_4 = u_2 + v_13 * make_float3 (dt_11);
            reaction_1 = _S1890;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3  _S1896 = th_5;
        th_5 = th_6;
        v_12 = _S1896;
        w_7 = w_8;
    }
    *(&(globalParams_0->state_0)[_S1861]) = make_float4 (u_3.x, u_3.y, u_3.z, peak_0);
    *(&(globalParams_0->state_0)[_S1863]) = make_float4 (th_5.x, th_5.y, th_5.z, reaction_1.x);
    *(&(globalParams_0->state_0)[_S1865]) = make_float4 (v_12.x, v_12.y, v_12.z, reaction_1.y);
    *(&(globalParams_0->state_0)[_S1867]) = make_float4 (w_7.x, w_7.y, w_7.z, reaction_1.z);
    float3  _S1897 = rotate_0(&rg_8->rot_1, _S1870 + u_3 - _S1872);
    float3  _S1898 = rg_8->vel_0 + rg_8->vel_err_0 + cross_0(rg_8->w_5, _S1897);
    float3  _S1899 = rotate_0(&rg_8->rot_1, v_12);
    float3  v_world_0 = _S1898 + _S1899;
    float3  _S1900 = rotate_0(&rg_8->rot_1, w_7);
    comp_add1_0(work_2, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_8->w_5 + _S1900)) * dt_11);
    return;
}

static __device__ void drift_moments_0(uint c_38, float3  * tu_2, float3  * pv_2)
{
    ChunkStatic_0 * _S1901 = (&(globalParams_0->chunks_0)[c_38]);
    float4  _S1902 = __ldg(&_S1901->center_0);
    float _S1903 = _S1902.w;
    float4  _S1904 = __ldg(&_S1901->scale_0);
    float m_8 = _S1903 * _S1904.x;
    uint _S1905 = 4U * c_38;
    float4  _S1906 = *(&(globalParams_0->state_0)[_S1905]);
    *tu_2 = *tu_2 + float3 {_S1906.x, _S1906.y, _S1906.z} * make_float3 (m_8);
    float4  _S1907 = *(&(globalParams_0->state_0)[_S1905 + 2U]);
    *pv_2 = *pv_2 + float3 {_S1907.x, _S1907.y, _S1907.z} * make_float3 (m_8);
    return;
}

__device__ __shared__ FixedArray<uint, 512>  g_label_narrow_0;

__device__ __shared__ uint g_changed_narrow_0;

static __device__ bool island_connected_narrow_0(uint tid_18, Island_0 * isl_21)
{
    uint _S1908 = isl_21->range_0.x;
    uint n_10 = isl_21->range_0.y - _S1908;
    bool converged_3;
    if(n_10 > 512U)
    {
        converged_3 = true;
    }
    else
    {
        uint _S1909 = __ldg(&globalParams_0->params_0->device_connect_0);
        converged_3 = _S1909 == 0U;
    }
    if(converged_3)
    {
        return false;
    }
    uint c_39 = tid_18;
    for(;;)
    {
        if(c_39 < n_10)
        {
        }
        else
        {
            break;
        }
        (*&g_label_narrow_0)[c_39] = c_39;
        c_39 = c_39 + 256U;
    }
    __syncthreads();
    converged_3 = false;
    uint pass_1 = 0U;
    for(;;)
    {
        if(pass_1 <= n_10)
        {
        }
        else
        {
            break;
        }
        if(tid_18 == 0U)
        {
            *&g_changed_narrow_0 = 0U;
        }
        __syncthreads();
        c_39 = tid_18;
        for(;;)
        {
            if(c_39 < n_10)
            {
            }
            else
            {
                break;
            }
            uint _S1910 = (*&g_label_narrow_0)[c_39];
            uint gc_1 = _S1908 + c_39;
            uint _S1911 = __ldg((&(globalParams_0->index_0)[gc_1]));
            uint l_7 = _S1910;
            uint e_8 = _S1911;
            for(;;)
            {
                uint _S1912 = __ldg((&(globalParams_0->index_0)[gc_1 + 1U]));
                if(e_8 < _S1912)
                {
                }
                else
                {
                    break;
                }
                uint _S1913 = __ldg((&(globalParams_0->index_0)[e_8]));
                uint bond_2 = _S1913 >> int(1);
                JointBond_0 _S1914 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                bool _S1915 = (_S1914.stiff1_0.w) != 0.0f;
                JointState_0 _S1916 = (&(globalParams_0->bond_dyn_0)[bond_2])->js_0;
                bool _S1917 = connected_0(&_S1916, _S1915);
                if(!_S1917)
                {
                    e_8 = e_8 + 1U;
                    continue;
                }
                uint other_1;
                if((_S1913 & 1U) == 0U)
                {
                    JointBond_0 _S1918 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                    other_1 = _S1918.ids_0.z;
                }
                else
                {
                    JointBond_0 _S1919 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                    other_1 = _S1919.ids_0.y;
                }
                l_7 = (U32_min((l_7), ((*&g_label_narrow_0)[other_1 - _S1908])));
                e_8 = e_8 + 1U;
            }
            uint _S1920 = (U32_min((l_7), ((*&g_label_narrow_0)[l_7])));
            if(_S1920 < (*&g_label_narrow_0)[c_39])
            {
                (*&g_label_narrow_0)[c_39] = _S1920;
                *&g_changed_narrow_0 = 1U;
            }
            c_39 = c_39 + 256U;
        }
        __syncthreads();
        bool converged_4 = (*&g_changed_narrow_0) == 0U;
        __syncthreads();
        if(converged_4)
        {
            converged_3 = converged_4;
            break;
        }
        uint _S1921 = pass_1 + 1U;
        converged_3 = converged_4;
        pass_1 = _S1921;
    }
    if(!converged_3)
    {
        return false;
    }
    if(tid_18 == 0U)
    {
        *&g_changed_narrow_0 = 0U;
    }
    __syncthreads();
    c_39 = tid_18;
    for(;;)
    {
        if(c_39 < n_10)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_narrow_0)[c_39]) != 0U)
        {
            *&g_changed_narrow_0 = 1U;
        }
        c_39 = c_39 + 256U;
    }
    __syncthreads();
    return (*&g_changed_narrow_0) == 0U;
}

static __device__ void island_frame_at_0(uint gi_0, uint tid_19, uint _S1922)
{
    bool woke_0;
    uint _S1923;
    uint _S1924;
    uint _S1925;
    uint _S1926;
    uint _S1927;
    uint _S1928;
    Island_0 isl_22 = *(&(globalParams_0->islands_0)[gi_0]);
    bool driven_0 = (((&isl_22)->info_1.x) & 2U) != 0U;
    bool _S1929 = !((((&isl_22)->info_1.x) & 1U) != 0U);
    uint _S1930 = __ballot_sync(_S1922, _S1929);
    bool _S1931;
    uint cov_2;
    if(_S1929)
    {
        bool _S1932 = !driven_0;
        uint _S1933 = __ballot_sync(_S1922, true);
        _S1931 = _S1932;
        cov_2 = _S1933;
    }
    else
    {
        uint _S1934 = __ballot_sync(_S1922, true);
        _S1931 = false;
        cov_2 = _S1934;
    }
    bool contact_island_0 = (((&isl_22)->info_1.x) & 4U) != 0U;
    bool _S1935 = (((&isl_22)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_19);
    bool _S1936 = tid_19 == 0U;
    uint _S1937 = __ballot_sync(cov_2, _S1936);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1936)
    {
        uint _S1938 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1939 = contact_island_0 != (_S1938 == 1U);
        uint _S1940 = __ballot_sync(_S1937, _S1939);
        if(_S1939)
        {
            uint _S1941 = __ballot_sync(_S1937, true);
            settled_0 = true;
            run_0 = _S1941;
        }
        else
        {
            bool _S1942 = (((&isl_22)->info_1.x) & 8U) != 0U;
            uint _S1943 = __ballot_sync(_S1937, true);
            settled_0 = _S1942;
            run_0 = _S1943;
        }
        uint _S1944 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1945 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1945;
        }
        else
        {
            uint _S1946 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1946;
        }
        uint _S1947 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1948 = isl_22;
            bool _S1949 = contact_stopped_0(&_S1948);
            uint _S1950 = __ballot_sync(done_1, true);
            settled_0 = _S1949;
            done_1 = _S1950;
        }
        else
        {
            uint _S1951 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1951;
        }
        uint _S1952 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1953 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1954 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1955 = __ballot_sync(cov_2, true);
        cov_2 = _S1955;
    }
    else
    {
        uint _S1956 = __ballot_sync(cov_2, true);
        cov_2 = _S1956;
    }
    __syncthreads();
    bool _S1957 = (((&isl_22)->info_1.z) & 1U) != 0U;
    uint _S1958 = __ballot_sync(cov_2, _S1957);
    if(_S1957)
    {
        uint _S1959 = __ballot_sync(cov_2, true);
        settled_0 = true;
        cov_2 = _S1959;
    }
    else
    {
        bool _S1960 = (*&g_run_0) == 0U;
        uint _S1961 = __ballot_sync(cov_2, true);
        settled_0 = _S1960;
        cov_2 = _S1961;
    }
    uint _S1962 = __ballot_sync(cov_2, settled_0);
    if(settled_0)
    {
        uint _S1963 = __ballot_sync(cov_2, true);
        cov_2 = 0U;
        run_0 = _S1963;
    }
    else
    {
        uint _S1964 = (&isl_22)->info_1.y;
        uint _S1965 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1966 = (U32_min((_S1964), (_S1965)));
        uint _S1967 = __ballot_sync(cov_2, true);
        cov_2 = _S1966;
        run_0 = _S1967;
    }
    float _S1968 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1969 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1970 = _S1969 != 0U;
    uint _S1971 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1972 = _S1971 != 0U;
    Island_0 _S1973 = isl_22;
    Rigid_0 _S1974 = rigid_of_0(&_S1973);
    Rigid_0 rg_9 = _S1974;
    float work_3 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1935;
    done_1 = 0U;
    bool woke_1 = false;
    bool resumed_0 = false;
    uint _S1975 = run_0;
    for(;;)
    {
        uint _S1976 = 0U;
        bool _S1977 = done_1 < cov_2;
        uint _S1978 = __ballot_sync(_S1975, _S1977);
        if(_S1977)
        {
            uint _S1979 = __ballot_sync(_S1975, true);
            _S1976 = _S1979;
        }
        else
        {
            uint _S1980 = __ballot_sync(_S1975, false);
            uint _S1981 = __ballot_sync(_S1975, false);
            uint _S1982 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_2 = _S1982;
            break;
        }
        uint abs_step_1 = (&isl_22)->info_1.w + done_1 + 1U;
        uint _S1983 = abs_step_1 - 1U;
        uint _S1984 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_22 = _S1983 - _S1984;
        bool quiet_0 = (((&isl_22)->info_1.x) & 32U) != 0U;
        uint _S1985 = __ballot_sync(_S1976, settled_0);
        bool _S1986;
        uint _S1987;
        if(settled_0)
        {
            bool _S1988 = !quiet_0;
            uint _S1989 = __ballot_sync(_S1976, true);
            _S1986 = _S1988;
            _S1987 = _S1989;
        }
        else
        {
            uint _S1990 = __ballot_sync(_S1976, true);
            _S1986 = false;
            _S1987 = _S1990;
        }
        uint _S1991 = __ballot_sync(_S1987, _S1986);
        bool _S1992;
        bool explicit_step_0;
        uint c_40;
        uint _S1993;
        uint c_41;
        if(_S1986)
        {
            float3  _S1994 = make_float3 (0.0f);
            float3  norm_1 = _S1994;
            float3  unused0_0 = _S1994;
            c_40 = (&isl_22)->range_0.x + tid_19;
            _S1993 = _S1991;
            for(;;)
            {
                bool _S1995 = c_40 < ((&isl_22)->range_0.y);
                uint _S1996 = __ballot_sync(_S1993, _S1995);
                if(_S1995)
                {
                    uint _S1997 = __ballot_sync(_S1993, true);
                }
                else
                {
                    uint _S1998 = __ballot_sync(_S1993, false);
                    uint _S1999 = __ballot_sync(_S1993, false);
                    uint _S2000 = __ballot_sync(_S1991, true);
                    _S1923 = _S2000;
                    break;
                }
                Quat_0 _S2001 = (&rg_9)->rot_1;
                float _S2002 = settled_chunk_load_0(c_40, &_S2001, k_22, _S1968, contact_island_0);
                *&((&norm_1)->x) = *&((&norm_1)->x) + _S2002;
                uint _S2003 = __ballot_sync(_S1993, true);
                c_40 = c_40 + 256U;
                _S1993 = _S2003;
            }
            group_sum3_0(tid_19, &norm_1, &unused0_0, _S1923);
            uint _S2004 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S2005 = _S2004 == 1U;
            uint _S2006 = __ballot_sync(_S1923, _S2005);
            if(_S2005)
            {
                bool _S2007 = (F32_abs((norm_1.x - (&isl_22)->energy_1.z))) > ((&isl_22)->energy_1.w);
                uint _S2008 = __ballot_sync(_S1923, true);
                _S1992 = _S2007;
                c_41 = _S2008;
            }
            else
            {
                uint _S2009 = __ballot_sync(_S1923, true);
                _S1992 = false;
                c_41 = _S2009;
            }
            uint _S2010 = __ballot_sync(c_41, _S1992);
            if(_S1992)
            {
                uint _S2011 = __ballot_sync(c_41, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S2012 = __ballot_sync(c_41, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S2013 = __ballot_sync(_S1987, true);
            settled_0 = explicit_step_0;
            c_40 = _S2013;
        }
        else
        {
            uint _S2014 = __ballot_sync(_S1987, true);
            woke_0 = woke_1;
            c_40 = _S2014;
        }
        uint _S2015 = __ballot_sync(c_40, _S1929);
        if(_S1929)
        {
            bool _S2016 = !quiet_0;
            uint _S2017 = __ballot_sync(c_40, true);
            _S1992 = _S2016;
            _S1993 = _S2017;
        }
        else
        {
            uint _S2018 = __ballot_sync(c_40, true);
            _S1992 = false;
            _S1993 = _S2018;
        }
        uint _S2019 = __ballot_sync(_S1993, _S1992);
        uint _S2020;
        if(_S1992)
        {
            float3  _S2021 = make_float3 (0.0f);
            float3  f_17 = _S2021;
            float3  t_15 = _S2021;
            c_41 = (&isl_22)->range_0.x + tid_19;
            _S2020 = _S2019;
            for(;;)
            {
                bool _S2022 = c_41 < ((&isl_22)->range_0.y);
                uint _S2023 = __ballot_sync(_S2020, _S2022);
                if(_S2022)
                {
                    uint _S2024 = __ballot_sync(_S2020, true);
                }
                else
                {
                    uint _S2025 = __ballot_sync(_S2020, false);
                    uint _S2026 = __ballot_sync(_S2020, false);
                    uint _S2027 = __ballot_sync(_S2019, true);
                    _S1924 = _S2027;
                    break;
                }
                Island_0 _S2028 = isl_22;
                Rigid_0 _S2029 = rg_9;
                net_load_0(c_41, &_S2028, &_S2029, k_22, _S1968, contact_island_0, &f_17, &t_15);
                uint _S2030 = __ballot_sync(_S2020, true);
                c_41 = c_41 + 256U;
                _S2020 = _S2030;
            }
            group_sum3_0(tid_19, &f_17, &t_15, _S1924);
            Island_0 _S2031 = isl_22;
            rigid_acceleration_0(&_S2031, &rg_9, f_17, t_15);
            uint _S2032 = __ballot_sync(_S1993, true);
            c_41 = _S2032;
        }
        else
        {
            uint _S2033 = __ballot_sync(_S1993, true);
            c_41 = _S2033;
        }
        bool _S2034 = !settled_0;
        uint _S2035 = __ballot_sync(c_41, _S2034);
        if(_S2034)
        {
            bool _S2036 = !quiet_0;
            uint _S2037 = __ballot_sync(c_41, true);
            explicit_step_0 = _S2036;
            _S2020 = _S2037;
        }
        else
        {
            uint _S2038 = __ballot_sync(c_41, true);
            explicit_step_0 = false;
            _S2020 = _S2038;
        }
        uint _S2039 = __ballot_sync(_S2020, explicit_step_0);
        uint i_28;
        uint _S2040;
        uint c_42;
        uint _S2041;
        if(explicit_step_0)
        {
            i_28 = (&isl_22)->range_0.z + tid_19;
            _S2040 = _S2039;
            for(;;)
            {
                uint _S2042 = 0U;
                bool _S2043 = i_28 < ((&isl_22)->range_0.w);
                uint _S2044 = __ballot_sync(_S2040, _S2043);
                if(_S2043)
                {
                    uint _S2045 = __ballot_sync(_S2040, true);
                    _S2042 = _S2045;
                }
                else
                {
                    uint _S2046 = __ballot_sync(_S2040, false);
                    uint _S2047 = __ballot_sync(_S2040, false);
                    uint _S2048 = __ballot_sync(_S2039, true);
                    _S1925 = _S2048;
                    break;
                }
                bool _S2049 = bond_update_0(i_28, _S1968, _S1970, abs_step_1, false);
                uint _S2050 = __ballot_sync(_S2042, _S2049);
                if(_S2049)
                {
                    *&g_halt_0 = 1U;
                    uint _S2051 = __ballot_sync(_S2042, true);
                }
                else
                {
                    uint _S2052 = __ballot_sync(_S2042, true);
                }
                uint _S2053 = __ballot_sync(_S2040, true);
                i_28 = i_28 + 256U;
                _S2040 = _S2053;
            }
            __syncthreads();
            c_42 = (&isl_22)->range_0.x + tid_19;
            _S2041 = _S1925;
            for(;;)
            {
                bool _S2054 = c_42 < ((&isl_22)->range_0.y);
                uint _S2055 = __ballot_sync(_S2041, _S2054);
                if(_S2054)
                {
                    uint _S2056 = __ballot_sync(_S2041, true);
                }
                else
                {
                    uint _S2057 = __ballot_sync(_S2041, false);
                    uint _S2058 = __ballot_sync(_S2041, false);
                    uint _S2059 = __ballot_sync(_S1925, true);
                    break;
                }
                Island_0 _S2060 = isl_22;
                Rigid_0 _S2061 = rg_9;
                chunk_update_0(c_42, &_S2060, &_S2061, _S1968, _S1972, k_22, contact_island_0, &work_3, &work_err_1);
                uint _S2062 = __ballot_sync(_S2041, true);
                c_42 = c_42 + 256U;
                _S2041 = _S2062;
            }
            __syncthreads();
            uint _S2063 = __ballot_sync(_S2020, true);
            i_28 = _S2063;
        }
        else
        {
            uint _S2064 = __ballot_sync(_S2020, true);
            i_28 = _S2064;
        }
        uint _S2065 = __ballot_sync(i_28, _S1931);
        bool _S2066;
        if(_S1931)
        {
            bool _S2067 = !quiet_0;
            uint _S2068 = __ballot_sync(i_28, true);
            _S2066 = _S2067;
            _S2040 = _S2068;
        }
        else
        {
            uint _S2069 = __ballot_sync(i_28, true);
            _S2066 = false;
            _S2040 = _S2069;
        }
        uint _S2070 = __ballot_sync(_S2040, _S2066);
        if(_S2066)
        {
            Island_0 _S2071 = isl_22;
            integrate_rigid_0(&_S2071, &rg_9, _S1968);
            uint _S2072 = __ballot_sync(_S2040, true);
            c_42 = _S2072;
        }
        else
        {
            uint _S2073 = __ballot_sync(_S2040, true);
            c_42 = _S2073;
        }
        uint _S2074 = __ballot_sync(c_42, _S1929);
        bool _S2075;
        if(_S1929)
        {
            uint _S2076 = __ballot_sync(c_42, true);
            _S2075 = explicit_step_0;
            _S2041 = _S2076;
        }
        else
        {
            uint _S2077 = __ballot_sync(c_42, true);
            _S2075 = false;
            _S2041 = _S2077;
        }
        uint _S2078 = __ballot_sync(_S2041, _S2075);
        uint c_43;
        uint _S2079;
        uint c_44;
        uint _S2080;
        uint c_45;
        if(_S2075)
        {
            float4  _S2081 = (&isl_22)->wcom_0;
            float3  _S2082 = float3 {_S2081.x, _S2081.y, _S2081.z};
            float3  _S2083 = make_float3 (0.0f);
            float3  tu_3 = _S2083;
            float3  pv_3 = _S2083;
            c_43 = (&isl_22)->range_0.x + tid_19;
            _S2079 = _S2078;
            for(;;)
            {
                bool _S2084 = c_43 < ((&isl_22)->range_0.y);
                uint _S2085 = __ballot_sync(_S2079, _S2084);
                if(_S2084)
                {
                    uint _S2086 = __ballot_sync(_S2079, true);
                }
                else
                {
                    uint _S2087 = __ballot_sync(_S2079, false);
                    uint _S2088 = __ballot_sync(_S2079, false);
                    uint _S2089 = __ballot_sync(_S2078, true);
                    _S1926 = _S2089;
                    break;
                }
                drift_moments_0(c_43, &tu_3, &pv_3);
                uint _S2090 = __ballot_sync(_S2079, true);
                c_43 = c_43 + 256U;
                _S2079 = _S2090;
            }
            group_sum3_0(tid_19, &tu_3, &pv_3, _S1926);
            float3  tr_5 = tu_3 / make_float3 ((&isl_22)->wcom_0.w);
            float3  dv_5 = pv_3 / make_float3 ((&isl_22)->wcom_0.w);
            float3  lu_3 = _S2083;
            float3  lv_3 = _S2083;
            c_44 = (&isl_22)->range_0.x + tid_19;
            _S2080 = _S1926;
            for(;;)
            {
                bool _S2091 = c_44 < ((&isl_22)->range_0.y);
                uint _S2092 = __ballot_sync(_S2080, _S2091);
                if(_S2091)
                {
                    uint _S2093 = __ballot_sync(_S2080, true);
                }
                else
                {
                    uint _S2094 = __ballot_sync(_S2080, false);
                    uint _S2095 = __ballot_sync(_S2080, false);
                    uint _S2096 = __ballot_sync(_S1926, true);
                    _S1927 = _S2096;
                    break;
                }
                drift_angular_0(c_44, _S2082, tr_5, dv_5, &lu_3, &lv_3);
                uint _S2097 = __ballot_sync(_S2080, true);
                c_44 = c_44 + 256U;
                _S2080 = _S2097;
            }
            group_sum3_0(tid_19, &lu_3, &lv_3, _S1927);
            float3  phi_4 = rows_mul_0((&isl_22)->winv0_0, (&isl_22)->winv1_0, (&isl_22)->winv2_0, lu_3);
            float3  dw_3 = rows_mul_0((&isl_22)->winv0_0, (&isl_22)->winv1_0, (&isl_22)->winv2_0, lv_3);
            c_45 = (&isl_22)->range_0.x + tid_19;
            uint _S2098 = _S1927;
            for(;;)
            {
                bool _S2099 = c_45 < ((&isl_22)->range_0.y);
                uint _S2100 = __ballot_sync(_S2098, _S2099);
                if(_S2099)
                {
                    uint _S2101 = __ballot_sync(_S2098, true);
                }
                else
                {
                    uint _S2102 = __ballot_sync(_S2098, false);
                    uint _S2103 = __ballot_sync(_S2098, false);
                    uint _S2104 = __ballot_sync(_S1927, true);
                    _S1928 = _S2104;
                    break;
                }
                drift_apply_0(c_45, _S2082, tr_5, phi_4, dv_5, dw_3);
                uint _S2105 = __ballot_sync(_S2098, true);
                c_45 = c_45 + 256U;
                _S2098 = _S2105;
            }
            bool _S2106 = !driven_0;
            uint _S2107 = __ballot_sync(_S1928, _S2106);
            if(_S2106)
            {
                Island_0 _S2108 = isl_22;
                drift_rigid_0(&_S2108, &rg_9, tr_5, phi_4, dv_5, dw_3);
                uint _S2109 = __ballot_sync(_S1928, true);
            }
            else
            {
                uint _S2110 = __ballot_sync(_S1928, true);
            }
            __syncthreads();
            uint _S2111 = __ballot_sync(_S2041, true);
            c_43 = _S2111;
        }
        else
        {
            uint _S2112 = __ballot_sync(_S2041, true);
            c_43 = _S2112;
        }
        uint _S2113 = __ballot_sync(c_43, _S1936);
        bool _S2114;
        if(_S1936)
        {
            bool _S2115 = ((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x);
            uint _S2116 = __ballot_sync(c_43, true);
            _S2114 = _S2115;
            _S2079 = _S2116;
        }
        else
        {
            uint _S2117 = __ballot_sync(c_43, true);
            _S2114 = false;
            _S2079 = _S2117;
        }
        uint _S2118 = __ballot_sync(_S2079, _S2114);
        if(_S2114)
        {
            Island_0 _S2119 = isl_22;
            Rigid_0 _S2120 = rg_9;
            record_probes_0(&_S2119, &_S2120, k_22);
            uint _S2121 = __ballot_sync(_S2079, true);
            c_44 = _S2121;
        }
        else
        {
            uint _S2122 = __ballot_sync(_S2079, true);
            c_44 = _S2122;
        }
        uint _S2123 = done_1 + 1U;
        bool _S2124 = (*&g_halt_0) != 0U;
        uint _S2125 = __ballot_sync(c_44, _S2124);
        bool _S2126;
        if(_S2124)
        {
            Island_0 _S2127 = isl_22;
            bool _S2128 = island_connected_narrow_0(tid_19, &_S2127);
            uint _S2129 = __ballot_sync(c_44, true);
            _S2126 = _S2128;
            _S2080 = _S2129;
        }
        else
        {
            uint _S2130 = __ballot_sync(c_44, true);
            _S2126 = false;
            _S2080 = _S2130;
        }
        uint _S2131 = __ballot_sync(_S2080, _S2126);
        bool resumed_1;
        if(_S2126)
        {
            uint _S2132 = __ballot_sync(_S2131, _S1936);
            if(_S1936)
            {
                *&g_halt_0 = 0U;
                uint _S2133 = __ballot_sync(_S2131, true);
            }
            else
            {
                uint _S2134 = __ballot_sync(_S2131, true);
            }
            __syncthreads();
            uint _S2135 = __ballot_sync(_S2080, true);
            resumed_1 = true;
            c_45 = _S2135;
        }
        else
        {
            uint _S2136 = __ballot_sync(_S2080, true);
            resumed_1 = resumed_0;
            c_45 = _S2136;
        }
        bool _S2137 = (*&g_halt_0) != 0U;
        uint _S2138 = __ballot_sync(c_45, _S2137);
        if(_S2137)
        {
            uint _S2139 = __ballot_sync(c_45, false);
            uint _S2140 = __ballot_sync(_S1975, false);
            uint _S2141 = __ballot_sync(run_0, true);
            done_1 = _S2123;
            resumed_0 = resumed_1;
            cov_2 = _S2141;
            break;
        }
        else
        {
            uint _S2142 = __ballot_sync(c_45, true);
        }
        uint _S2143 = __ballot_sync(_S1975, true);
        done_1 = _S2123;
        woke_1 = woke_0;
        resumed_0 = resumed_1;
        _S1975 = _S2143;
    }
    float3  wsum_0 = make_float3 (work_3, work_err_1, 0.0f);
    float3  unused_3 = make_float3 (0.0f);
    group_sum3_0(tid_19, &wsum_0, &unused_3, cov_2);
    uint _S2144 = __ballot_sync(cov_2, _S1936);
    if(_S1936)
    {
        Quat_0 _S2145 = (&rg_9)->rot_1;
        float4  _S2146 = quat_vec_0(&_S2145);
        (&isl_22)->rotation_0 = _S2146;
        (&isl_22)->rotation_err_0 = (&rg_9)->rot_err_0;
        (&isl_22)->position_0 = make_float4 ((&rg_9)->pos_0.x, (&rg_9)->pos_0.y, (&rg_9)->pos_0.z, 0.0f);
        (&isl_22)->position_err_0 = make_float4 ((&rg_9)->pos_err_0.x, (&rg_9)->pos_err_0.y, (&rg_9)->pos_err_0.z, 0.0f);
        (&isl_22)->velocity_0 = make_float4 ((&rg_9)->vel_0.x, (&rg_9)->vel_0.y, (&rg_9)->vel_0.z, 0.0f);
        (&isl_22)->velocity_err_0 = make_float4 ((&rg_9)->vel_err_0.x, (&rg_9)->vel_err_0.y, (&rg_9)->vel_err_0.z, 0.0f);
        (&isl_22)->angular_velocity_0 = make_float4 ((&rg_9)->w_5.x, (&rg_9)->w_5.y, (&rg_9)->w_5.z, 0.0f);
        (&isl_22)->momentum_0 = make_float4 ((&rg_9)->l_1.x, (&rg_9)->l_1.y, (&rg_9)->l_1.z, 0.0f);
        (&isl_22)->momentum_err_0 = make_float4 ((&rg_9)->l_err_0.x, (&rg_9)->l_err_0.y, (&rg_9)->l_err_0.z, 0.0f);
        (&isl_22)->done_0 = done_1;
        *&((&(&isl_22)->info_1)->y) = *&((&(&isl_22)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S1931 = contact_island_0;
        }
        else
        {
            _S1931 = false;
        }
        if(_S1931)
        {
            contact_split_at_0((&isl_22)->info_1.w + done_1);
        }
        comp_add1_0(&((&(&isl_22)->energy_1)->x), &((&(&isl_22)->energy_1)->y), wsum_0.x);
        *&((&(&isl_22)->energy_1)->y) = *&((&(&isl_22)->energy_1)->y) + wsum_0.y;
        *&((&(&isl_22)->info_1)->w) = *&((&(&isl_22)->info_1)->w) + done_1;
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_22)->info_1)->z) = (*&((&(&isl_22)->info_1)->z)) | 1U;
        }
        uint _S2147 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S2148 = _S2147 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S2149 = _S2148 | cov_2;
        if(resumed_0)
        {
            cov_2 = 2097280U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S2149 | cov_2;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_22)->info_1.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_2 = 4096U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_4 = cov_3 | cov_2;
            if((((&isl_22)->info_1.x) & 16U) != 0U)
            {
                _S1931 = !quiet_1;
            }
            else
            {
                _S1931 = false;
            }
            if(_S1931)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            uint _S2150 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S2150 == 1U)
            {
                cov_2 = 524288U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_6 = cov_5 | cov_2;
            if(((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x))
            {
                cov_2 = 262144U;
            }
            else
            {
                cov_2 = 0U;
            }
            cov_2 = cov_6 | cov_2;
        }
        else
        {
            cov_2 = cov_3;
        }
        (&isl_22)->coverage_0 = ((&isl_22)->coverage_0) | cov_2;
        if(woke_0)
        {
            *&((&(&isl_22)->info_1)->x) = (*&((&(&isl_22)->info_1)->x)) & 4294967279U;
            *&((&(&isl_22)->info_1)->z) = (*&((&(&isl_22)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[gi_0]) = isl_22;
    }
    return;
}

extern "C" __global__ void island_frame()
{
    uint _S2151 = __ballot_sync(4294967295U, true);
    island_frame_at_0(blockIdx.x, threadIdx.x, _S2151);
    return;
}

static __device__ void wide_chunks_at_0(uint gx_0, uint tid_20, uint _S2152)
{
    uint _S2153 = 0U;
    uint _S2154 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    WideGroup_0 wg_5 = wide_group_0(_S2154, gx_0);
    Island_0 isl_23 = *(&(globalParams_0->islands_0)[wg_5.island_2]);
    bool _S2155 = wide_enter_1(tid_20, wg_5.island_2);
    bool _S2156 = !_S2155;
    uint _S2157 = __ballot_sync(_S2152, _S2156);
    if(_S2156)
    {
        return;
    }
    else
    {
        uint _S2158 = __ballot_sync(_S2152, true);
        _S2153 = _S2158;
    }
    uint _S2159 = 0U;
    uint _S2160 = isl_23.info_1.x;
    bool anchored_0 = (_S2160 & 1U) != 0U;
    bool _S2161 = (_S2160 & 16U) != 0U;
    uint _S2162 = __ballot_sync(_S2153, _S2161);
    if(_S2161)
    {
        if(tid_20 == 0U)
        {
            uint _S2163 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S2163 + 8U * gx_0 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S2164 = __ballot_sync(_S2153, true);
        _S2159 = _S2164;
    }
    Island_0 _S2165 = isl_23;
    WideGroup_0 _S2166 = wg_5;
    Rigid_0 _S2167 = wide_rigid_frame_0(tid_20, &_S2165, &_S2166, _S2159);
    float work_4 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S2168 = make_float3 (0.0f);
    float3  tu_4 = _S2168;
    float3  pv_4 = _S2168;
    uint c_46 = wg_5.begin_0 + tid_20;
    bool _S2169 = c_46 < (wg_5.end_0);
    uint _S2170 = __ballot_sync(_S2159, _S2169);
    uint _S2171;
    if(_S2169)
    {
        float _S2172 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2173 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S2174 = _S2173 != 0U;
        Island_0 _S2175 = isl_23;
        uint _S2176 = wide_step_0(&_S2175);
        bool _S2177 = (_S2160 & 4U) != 0U;
        Island_0 _S2178 = isl_23;
        Rigid_0 _S2179 = _S2167;
        chunk_update_0(c_46, &_S2178, &_S2179, _S2172, _S2174, _S2176, _S2177, &work_4, &work_err_2);
        bool _S2180 = !anchored_0;
        uint _S2181 = __ballot_sync(_S2170, _S2180);
        if(_S2180)
        {
            drift_moments_0(c_46, &tu_4, &pv_4);
            uint _S2182 = __ballot_sync(_S2170, true);
        }
        else
        {
            uint _S2183 = __ballot_sync(_S2170, true);
        }
        uint _S2184 = __ballot_sync(_S2159, true);
        _S2171 = _S2184;
    }
    else
    {
        uint _S2185 = __ballot_sync(_S2159, true);
        _S2171 = _S2185;
    }
    float3  wsum_1 = make_float3 (work_4, work_err_2, 0.0f);
    float3  unused_4 = _S2168;
    group_sum3_0(tid_20, &wsum_1, &unused_4, _S2171);
    bool _S2186 = !anchored_0;
    uint _S2187 = __ballot_sync(_S2171, _S2186);
    if(_S2186)
    {
        group_sum3_0(tid_20, &tu_4, &pv_4, _S2187);
        uint _S2188 = __ballot_sync(_S2171, true);
    }
    if(tid_20 == 0U)
    {
        uint _S2189 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S2190 = 8U * gx_0;
        *(&(globalParams_0->scratch_0)[_S2189 + _S2190 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S2186)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4);
        }
        uint _S2191 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S2191 + _S2190 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_chunks()
{
    uint _S2192 = __ballot_sync(4294967295U, true);
    wide_chunks_at_0(blockIdx.x, threadIdx.x, _S2192);
    return;
}

extern "C" __global__ void sums_and_impactors()
{
    uint _S2193 = __ballot_sync(4294967295U, true);
    uint _S2194 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_0 = (_S2194 + 255U) / 256U;
    uint _S2195 = blockIdx.x;
    bool _S2196 = _S2195 < sums_groups_0;
    uint _S2197 = __ballot_sync(_S2193, _S2196);
    if(_S2196)
    {
        contact_sum_at_0(_S2195 * 256U + threadIdx.x);
    }
    else
    {
        impactor_integrate_at_0(_S2195 - sums_groups_0, threadIdx.x, _S2193 & (~_S2197));
        uint _S2198 = __ballot_sync(_S2193, true);
    }
    return;
}

extern "C" __global__ void islands_and_wide_chunks()
{
    uint _S2199 = __ballot_sync(4294967295U, true);
    uint _S2200 = blockIdx.x;
    uint _S2201 = __ldg(&globalParams_0->params_0->halt_index_0);
    bool _S2202 = _S2200 < _S2201;
    uint _S2203 = __ballot_sync(_S2199, _S2202);
    if(_S2202)
    {
        island_frame_at_0(_S2200, threadIdx.x, _S2203);
        uint _S2204 = __ballot_sync(_S2199, true);
    }
    else
    {
        uint _S2205 = _S2199 & (~_S2203);
        uint _S2206 = __ldg(&globalParams_0->params_0->halt_index_0);
        wide_chunks_at_0(_S2200 - _S2206, threadIdx.x, _S2205);
        uint _S2207 = __ballot_sync(_S2199, true);
    }
    return;
}

static __device__ void wide_bonds_at_0(uint gx_1, uint tid_21, uint _S2208)
{
    uint _S2209 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = gx_1 < _S2209;
    uint _S2210 = __ballot_sync(_S2208, bond_group_0);
    WideGroup_0 wg_6;
    uint _S2211;
    if(bond_group_0)
    {
        uint _S2212 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S2213 = wide_group_0(_S2212, gx_1);
        uint _S2214 = __ballot_sync(_S2208, true);
        wg_6 = _S2213;
        _S2211 = _S2214;
    }
    else
    {
        uint _S2215 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S2216 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S2217 = wide_group_0(_S2215, gx_1 - _S2216);
        uint _S2218 = __ballot_sync(_S2208, true);
        wg_6 = _S2217;
        _S2211 = _S2218;
    }
    uint _S2219 = 0U;
    WideGroup_0 _S2220 = wg_6;
    Island_0 isl_24 = *(&(globalParams_0->islands_0)[wg_6.island_2]);
    bool _S2221 = wide_enter_1(tid_21, wg_6.island_2);
    bool _S2222 = !_S2221;
    uint _S2223 = __ballot_sync(_S2211, _S2222);
    if(_S2222)
    {
        return;
    }
    else
    {
        uint _S2224 = __ballot_sync(_S2211, true);
        _S2219 = _S2224;
    }
    uint _S2225 = 0U;
    Island_0 _S2226 = isl_24;
    uint _S2227 = wide_step_0(&_S2226);
    uint _S2228 = __ballot_sync(_S2219, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_24.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_29 = wg_6.begin_0 + tid_21;
        bool _S2229;
        if(i_29 < (wg_6.end_0))
        {
            float _S2230 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S2231 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S2232 = bond_update_0(i_29, _S2230, _S2231 != 0U, isl_24.info_1.w + 1U, true);
            _S2229 = _S2232;
        }
        else
        {
            _S2229 = false;
        }
        if(_S2229)
        {
            *&((&(&(globalParams_0->islands_0)[_S2220.island_2])->info_1)->z) = (isl_24.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S2233 = __ballot_sync(_S2219, true);
        _S2225 = _S2233;
    }
    uint _S2234 = 0U;
    uint _S2235 = isl_24.info_1.x;
    bool _S2236 = (_S2235 & 1U) != 0U;
    uint _S2237 = __ballot_sync(_S2225, _S2236);
    if(_S2236)
    {
        return;
    }
    else
    {
        uint _S2238 = __ballot_sync(_S2225, true);
        _S2234 = _S2238;
    }
    float3  _S2239 = make_float3 (0.0f);
    float3  f_18 = _S2239;
    float3  t_16 = _S2239;
    uint c_47 = wg_6.begin_0 + tid_21;
    bool _S2240 = c_47 < (wg_6.end_0);
    uint _S2241 = __ballot_sync(_S2234, _S2240);
    if(_S2240)
    {
        Island_0 _S2242 = isl_24;
        Rigid_0 _S2243 = rigid_of_0(&_S2242);
        float _S2244 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S2245 = (_S2235 & 4U) != 0U;
        Island_0 _S2246 = isl_24;
        Rigid_0 _S2247 = _S2243;
        net_load_0(c_47, &_S2246, &_S2247, _S2227, _S2244, _S2245, &f_18, &t_16);
        uint _S2248 = __ballot_sync(_S2234, true);
        _S2211 = _S2248;
    }
    else
    {
        uint _S2249 = __ballot_sync(_S2234, true);
        _S2211 = _S2249;
    }
    group_sum3_0(tid_21, &f_18, &t_16, _S2211);
    bool _S2250 = tid_21 == 0U;
    uint _S2251 = __ballot_sync(_S2211, _S2250);
    if(_S2250)
    {
        uint _S2252 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(gx_1 - _S2252, 0U, f_18, t_16);
    }
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S2253 = __ballot_sync(4294967295U, true);
    wide_bonds_at_0(blockIdx.x, threadIdx.x, _S2253);
    return;
}

extern "C" __global__ void sums_impactors_bonds()
{
    uint _S2254 = __ballot_sync(4294967295U, true);
    uint _S2255 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_1 = (_S2255 + 255U) / 256U;
    uint _S2256 = __ldg(&globalParams_0->params_0->impactor_count_0);
    uint _S2257 = (U32_max((_S2256), (1U)));
    uint _S2258 = blockIdx.x;
    bool _S2259 = _S2258 < sums_groups_1;
    uint _S2260 = __ballot_sync(_S2254, _S2259);
    if(_S2259)
    {
        contact_sum_at_0(_S2258 * 256U + threadIdx.x);
    }
    else
    {
        uint _S2261 = _S2254 & (~_S2260);
        bool _S2262 = _S2258 < (sums_groups_1 + _S2257);
        uint _S2263 = __ballot_sync(_S2261, _S2262);
        if(_S2262)
        {
            impactor_integrate_at_0(_S2258 - sums_groups_1, threadIdx.x, _S2263);
            uint _S2264 = __ballot_sync(_S2261, true);
        }
        else
        {
            wide_bonds_at_0(_S2258 - sums_groups_1 - _S2257, threadIdx.x, _S2261 & (~_S2263));
            uint _S2265 = __ballot_sync(_S2261, true);
        }
    }
    return;
}

