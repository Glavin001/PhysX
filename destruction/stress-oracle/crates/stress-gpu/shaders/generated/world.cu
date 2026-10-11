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
    uint4  _S36 = __ldg(&(&(globalParams_0->chunks_0)[c_0])->info_0);
    Island_0 * _S37 = (&(globalParams_0->islands_0)[_S36.y]);
    Quat_0 q_2 = quat_of_0(_S37->rotation_0);
    WorldPoint_0 w_2;
    float4  _S38 = _S37->position_0;
    (&w_2)->hi_0 = float3 {_S38.x, _S38.y, _S38.z};
    float4  _S39 = _S37->position_err_0;
    (&w_2)->lo_0 = float3 {_S39.x, _S39.y, _S39.z};
    float4  _S40 = __ldg(&(&(globalParams_0->chunks_0)[c_0])->center_0);
    float4  _S41 = *(&(globalParams_0->state_0)[4U * c_0]);
    float3  _S42 = float3 {_S40.x, _S40.y, _S40.z} + float3 {_S41.x, _S41.y, _S41.z};
    Quat_0 _S43 = q_2;
    float3  _S44 = rotate_0(&_S43, _S42);
    (&w_2)->rel_0 = _S44;
    return w_2;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_2, WorldPoint_0 * b_2)
{
    return a_2->hi_0 - b_2->hi_0 + (a_2->lo_0 - b_2->lo_0) + (a_2->rel_0 - b_2->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_1)
{
    float n_0 = length_0(v_1);
    float3  _S45;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S45 = v_1 / make_float3 (n_0);
    }
    else
    {
        _S45 = make_float3 (0.0f);
    }
    return _S45;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_0, float angle_0)
{
    float3  a_3 = safe_normalize_0(axis_0);
    float _S46 = 0.5f * angle_0;
    float s_0 = (F32_sin((_S46)));
    Quat_0 q_3;
    (&q_3)->w_1 = (F32_cos((_S46)));
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
    uint4  _S47 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->info_0);
    Quat_0 q_4 = quat_of_0((&(globalParams_0->islands_0)[_S47.y])->rotation_0);
    float4  _S48 = *(&(globalParams_0->state_0)[4U * c_1 + 1U]);
    float3  th_0 = float3 {_S48.x, _S48.y, _S48.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_0, length_0(th_0));
    Box_0 b_3;
    (&b_3)->center_1 = center_2;
    float4  _S49 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot0_0);
    float _S50 = _S49.x;
    float4  _S51 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot1_0);
    float _S52 = _S51.x;
    float4  _S53 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot2_0);
    float3  _S54 = make_float3 (_S50, _S52, _S53.x);
    Quat_0 _S55 = hidden_0;
    float3  _S56 = rotate_0(&_S55, _S54);
    Quat_0 _S57 = q_4;
    float3  _S58 = rotate_0(&_S57, _S56);
    (&b_3)->axis0_0 = _S58;
    float4  _S59 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot0_0);
    float _S60 = _S59.y;
    float4  _S61 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot1_0);
    float _S62 = _S61.y;
    float4  _S63 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot2_0);
    float3  _S64 = make_float3 (_S60, _S62, _S63.y);
    Quat_0 _S65 = hidden_0;
    float3  _S66 = rotate_0(&_S65, _S64);
    Quat_0 _S67 = q_4;
    float3  _S68 = rotate_0(&_S67, _S66);
    (&b_3)->axis1_0 = _S68;
    float4  _S69 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot0_0);
    float _S70 = _S69.z;
    float4  _S71 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot1_0);
    float _S72 = _S71.z;
    float4  _S73 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->crot2_0);
    float3  _S74 = make_float3 (_S70, _S72, _S73.z);
    Quat_0 _S75 = hidden_0;
    float3  _S76 = rotate_0(&_S75, _S74);
    Quat_0 _S77 = q_4;
    float3  _S78 = rotate_0(&_S77, _S76);
    (&b_3)->axis2_0 = _S78;
    float4  _S79 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->half_0);
    (&b_3)->half_2 = float3 {_S79.x, _S79.y, _S79.z};
    float4  _S80 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->cmat_0);
    (&b_3)->hull_at_0 = (F32_asuint((_S80.z)));
    float4  _S81 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->cmat_0);
    (&b_3)->hull_v_0 = (F32_asuint((_S81.w))) & 255U;
    float4  _S82 = __ldg(&(&(globalParams_0->chunks_0)[c_1])->cmat_0);
    (&b_3)->hull_f_0 = (F32_asuint((_S82.w))) >> int(8);
    return b_3;
}

static __device__ uint sample_count_0(Box_0 * b_4)
{
    uint _S83 = b_4->hull_v_0;
    uint _S84;
    if((b_4->hull_v_0) == 0U)
    {
        _S84 = 14U;
    }
    else
    {
        _S84 = _S83 + b_4->hull_f_0;
    }
    return _S84;
}

static __device__ bool may_overlap_0(Box_0 * a_4, Box_0 * b_5)
{
    float3  _S85 = b_5->center_1 - a_4->center_1;
    float3  _S86 = a_4->half_2;
    float3  _S87 = b_5->half_2;
    float _S88 = 0.00000999999974738f * (length_0(a_4->half_2) + length_0(b_5->half_2));
    float3  _S89 = a_4->axis0_0;
    float3  _S90 = a_4->axis1_0;
    float3  _S91 = a_4->axis2_0;
    float3  _S92 = b_5->axis0_0;
    float3  _S93 = b_5->axis1_0;
    float3  _S94 = b_5->axis2_0;
    FixedArray<float3 , 6>  _S95 = { {
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
            l_0 = _S95[i_6];
        }
        else
        {
            uint _S96 = i_6 - 6U;
            l_0 = cross_0(_S95[_S96 / 3U], _S95[3U + _S96 % 3U]);
        }
        float len_0 = length_0(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_6 = i_6 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S85, l_0)))) > (_S86.x * (F32_abs((dot_0(_S89, l_0)))) + _S86.y * (F32_abs((dot_0(_S90, l_0)))) + _S86.z * (F32_abs((dot_0(_S91, l_0)))) + (_S87.x * (F32_abs((dot_0(_S92, l_0)))) + _S87.y * (F32_abs((dot_0(_S93, l_0)))) + _S87.z * (F32_abs((dot_0(_S94, l_0))))) + _S88 * len_0))
        {
            return false;
        }
        i_6 = i_6 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_2, float3  * v_2, float3  * w_3)
{
    uint4  _S97 = __ldg(&(&(globalParams_0->chunks_0)[c_2])->info_0);
    Island_0 * _S98 = (&(globalParams_0->islands_0)[_S97.y]);
    Quat_0 q_5 = quat_of_0(_S98->rotation_0);
    float4  _S99 = __ldg(&(&(globalParams_0->chunks_0)[c_2])->center_0);
    uint _S100 = 4U * c_2;
    float4  _S101 = *(&(globalParams_0->state_0)[_S100]);
    float4  _S102 = _S98->com_0;
    float3  _S103 = float3 {_S99.x, _S99.y, _S99.z} + float3 {_S101.x, _S101.y, _S101.z} - float3 {_S102.x, _S102.y, _S102.z};
    Quat_0 _S104 = q_5;
    float3  _S105 = rotate_0(&_S104, _S103);
    float4  _S106 = _S98->velocity_0;
    float4  _S107 = _S98->velocity_err_0;
    float4  _S108 = _S98->angular_velocity_0;
    float3  _S109 = float3 {_S108.x, _S108.y, _S108.z};
    float3  _S110 = float3 {_S106.x, _S106.y, _S106.z} + float3 {_S107.x, _S107.y, _S107.z} + cross_0(_S109, _S105);
    float4  _S111 = *(&(globalParams_0->state_0)[_S100 + 2U]);
    float3  _S112 = float3 {_S111.x, _S111.y, _S111.z};
    Quat_0 _S113 = q_5;
    float3  _S114 = rotate_0(&_S113, _S112);
    *v_2 = _S110 + _S114;
    float4  _S115 = *(&(globalParams_0->state_0)[_S100 + 3U]);
    float3  _S116 = float3 {_S115.x, _S115.y, _S115.z};
    Quat_0 _S117 = q_5;
    float3  _S118 = rotate_0(&_S117, _S116);
    *w_3 = _S109 + _S118;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_6, float3  local_0)
{
    return b_6->axis0_0 * make_float3 (local_0.x) + b_6->axis1_0 * make_float3 (local_0.y) + b_6->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_7, uint k_0)
{
    float3  _S119;
    if(k_0 == 0U)
    {
        _S119 = b_7->axis0_0;
    }
    else
    {
        if(k_0 == 1U)
        {
            _S119 = b_7->axis1_0;
        }
        else
        {
            _S119 = b_7->axis2_0;
        }
    }
    return _S119;
}

static __device__ float comp3_0(float3  v_3, uint k_1)
{
    float _S120;
    if(k_1 == 0U)
    {
        _S120 = v_3.x;
    }
    else
    {
        if(k_1 == 1U)
        {
            _S120 = v_3.y;
        }
        else
        {
            _S120 = v_3.z;
        }
    }
    return _S120;
}

static __device__ float3  sample_point_0(Box_0 * b_8, uint i_7)
{
    uint _S121 = b_8->hull_v_0;
    if((b_8->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_7 < _S121)
        {
            float4  _S122 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + i_7]));
            local_1 = float3 {_S122.x, _S122.y, _S122.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S123 = __ldg((&(globalParams_0->loads_0)[b_8->hull_at_0 + _S121 + b_8->hull_f_0 + (i_7 - _S121)]));
            local_1 = float3 {_S123.x, _S123.y, _S123.z};
        }
        float3  _S124 = b_8->center_1;
        float3  _S125 = box_to_world_0(b_8, local_1);
        return _S124 + _S125;
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
        float _S126;
        if((i_7 & 2U) == 0U)
        {
            _S126 = - h_0.y;
        }
        else
        {
            _S126 = h_0.y;
        }
        float _S127;
        if((i_7 & 4U) == 0U)
        {
            _S127 = - h_0.z;
        }
        else
        {
            _S127 = h_0.z;
        }
        return b_8->center_1 + b_8->axis0_0 * make_float3 (sign_0) + b_8->axis1_0 * make_float3 (_S126) + b_8->axis2_0 * make_float3 (_S127);
    }
    uint _S128 = i_7 - 8U;
    uint axis_1 = _S128 / 2U;
    if((_S128 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S129 = b_8->center_1;
    float3  _S130 = box_axis_0(b_8, axis_1);
    return _S129 + _S130 * make_float3 (sign_0 * comp3_0(b_8->half_2, axis_1));
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
        float4  _S131 = __ldg((&(globalParams_0->loads_0)[b_10->hull_at_0 + b_10->hull_v_0 + f_0]));
        float d_0 = dot_0(float3 {_S131.x, _S131.y, _S131.z}, local_2) - _S131.w;
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
    float3  _S132 = b_11->half_2;
    if((dot_0(r_2, r_2)) > (dot_0(b_11->half_2, b_11->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S133 = b_11->hull_v_0;
    if((b_11->hull_v_0) != 0U)
    {
        float3  _S134 = box_to_local_0(b_11, r_2);
        uint face_1;
        float _S135 = hull_signed_distance_0(b_11, _S134, &face_1);
        if(!(_S135 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S135;
        float4  _S136 = __ldg((&(globalParams_0->loads_0)[b_11->hull_at_0 + _S133 + face_1]));
        float3  _S137 = box_to_world_0(b_11, float3 {_S136.x, _S136.y, _S136.z});
        *normal_1 = _S137;
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
        float3  _S138 = box_axis_0(b_11, k_2);
        float local_3 = dot_0(r_2, _S138);
        float d_1 = comp3_0(_S132, k_2) - (F32_abs((local_3)));
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            float _S139;
            if(local_3 >= 0.0f)
            {
                _S139 = 1.0f;
            }
            else
            {
                _S139 = -1.0f;
            }
            best_1 = d_1;
            axis_2 = k_2;
            side_0 = _S139;
        }
        k_2 = k_2 + 1U;
    }
    *depth_0 = best_1;
    float3  _S140 = box_axis_0(b_11, axis_2);
    *normal_1 = _S140 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_0, float3  * p_1, float3  * n_1, float * d_2)
{
    if(e_0 < na_0)
    {
        float3  _S141 = sample_point_0(ba_0, e_0);
        *p_1 = _S141;
        bool _S142 = penetration_0(bb_0, _S141, d_2, n_1);
        return _S142;
    }
    float3  _S143 = sample_point_0(bb_0, e_0 - na_0);
    *p_1 = _S143;
    bool _S144 = penetration_0(ba_0, _S143, d_2, n_1);
    if(!_S144)
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

static __device__ uint pair_count_sum_0(uint x_14, uint lanes_1, uint _S145)
{
    bool _S146 = lanes_1 > 1U;
    uint _S147 = __ballot_sync(_S145, _S146);
    uint _S148;
    if(_S146)
    {
        uint _S149 = WaveActiveSum_3(x_14, _S147);
        uint _S150 = __ballot_sync(_S145, true);
        _S148 = _S149;
    }
    else
    {
        _S148 = x_14;
    }
    return _S148;
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
        float3  _S151 = box_axis_0(b_12, k_3);
        float c_3 = (F32_abs((dot_0(d_3, _S151))));
        float h_2 = h_1 + c_3 * comp3_0(b_12->half_2, k_3);
        uint _S152 = k_3 + 1U;
        float area_1 = area_0 + c_3 * 4.0f * comp3_0(b_12->half_2, _S152 % 3U) * comp3_0(b_12->half_2, (k_3 + 2U) % 3U);
        k_3 = _S152;
        h_1 = h_2;
        area_0 = area_1;
    }
    return make_float2 (h_1, area_0);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_5, float eb_0, Box_0 * b_13, float3  dir_0)
{
    float3  d_4 = safe_normalize_0(dir_0);
    float2  _S153 = half_thickness_and_area_0(a_5, d_4);
    float2  _S154 = half_thickness_and_area_0(b_13, d_4);
    return (F32_min((_S153.y), (_S154.y))) / (_S153.x / ea_0 + _S154.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_4, float m_red_0, float friction_0, float depth_1, float3  normal_2, float3  rel_velocity_0, float dt_1, uint points_0, float * stored_0, float * dissipated_1)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_1;
    float _S155 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_2);
    float _S156 = k_4 * depth_1;
    float _S157 = (F32_min((2.0f * _S155 * (F32_sqrt((k_4 * m_red_0)))), (c_max_0))) * vn_0;
    float _S158 = _S156 - _S157;
    float _S159 = (F32_max((_S158), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_2 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S160 = friction_0 * _S159;
    float _S161 = (F32_min((_S160), ((F32_min((c_max_0), (_S160 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S161 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_0 = 0.5f * k_4 * depth_1 * depth_1;
    float damping_power_0;
    if(_S158 > 0.0f)
    {
        damping_power_0 = _S157 * vn_0;
    }
    else
    {
        damping_power_0 = _S156 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_1 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_1;
    return normal_2 * make_float3 (_S159) + ft_0;
}

static __device__ float3  pair_sum3_0(float3  x_15, uint lanes_2, uint _S162)
{
    bool _S163 = lanes_2 > 1U;
    uint _S164 = __ballot_sync(_S162, _S163);
    float3  _S165;
    if(_S163)
    {
        float3  _S166 = WaveActiveSum_2(x_15, _S164);
        uint _S167 = __ballot_sync(_S162, true);
        _S165 = _S166;
    }
    else
    {
        _S165 = x_15;
    }
    return _S165;
}

static __device__ float pair_sum_0(float x_16, uint lanes_3, uint _S168)
{
    bool _S169 = lanes_3 > 1U;
    uint _S170 = __ballot_sync(_S168, _S169);
    float _S171;
    if(_S169)
    {
        float _S172 = WaveActiveSum_1(x_16, _S170);
        uint _S173 = __ballot_sync(_S168, true);
        _S171 = _S172;
    }
    else
    {
        _S171 = x_16;
    }
    return _S171;
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
    uint _S174 = atomicOr(&(&(globalParams_0->islands_0)[island_0])->coverage_0, bits_0);
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
    uint _S175 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S176 = __ldg(&globalParams_0->params_0->halt_index_0);
    cov_mark_0(_S175, (&(globalParams_0->islands_0)[_S176])->coverage_0, bits_2);
    return;
}

static __device__ void pair_contact_0(uint i_8, uint lane_0, uint lanes_4, uint _S177)
{
    uint _S178 = 0U;
    uint _S179;
    uint _S180;
    uint _S181 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_0 = _S181 + 6U * i_8;
    uint _S182 = __ldg((&(globalParams_0->index_0)[at_0]));
    uint _S183 = __ldg((&(globalParams_0->index_0)[at_0 + 1U]));
    uint _S184 = __ldg((&(globalParams_0->index_0)[at_0 + 2U]));
    uint _S185 = __ldg((&(globalParams_0->index_0)[at_0 + 3U]));
    uint _S186 = __ldg((&(globalParams_0->index_0)[at_0 + 4U]));
    float _S187 = (U32_asfloat((_S186)));
    uint _S188 = __ldg((&(globalParams_0->index_0)[at_0 + 5U]));
    float _S189 = (U32_asfloat((_S188)));
    float _S190 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S191 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S191 + 2U * _S184;
    WorldPoint_0 wa_0 = chunk_world_0(_S182);
    WorldPoint_0 _S192 = chunk_world_0(_S183);
    WorldPoint_0 _S193 = wa_0;
    float3  _S194 = world_diff_0(&_S192, &_S193);
    float _S195 = length_0(_S194);
    float4  _S196 = __ldg(&(&(globalParams_0->chunks_0)[_S182])->half_0);
    float _S197 = _S196.w;
    float4  _S198 = __ldg(&(&(globalParams_0->chunks_0)[_S183])->half_0);
    bool touching_0 = !(_S195 > (_S197 + _S198.w));
    uint _S199 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S200 = (&(globalParams_0->scratch_0)[_S199 + i_8]);
    float4  ledger_1 = *_S200;
    uint flags_0 = (F32_asuint(((*_S200).w)));
    float3  _S201 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S182, _S201);
    Box_0 bb_1 = chunk_box_0(_S183, _S194);
    Box_0 _S202 = ba_1;
    uint _S203 = sample_count_0(&_S202);
    Box_0 _S204 = bb_1;
    uint _S205 = sample_count_0(&_S204);
    uint _S206 = _S203 + _S205;
    bool _S207 = !touching_0;
    uint _S208 = __ballot_sync(_S177, _S207);
    uint e_1;
    bool has_state_0;
    if(_S207)
    {
        if((flags_0 & 1U) != 0U)
        {
            e_1 = lane_0;
            for(;;)
            {
                if(e_1 < _S206)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S185 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
                uint _S209 = __ldg(&globalParams_0->params_0->ledger_base_0);
                *(&(globalParams_0->scratch_0)[_S209 + i_8]) = ledger_1;
            }
        }
        return;
    }
    else
    {
        uint _S210 = __ballot_sync(_S177, true);
        _S178 = _S210;
    }
    Box_0 _S211 = ba_1;
    Box_0 _S212 = bb_1;
    bool _S213 = may_overlap_0(&_S211, &_S212);
    uint _S214 = __ballot_sync(_S178, _S213);
    uint count_0;
    float3  fa_0;
    float3  ta_0;
    float3  fb_0;
    float3  tb_0;
    float stored_sum_0;
    float diss_sum_0;
    if(_S213)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S182, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S183, &vb0_0, &wb0_0);
        e_1 = lane_0;
        count_0 = 0U;
        uint engaged_0 = 0U;
        uint _S215 = _S214;
        for(;;)
        {
            uint _S216 = 0U;
            bool _S217 = e_1 < _S206;
            uint _S218 = __ballot_sync(_S215, _S217);
            if(_S217)
            {
                uint _S219 = __ballot_sync(_S215, true);
                _S216 = _S219;
            }
            else
            {
                uint _S220 = __ballot_sync(_S215, false);
                uint _S221 = __ballot_sync(_S215, false);
                uint _S222 = __ballot_sync(_S214, true);
                _S179 = _S222;
                break;
            }
            uint _S223 = 0U;
            Box_0 _S224 = ba_1;
            Box_0 _S225 = bb_1;
            float3  p_2;
            float3  n_2;
            float d_5;
            bool _S226 = pair_point_0(&_S224, &_S225, _S203, e_1, &p_2, &n_2, &d_5);
            bool _S227 = !_S226;
            uint _S228 = __ballot_sync(_S216, _S227);
            if(_S227)
            {
                uint _S229 = _S185 + e_1;
                bool _S230 = !is_nan_0((*(&(globalParams_0->contact_state_0)[_S229])).x);
                uint _S231 = __ballot_sync(_S228, _S230);
                if(_S230)
                {
                    *(&(globalParams_0->contact_state_0)[_S229]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                    uint _S232 = __ballot_sync(_S228, true);
                }
                else
                {
                    uint _S233 = __ballot_sync(_S228, true);
                }
                uint _S234 = __ballot_sync(_S216, false);
                uint _S235 = __ballot_sync(_S215, true);
                _S215 = _S235;
                e_1 = e_1 + lanes_4;
                continue;
            }
            else
            {
                uint _S236 = __ballot_sync(_S216, true);
                _S223 = _S236;
            }
            uint _S237 = count_0 + 1U;
            uint _S238 = _S185 + e_1;
            float4  * _S239 = (&(globalParams_0->contact_state_0)[_S238]);
            float4  entry_0 = *_S239;
            bool _S240 = is_nan_0((*_S239).x);
            uint _S241 = __ballot_sync(_S223, _S240);
            uint _S242;
            if(_S240)
            {
                uint _S243 = __ballot_sync(_S223, true);
                has_state_0 = true;
                _S242 = _S243;
            }
            else
            {
                float4  _S244 = entry_0;
                bool _S245 = (dot_0(float3 {_S244.y, _S244.z, _S244.w}, n_2)) < 0.99000000953674316f;
                uint _S246 = __ballot_sync(_S223, true);
                has_state_0 = _S245;
                _S242 = _S246;
            }
            uint _S247 = __ballot_sync(_S242, has_state_0);
            uint _S248;
            if(has_state_0)
            {
                bool _S249 = d_5 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_2) - (vb0_0 + cross_0(wb0_0, p_2 - bb_1.center_1)), n_2)))) * _S190 + 9.99999971718068537e-10f);
                uint _S250 = __ballot_sync(_S247, _S249);
                if(_S249)
                {
                    float _S251 = d_5;
                    uint _S252 = __ballot_sync(_S247, true);
                    stored_sum_0 = _S251;
                }
                else
                {
                    uint _S253 = __ballot_sync(_S247, true);
                    stored_sum_0 = 0.0f;
                }
                entry_0 = make_float4 (stored_sum_0, n_2.x, n_2.y, n_2.z);
                uint _S254 = __ballot_sync(_S242, true);
                _S248 = _S254;
            }
            else
            {
                uint _S255 = __ballot_sync(_S242, true);
                _S248 = _S255;
            }
            *&((&entry_0)->x) = (F32_min((entry_0.x), (d_5)));
            *(&(globalParams_0->contact_state_0)[_S238]) = entry_0;
            bool _S256 = (d_5 - entry_0.x) > 0.0f;
            uint _S257 = __ballot_sync(_S248, _S256);
            uint engaged_1;
            if(_S256)
            {
                uint _S258 = engaged_0 + 1U;
                uint _S259 = __ballot_sync(_S248, true);
                engaged_1 = _S258;
            }
            else
            {
                uint _S260 = __ballot_sync(_S248, true);
                engaged_1 = engaged_0;
            }
            uint _S261 = __ballot_sync(_S215, true);
            count_0 = _S237;
            engaged_0 = engaged_1;
            _S215 = _S261;
            e_1 = e_1 + lanes_4;
        }
        uint _S262 = pair_count_sum_0(count_0, lanes_4, _S179);
        uint _S263 = pair_count_sum_0(engaged_0, lanes_4, _S179);
        bool _S264 = _S262 > 0U;
        uint _S265 = __ballot_sync(_S179, _S264);
        if(_S264)
        {
            float4  _S266 = __ldg(&(&(globalParams_0->chunks_0)[_S182])->cmat_0);
            float _S267 = _S266.x;
            float4  _S268 = __ldg(&(&(globalParams_0->chunks_0)[_S183])->cmat_0);
            float _S269 = _S268.x;
            float3  _S270 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S271 = ba_1;
            Box_0 _S272 = bb_1;
            float _S273 = contact_stiffness_0(_S267, &_S271, _S269, &_S272, _S270);
            float _S274 = _S273 / (F32_max((float(_S263)), (10.0f)));
            e_1 = lane_0;
            fa_0 = _S201;
            ta_0 = _S201;
            fb_0 = _S201;
            tb_0 = _S201;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            count_0 = _S265;
            for(;;)
            {
                uint _S275 = 0U;
                bool _S276 = e_1 < _S206;
                uint _S277 = __ballot_sync(count_0, _S276);
                if(_S276)
                {
                    uint _S278 = __ballot_sync(count_0, true);
                    _S275 = _S278;
                }
                else
                {
                    uint _S279 = __ballot_sync(count_0, false);
                    uint _S280 = __ballot_sync(count_0, false);
                    uint _S281 = __ballot_sync(_S265, true);
                    _S180 = _S281;
                    break;
                }
                uint _S282 = 0U;
                Box_0 _S283 = ba_1;
                Box_0 _S284 = bb_1;
                float3  p_3;
                float3  n_3;
                float d_6;
                bool _S285 = pair_point_0(&_S283, &_S284, _S203, e_1, &p_3, &n_3, &d_6);
                bool _S286 = !_S285;
                uint _S287 = __ballot_sync(_S275, _S286);
                if(_S286)
                {
                    uint _S288 = __ballot_sync(_S275, false);
                    uint _S289 = __ballot_sync(count_0, true);
                    count_0 = _S289;
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                else
                {
                    uint _S290 = __ballot_sync(_S275, true);
                    _S282 = _S290;
                }
                float eff_0 = d_6 - (*(&(globalParams_0->contact_state_0)[_S185 + e_1])).x;
                bool _S291 = eff_0 <= 0.0f;
                uint _S292 = __ballot_sync(_S282, _S291);
                if(_S291)
                {
                    uint _S293 = __ballot_sync(_S282, false);
                    uint _S294 = __ballot_sync(count_0, true);
                    count_0 = _S294;
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                else
                {
                    uint _S295 = __ballot_sync(_S282, true);
                }
                float stored_1;
                float diss_0;
                float3  f_1 = penalty_force_0(_S274, _S187, _S189, eff_0, n_3, va0_0 + cross_0(wa0_0, p_3) - (vb0_0 + cross_0(wb0_0, p_3 - bb_1.center_1)), _S190, _S263, &stored_1, &diss_0);
                float3  fa_1 = fa_0 + f_1;
                float3  ta_1 = ta_0 + cross_0(p_3, f_1);
                float3  _S296 = - f_1;
                float3  fb_1 = fb_0 + _S296;
                float3  tb_1 = tb_0 + cross_0(p_3 - bb_1.center_1, _S296);
                float stored_sum_1 = stored_sum_0 + stored_1;
                float diss_sum_1 = diss_sum_0 + diss_0;
                uint _S297 = __ballot_sync(count_0, true);
                fa_0 = fa_1;
                ta_0 = ta_1;
                fb_0 = fb_1;
                tb_0 = tb_1;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                count_0 = _S297;
                e_1 = e_1 + lanes_4;
            }
            float3  _S298 = pair_sum3_0(fa_0, lanes_4, _S180);
            float3  _S299 = pair_sum3_0(ta_0, lanes_4, _S180);
            float3  _S300 = pair_sum3_0(fb_0, lanes_4, _S180);
            float3  _S301 = pair_sum3_0(tb_0, lanes_4, _S180);
            float _S302 = pair_sum_0(stored_sum_0, lanes_4, _S180);
            float _S303 = pair_sum_0(diss_sum_0, lanes_4, _S180);
            uint _S304 = __ballot_sync(_S179, true);
            has_state_0 = true;
            diss_sum_0 = _S303;
            fa_0 = _S298;
            ta_0 = _S299;
            fb_0 = _S300;
            tb_0 = _S301;
            stored_sum_0 = _S302;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_0 = _S201;
            ta_0 = _S201;
            fb_0 = _S201;
            tb_0 = _S201;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_0 = _S201;
        ta_0 = _S201;
        fb_0 = _S201;
        tb_0 = _S201;
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
            if(e_1 < _S206)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S185 + e_1]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
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
    bool _S305;
    if(loaded_0)
    {
        _S305 = true;
    }
    else
    {
        _S305 = (flags_0 & 2U) != 0U;
    }
    if(_S305)
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
    uint _S306 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S306 + i_8]) = ledger_1;
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
    float3  _S307 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S308 = q_6;
    float3  _S309 = rotate_0(&_S308, _S307);
    (&b_14)->axis0_0 = _S309;
    float3  _S310 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S311 = q_6;
    float3  _S312 = rotate_0(&_S311, _S310);
    (&b_14)->axis1_0 = _S312;
    float3  _S313 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S314 = q_6;
    float3  _S315 = rotate_0(&_S314, _S313);
    (&b_14)->axis2_0 = _S315;
    (&b_14)->half_2 = half_3;
    (&b_14)->hull_at_0 = 0U;
    (&b_14)->hull_v_0 = 0U;
    (&b_14)->hull_f_0 = 0U;
    return b_14;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_15)
{
    uint _S316;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S316 = 1U;
    }
    else
    {
        uint _S317 = sample_count_0(b_15);
        _S316 = _S317 + 14U;
    }
    return _S316;
}

static __device__ bool sphere_contact_0(Box_0 * b_16, float3  center_4, float radius_0, float3  * point_0, float3  * normal_3, float * depth_2)
{
    float3  _S318 = make_float3 (0.0f);
    *point_0 = _S318;
    *normal_3 = _S318;
    *depth_2 = 0.0f;
    float3  _S319 = b_16->center_1;
    float3  r_3 = center_4 - b_16->center_1;
    float3  _S320 = b_16->axis0_0;
    float3  _S321 = b_16->axis1_0;
    float3  _S322 = b_16->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_3, b_16->axis0_0), dot_0(r_3, b_16->axis1_0), dot_0(r_3, b_16->axis2_0));
    uint _S323 = b_16->hull_v_0;
    if((b_16->hull_v_0) != 0U)
    {
        uint face_2;
        float _S324 = hull_signed_distance_0(b_16, local_4, &face_2);
        if(_S324 >= radius_0)
        {
            return false;
        }
        float4  _S325 = __ldg((&(globalParams_0->loads_0)[b_16->hull_at_0 + _S323 + face_2]));
        float3  _S326 = box_to_world_0(b_16, float3 {_S325.x, _S325.y, _S325.z});
        *normal_3 = _S326;
        *point_0 = center_4 - _S326 * make_float3 ((F32_max((_S324), (0.0f))));
        *depth_2 = radius_0 - _S324;
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
        *normal_3 = _S320 * make_float3 (dn_0.x) + _S321 * make_float3 (dn_0.y) + _S322 * make_float3 (dn_0.z);
        *point_0 = _S319 + _S320 * make_float3 (q_7.x) + _S321 * make_float3 (q_7.y) + _S322 * make_float3 (q_7.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_4;
    bool _S327 = penetration_0(b_16, center_4, &inside_0, &n_4);
    if(!_S327)
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
    float3  _S328 = make_float3 (0.0f);
    *p_4 = _S328;
    *n_5 = _S328;
    *d_8 = 0.0f;
    float4  _S329 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S330 = sphere_contact_0(b_17, _S328, _S329.y - crush_depth_0, p_4, n_5, d_8);
        if(!_S330)
        {
            return false;
        }
        *n_5 = - *n_5;
        return true;
    }
    uint _S331 = sample_count_0(b_17);
    if(j_0 < _S331)
    {
        float3  _S332 = sample_point_0(b_17, j_0);
        *p_4 = _S332;
        bool _S333 = penetration_0(shrunk_0, _S332, d_8, n_5);
        return _S333;
    }
    float3  _S334 = sample_point_0(shrunk_0, j_0 - _S331);
    *p_4 = _S334;
    bool _S335 = penetration_0(b_17, _S334, d_8, n_5);
    if(!_S335)
    {
        return false;
    }
    *n_5 = - *n_5;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S336)
{
    Impactor_0 * _S337 = (&(globalParams_0->impactors_0)[_S336]);
    WorldPoint_0 wi_0;
    float4  _S338 = _S337->position_1;
    (&wi_0)->hi_0 = float3 {_S338.x, _S338.y, _S338.z};
    float4  _S339 = _S337->position_err_1;
    (&wi_0)->lo_0 = float3 {_S339.x, _S339.y, _S339.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S340, float3  _S341, float3  _S342)
{
    Quat_0 q_8 = quat_of_0((&(globalParams_0->impactors_0)[_S340])->rotation_1);
    Box_0 b_18;
    (&b_18)->center_1 = _S341;
    float3  _S343 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S344 = q_8;
    float3  _S345 = rotate_0(&_S344, _S343);
    (&b_18)->axis0_0 = _S345;
    float3  _S346 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S347 = q_8;
    float3  _S348 = rotate_0(&_S347, _S346);
    (&b_18)->axis1_0 = _S348;
    float3  _S349 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S350 = q_8;
    float3  _S351 = rotate_0(&_S350, _S349);
    (&b_18)->axis2_0 = _S351;
    (&b_18)->half_2 = _S342;
    (&b_18)->hull_at_0 = 0U;
    (&b_18)->hull_v_0 = 0U;
    (&b_18)->hull_f_0 = 0U;
    return b_18;
}

static __device__ Box_0 impactor_shrunk_0(uint _S352, float _S353, Box_0 * _S354)
{
    Box_0 shrunk_1 = *_S354;
    (&shrunk_1)->half_2 = _S354->half_2 - min_0(make_float3 (_S353), _S354->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S355, float _S356, Box_0 * _S357, Box_0 * _S358, uint _S359, float3  * _S360, float3  * _S361, float * _S362)
{
    Impactor_0 _S363 = *(&(globalParams_0->impactors_0)[_S355]);
    float3  _S364 = make_float3 (0.0f);
    *_S360 = _S364;
    *_S361 = _S364;
    *_S362 = 0.0f;
    if((_S363.shape_0.x) == 0.0f)
    {
        bool _S365 = sphere_contact_0(_S358, _S364, _S363.shape_0.y - _S356, _S360, _S361, _S362);
        if(!_S365)
        {
            return false;
        }
        *_S361 = - *_S361;
        return true;
    }
    uint _S366 = sample_count_0(_S358);
    if(_S359 < _S366)
    {
        float3  _S367 = sample_point_0(_S358, _S359);
        *_S360 = _S367;
        bool _S368 = penetration_0(_S357, _S367, _S362, _S361);
        return _S368;
    }
    float3  _S369 = sample_point_0(_S357, _S359 - _S366);
    *_S360 = _S369;
    bool _S370 = penetration_0(_S358, _S369, _S362, _S361);
    if(!_S370)
    {
        return false;
    }
    *_S361 = - *_S361;
    return true;
}

static __device__ void impactor_candidate_forces_0(uint k_5, uint lane_1, uint lanes_5, uint _S371)
{
    uint _S372;
    uint _S373;
    bool _S374;
    uint _S375;
    uint _S376 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S377 = 3U * k_5;
    uint at_1 = _S376 + _S377;
    uint _S378 = __ldg((&(globalParams_0->index_0)[at_1]));
    uint _S379 = __ldg((&(globalParams_0->index_0)[at_1 + 1U]));
    uint _S380 = __ldg((&(globalParams_0->index_0)[at_1 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S380]);
    float _S381 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S382 = make_float3 (0.0f);
    uint _S383 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S383 + _S377]);
    bool _S384 = (imp_3.cand_0.z) == 0U;
    uint _S385 = __ballot_sync(_S371, _S384);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if(_S384)
    {
        WorldPoint_0 _S386 = impactor_point_0(_S380);
        WorldPoint_0 _S387 = chunk_world_0(_S378);
        WorldPoint_0 _S388 = _S386;
        float3  _S389 = world_diff_0(&_S387, &_S388);
        float _S390 = length_0(_S389);
        float _S391 = imp_3.half_1.w;
        float4  _S392 = __ldg(&(&(globalParams_0->chunks_0)[_S378])->half_0);
        bool _S393 = !(_S390 > (_S391 + _S392.w));
        uint _S394 = __ballot_sync(_S385, _S393);
        if(_S393)
        {
            float4  _S395 = imp_3.half_1;
            Box_0 _S396 = impactor_box_1(_S380, _S382, float3 {_S395.x, _S395.y, _S395.z});
            Box_0 b_19 = chunk_box_0(_S378, _S389);
            float _S397 = imp_3.mat_0.x;
            float4  _S398 = __ldg(&(&(globalParams_0->chunks_0)[_S378])->cmat_0);
            float _S399 = _S398.x;
            float3  _S400 = b_19.center_1 - _S396.center_1;
            Box_0 _S401 = _S396;
            Box_0 _S402 = b_19;
            float _S403 = contact_stiffness_0(_S397, &_S401, _S399, &_S402, _S400);
            float _S404 = imp_3.geom_0.y;
            Box_0 _S405 = _S396;
            Box_0 _S406 = impactor_shrunk_0(_S380, _S404, &_S405);
            uint j_1 = lane_1;
            uint n_6 = 0U;
            uint j_2 = _S394;
            for(;;)
            {
                uint _S407 = 0U;
                Impactor_0 _S408 = imp_3;
                Box_0 _S409 = b_19;
                uint _S410 = impactor_slots_0(&_S408, &_S409);
                _S372 = _S410;
                bool _S411 = j_1 < _S410;
                uint _S412 = __ballot_sync(j_2, _S411);
                if(_S411)
                {
                    uint _S413 = __ballot_sync(j_2, true);
                    _S407 = _S413;
                }
                else
                {
                    uint _S414 = __ballot_sync(j_2, false);
                    uint _S415 = __ballot_sync(j_2, false);
                    uint _S416 = __ballot_sync(_S394, true);
                    _S373 = _S416;
                    break;
                }
                Box_0 _S417 = _S406;
                Box_0 _S418 = b_19;
                float3  p_5;
                float3  nrm_0;
                float dep_0;
                bool _S419 = impactor_contact_1(_S380, _S404, &_S417, &_S418, j_1, &p_5, &nrm_0, &dep_0);
                uint _S420 = __ballot_sync(_S407, _S419);
                if(_S419)
                {
                    uint _S421 = n_6 + 1U;
                    uint _S422 = __ballot_sync(_S407, true);
                    n_6 = _S421;
                }
                else
                {
                    uint _S423 = __ballot_sync(_S407, true);
                }
                uint _S424 = __ballot_sync(j_2, true);
                j_1 = j_1 + lanes_5;
                j_2 = _S424;
            }
            uint _S425 = pair_count_sum_0(n_6, lanes_5, _S373);
            bool _S426 = (imp_3.shape_0.x) == 0.0f;
            uint _S427 = __ballot_sync(_S373, _S426);
            float _S428;
            if(_S426)
            {
                uint _S429 = __ballot_sync(_S373, true);
                _S428 = _S403;
                j_1 = _S429;
            }
            else
            {
                float _S430 = _S403 / (F32_max((float(_S425)), (10.0f)));
                uint _S431 = __ballot_sync(_S373, true);
                _S428 = _S430;
                j_1 = _S431;
            }
            uint _S432 = __ballot_sync(j_1, _S426);
            if(_S426)
            {
                uint _S433 = __ballot_sync(j_1, true);
                j_1 = 1U;
                n_6 = _S433;
            }
            else
            {
                uint _S434 = __ballot_sync(j_1, true);
                j_1 = _S425;
                n_6 = _S434;
            }
            float4  _S435 = __ldg(&(&(globalParams_0->chunks_0)[_S378])->center_0);
            float m_1 = _S435.w;
            float _S436 = imp_3.mat_0.z;
            float _S437 = m_1 * _S436 / (m_1 + _S436);
            float _S438 = __ldg(&globalParams_0->params_0->pair_friction_0);
            bool _S439 = _S438 >= 0.0f;
            uint _S440 = __ballot_sync(n_6, _S439);
            float _S441;
            if(_S439)
            {
                float _S442 = __ldg(&globalParams_0->params_0->pair_friction_0);
                uint _S443 = __ballot_sync(n_6, true);
                _S441 = _S442;
                n_6 = _S443;
            }
            else
            {
                float _S444 = imp_3.mat_0.y;
                float4  _S445 = __ldg(&(&(globalParams_0->chunks_0)[_S378])->cmat_0);
                float _S446 = (F32_min((_S444), (_S445.y)));
                uint _S447 = __ballot_sync(n_6, true);
                _S441 = _S446;
                n_6 = _S447;
            }
            float4  _S448 = imp_3.velocity_1;
            float4  _S449 = imp_3.velocity_err_1;
            float3  _S450 = float3 {_S448.x, _S448.y, _S448.z} + float3 {_S449.x, _S449.y, _S449.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S378, &vc_0, &wc_0);
            hit_0 = false;
            j_2 = lane_1;
            f_sum_0 = _S382;
            t_sum_0 = _S382;
            imp_f_0 = _S382;
            imp_t_0 = _S382;
            float diss_sum_2 = 0.0f;
            uint _S451 = n_6;
            for(;;)
            {
                bool _S452 = _S425 > 0U;
                _S374 = _S452;
                uint _S453 = __ballot_sync(_S451, _S452);
                uint _S454;
                bool _S455;
                if(_S452)
                {
                    bool _S456 = j_2 < _S372;
                    uint _S457 = __ballot_sync(_S451, true);
                    _S455 = _S456;
                    _S454 = _S457;
                }
                else
                {
                    uint _S458 = __ballot_sync(_S451, true);
                    _S455 = false;
                    _S454 = _S458;
                }
                uint _S459 = 0U;
                uint _S460 = __ballot_sync(_S454, _S455);
                if(_S455)
                {
                    uint _S461 = __ballot_sync(_S454, true);
                    _S459 = _S461;
                }
                else
                {
                    uint _S462 = __ballot_sync(_S454, false);
                    uint _S463 = __ballot_sync(_S451, false);
                    uint _S464 = __ballot_sync(n_6, true);
                    _S375 = _S464;
                    break;
                }
                Impactor_0 _S465 = imp_3;
                Box_0 _S466 = _S406;
                Box_0 _S467 = b_19;
                float3  p_6;
                float3  nrm_1;
                float dep_1;
                bool _S468 = impactor_contact_0(&_S465, _S404, &_S466, &_S467, j_2, &p_6, &nrm_1, &dep_1);
                bool _S469 = !_S468;
                uint _S470 = __ballot_sync(_S459, _S469);
                if(_S469)
                {
                    uint _S471 = __ballot_sync(_S459, false);
                    uint _S472 = __ballot_sync(_S451, true);
                    _S451 = _S472;
                    j_2 = j_2 + lanes_5;
                    continue;
                }
                else
                {
                    uint _S473 = __ballot_sync(_S459, true);
                }
                float4  _S474 = imp_3.angular_velocity_1;
                float stored_2;
                float diss_1;
                float3  f_2 = penalty_force_0(_S428, _S437, _S441, dep_1 * imp_3.geom_0.x, nrm_1, vc_0 + cross_0(wc_0, p_6 - b_19.center_1) - (_S450 + cross_0(float3 {_S474.x, _S474.y, _S474.z}, p_6)), _S381, j_1, &stored_2, &diss_1);
                float3  f_sum_1 = f_sum_0 + f_2;
                float3  t_sum_1 = t_sum_0 + cross_0(p_6 - b_19.center_1, f_2);
                float3  imp_f_1 = imp_f_0 - f_2;
                float3  imp_t_1 = imp_t_0 - cross_0(p_6, f_2);
                float diss_sum_3 = diss_sum_2 + diss_1;
                uint _S475 = __ballot_sync(_S451, true);
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                _S451 = _S475;
                j_2 = j_2 + lanes_5;
            }
            float3  _S476 = pair_sum3_0(f_sum_0, lanes_5, _S375);
            float3  _S477 = pair_sum3_0(t_sum_0, lanes_5, _S375);
            float3  _S478 = pair_sum3_0(imp_f_0, lanes_5, _S375);
            float3  _S479 = pair_sum3_0(imp_t_0, lanes_5, _S375);
            float _S480 = pair_sum_0(diss_sum_2, lanes_5, _S375);
            bool _S481 = pair_any_0(hit_0, lanes_5, _S375);
            uint _S482 = __ballot_sync(_S375, _S374);
            if(_S374)
            {
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), _S480);
            }
            hit_0 = _S481;
            f_sum_0 = _S476;
            t_sum_0 = _S477;
            imp_f_0 = _S478;
            imp_t_0 = _S479;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S382;
            t_sum_0 = _S382;
            imp_f_0 = _S382;
            imp_t_0 = _S382;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S382;
        t_sum_0 = _S382;
        imp_f_0 = _S382;
        imp_t_0 = _S382;
    }
    if(lane_1 != 0U)
    {
        return;
    }
    uint _S483 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S484 = 2U * _S379;
    *(&(globalParams_0->scratch_0)[_S483 + _S484]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S485 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S485 + _S484 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S486 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S486 + _S377]) = data_0;
    uint _S487 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S487 + _S377 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S488 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S488 + _S377 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
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
    uint4  _S489 = __ldg(&(&(globalParams_0->chunks_0)[c_4])->cinfo_0);
    if((_S489.z) == 0U)
    {
        return;
    }
    uint _S490 = __ldg(&globalParams_0->params_0->cplan_base_0);
    uint _S491 = 4U * c_4;
    uint at_2 = _S490 + _S491;
    float4  * _S492 = (&(globalParams_0->scratch_0)[at_2]);
    float4  start_hi_0 = *_S492;
    float4  * _S493 = (&(globalParams_0->scratch_0)[at_2 + 1U]);
    float4  start_lo_0 = *_S493;
    float4  start_rot_0 = *(&(globalParams_0->scratch_0)[at_2 + 2U]);
    float4  start_vel_0 = *(&(globalParams_0->scratch_0)[at_2 + 3U]);
    WorldPoint_0 wp_0 = chunk_world_0(c_4);
    float4  _S494 = *_S492;
    float4  _S495 = *_S493;
    float3  moved_0 = wp_0.hi_0 - float3 {_S494.x, _S494.y, _S494.z} + (wp_0.lo_0 - float3 {_S495.x, _S495.y, _S495.z}) + wp_0.rel_0;
    float _S496 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S497 = _S496 - start_vel_0.w;
    float _S498 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S499 = _S497 + (_S498 - start_lo_0.w);
    uint4  _S500 = __ldg(&(&(globalParams_0->chunks_0)[c_4])->info_0);
    uint _S501 = (&(globalParams_0->islands_0)[_S500.y])->info_1.w;
    uint _S502 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S503 = float(_S501 - _S502);
    float _S504 = __ldg(&globalParams_0->params_0->dt_0);
    float since_0 = _S499 + _S503 * _S504;
    float3  _S505 = float3 {start_vel_0.x, start_vel_0.y, start_vel_0.z} * make_float3 (since_0);
    uint4  _S506 = __ldg(&(&(globalParams_0->chunks_0)[c_4])->cinfo_0);
    float3  _S507;
    if(((_S506.w) & 2U) != 0U)
    {
        float4  _S508 = __ldg(&globalParams_0->params_0->gravity_0);
        _S507 = make_float3 (0.5f) * float3 {_S508.x, _S508.y, _S508.z} * make_float3 (since_0) * make_float3 (since_0);
    }
    else
    {
        _S507 = make_float3 (0.0f);
    }
    float travel_0 = length_0(moved_0 - (_S505 + _S507));
    uint4  _S509 = __ldg(&(&(globalParams_0->chunks_0)[c_4])->cinfo_0);
    float travel_1;
    if(((_S509.w) & 1U) != 0U)
    {
        float4  _S510 = *(&(globalParams_0->state_0)[_S491 + 1U]);
        float3  th_1 = float3 {_S510.x, _S510.y, _S510.z};
        uint4  _S511 = __ldg(&(&(globalParams_0->chunks_0)[c_4])->info_0);
        Quat_0 _S512 = from_axis_angle_0(th_1, length_0(th_1));
        Quat_0 _S513 = quat_of_0((&(globalParams_0->islands_0)[_S511.y])->rotation_0);
        Quat_0 _S514 = _S512;
        Quat_0 _S515 = quat_mul_0(&_S513, &_S514);
        Quat_0 _S516 = quat_of_0(make_float4 ((- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).x, (- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).y, (- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).z, start_rot_0.w));
        Quat_0 _S517 = _S515;
        Quat_0 _S518 = quat_mul_0(&_S516, &_S517);
        float _S519 = 2.0f * (F32_atan2((length_0(make_float3 (_S518.x_12, _S518.y_4, _S518.z_0))), ((F32_abs((_S518.w_1))))));
        float4  _S520 = __ldg(&(&(globalParams_0->chunks_0)[c_4])->half_0);
        travel_1 = travel_0 + _S519 * _S520.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (start_hi_0.w))
    {
        uint _S521 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S522 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S521])->info_1)->z) = ((&(globalParams_0->islands_0)[_S522])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint _S523 = 0U;
    uint3  _S524 = blockIdx * blockDim + threadIdx;
    uint _S525 = __ballot_sync(4294967295U, true);
    uint i_9 = _S524.x;
    uint lanes_6 = pair_lane_count_0();
    uint _S526 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S526 * lanes_6;
    bool _S527 = i_9 < pair_threads_0;
    uint _S528 = __ballot_sync(_S525, _S527);
    if(_S527)
    {
        bool _S529 = pair_any_0(stopped_0(), lanes_6, _S528);
        bool _S530 = !_S529;
        uint _S531 = __ballot_sync(_S528, _S530);
        if(_S530)
        {
            uint _S532 = i_9 / lanes_6;
            uint _S533 = i_9 % lanes_6;
            pair_contact_0(_S532, _S533, lanes_6, _S531);
            uint _S534 = __ballot_sync(_S528, true);
        }
        return;
    }
    else
    {
        uint _S535 = __ballot_sync(_S525, true);
        _S523 = _S535;
    }
    uint j_3 = i_9 - pair_threads_0;
    uint _S536 = __ldg(&globalParams_0->params_0->cand_count_0);
    uint cand_threads_0 = _S536 * lanes_6;
    bool _S537 = j_3 < cand_threads_0;
    uint _S538 = __ballot_sync(_S523, _S537);
    if(_S537)
    {
        bool _S539 = pair_any_0(stopped_0(), lanes_6, _S538);
        bool _S540 = !_S539;
        uint _S541 = __ballot_sync(_S538, _S540);
        if(_S540)
        {
            uint _S542 = j_3 / lanes_6;
            uint _S543 = j_3 % lanes_6;
            impactor_candidate_forces_0(_S542, _S543, lanes_6, _S541);
            uint _S544 = __ballot_sync(_S538, true);
        }
        return;
    }
    uint _S545 = j_3 - cand_threads_0;
    uint _S546 = __ldg(&globalParams_0->params_0->chunk_count_0);
    bool _S547;
    if(_S545 < _S546)
    {
        _S547 = !stopped_0();
    }
    else
    {
        _S547 = false;
    }
    if(_S547)
    {
        travel_check_0(_S545);
    }
    return;
}

static __device__ uint impactor_contact_count_0(uint _S548, float _S549, Box_0 * _S550, Box_0 * _S551)
{
    Impactor_0 _S552 = *(&(globalParams_0->impactors_0)[_S548]);
    uint j_4 = 0U;
    uint count_1 = 0U;
    for(;;)
    {
        Impactor_0 _S553 = _S552;
        uint _S554 = impactor_slots_0(&_S553, _S551);
        if(j_4 < _S554)
        {
        }
        else
        {
            break;
        }
        float3  p_7;
        float3  n_7;
        float d_9;
        bool _S555 = impactor_contact_1(_S548, _S549, _S550, _S551, j_4, &p_7, &n_7, &d_9);
        if(_S555)
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
    uint _S556 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S557;
    if(k_6 >= _S556)
    {
        _S557 = true;
    }
    else
    {
        _S557 = stopped_0();
    }
    if(_S557)
    {
        return;
    }
    uint _S558 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S559 = 3U * k_6;
    uint at_3 = _S558 + _S559;
    uint _S560 = __ldg((&(globalParams_0->index_0)[at_3]));
    uint _S561 = __ldg((&(globalParams_0->index_0)[at_3 + 2U]));
    Impactor_0 * _S562 = (&(globalParams_0->impactors_0)[_S561]);
    Impactor_0 imp_4 = *_S562;
    if(((*_S562).cand_0.z) == 0U)
    {
        _S557 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S557 = false;
    }
    float total_0;
    float ksum_0;
    if(_S557)
    {
        WorldPoint_0 _S563 = impactor_point_0(_S561);
        WorldPoint_0 _S564 = chunk_world_0(_S560);
        WorldPoint_0 _S565 = _S563;
        float3  _S566 = world_diff_0(&_S564, &_S565);
        float _S567 = length_0(_S566);
        float _S568 = imp_4.half_1.w;
        float4  _S569 = __ldg(&(&(globalParams_0->chunks_0)[_S560])->half_0);
        if(!(_S567 > (_S568 + _S569.w)))
        {
            float4  _S570 = imp_4.half_1;
            Box_0 _S571 = impactor_box_1(_S561, make_float3 (0.0f), float3 {_S570.x, _S570.y, _S570.z});
            Box_0 b_20 = chunk_box_0(_S560, _S566);
            float _S572 = imp_4.mat_0.x;
            float4  _S573 = __ldg(&(&(globalParams_0->chunks_0)[_S560])->cmat_0);
            float _S574 = _S573.x;
            float3  _S575 = b_20.center_1 - _S571.center_1;
            Box_0 _S576 = _S571;
            Box_0 _S577 = b_20;
            float _S578 = contact_stiffness_0(_S572, &_S576, _S574, &_S577, _S575);
            float _S579 = imp_4.crush_1.w;
            Box_0 _S580 = _S571;
            Box_0 _S581 = impactor_shrunk_0(_S561, _S579, &_S580);
            Box_0 _S582 = _S581;
            Box_0 _S583 = b_20;
            uint _S584 = impactor_contact_count_0(_S561, _S579, &_S582, &_S583);
            float _S585;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S585 = _S578;
            }
            else
            {
                _S585 = _S578 / (F32_max((float(_S584)), (10.0f)));
            }
            uint j_5 = 0U;
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S584 > 0U)
                {
                    Impactor_0 _S586 = imp_4;
                    Box_0 _S587 = b_20;
                    uint _S588 = impactor_slots_0(&_S586, &_S587);
                    _S557 = j_5 < _S588;
                }
                else
                {
                    _S557 = false;
                }
                if(_S557)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S589 = imp_4;
                Box_0 _S590 = _S581;
                Box_0 _S591 = b_20;
                float3  p_8;
                float3  nrm_2;
                float dep_2;
                bool _S592 = impactor_contact_0(&_S589, _S579, &_S590, &_S591, j_5, &p_8, &nrm_2, &dep_2);
                if(!_S592)
                {
                    j_5 = j_5 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S585;
                total_0 = total_0 + _S585 * dep_2;
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
    uint _S593 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S593 + _S559]);
    uint _S594 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S594 + _S559]) = make_float4 (total_0, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S595;
    uint _S596 = __ballot_sync(4294967295U, true);
    uint ii_0 = blockIdx.x;
    uint tid_2 = threadIdx.x;
    uint _S597 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S598 = ii_0 >= _S597;
    uint _S599 = __ballot_sync(_S596, _S598);
    bool _S600;
    uint k_7;
    if(_S598)
    {
        uint _S601 = __ballot_sync(_S596, true);
        _S600 = true;
        k_7 = _S601;
    }
    else
    {
        bool _S602 = stopped_0();
        uint _S603 = __ballot_sync(_S596, true);
        _S600 = _S602;
        k_7 = _S603;
    }
    uint _S604 = 0U;
    uint _S605 = __ballot_sync(k_7, _S600);
    if(_S600)
    {
        return;
    }
    else
    {
        uint _S606 = __ballot_sync(k_7, true);
        _S604 = _S606;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_0]);
    float4  _S607 = make_float4 (0.0f);
    float4  shares_0 = _S607;
    float4  unused_0 = _S607;
    k_7 = (&imp_5)->cand_0.x + tid_2;
    uint _S608;
    _S608 = _S604;
    for(;;)
    {
        bool _S609 = k_7 < ((&imp_5)->cand_0.y);
        uint _S610 = __ballot_sync(_S608, _S609);
        if(_S609)
        {
            uint _S611 = __ballot_sync(_S608, true);
        }
        else
        {
            uint _S612 = __ballot_sync(_S608, false);
            uint _S613 = __ballot_sync(_S608, false);
            uint _S614 = __ballot_sync(_S604, true);
            _S595 = _S614;
            break;
        }
        uint _S615 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S615 + 3U * k_7]);
        uint _S616 = __ballot_sync(_S608, true);
        k_7 = k_7 + 256U;
        _S608 = _S616;
    }
    group_sum2_0(tid_2, &shares_0, &unused_0, _S595);
    bool _S617 = tid_2 != 0U;
    uint _S618 = __ballot_sync(_S595, _S617);
    if(_S617)
    {
        _S600 = true;
    }
    else
    {
        _S600 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S600)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_1 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S600 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S600 = false;
    }
    if(_S600)
    {
        _S600 = total_1 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S600 = false;
    }
    if(_S600)
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
    uint _S619 = table_0 + 4U * g_0;
    uint _S620 = __ldg((&(globalParams_0->index_0)[_S619]));
    (&w_4)->island_2 = _S620;
    uint _S621 = __ldg((&(globalParams_0->index_0)[_S619 + 1U]));
    (&w_4)->begin_0 = _S621;
    uint _S622 = __ldg((&(globalParams_0->index_0)[_S619 + 2U]));
    (&w_4)->end_0 = _S622;
    uint _S623 = __ldg((&(globalParams_0->index_0)[_S619 + 3U]));
    (&w_4)->first_0 = _S623;
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
    uint _S624 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S625 = (&(globalParams_0->islands_0)[_S624])->info_1;
    bool _S626;
    if((((&(globalParams_0->islands_0)[_S624])->info_1.z) & 1U) != 0U)
    {
        _S626 = true;
    }
    else
    {
        uint _S627 = _S625.y;
        if(_S627 != 0U)
        {
            _S626 = _S627 <= (isl_0->info_1.w);
        }
        else
        {
            _S626 = false;
        }
    }
    return _S626;
}

static __device__ bool wide_runs_0(Island_0 * isl_1)
{
    uint4  _S628 = isl_1->info_1;
    bool _S629;
    if(((isl_1->info_1.z) & 1U) != 0U)
    {
        _S629 = true;
    }
    else
    {
        _S629 = (_S628.y) == 0U;
    }
    if(_S629)
    {
        return false;
    }
    if(((_S628.x) & 4U) == 0U)
    {
        _S629 = true;
    }
    else
    {
        bool _S630 = contact_stopped_0(isl_1);
        _S629 = !_S630;
    }
    return _S629;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_4, Island_0 * isl_2)
{
    seen_clear_0(tid_4);
    if(tid_4 == 0U)
    {
        bool _S631 = wide_runs_0(isl_2);
        int _S632;
        if(_S631)
        {
            _S632 = int(1);
        }
        else
        {
            _S632 = int(0);
        }
        *&g_wide_run_0 = uint(_S632);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_3)
{
    uint _S633 = isl_3->info_1.w;
    uint _S634 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S633 - _S634;
}

static __device__ float time_since_0(float4  origin_0, uint k_8, float dt_2)
{
    float _S635 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S636 = _S635 - origin_0.x;
    float _S637 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S636 + (_S637 - origin_0.y) + float(k_8) * dt_2;
}

static __device__ float table_eval_0(uint offset_0, uint count_2, float tau_0)
{
    float4  _S638 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S638.x))
    {
        return _S638.y;
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
        uint _S639 = offset_0 + i_10;
        float4  _S640 = __ldg((&(globalParams_0->loads_0)[_S639]));
        float _S641 = _S640.x;
        if(tau_0 <= _S641)
        {
            float4  _S642 = __ldg((&(globalParams_0->loads_0)[_S639 - 1U]));
            float _S643 = _S642.x;
            float _S644 = _S642.y;
            return _S644 + (tau_0 - _S643) / (F32_max((_S641 - _S643), (1.00000000317107685e-30f))) * (_S640.y - _S644);
        }
        i_10 = i_10 + 1U;
    }
    float4  _S645 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_2 - 1U]));
    return _S645.y;
}

static __device__ float eval_function_0(uint term_0, uint k_9, float dt_3, float shift_0)
{
    uint _S646 = 5U * term_0;
    float4  _S647 = __ldg((&(globalParams_0->loads_0)[_S646]));
    uint4  info_2 = asuint_0(_S647);
    float4  _S648 = __ldg((&(globalParams_0->loads_0)[_S646 + 3U]));
    float4  _S649 = __ldg((&(globalParams_0->loads_0)[_S646 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S648.z;
    }
    float tau_1 = time_since_0(_S648, k_9, dt_3) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S650 = _S649.x;
            if(tau_1 >= _S650)
            {
                shape_1 = _S649.y;
            }
            else
            {
                shape_1 = _S649.y * tau_1 / _S650;
            }
        }
        return shape_1;
    }
    bool _S651;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S651 = true;
        }
        else
        {
            _S651 = tau_1 > (_S649.x);
        }
        if(_S651)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S649.y * (F32_sin((3.14159274101257324f * tau_1 / _S649.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S649.y;
        if(sn_0 < 0.0f)
        {
            _S651 = true;
        }
        else
        {
            _S651 = sn_0 > 1.0f;
        }
        if(_S651)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S649.x * (1.0f - sn_0) * (F32_exp((- _S649.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S649.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S649.x;
        if(sn_1 < 0.0f)
        {
            _S651 = true;
        }
        else
        {
            _S651 = sn_1 > 1.0f;
        }
        if(_S651)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S649.y * sn_1)));
        }
        float clearing_0 = _S648.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S652 = _S649.w;
        return (_S652 + (_S649.z - _S652) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S653 = _S649.y;
        if(tau_1 < _S653)
        {
            return _S649.x;
        }
        float s_1 = tau_1 - _S653;
        float _S654 = _S649.w;
        if(s_1 > _S654)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S649.z * (F32_sin((3.14159274101257324f * s_1 / _S654)));
        }
        return shape_1;
    }
    float _S655 = _S649.x;
    if(_S655 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S655, 0.0f, 1.0f);
}

static __device__ void chunk_loads_0(uint c_5, Quat_0 * rot_0, uint k_10, float dt_4, bool contact_0, float rep_shift_0, float3  * f_3, float3  * t_2, float3  * rf_0, float3  * rm_0)
{
    bool _S656;
    float3  _S657 = make_float3 (0.0f);
    *f_3 = _S657;
    *t_2 = _S657;
    *rf_0 = _S657;
    *rm_0 = _S657;
    uint4  _S658 = __ldg(&(&(globalParams_0->chunks_0)[c_5])->load_range_0);
    uint term_1 = _S658.x;
    for(;;)
    {
        uint4  _S659 = __ldg(&(&(globalParams_0->chunks_0)[c_5])->load_range_0);
        if(term_1 < (_S659.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S660 = 5U * term_1;
        float4  _S661 = __ldg((&(globalParams_0->loads_0)[_S660]));
        uint _S662 = asuint_0(_S661).y;
        bool replacement_0 = _S662 == 2U;
        float4  _S663 = __ldg((&(globalParams_0->loads_0)[_S660 + 1U]));
        float4  _S664 = __ldg((&(globalParams_0->loads_0)[_S660 + 2U]));
        float _S665;
        if(replacement_0)
        {
            _S665 = rep_shift_0;
        }
        else
        {
            _S665 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, k_10, dt_4, _S665);
        if(replacement_0)
        {
            *rf_0 = *rf_0 + float3 {_S663.x, _S663.y, _S663.z} * make_float3 (value_0);
            *rm_0 = *rm_0 + float3 {_S664.x, _S664.y, _S664.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S662 == 0U)
        {
            _S656 = true;
        }
        else
        {
            _S656 = _S662 == 3U;
        }
        float3  fw_0;
        if(_S656)
        {
            fw_0 = float3 {_S663.x, _S663.y, _S663.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S666 = rotate_0(rot_0, float3 {_S663.x, _S663.y, _S663.z});
            fw_0 = _S666 * make_float3 (- value_0 * _S663.w);
        }
        float3  lever_0;
        if(_S662 == 3U)
        {
            float4  _S667 = *(&(globalParams_0->state_0)[4U * c_5]);
            lever_0 = float3 {_S664.x, _S664.y, _S664.z} - float3 {_S667.x, _S667.y, _S667.z};
        }
        else
        {
            lever_0 = float3 {_S664.x, _S664.y, _S664.z};
        }
        *f_3 = *f_3 + fw_0;
        float3  _S668 = rotate_0(rot_0, lever_0);
        *t_2 = *t_2 + cross_0(_S668, fw_0);
        term_1 = term_1 + 1U;
    }
    if(contact_0)
    {
        uint4  _S669 = __ldg(&(&(globalParams_0->chunks_0)[c_5])->cinfo_0);
        _S656 = (_S669.z) != 0U;
    }
    else
    {
        _S656 = false;
    }
    if(_S656)
    {
        uint4  _S670 = __ldg(&(&(globalParams_0->chunks_0)[c_5])->cinfo_0);
        uint g_1 = _S670.x;
        for(;;)
        {
            uint4  _S671 = __ldg(&(&(globalParams_0->chunks_0)[c_5])->cinfo_0);
            if(g_1 < (_S671.y))
            {
            }
            else
            {
                break;
            }
            uint _S672 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S673 = 2U * g_1;
            float4  _S674 = *(&(globalParams_0->scratch_0)[_S672 + _S673]);
            *f_3 = *f_3 + float3 {_S674.x, _S674.y, _S674.z};
            uint _S675 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S676 = *(&(globalParams_0->scratch_0)[_S675 + _S673 + 1U]);
            *t_2 = *t_2 + float3 {_S676.x, _S676.y, _S676.z};
            g_1 = g_1 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint c_6, Quat_0 * rot_1, uint k_11, float dt_5, bool contact_1, float3  * f_4, float3  * t_3)
{
    float3  rf_1;
    float3  rm_1;
    chunk_loads_0(c_6, rot_1, k_11, dt_5, contact_1, 0.0f, f_4, t_3, &rf_1, &rm_1);
    return;
}

static __device__ void record_chunk_load_0(uint c_7, float3  f_5, float3  t_4)
{
    uint _S677 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S677 == 0U)
    {
        return;
    }
    uint _S678 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S679 = 2U * c_7;
    *(&(globalParams_0->scratch_0)[_S678 + _S679]) = make_float4 (f_5.x, f_5.y, f_5.z, 0.0f);
    uint _S680 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S680 + _S679 + 1U]) = make_float4 (t_4.x, t_4.y, t_4.z, 0.0f);
    uint _S681 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S682 = (&(globalParams_0->scratch_0)[_S681 + _S679]);
    uint _S683 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S684 = *(&(globalParams_0->scratch_0)[_S683 + _S679]);
    *_S682 = make_float4 ((float3 {_S684.x, _S684.y, _S684.z} + f_5).x, (float3 {_S684.x, _S684.y, _S684.z} + f_5).y, (float3 {_S684.x, _S684.y, _S684.z} + f_5).z, 0.0f);
    uint _S685 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S686 = (&(globalParams_0->scratch_0)[_S685 + _S679 + 1U]);
    uint _S687 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S688 = *(&(globalParams_0->scratch_0)[_S687 + _S679 + 1U]);
    *_S686 = make_float4 ((float3 {_S688.x, _S688.y, _S688.z} + t_4).x, (float3 {_S688.x, _S688.y, _S688.z} + t_4).y, (float3 {_S688.x, _S688.y, _S688.z} + t_4).z, 0.0f);
    return;
}

static __device__ float settled_chunk_load_0(uint c_8, Quat_0 * rot_2, uint k_12, float dt_6, bool contact_2)
{
    float3  f_6;
    float3  t_5;
    chunk_external_0(c_8, rot_2, k_12, dt_6, contact_2, &f_6, &t_5);
    record_chunk_load_0(c_8, f_6, t_5);
    return length_0(f_6);
}

static __device__ uint seen_bits_0()
{
    uint _S689;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S689 = 32768U;
    }
    else
    {
        _S689 = 0U;
    }
    uint _S690;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S690 = 65536U;
    }
    else
    {
        _S690 = 0U;
    }
    uint _S691 = _S689 | _S690;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S689 = 131072U;
    }
    else
    {
        _S689 = 0U;
    }
    uint _S692 = _S691 | _S689;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S689 = 32U;
    }
    else
    {
        _S689 = 0U;
    }
    uint _S693 = _S692 | _S689;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S689 = 64U;
    }
    else
    {
        _S689 = 0U;
    }
    return _S693 | _S689;
}

static __device__ bool wide_enter_1(uint _S694, uint _S695)
{
    Island_0 _S696 = *(&(globalParams_0->islands_0)[_S695]);
    seen_clear_0(_S694);
    if(_S694 == 0U)
    {
        Island_0 _S697 = _S696;
        bool _S698 = wide_runs_0(&_S697);
        int _S699;
        if(_S698)
        {
            _S699 = int(1);
        }
        else
        {
            _S699 = int(0);
        }
        *&g_wide_run_0 = uint(_S699);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S700 = 0U;
    uint _S701;
    uint _S702 = __ballot_sync(4294967295U, true);
    uint tid_5 = threadIdx.x;
    uint _S703 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S704 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S703, _S704);
    bool _S705 = _S704 != (wg_0.first_0);
    uint _S706 = __ballot_sync(_S702, _S705);
    if(_S705)
    {
        return;
    }
    else
    {
        uint _S707 = __ballot_sync(_S702, true);
        _S700 = _S707;
    }
    Island_0 * _S708 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_4 = *_S708;
    uint _S709 = (*_S708).info_1.x;
    bool _S710 = (_S709 & 16U) == 0U;
    uint _S711 = __ballot_sync(_S700, _S710);
    bool _S712;
    uint c_9;
    if(_S710)
    {
        uint _S713 = __ballot_sync(_S700, true);
        _S712 = true;
        c_9 = _S713;
    }
    else
    {
        bool _S714 = wide_enter_1(tid_5, wg_0.island_2);
        bool _S715 = !_S714;
        uint _S716 = __ballot_sync(_S700, true);
        _S712 = _S715;
        c_9 = _S716;
    }
    uint _S717 = 0U;
    uint _S718 = __ballot_sync(c_9, _S712);
    if(_S712)
    {
        return;
    }
    else
    {
        uint _S719 = __ballot_sync(c_9, true);
        _S717 = _S719;
    }
    Quat_0 _S720 = quat_of_0(isl_4.rotation_0);
    bool _S721 = (_S709 & 4U) != 0U;
    float3  _S722 = make_float3 (0.0f);
    float3  norm_0 = _S722;
    float3  unused_1 = _S722;
    c_9 = isl_4.range_0.x + tid_5;
    uint cov_0;
    cov_0 = _S717;
    for(;;)
    {
        bool _S723 = c_9 < (isl_4.range_0.y);
        uint _S724 = __ballot_sync(cov_0, _S723);
        if(_S723)
        {
            uint _S725 = __ballot_sync(cov_0, true);
        }
        else
        {
            uint _S726 = __ballot_sync(cov_0, false);
            uint _S727 = __ballot_sync(cov_0, false);
            uint _S728 = __ballot_sync(_S717, true);
            _S701 = _S728;
            break;
        }
        Island_0 _S729 = isl_4;
        uint _S730 = wide_step_0(&_S729);
        float _S731 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S732 = _S720;
        float _S733 = settled_chunk_load_0(c_9, &_S732, _S730, _S731, _S721);
        *&((&norm_0)->x) = *&((&norm_0)->x) + _S733;
        uint _S734 = __ballot_sync(cov_0, true);
        c_9 = c_9 + 256U;
        cov_0 = _S734;
    }
    group_sum3_0(tid_5, &norm_0, &unused_1, _S701);
    bool _S735 = tid_5 != 0U;
    uint _S736 = __ballot_sync(_S701, _S735);
    if(_S735)
    {
        return;
    }
    uint cov_1 = 1024U | (seen_bits_0());
    uint _S737 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S737 == 1U)
    {
        _S712 = (F32_abs((norm_0.x - isl_4.energy_1.z))) > (isl_4.energy_1.w);
    }
    else
    {
        _S712 = false;
    }
    if(_S712)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S709 & 4294967279U;
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

static __device__ void wide_partials_0(uint tid_6, uint first_1, uint count_3, uint p_9, float3  * a_7, float3  * b_21, uint _S738)
{
    uint _S739;
    float4  _S740 = make_float4 (0.0f);
    float4  x_18 = _S740;
    float4  y_5 = _S740;
    uint s_2 = tid_6;
    uint _S741 = _S738;
    for(;;)
    {
        bool _S742 = s_2 < count_3;
        uint _S743 = __ballot_sync(_S741, _S742);
        if(_S742)
        {
            uint _S744 = __ballot_sync(_S741, true);
        }
        else
        {
            uint _S745 = __ballot_sync(_S741, false);
            uint _S746 = __ballot_sync(_S741, false);
            uint _S747 = __ballot_sync(_S738, true);
            _S739 = _S747;
            break;
        }
        uint _S748 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S749 = 8U * (first_1 + s_2);
        x_18 = x_18 + *(&(globalParams_0->scratch_0)[_S748 + _S749 + p_9]);
        uint _S750 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S750 + _S749 + p_9 + 1U]);
        uint _S751 = __ballot_sync(_S741, true);
        s_2 = s_2 + 256U;
        _S741 = _S751;
    }
    group_sum2_0(tid_6, &x_18, &y_5, _S739);
    float4  _S752 = x_18;
    *a_7 = float3 {_S752.x, _S752.y, _S752.z};
    float4  _S753 = y_5;
    *b_21 = float3 {_S753.x, _S753.y, _S753.z};
    return;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_4)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_4), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_4), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_4));
}

static __device__ void drift_angular_0(uint c_10, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    float4  _S754 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->center_0);
    float3  r_5 = float3 {_S754.x, _S754.y, _S754.z} - wcom_1;
    float4  _S755 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->scale_0);
    float kw_0 = _S755.x;
    uint _S756 = 4U * c_10;
    float4  _S757 = *(&(globalParams_0->state_0)[_S756]);
    float3  _S758 = cross_0(r_5, float3 {_S757.x, _S757.y, _S757.z} - tr_0);
    float4  _S759 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->center_0);
    float3  _S760 = _S758 * make_float3 (_S759.w);
    float4  _S761 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->inertia0_0);
    float4  _S762 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->inertia1_0);
    float4  _S763 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->inertia2_0);
    float4  _S764 = *(&(globalParams_0->state_0)[_S756 + 1U]);
    *lu_0 = *lu_0 + (_S760 + rows_mul_0(_S761, _S762, _S763, float3 {_S764.x, _S764.y, _S764.z})) * make_float3 (kw_0);
    float4  _S765 = *(&(globalParams_0->state_0)[_S756 + 2U]);
    float3  _S766 = cross_0(r_5, float3 {_S765.x, _S765.y, _S765.z} - dv_0);
    float4  _S767 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->center_0);
    float3  _S768 = _S766 * make_float3 (_S767.w);
    float4  _S769 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->inertia0_0);
    float4  _S770 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->inertia1_0);
    float4  _S771 = __ldg(&(&(globalParams_0->chunks_0)[c_10])->inertia2_0);
    float4  _S772 = *(&(globalParams_0->state_0)[_S756 + 3U]);
    *lv_0 = *lv_0 + (_S768 + rows_mul_0(_S769, _S770, _S771, float3 {_S772.x, _S772.y, _S772.z})) * make_float3 (kw_0);
    return;
}

static __device__ void wide_store_0(uint slot_0, uint p_10, float3  a_8, float3  b_22)
{
    uint _S773 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S774 = 8U * slot_0;
    *(&(globalParams_0->scratch_0)[_S773 + _S774 + p_10]) = make_float4 (a_8.x, a_8.y, a_8.z, 0.0f);
    uint _S775 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S775 + _S774 + p_10 + 1U]) = make_float4 (b_22.x, b_22.y, b_22.z, 0.0f);
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S776 = __ballot_sync(4294967295U, true);
    uint tid_7 = threadIdx.x;
    uint _S777 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S778 = blockIdx.x;
    WideGroup_0 wg_1 = wide_group_0(_S777, _S778);
    Island_0 * _S779 = (&(globalParams_0->islands_0)[wg_1.island_2]);
    Island_0 isl_5 = *_S779;
    bool _S780 = (((*_S779).info_1.x) & 17U) != 0U;
    uint _S781 = __ballot_sync(_S776, _S780);
    bool _S782;
    uint _S783;
    if(_S780)
    {
        uint _S784 = __ballot_sync(_S776, true);
        _S782 = true;
        _S783 = _S784;
    }
    else
    {
        bool _S785 = wide_enter_1(tid_7, wg_1.island_2);
        bool _S786 = !_S785;
        uint _S787 = __ballot_sync(_S776, true);
        _S782 = _S786;
        _S783 = _S787;
    }
    uint _S788 = 0U;
    uint _S789 = __ballot_sync(_S783, _S782);
    if(_S782)
    {
        return;
    }
    else
    {
        uint _S790 = __ballot_sync(_S783, true);
        _S788 = _S790;
    }
    float3  tu_0;
    float3  pv_0;
    wide_partials_0(tid_7, wg_1.first_0, isl_5.wide_groups_0, 2U, &tu_0, &pv_0, _S788);
    float _S791 = isl_5.wcom_0.w;
    float3  tr_1 = tu_0 / make_float3 (_S791);
    float3  dv_1 = pv_0 / make_float3 (_S791);
    float3  _S792 = make_float3 (0.0f);
    float3  lu_1 = _S792;
    float3  lv_1 = _S792;
    uint c_11 = wg_1.begin_0 + tid_7;
    bool _S793 = c_11 < (wg_1.end_0);
    uint _S794 = __ballot_sync(_S788, _S793);
    if(_S793)
    {
        float4  _S795 = isl_5.wcom_0;
        drift_angular_0(c_11, float3 {_S795.x, _S795.y, _S795.z}, tr_1, dv_1, &lu_1, &lv_1);
        uint _S796 = __ballot_sync(_S788, true);
        _S783 = _S796;
    }
    else
    {
        uint _S797 = __ballot_sync(_S788, true);
        _S783 = _S797;
    }
    group_sum3_0(tid_7, &lu_1, &lv_1, _S783);
    bool _S798 = tid_7 == 0U;
    uint _S799 = __ballot_sync(_S783, _S798);
    if(_S798)
    {
        wide_store_0(_S778, 4U, lu_1, lv_1);
    }
    return;
}

struct Rigid_0
{
    Quat_0 rot_3;
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
    (&rg_0)->rot_3 = quat_of_0(isl_6->rotation_0);
    (&rg_0)->rot_err_0 = isl_6->rotation_err_0;
    float4  _S800 = isl_6->position_0;
    (&rg_0)->pos_0 = float3 {_S800.x, _S800.y, _S800.z};
    float4  _S801 = isl_6->position_err_0;
    (&rg_0)->pos_err_0 = float3 {_S801.x, _S801.y, _S801.z};
    float4  _S802 = isl_6->velocity_0;
    (&rg_0)->vel_0 = float3 {_S802.x, _S802.y, _S802.z};
    float4  _S803 = isl_6->velocity_err_0;
    (&rg_0)->vel_err_0 = float3 {_S803.x, _S803.y, _S803.z};
    float4  _S804 = isl_6->angular_velocity_0;
    (&rg_0)->w_5 = float3 {_S804.x, _S804.y, _S804.z};
    float4  _S805 = isl_6->momentum_0;
    (&rg_0)->l_1 = float3 {_S805.x, _S805.y, _S805.z};
    float4  _S806 = isl_6->momentum_err_0;
    (&rg_0)->l_err_0 = float3 {_S806.x, _S806.y, _S806.z};
    float3  _S807 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S807;
    (&rg_0)->a_9 = _S807;
    (&rg_0)->alpha_0 = _S807;
    return rg_0;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_9, float3  v_5)
{
    Quat_0 c_12;
    (&c_12)->w_1 = q_9->w_1;
    (&c_12)->x_12 = - q_9->x_12;
    (&c_12)->y_4 = - q_9->y_4;
    (&c_12)->z_0 = - q_9->z_0;
    Quat_0 _S808 = c_12;
    float3  _S809 = rotate_0(&_S808, v_5);
    return _S809;
}

static __device__ float3  world_mul_0(Quat_0 * q_10, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_6)
{
    float3  _S810 = inverse_rotate_0(q_10, v_6);
    float3  _S811 = rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, _S810));
    return _S811;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_7, Rigid_0 * rg_1, float3  f_7, float3  t_6)
{
    Quat_0 _S812 = rg_1->rot_3;
    float3  _S813 = world_mul_0(&_S812, isl_7->inertia0_1, isl_7->inertia1_1, isl_7->inertia2_1, rg_1->w_5);
    rg_1->a_9 = f_7 / make_float3 (isl_7->com_0.w);
    float3  _S814 = t_6 - cross_0(rg_1->w_5, _S813);
    Quat_0 _S815 = rg_1->rot_3;
    float3  _S816 = world_mul_0(&_S815, isl_7->inv0_1, isl_7->inv1_1, isl_7->inv2_1, _S814);
    rg_1->alpha_0 = _S816;
    rg_1->torque_0 = t_6;
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_8, Island_0 * isl_8, WideGroup_0 * wg_2, uint _S817)
{
    Rigid_0 _S818 = rigid_of_0(isl_8);
    Rigid_0 rg_2 = _S818;
    bool _S819 = ((isl_8->info_1.x) & 1U) == 0U;
    uint _S820 = __ballot_sync(_S817, _S819);
    if(_S819)
    {
        float3  f_8;
        float3  t_7;
        wide_partials_0(tid_8, wg_2->first_0, isl_8->wide_groups_0, 0U, &f_8, &t_7, _S820);
        rigid_acceleration_0(isl_8, &rg_2, f_8, t_7);
        uint _S821 = __ballot_sync(_S817, true);
    }
    return rg_2;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_19)
{
    float3  t_8 = *sum_1 + x_19;
    float3  _S822 = abs_1(x_19);
    *err_1 = *err_1 + (_slang_select((abs_1(*sum_1)) >= _S822, *sum_1,x_19) - t_8 + _slang_select((abs_1(*sum_1)) >= _S822, x_19,*sum_1));
    *sum_1 = t_8;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_0, float dt_7, float3  v_7)
{
    float _S823 = length_0(omega_0);
    float angle_1 = _S823 * dt_7;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_10 = omega_0 / make_float3 (_S823);
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
    float4  t_9 = *sum_2 + x_20;
    float4  _S824 = abs_0(x_20);
    *err_2 = *err_2 + (_slang_select((abs_0(*sum_2)) >= _S824, *sum_2,x_20) - t_9 + _slang_select((abs_0(*sum_2)) >= _S824, x_20,*sum_2));
    *sum_2 = t_9;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_1, float4  * lo_1, float4  x_21)
{
    Quat_0 _S825 = *hi_1;
    float4  _S826 = quat_vec_0(&_S825);
    float4  sum_3 = _S826;
    comp_add4_0(&sum_3, lo_1, x_21);
    float4  t_10 = sum_3 + *lo_1;
    *lo_1 = *lo_1 - (t_10 - sum_3);
    *hi_1 = quat_of_0(t_10);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_2, float4  * lo_2, float3  omega_1, float dt_8)
{
    float _S827 = length_0(omega_1);
    float angle_3 = _S827 * dt_8;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_10 = turn_minus_one_0(omega_1 / make_float3 (_S827), angle_3);
    Quat_0 dq_0;
    (&dq_0)->x_12 = d_10.x;
    (&dq_0)->y_4 = d_10.y;
    (&dq_0)->z_0 = d_10.z;
    (&dq_0)->w_1 = d_10.w;
    Quat_0 _S828 = dq_0;
    Quat_0 _S829 = *hi_2;
    Quat_0 _S830 = quat_mul_0(&_S828, &_S829);
    Quat_0 _S831 = _S830;
    float4  _S832 = quat_vec_0(&_S831);
    quat_accumulate_0(hi_2, lo_2, _S832);
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_9, Rigid_0 * rg_3, float dt_9)
{
    comp_add_0(&rg_3->l_1, &rg_3->l_err_0, rg_3->torque_0 * make_float3 (dt_9));
    float3  l_2 = rg_3->l_1 + rg_3->l_err_0;
    comp_add_0(&rg_3->vel_0, &rg_3->vel_err_0, rg_3->a_9 * make_float3 (dt_9));
    float3  vel_1 = rg_3->vel_0 + rg_3->vel_err_0;
    float4  _S833 = isl_9->inv0_1;
    float4  _S834 = isl_9->inv1_1;
    float4  _S835 = isl_9->inv2_1;
    Quat_0 _S836 = rg_3->rot_3;
    float3  _S837 = world_mul_0(&_S836, isl_9->inv0_1, isl_9->inv1_1, isl_9->inv2_1, l_2);
    float3  _S838 = vel_1 * make_float3 (dt_9);
    float4  _S839 = isl_9->com_0;
    float3  _S840 = float3 {_S839.x, _S839.y, _S839.z};
    Quat_0 _S841 = rg_3->rot_3;
    float3  _S842 = rotate_0(&_S841, _S840);
    comp_add_0(&rg_3->pos_0, &rg_3->pos_err_0, _S838 - turn_difference_0(_S837, dt_9, _S842));
    turn_left_0(&rg_3->rot_3, &rg_3->rot_err_0, _S837, dt_9);
    Quat_0 _S843 = rg_3->rot_3;
    float3  _S844 = world_mul_0(&_S843, _S833, _S834, _S835, l_2);
    rg_3->w_5 = _S844;
    return;
}

static __device__ void drift_apply_0(uint c_13, float3  wcom_2, float3  tr_2, float3  phi_0, float3  dv_2, float3  dw_0)
{
    float4  _S845 = __ldg(&(&(globalParams_0->chunks_0)[c_13])->center_0);
    float3  r_6 = float3 {_S845.x, _S845.y, _S845.z} - wcom_2;
    uint _S846 = 4U * c_13;
    float4  _S847 = *(&(globalParams_0->state_0)[_S846]);
    *(&(globalParams_0->state_0)[_S846]) = make_float4 ((float3 {_S847.x, _S847.y, _S847.z} - (tr_2 + cross_0(phi_0, r_6))).x, (float3 {_S847.x, _S847.y, _S847.z} - (tr_2 + cross_0(phi_0, r_6))).y, (float3 {_S847.x, _S847.y, _S847.z} - (tr_2 + cross_0(phi_0, r_6))).z, (*(&(globalParams_0->state_0)[_S846])).w);
    uint _S848 = _S846 + 1U;
    float4  _S849 = *(&(globalParams_0->state_0)[_S848]);
    *(&(globalParams_0->state_0)[_S848]) = make_float4 ((float3 {_S849.x, _S849.y, _S849.z} - phi_0).x, (float3 {_S849.x, _S849.y, _S849.z} - phi_0).y, (float3 {_S849.x, _S849.y, _S849.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S848])).w);
    uint _S850 = _S846 + 2U;
    float4  _S851 = *(&(globalParams_0->state_0)[_S850]);
    *(&(globalParams_0->state_0)[_S850]) = make_float4 ((float3 {_S851.x, _S851.y, _S851.z} - (dv_2 + cross_0(dw_0, r_6))).x, (float3 {_S851.x, _S851.y, _S851.z} - (dv_2 + cross_0(dw_0, r_6))).y, (float3 {_S851.x, _S851.y, _S851.z} - (dv_2 + cross_0(dw_0, r_6))).z, (*(&(globalParams_0->state_0)[_S850])).w);
    uint _S852 = _S846 + 3U;
    float4  _S853 = *(&(globalParams_0->state_0)[_S852]);
    *(&(globalParams_0->state_0)[_S852]) = make_float4 ((float3 {_S853.x, _S853.y, _S853.z} - dw_0).x, (float3 {_S853.x, _S853.y, _S853.z} - dw_0).y, (float3 {_S853.x, _S853.y, _S853.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S852])).w);
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
    Quat_0 _S854 = *hi_3;
    Quat_0 _S855 = dq_1;
    Quat_0 _S856 = quat_mul_0(&_S854, &_S855);
    Quat_0 _S857 = _S856;
    float4  _S858 = quat_vec_0(&_S857);
    quat_accumulate_0(hi_3, lo_3, _S858);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_10, Rigid_0 * rg_4, float3  tr_3, float3  phi_2, float3  dv_3, float3  dw_1)
{
    float4  _S859 = isl_10->wcom_0;
    float3  wcom_3 = float3 {_S859.x, _S859.y, _S859.z};
    Quat_0 rot_4 = rg_4->rot_3;
    float3  _S860 = tr_3 - cross_0(phi_2, wcom_3);
    Quat_0 _S861 = rg_4->rot_3;
    float3  _S862 = rotate_0(&_S861, _S860);
    comp_add_0(&rg_4->pos_0, &rg_4->pos_err_0, _S862);
    Quat_0 _S863 = rg_4->rot_3;
    float3  _S864 = inverse_rotate_0(&_S863, rg_4->w_5);
    float4  _S865 = isl_10->inertia0_1;
    float4  _S866 = isl_10->inertia1_1;
    float4  _S867 = isl_10->inertia2_1;
    float3  _S868 = cross_0(phi_2, rows_mul_0(isl_10->inertia0_1, isl_10->inertia1_1, isl_10->inertia2_1, _S864)) - rows_mul_0(isl_10->inertia0_1, isl_10->inertia1_1, isl_10->inertia2_1, cross_0(phi_2, _S864));
    Quat_0 _S869 = rg_4->rot_3;
    float3  _S870 = rotate_0(&_S869, _S868);
    turn_right_0(&rg_4->rot_3, &rg_4->rot_err_0, phi_2);
    float4  _S871 = isl_10->com_0;
    float3  _S872 = dv_3 + cross_0(dw_1, float3 {_S871.x, _S871.y, _S871.z} - wcom_3);
    Quat_0 _S873 = rot_4;
    float3  _S874 = rotate_0(&_S873, _S872);
    comp_add_0(&rg_4->vel_0, &rg_4->vel_err_0, _S874);
    Quat_0 _S875 = rot_4;
    float3  _S876 = rotate_0(&_S875, dw_1);
    rg_4->w_5 = rg_4->w_5 + _S876;
    Quat_0 _S877 = rg_4->rot_3;
    float3  _S878 = world_mul_0(&_S877, _S865, _S866, _S867, _S876);
    comp_add_0(&rg_4->l_1, &rg_4->l_err_0, _S870 + _S878);
    return;
}

extern "C" __global__ void wide_rigid()
{
    uint _S879 = __ballot_sync(4294967295U, true);
    uint tid_9 = threadIdx.x;
    uint _S880 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S881 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S880, _S881);
    Island_0 * _S882 = (&(globalParams_0->islands_0)[wg_3.island_2]);
    Island_0 isl_11 = *_S882;
    uint _S883 = (*_S882).info_1.x;
    bool _S884 = (_S883 & 1U) != 0U;
    uint _S885 = __ballot_sync(_S879, _S884);
    bool _S886;
    uint _S887;
    if(_S884)
    {
        uint _S888 = __ballot_sync(_S879, true);
        _S886 = true;
        _S887 = _S888;
    }
    else
    {
        bool _S889 = wide_enter_1(tid_9, wg_3.island_2);
        bool _S890 = !_S889;
        uint _S891 = __ballot_sync(_S879, true);
        _S886 = _S890;
        _S887 = _S891;
    }
    uint _S892 = 0U;
    uint _S893 = __ballot_sync(_S887, _S886);
    if(_S886)
    {
        return;
    }
    else
    {
        uint _S894 = __ballot_sync(_S887, true);
        _S892 = _S894;
    }
    uint _S895 = 0U;
    bool _S896 = (_S883 & 16U) != 0U;
    uint _S897 = __ballot_sync(_S892, _S896);
    if(_S896)
    {
        uint _S898 = 0U;
        bool _S899 = _S881 != (wg_3.first_0);
        uint _S900 = __ballot_sync(_S897, _S899);
        if(_S899)
        {
            return;
        }
        else
        {
            uint _S901 = __ballot_sync(_S897, true);
            _S898 = _S901;
        }
        Island_0 _S902 = isl_11;
        WideGroup_0 _S903 = wg_3;
        Rigid_0 _S904 = wide_rigid_frame_0(tid_9, &_S902, &_S903, _S898);
        Rigid_0 rs_0 = _S904;
        bool _S905 = tid_9 != 0U;
        uint _S906 = __ballot_sync(_S898, _S905);
        if(_S905)
        {
            _S886 = true;
        }
        else
        {
            _S886 = (_S883 & 2U) != 0U;
        }
        if(_S886)
        {
            return;
        }
        float _S907 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S908 = isl_11;
        integrate_rigid_0(&_S908, &rs_0, _S907);
        Quat_0 _S909 = (&rs_0)->rot_3;
        float4  _S910 = quat_vec_0(&_S909);
        (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_0 = _S910;
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
        uint _S911 = __ballot_sync(_S892, true);
        _S895 = _S911;
    }
    float3  tu_1;
    float3  pv_1;
    wide_partials_0(tid_9, wg_3.first_0, isl_11.wide_groups_0, 2U, &tu_1, &pv_1, _S895);
    float3  lu_2;
    float3  lv_2;
    wide_partials_0(tid_9, wg_3.first_0, isl_11.wide_groups_0, 4U, &lu_2, &lv_2, _S895);
    float _S912 = isl_11.wcom_0.w;
    float3  tr_4 = tu_1 / make_float3 (_S912);
    float3  dv_4 = pv_1 / make_float3 (_S912);
    float3  phi_3 = rows_mul_0(isl_11.winv0_0, isl_11.winv1_0, isl_11.winv2_0, lu_2);
    float3  dw_2 = rows_mul_0(isl_11.winv0_0, isl_11.winv1_0, isl_11.winv2_0, lv_2);
    uint c_14 = wg_3.begin_0 + tid_9;
    bool _S913 = c_14 < (wg_3.end_0);
    uint _S914 = __ballot_sync(_S895, _S913);
    if(_S913)
    {
        float4  _S915 = isl_11.wcom_0;
        drift_apply_0(c_14, float3 {_S915.x, _S915.y, _S915.z}, tr_4, phi_3, dv_4, dw_2);
        uint _S916 = __ballot_sync(_S895, true);
        _S887 = _S916;
    }
    else
    {
        uint _S917 = __ballot_sync(_S895, true);
        _S887 = _S917;
    }
    uint _S918 = 0U;
    bool _S919 = _S881 != (wg_3.first_0);
    uint _S920 = __ballot_sync(_S887, _S919);
    if(_S919)
    {
        return;
    }
    else
    {
        uint _S921 = __ballot_sync(_S887, true);
        _S918 = _S921;
    }
    Island_0 _S922 = isl_11;
    WideGroup_0 _S923 = wg_3;
    Rigid_0 _S924 = wide_rigid_frame_0(tid_9, &_S922, &_S923, _S918);
    Rigid_0 rg_5 = _S924;
    bool _S925 = tid_9 != 0U;
    uint _S926 = __ballot_sync(_S918, _S925);
    if(_S925)
    {
        return;
    }
    if(!((_S883 & 2U) != 0U))
    {
        float _S927 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S928 = isl_11;
        integrate_rigid_0(&_S928, &rg_5, _S927);
        Island_0 _S929 = isl_11;
        drift_rigid_0(&_S929, &rg_5, tr_4, phi_3, dv_4, dw_2);
    }
    Quat_0 _S930 = (&rg_5)->rot_3;
    float4  _S931 = quat_vec_0(&_S930);
    (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_0 = _S931;
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
    float4  _S932 = __ldg(&ptr_0->geom0_0);
    float4  _S933 = __ldg(&ptr_0->geom1_0);
    float4  _S934 = __ldg(&ptr_0->stiff0_0);
    float4  _S935 = __ldg(&ptr_0->stiff1_0);
    float4  _S936 = __ldg(&ptr_0->rebar0_0);
    float4  _S937 = __ldg(&ptr_0->rebar1_0);
    uint4  _S938 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S939 = { _S932, _S933, _S934, _S935, _S936, _S937, _S938 };
    return _S939;
}

static __device__ bool connected_0(JointState_0 * st_0, bool has_rebar_0)
{
    bool _S940;
    if((st_0->damage_0) < 1.0f)
    {
        _S940 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S940 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S940 = false;
        }
    }
    return _S940;
}

static __device__ bool island_connected_0(uint tid_10, Island_0 * isl_12)
{
    uint _S941 = isl_12->range_0.x;
    uint n_8 = isl_12->range_0.y - _S941;
    bool converged_0;
    if(n_8 > 4096U)
    {
        converged_0 = true;
    }
    else
    {
        uint _S942 = __ldg(&globalParams_0->params_0->device_connect_0);
        converged_0 = _S942 == 0U;
    }
    if(converged_0)
    {
        return false;
    }
    uint c_15 = tid_10;
    for(;;)
    {
        if(c_15 < n_8)
        {
        }
        else
        {
            break;
        }
        (*&g_label_0)[c_15] = c_15;
        c_15 = c_15 + 256U;
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
        c_15 = tid_10;
        for(;;)
        {
            if(c_15 < n_8)
            {
            }
            else
            {
                break;
            }
            uint _S943 = (*&g_label_0)[c_15];
            uint gc_0 = _S941 + c_15;
            uint _S944 = __ldg((&(globalParams_0->index_0)[gc_0]));
            uint l_3 = _S943;
            uint e_2 = _S944;
            for(;;)
            {
                uint _S945 = __ldg((&(globalParams_0->index_0)[gc_0 + 1U]));
                if(e_2 < _S945)
                {
                }
                else
                {
                    break;
                }
                uint _S946 = __ldg((&(globalParams_0->index_0)[e_2]));
                uint bond_0 = _S946 >> int(1);
                JointBond_0 _S947 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                bool _S948 = (_S947.stiff1_0.w) != 0.0f;
                JointState_0 _S949 = (&(globalParams_0->bond_dyn_0)[bond_0])->js_0;
                bool _S950 = connected_0(&_S949, _S948);
                if(!_S950)
                {
                    e_2 = e_2 + 1U;
                    continue;
                }
                uint other_0;
                if((_S946 & 1U) == 0U)
                {
                    JointBond_0 _S951 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S951.ids_0.z;
                }
                else
                {
                    JointBond_0 _S952 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S952.ids_0.y;
                }
                l_3 = (U32_min((l_3), ((*&g_label_0)[other_0 - _S941])));
                e_2 = e_2 + 1U;
            }
            uint _S953 = (U32_min((l_3), ((*&g_label_0)[l_3])));
            if(_S953 < (*&g_label_0)[c_15])
            {
                (*&g_label_0)[c_15] = _S953;
                *&g_changed_0 = 1U;
            }
            c_15 = c_15 + 256U;
        }
        __syncthreads();
        bool converged_1 = (*&g_changed_0) == 0U;
        __syncthreads();
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S954 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S954;
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
    c_15 = tid_10;
    for(;;)
    {
        if(c_15 < n_8)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_0)[c_15]) != 0U)
        {
            *&g_changed_0 = 1U;
        }
        c_15 = c_15 + 256U;
    }
    __syncthreads();
    return (*&g_changed_0) == 0U;
}

static __device__ void write_probe_0(uint slot_1, uint k_13, float value_1)
{
    uint _S955 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S956 = _S955 * 4U;
    uint _S957 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_4 = _S956 + slot_1 * _S957 + k_13;
    float4  v_8 = *(&(globalParams_0->scratch_0)[at_4 / 4U]);
    *_slang_vector_get_element_ptr(&v_8, at_4 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_4 / 4U]) = v_8;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_13, Rigid_0 * rg_6, uint k_14)
{
    uint4  _S958 = isl_13->probes_0;
    uint at_5 = isl_13->probes_0.x;
    for(;;)
    {
        if(at_5 < (_S958.y))
        {
        }
        else
        {
            break;
        }
        float4  _S959 = __ldg((&(globalParams_0->loads_0)[at_5]));
        uint4  info_3 = asuint_0(_S959);
        float4  _S960 = __ldg((&(globalParams_0->loads_0)[at_5 + 1U]));
        float4  _S961 = __ldg((&(globalParams_0->loads_0)[at_5 + 2U]));
        float4  _S962 = __ldg((&(globalParams_0->loads_0)[at_5 + 3U]));
        uint kind_1 = info_3.x;
        uint i_11 = info_3.y;
        float value_2;
        if(kind_1 == 0U)
        {
            float4  _S963 = *(&(globalParams_0->state_0)[4U * i_11]);
            float3  small_0 = float3 {_S963.x, _S963.y, _S963.z} + make_float3 (_S960.w, _S961.w, _S962.w);
            float3  _S964 = rg_6->pos_0 - float3 {_S961.x, _S961.y, _S961.z};
            float4  _S965 = __ldg(&(&(globalParams_0->chunks_0)[i_11])->center_0);
            float3  _S966 = rotate_0(&rg_6->rot_3, float3 {_S965.x, _S965.y, _S965.z});
            float3  _S967 = _S964 + _S966;
            float3  _S968 = rg_6->pos_err_0 - float3 {_S962.x, _S962.y, _S962.z};
            float3  _S969 = rotate_0(&rg_6->rot_3, small_0);
            value_2 = dot_0(_S967 + (_S968 + _S969), float3 {_S960.x, _S960.y, _S960.z});
        }
        else
        {
            if(kind_1 == 1U)
            {
                float4  _S970 = __ldg(&(&(globalParams_0->chunks_0)[i_11])->center_0);
                uint _S971 = 4U * i_11;
                float4  _S972 = *(&(globalParams_0->state_0)[_S971]);
                float4  _S973 = isl_13->com_0;
                float3  _S974 = rotate_0(&rg_6->rot_3, float3 {_S970.x, _S970.y, _S970.z} + float3 {_S972.x, _S972.y, _S972.z} - float3 {_S973.x, _S973.y, _S973.z});
                float3  _S975 = rg_6->vel_0 + rg_6->vel_err_0 + cross_0(rg_6->w_5, _S974);
                float4  _S976 = *(&(globalParams_0->state_0)[_S971 + 2U]);
                float3  _S977 = rotate_0(&rg_6->rot_3, float3 {_S976.x, _S976.y, _S976.z});
                value_2 = dot_0(_S975 + _S977, float3 {_S960.x, _S960.y, _S960.z});
            }
            else
            {
                if(kind_1 == 2U)
                {
                    uint _S978 = 3U * i_11;
                    float4  _S979 = *(&(globalParams_0->scratch_0)[_S978]);
                    float3  f_9 = float3 {_S979.x, _S979.y, _S979.z};
                    bool _S980 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S980)
                    {
                        float4  _S981 = *(&(globalParams_0->scratch_0)[_S978 + 1U]);
                        mc_0 = float3 {_S981.x, _S981.y, _S981.z};
                    }
                    else
                    {
                        float4  _S982 = *(&(globalParams_0->scratch_0)[_S978 + 2U]);
                        mc_0 = float3 {_S982.x, _S982.y, _S982.z};
                    }
                    float3  fc_0;
                    if(_S980)
                    {
                        fc_0 = f_9;
                    }
                    else
                    {
                        fc_0 = - f_9;
                    }
                    value_2 = dot_0(fc_0, float3 {_S960.x, _S960.y, _S960.z}) + dot_0(mc_0, float3 {_S961.x, _S961.y, _S961.z});
                }
                else
                {
                    uint _S983 = 4U * i_11;
                    float3  _S984 = rotate_0(&rg_6->rot_3, make_float3 ((*(&(globalParams_0->state_0)[_S983 + 1U])).w, (*(&(globalParams_0->state_0)[_S983 + 2U])).w, (*(&(globalParams_0->state_0)[_S983 + 3U])).w));
                    value_2 = dot_0(_S984, float3 {_S960.x, _S960.y, _S960.z});
                }
            }
        }
        write_probe_0(info_3.w, k_14, value_2);
        at_5 = at_5 + 4U;
    }
    return;
}

static __device__ void contact_split_at_0(uint at_6)
{
    uint _S985 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_0 = (&(globalParams_0->islands_0)[_S985])->info_1.y;
    uint _S986 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S987;
    if(previous_0 == 0U)
    {
        _S987 = at_6;
    }
    else
    {
        _S987 = (U32_min((previous_0), (at_6)));
    }
    *&((&(&(globalParams_0->islands_0)[_S986])->info_1)->y) = _S987;
    return;
}

extern "C" __global__ void wide_end()
{
    uint _S988 = 0U;
    uint _S989 = __ballot_sync(4294967295U, true);
    uint tid_11 = threadIdx.x;
    uint _S990 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S991 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S990, _S991);
    bool _S992 = _S991 != (wg_4.first_0);
    uint _S993 = __ballot_sync(_S989, _S992);
    if(_S992)
    {
        return;
    }
    else
    {
        uint _S994 = __ballot_sync(_S989, true);
        _S988 = _S994;
    }
    uint _S995 = 0U;
    Island_0 * _S996 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_14 = *_S996;
    Island_0 _S997 = *_S996;
    bool _S998 = wide_enter_0(tid_11, &_S997);
    bool _S999 = !_S998;
    uint _S1000 = __ballot_sync(_S988, _S999);
    if(_S999)
    {
        return;
    }
    else
    {
        uint _S1001 = __ballot_sync(_S988, true);
        _S995 = _S1001;
    }
    float3  work_0;
    float3  flags_1;
    wide_partials_0(tid_11, wg_4.first_0, (&isl_14)->wide_groups_0, 6U, &work_0, &flags_1, _S995);
    bool halt_0 = (((&isl_14)->info_1.z) & 2U) != 0U;
    uint _S1002 = __ballot_sync(_S995, halt_0);
    bool whole_0;
    if(halt_0)
    {
        Island_0 _S1003 = isl_14;
        bool _S1004 = island_connected_0(tid_11, &_S1003);
        whole_0 = _S1004;
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
    Island_0 _S1005 = isl_14;
    uint _S1006 = wide_step_0(&_S1005);
    if(((&isl_14)->probes_0.y) > ((&isl_14)->probes_0.x))
    {
        Island_0 _S1007 = isl_14;
        Rigid_0 _S1008 = rigid_of_0(&_S1007);
        Island_0 _S1009 = isl_14;
        Rigid_0 _S1010 = _S1008;
        record_probes_0(&_S1009, &_S1010, _S1006);
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
    uint _S1011;
    if(halt_1)
    {
        _S1011 = 128U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1012 = 256U | _S1011;
    if(((&isl_14)->probes_0.y) > ((&isl_14)->probes_0.x))
    {
        _S1011 = 262144U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1013 = _S1012 | _S1011;
    if((((&isl_14)->info_1.x) & 4U) != 0U)
    {
        _S1011 = 524288U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1014 = _S1013 | _S1011;
    if((flags_1.x) > 0.0f)
    {
        _S1011 = 32768U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1015 = _S1014 | _S1011;
    if((flags_1.y) > 0.0f)
    {
        _S1011 = 65536U;
    }
    else
    {
        _S1011 = 0U;
    }
    uint _S1016 = _S1015 | _S1011;
    if((flags_1.z) > 0.0f)
    {
        _S1011 = 131072U;
    }
    else
    {
        _S1011 = 0U;
    }
    (&isl_14)->coverage_0 = ((&isl_14)->coverage_0) | (_S1016 | _S1011);
    *(&(globalParams_0->islands_0)[wg_4.island_2]) = isl_14;
    return;
}

static __device__ uint sv_0(uint c_16, uint slot_2)
{
    uint _S1017 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1017 + 23U * c_16 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_12, Island_0 * isl_15, uint slot_3, uint _S1018)
{
    uint _S1019;
    uint _S1020;
    float3  _S1021 = make_float3 (0.0f);
    float3  net_f_0 = _S1021;
    float3  net_m_0 = _S1021;
    uint4  _S1022 = isl_15->range_0;
    uint _S1023 = isl_15->range_0.x + tid_12;
    uint c_17 = _S1023;
    uint _S1024 = _S1018;
    for(;;)
    {
        uint _S1025 = _S1022.y;
        _S1019 = _S1025;
        bool _S1026 = c_17 < _S1025;
        uint _S1027 = __ballot_sync(_S1024, _S1026);
        if(_S1026)
        {
            uint _S1028 = __ballot_sync(_S1024, true);
        }
        else
        {
            uint _S1029 = __ballot_sync(_S1024, false);
            uint _S1030 = __ballot_sync(_S1024, false);
            uint _S1031 = __ballot_sync(_S1018, true);
            _S1020 = _S1031;
            break;
        }
        float4  _S1032 = *(&(globalParams_0->scratch_0)[sv_0(c_17, slot_3)]);
        float3  fi_0 = float3 {_S1032.x, _S1032.y, _S1032.z};
        net_f_0 = net_f_0 + fi_0;
        float4  _S1033 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->center_0);
        float4  _S1034 = isl_15->com_0;
        float4  _S1035 = *(&(globalParams_0->scratch_0)[sv_0(c_17, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1033.x, _S1033.y, _S1033.z} - float3 {_S1034.x, _S1034.y, _S1034.z}, fi_0) + float3 {_S1035.x, _S1035.y, _S1035.z});
        uint _S1036 = __ballot_sync(_S1024, true);
        c_17 = c_17 + 256U;
        _S1024 = _S1036;
    }
    group_sum3_0(tid_12, &net_f_0, &net_m_0, _S1020);
    float4  _S1037 = isl_15->com_0;
    float3  _S1038 = net_f_0 / make_float3 (isl_15->com_0.w);
    float3  _S1039 = rows_mul_0(isl_15->inv0_1, isl_15->inv1_1, isl_15->inv2_1, net_m_0);
    c_17 = _S1023;
    for(;;)
    {
        if(c_17 < _S1019)
        {
        }
        else
        {
            break;
        }
        float4  _S1040 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->center_0);
        uint _S1041 = sv_0(c_17, slot_3);
        float4  * _S1042 = (&(globalParams_0->scratch_0)[_S1041]);
        float4  _S1043 = *(&(globalParams_0->scratch_0)[_S1041]);
        float3  _S1044 = float3 {_S1043.x, _S1043.y, _S1043.z};
        float3  _S1045 = _S1038 + cross_0(_S1039, float3 {_S1040.x, _S1040.y, _S1040.z} - float3 {_S1037.x, _S1037.y, _S1037.z});
        float4  _S1046 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->center_0);
        *_S1042 = make_float4 ((_S1044 - _S1045 * make_float3 (_S1046.w)).x, (_S1044 - _S1045 * make_float3 (_S1046.w)).y, (_S1044 - _S1045 * make_float3 (_S1046.w)).z, 0.0f);
        uint _S1047 = sv_0(c_17, slot_3 + 1U);
        float4  * _S1048 = (&(globalParams_0->scratch_0)[_S1047]);
        float4  _S1049 = *(&(globalParams_0->scratch_0)[_S1047]);
        float3  _S1050 = float3 {_S1049.x, _S1049.y, _S1049.z};
        float4  _S1051 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->inertia0_0);
        float4  _S1052 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->inertia1_0);
        float4  _S1053 = __ldg(&(&(globalParams_0->chunks_0)[c_17])->inertia2_0);
        *_S1048 = make_float4 ((_S1050 - rows_mul_0(_S1051, _S1052, _S1053, _S1039)).x, (_S1050 - rows_mul_0(_S1051, _S1052, _S1053, _S1039)).y, (_S1050 - rows_mul_0(_S1051, _S1052, _S1053, _S1039)).z, 0.0f);
        c_17 = c_17 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_13, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1054)
{
    uint _S1055;
    float4  _S1056 = make_float4 (0.0f);
    float4  acc_0 = _S1056;
    float4  unused_2 = _S1056;
    uint c_18 = c0_0 + tid_13;
    uint _S1057 = _S1054;
    for(;;)
    {
        bool _S1058 = c_18 < c1_0;
        uint _S1059 = __ballot_sync(_S1057, _S1058);
        if(_S1058)
        {
            uint _S1060 = __ballot_sync(_S1057, true);
        }
        else
        {
            uint _S1061 = __ballot_sync(_S1057, false);
            uint _S1062 = __ballot_sync(_S1057, false);
            uint _S1063 = __ballot_sync(_S1054, true);
            _S1055 = _S1063;
            break;
        }
        float4  _S1064 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sa_2)]);
        float4  _S1065 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sb_2)]);
        float4  _S1066 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sa_2 + 1U)]);
        float4  _S1067 = *(&(globalParams_0->scratch_0)[sv_0(c_18, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1064.x, _S1064.y, _S1064.z}, float3 {_S1065.x, _S1065.y, _S1065.z}) + dot_0(float3 {_S1066.x, _S1066.y, _S1066.z}, float3 {_S1067.x, _S1067.y, _S1067.z}));
        uint _S1068 = __ballot_sync(_S1057, true);
        c_18 = c_18 + 256U;
        _S1057 = _S1068;
    }
    group_sum2_0(tid_13, &acc_0, &unused_2, _S1055);
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
    float _S1069 = q_lin_0.z;
    float axial_0 = fdiv_0(_S1069, area_2);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_24->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_24->geom1_0.y);
    float _S1070 = q_lin_0.x;
    float _S1071 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S1070 * _S1070 + _S1071 * _S1071), area_2) + fdiv_0((F32_abs((q_ang_0.z))), b_24->geom0_0.w);
    Measures_0 m_2;
    (&m_2)->tension_0 = axial_0 + bending_0;
    (&m_2)->shear_0 = shear_1;
    float _S1072 = - axial_0;
    (&m_2)->normal_compression_0 = (F32_max((_S1072), (0.0f)));
    (&m_2)->compression_0 = _S1072 + bending_0;
    (&m_2)->compressive_force_0 = (F32_max((- _S1069), (0.0f)));
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
    float4  _S1073 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_7 <= ref_0)
    {
        return 1.0f;
    }
    float _S1074 = _S1073.z;
    float f_10;
    if(r_7 <= _S1074)
    {
        f_10 = fpow_0(fdiv_0(r_7, ref_0), _S1073.y);
    }
    else
    {
        f_10 = fpow_0(fdiv_0(_S1074, ref_0), _S1073.y) * fpow_0(fdiv_0(r_7, _S1074), _S1073.w);
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

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_26, Measures_0 * m_3, float multiplier_0)
{
    float fc_1 = mat_3->strength_0.y * multiplier_0;
    float _S1075 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_3->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_3->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S1076;
    if(_S1075 > 0.0f)
    {
        _S1076 = fdiv_0(m_3->shear_0, _S1075);
    }
    else
    {
        _S1076 = infinity_0();
    }
    *&((&idx_0)->y) = _S1076;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_3->compression_0, fc_1)), (0.0f)));
    float _S1077 = b_26->stiff1_0.y;
    if(_S1077 > 0.0f)
    {
        _S1076 = fdiv_0(m_3->compressive_force_0, _S1077);
    }
    else
    {
        _S1076 = 0.0f;
    }
    *&((&idx_0)->w) = _S1076;
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
    float _S1078 = (F32_max((damage_law_0(kind_3, lambda_0, r_9)), (d_old_0)));
    bool _S1079;
    if(_S1078 <= d_old_0)
    {
        _S1079 = true;
    }
    else
    {
        _S1079 = d_old_0 >= 1.0f;
    }
    if(_S1079)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S1080 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_9 > 1.0f)
        {
            return make_float2 (_S1078, fdiv_0(u0_0 * r_9, r_9 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_9))) - (F32_min((_S1080), (r_9)))), (0.0f))));
        }
        return make_float2 (_S1078, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_9 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S1080), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S1078 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S1078, plateau_0 + snap_0);
}

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_4;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S1081 = - h0_0;
    float _S1082 = - h1_0;
    FixedArray<float2 , 4>  _S1083 = { {
        float2 {
            _S1081, _S1082
        }, float2 {
            h0_0, _S1082
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S1081, h1_0
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
        uint _S1084 = i_12;
        uint _S1085 = i_12 + 1U;
        uint _S1086 = _S1085 % 4U;
        float _S1087 = _S1083[i_12].y;
        float _S1088 = _S1083[i_12].x;
        float fp_0 = dz_0 + ax_0 * _S1087 - ay_0 * _S1088;
        float _S1089 = _S1083[_S1086].y;
        float _S1090 = _S1083[_S1086].x;
        float fq_0 = dz_0 + ax_0 * _S1089 - ay_0 * _S1090;
        bool _S1091 = fp_0 < 0.0f;
        if(_S1091)
        {
            uint _S1092 = count_5 + 1U;
            poly_0[count_5] = _S1083[_S1084];
            count_4 = _S1092;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S1091 != (fq_0 < 0.0f))
        {
            float t_11 = fp_0 / (fp_0 - fq_0);
            uint _S1093 = count_4 + 1U;
            poly_0[count_4] = make_float2 (_S1088 + t_11 * (_S1090 - _S1088), _S1087 + t_11 * (_S1089 - _S1087));
            count_5 = _S1093;
        }
        else
        {
            count_5 = count_4;
        }
        i_12 = _S1085;
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
        float _S1094 = o_1.x;
        float x0_0 = poly_0[i_12].x - _S1094;
        float _S1095 = o_1.y;
        float y0_0 = poly_0[i_12].y - _S1095;
        uint _S1096 = i_12 + 1U;
        uint _S1097 = _S1096 % count_5;
        float x1_0 = poly_0[_S1097].x - _S1094;
        float y1_0 = poly_0[_S1097].y - _S1095;
        float _S1098 = x0_0 * y1_0;
        float _S1099 = x1_0 * y0_0;
        float cr_0 = _S1098 - _S1099;
        float a_15 = a_14 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S1098 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S1099) * cr_0 / 24.0f;
        i_12 = _S1096;
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
    float _S1100 = a_14 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S1100 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_14 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S1100 * cy_0;
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
    float k_15 = kn_0 / (w0_1 * w1_1);
    float fc_2 = dz_1 + ax_1 * r_10[int(2)] - ay_1 * r_10[int(1)];
    float _S1101 = a_16 * fc_2;
    float _S1102 = - ay_1;
    return make_float4 (k_15 * a_16 * fc_2, k_15 * (_S1101 * r_10[int(2)] + (_S1102 * r_10[int(5)] + ax_1 * r_10[int(4)])), - k_15 * (_S1101 * r_10[int(1)] + (_S1102 * r_10[int(3)] + ax_1 * r_10[int(5)])), 0.5f * k_15 * (_S1101 * fc_2 + ay_1 * ay_1 * r_10[int(3)] + ax_1 * ax_1 * r_10[int(4)] - 2.0f * ax_1 * ay_1 * r_10[int(5)]));
}

static __device__ float signum_0(float x_24)
{
    float _S1103;
    if(((F32_asuint((x_24))) & 2147483648U) != 0U)
    {
        _S1103 = -1.0f;
    }
    else
    {
        _S1103 = 1.0f;
    }
    return _S1103;
}

static __device__ float2  return_map_0(float k_16, float total_2, float plastic_0, float cap_0)
{
    float trial_0 = k_16 * (total_2 - plastic_0);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_11 = cap_0 * signum_0(trial_0);
    return make_float2 (f_11, fdiv_0(trial_0 - f_11, k_16));
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
    Contact_0 c_19;
    float3  _S1104 = make_float3 (0.0f);
    (&c_19)->q_lin_1 = _S1104;
    (&c_19)->q_ang_1 = _S1104;
    (&c_19)->energy_2 = 0.0f;
    (&c_19)->diss_2 = 0.0f;
    (&c_19)->plastic_1 = plastic_2;
    uint _S1105 = mat_4->kind_flags_0.y;
    if((_S1105 & 2U) == 0U)
    {
        return c_19;
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
    if((_S1105 & 4U) != 0U)
    {
        float4  p_11 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S1106 = p_11.y;
        float _S1107 = p_11.z;
        float _S1108 = p_11.w;
        nc_sum_0 = p_11.x;
        m1_0 = _S1106;
        m2_0 = _S1107;
        energy_3 = _S1108;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S1109 = d_ang_0.x;
        float _S1110 = d_ang_0.y;
        float spread_0 = (F32_abs((_S1109))) * 0.4166666567325592f * w1_2 + (F32_abs((_S1110))) * 0.4166666567325592f * w0_2;
        float _S1111 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S1111))) + spread_0);
        if((_S1111 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S1111 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S1112 = ki_0 * _S1109 * i2_0;
                float _S1113 = ki_0 * _S1110 * i1_0;
                float _S1114 = 0.5f * ki_0 * (36.0f * _S1111 * _S1111 + _S1109 * _S1109 * i2_0 + _S1110 * _S1110 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S1111;
                m1_0 = _S1112;
                m2_0 = _S1113;
                energy_3 = _S1114;
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
                    float _S1115 = SPRING_AT_0[i_13] * w0_2;
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
                        float di_0 = _S1111 + _S1109 * s2_0 - _S1110 * _S1115;
                        if(di_0 < 0.0f)
                        {
                            float f_12 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_12 * s2_0;
                            float m2_2 = m2_0 - f_12 * _S1115;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_12;
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
    (&c_19)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_19)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S1116 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S1117 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S1116 * _S1116 + _S1117 * _S1117);
    bool _S1118;
    if(tn_0 > slide_cap_0)
    {
        _S1118 = tn_0 > 0.0f;
    }
    else
    {
        _S1118 = false;
    }
    if(_S1118)
    {
        float _S1119 = fdiv_0(_S1116, tn_0);
        float _S1120 = fdiv_0(_S1117, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_12)->x) = *&((&p_12)->x) + _S1119 * dslip_0;
        *&((&p_12)->y) = *&((&p_12)->y) + _S1120 * dslip_0;
        *&((&(&c_19)->q_lin_1)->x) = _S1119 * slide_cap_0;
        *&((&(&c_19)->q_lin_1)->y) = _S1120 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_19)->q_lin_1)->x) = _S1116;
        *&((&(&c_19)->q_lin_1)->y) = _S1117;
        diss_3 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_12.z, slide_cap_0 * b_27->geom1_0.z);
    float _S1121 = tq_0.x;
    float _S1122 = tq_0.y;
    float diss_4 = diss_3 + (F32_abs((_S1121))) * (F32_abs((_S1122)));
    *&((&p_12)->z) = *&((&p_12)->z) + _S1122;
    *&((&(&c_19)->q_ang_1)->z) = _S1121;
    (&c_19)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_19)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_19)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S1121), kt_0));
    (&c_19)->diss_2 = diss_4;
    (&c_19)->plastic_1 = p_12;
    return c_19;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_28, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S1123 = mat_5->kind_flags_0.y;
    if((_S1123 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_28->stiff0_0.x;
    float ks_1 = b_28->stiff0_0.y;
    float kt_1 = b_28->stiff1_0.x;
    float w0_3 = b_28->geom0_0.y;
    float w1_3 = b_28->geom0_0.z;
    float nc_sum_1;
    if((_S1123 & 4U) != 0U)
    {
        float4  _S1124 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S1124.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S1125 = d_ang_1.x;
        float _S1126 = d_ang_1.y;
        float spread_1 = (F32_abs((_S1125))) * 0.4166666567325592f * w1_3 + (F32_abs((_S1126))) * 0.4166666567325592f * w0_3;
        float _S1127 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S1127))) + spread_1);
        if((_S1127 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S1127 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S1127;
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
                    float _S1128 = SPRING_AT_0[i_14] * w0_3;
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
                        float di_1 = _S1127 + _S1125 * (SPRING_AT_0[j_7] * w1_3) - _S1126 * _S1128;
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
    float _S1129 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S1130 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S1129 * _S1129 + _S1130 * _S1130);
    bool _S1131;
    if(tn_1 > slide_cap_1)
    {
        _S1131 = tn_1 > 0.0f;
    }
    else
    {
        _S1131 = false;
    }
    if(_S1131)
    {
        float _S1132 = fdiv_0(_S1130, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_13)->x) = *&((&p_13)->x) + fdiv_0(_S1129, tn_1) * dslip_1;
        *&((&p_13)->y) = *&((&p_13)->y) + _S1132 * dslip_1;
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
    float _S1133 = mat_6->misc_0.y;
    return fdiv_0((_S1133 + 1.0f) * fpow_0(s_5, _S1133), mat_6->misc_0.z);
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

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_29, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_10, bool fracture_1)
{
    float kn_3 = b_29->stiff0_0.x;
    float ks_2 = b_29->stiff0_0.y;
    float kb1_0 = b_29->stiff0_0.z;
    float kb2_0 = b_29->stiff0_0.w;
    float4  _S1134 = b_29->stiff1_0;
    float kt_2 = b_29->stiff1_0.x;
    bool has_rebar_1 = (b_29->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_2 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_2 & 1U) != 0U;
    JointState_0 st_1 = *state_2;
    bool _S1135 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S1136 = stress_measures_0(b_29, qe_lin_0, qe_ang_0);
    float _S1137 = (F32_max(((F32_max((_S1136.tension_0), (_S1136.shear_0)))), (_S1136.compression_0)));
    bool _S1138 = dt_10 > 0.0f;
    float dif_1;
    if(_S1138)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S1137 - (&st_1)->governing_stress_0, dt_10)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S1134.z;
        if((flags_2 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_10, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_10, tau_2)), (1.0f)));
        }
        (&st_1)->strain_rate_0 = (&st_1)->strain_rate_0 + (raw_0 - (&st_1)->strain_rate_0) * dif_1;
        (&st_1)->governing_stress_0 = _S1137;
    }
    if((flags_2 & 32U) != 0U)
    {
        float _S1139 = dif_factor_0(mat_7, (&st_1)->strain_rate_0);
        dif_1 = _S1139;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_29->geom1_0.w;
    float _S1140 = fatigue_factor_0(mat_7, (&st_1)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S1140;
    Measures_0 _S1141 = _S1136;
    float4  _S1142 = failure_indices_0(mat_7, b_29, &_S1141, multiplier_1);
    float _S1143 = _S1142.x;
    float _S1144 = _S1142.y;
    (&st_1)->utilization_0 = (F32_max(((F32_max((_S1143), (_S1144)))), ((F32_max((_S1142.z), (_S1142.w))))));
    float _S1145 = d_lin_2.x;
    float _S1146 = d_lin_2.y;
    float _S1147 = ks_2 * (sq_0(_S1145) + sq_0(_S1146)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S1148 = d_lin_2.z;
    bool _S1149 = _S1148 > 0.0f;
    if(_S1149)
    {
        dif_1 = kn_3 * sq_0(_S1148);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S1147 + dif_1);
    float psi_c_0;
    if(_S1148 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S1148);
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
    bool _S1150;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S1151 = _S1143 >= _S1144;
        if(_S1151)
        {
            diss_contact_0 = _S1143;
        }
        else
        {
            diss_contact_0 = _S1144;
        }
        uint mode_ts_0;
        if(_S1151)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_1)->kappa_0))
        {
            _S1150 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S1150 = false;
        }
        if(_S1150)
        {
            _S1150 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S1150 = false;
        }
        uint mode_c_0;
        if(_S1150)
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
            float _S1152 = inc_0.x;
            if(_S1152 > ((&st_1)->damage_0))
            {
                Contact_0 _S1153 = contact_part_0(mat_7, b_29, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S1154 = (F32_max((_S1153.energy_2 - (1.0f - (&st_1)->crush_0) * psi_c_0), (0.0f)));
                float _S1155 = (F32_max((inc_0.y - _S1154 * (_S1152 - (&st_1)->damage_0)), (0.0f)));
                float _S1156 = (F32_max(((psi_ts_0 - _S1154) * (_S1152 - (&st_1)->damage_0) - _S1155), (0.0f)));
                (&st_1)->damage_0 = _S1152;
                (&st_1)->mode_0 = mode_ts_0;
                dissipated_3 = _S1155;
                overshoot_1 = _S1156;
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
        float _S1157 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S1158 = contact_part_0(mat_7, b_29, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S1157) + _S1158.q_ang_1 * make_float3 (_S1157);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S1159 = stress_measures_0(b_29, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S1160 = _S1159;
        float4  _S1161 = failure_indices_0(mat_7, b_29, &_S1160, multiplier_1);
        float _S1162 = _S1161.z;
        float _S1163 = _S1161.w;
        bool _S1164 = _S1162 >= _S1163;
        if(_S1164)
        {
            psi_contact_0 = _S1162;
        }
        else
        {
            psi_contact_0 = _S1163;
        }
        if(_S1164)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_1)->kappa_c_0))
        {
            _S1150 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S1150 = false;
        }
        if(_S1150)
        {
            _S1150 = psi_c_0 > 0.0f;
        }
        else
        {
            _S1150 = false;
        }
        if(_S1150)
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
            float _S1165 = inc_1.x;
            if(_S1165 > ((&st_1)->crush_0))
            {
                float _S1166 = inc_1.y;
                float dissipated_4 = dissipated_3 + _S1166;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S1165 - (&st_1)->crush_0) - _S1166), (0.0f)));
                (&st_1)->crush_0 = _S1165;
                (&st_1)->mode_0 = mode_c_0;
                if(_S1165 >= 1.0f)
                {
                    _S1150 = ((&st_1)->damage_0) < 1.0f;
                }
                else
                {
                    _S1150 = false;
                }
                if(_S1150)
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
    float3  _S1167 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_1)->damage_0) == 0.0f)
    {
        if((flags_2 & 8U) == 0U)
        {
            float3  _S1168 = contact_offsets_0(mat_7, b_29, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_1)->plastic_x_0 = _S1168.x;
            (&st_1)->plastic_y_0 = _S1168.y;
            (&st_1)->plastic_t_0 = _S1168.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S1167;
        qc_ang_0 = _S1167;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S1169 = contact_part_0(mat_7, b_29, (&st_1)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_1)->plastic_x_0 = _S1169.plastic_1.x;
        (&st_1)->plastic_y_0 = _S1169.plastic_1.y;
        (&st_1)->plastic_t_0 = _S1169.plastic_1.z;
        diss_contact_0 = _S1169.diss_2;
        qc_lin_0 = _S1169.q_lin_1;
        qc_ang_0 = _S1169.q_ang_1;
        psi_contact_0 = _S1169.energy_2;
    }
    float dissipated_6 = dissipated_3 + dmg_0 * diss_contact_0;
    if(_S1149)
    {
        intact_normal_0 = kn_3 * _S1148;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_1)->crush_0) * kn_3 * _S1148;
    }
    float _S1170 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S1170 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S1170 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S1170 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S1170) + qc_ang_0 * make_float3 (dmg_0);
    float stored_4 = _S1170 * (psi_ts_0 + (1.0f - (&st_1)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S1150 = ((&st_1)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S1150 = false;
    }
    float stored_5;
    float3  force_lin_3;
    if(_S1150)
    {
        float k_axial_0 = b_29->rebar0_0.x;
        float k_dowel_0 = b_29->rebar0_0.y;
        float yield_force_0 = b_29->rebar0_0.z;
        float dowel_capacity_0 = b_29->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S1148, (&st_1)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S1145, (&st_1)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S1146, (&st_1)->rebar_slip1_0, dowel_capacity_0);
        float _S1171 = nr_0.y;
        float _S1172 = v1_0.y;
        float _S1173 = v2_0.y;
        float work_1 = yield_force_0 * (F32_abs((_S1171))) + dowel_capacity_0 * ((F32_abs((_S1172))) + (F32_abs((_S1173))));
        (&st_1)->rebar_plastic_0 = (&st_1)->rebar_plastic_0 + _S1171;
        (&st_1)->rebar_slip0_0 = (&st_1)->rebar_slip0_0 + _S1172;
        (&st_1)->rebar_slip1_0 = (&st_1)->rebar_slip1_0 + _S1173;
        (&st_1)->rebar_work_0 = (&st_1)->rebar_work_0 + work_1;
        float dissipated_7 = dissipated_6 + work_1;
        float _S1174 = nr_0.x;
        float _S1175 = v1_0.x;
        float _S1176 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S1174), k_axial_0) + fdiv_0(sq_0(_S1175) + sq_0(_S1176), k_dowel_0));
        if(fracture_1)
        {
            _S1150 = ((&st_1)->rebar_work_0) >= (b_29->rebar1_0.x);
        }
        else
        {
            _S1150 = false;
        }
        if(_S1150)
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
            force_lin_3 = force_lin_2 + make_float3 (_S1175, _S1176, _S1174);
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
        _S1150 = _S1138;
    }
    else
    {
        _S1150 = false;
    }
    if(_S1150)
    {
        _S1150 = (flags_2 & 64U) != 0U;
    }
    else
    {
        _S1150 = false;
    }
    if(_S1150)
    {
        Measures_0 _S1177 = stress_measures_0(b_29, force_lin_3, force_ang_2);
        Measures_0 _S1178 = _S1177;
        float4  _S1179 = failure_indices_0(mat_7, b_29, &_S1178, weibull_0);
        float _S1180 = life_rate_0(mat_7, (F32_max(((F32_max((_S1179.x), (_S1179.y)))), (_S1179.z))));
        (&st_1)->life_0 = (F32_max(((&st_1)->life_0 - _S1180 * dt_10), (0.0f)));
    }
    (&st_1)->dissipated_0 = (&st_1)->dissipated_0 + dissipated_3;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_1;
    (&resp_0)->dissipated_2 = dissipated_3;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_3 = stored_5;
    if(_S1135)
    {
        JointState_0 _S1181 = st_1;
        bool _S1182 = connected_0(&_S1181, has_rebar_1);
        _S1150 = !_S1182;
    }
    else
    {
        _S1150 = false;
    }
    (&resp_0)->disconnected_0 = _S1150;
    (&resp_0)->fatigue_before_0 = _S1140;
    (&resp_0)->measures_0 = _S1136;
    return resp_0;
}

static __device__ float3  to_local_0(uint _S1183, float3  _S1184)
{
    BondStatic_0 * _S1185 = (&(globalParams_0->bonds_0)[_S1183]);
    float4  _S1186 = __ldg(&_S1185->t1_0);
    float _S1187 = dot_0(_S1184, float3 {_S1186.x, _S1186.y, _S1186.z});
    float4  _S1188 = __ldg(&_S1185->t2_0);
    float _S1189 = dot_0(_S1184, float3 {_S1188.x, _S1188.y, _S1188.z});
    float4  _S1190 = __ldg(&_S1185->normal_0);
    return make_float3 (_S1187, _S1189, dot_0(_S1184, float3 {_S1190.x, _S1190.y, _S1190.z}));
}

static __device__ void static_kinematics_0(uint _S1191, float3  * _S1192, float3  * _S1193)
{
    BondStatic_0 * _S1194 = (&(globalParams_0->bonds_0)[_S1191]);
    JointBond_0 _S1195 = slang_ldg_0(&_S1194->law_0);
    uint ca_0 = _S1195.ids_0.y;
    uint cb_0 = _S1195.ids_0.z;
    uint _S1196 = 4U * cb_0;
    float4  _S1197 = *(&(globalParams_0->state_0)[_S1196]);
    uint _S1198 = 4U * ca_0;
    float4  _S1199 = *(&(globalParams_0->state_0)[_S1198]);
    float4  _S1200 = *(&(globalParams_0->scratch_0)[sv_0(cb_0, 21U)]);
    float4  _S1201 = *(&(globalParams_0->scratch_0)[sv_0(ca_0, 21U)]);
    float3  du_0 = float3 {_S1197.x, _S1197.y, _S1197.z} - float3 {_S1199.x, _S1199.y, _S1199.z} + (float3 {_S1200.x, _S1200.y, _S1200.z} - float3 {_S1201.x, _S1201.y, _S1201.z});
    uint _S1202 = _S1196 + 1U;
    float4  _S1203 = *(&(globalParams_0->state_0)[_S1202]);
    uint _S1204 = _S1198 + 1U;
    float4  _S1205 = *(&(globalParams_0->state_0)[_S1204]);
    uint _S1206 = sv_0(cb_0, 22U);
    float4  _S1207 = *(&(globalParams_0->scratch_0)[_S1206]);
    uint _S1208 = sv_0(ca_0, 22U);
    float4  _S1209 = *(&(globalParams_0->scratch_0)[_S1208]);
    float3  dth_0 = float3 {_S1203.x, _S1203.y, _S1203.z} - float3 {_S1205.x, _S1205.y, _S1205.z} + (float3 {_S1207.x, _S1207.y, _S1207.z} - float3 {_S1209.x, _S1209.y, _S1209.z});
    float4  _S1210 = *(&(globalParams_0->state_0)[_S1204]);
    float4  _S1211 = *(&(globalParams_0->scratch_0)[_S1208]);
    float3  ta_2 = float3 {_S1210.x, _S1210.y, _S1210.z} + float3 {_S1211.x, _S1211.y, _S1211.z};
    float4  _S1212 = *(&(globalParams_0->state_0)[_S1202]);
    float4  _S1213 = *(&(globalParams_0->scratch_0)[_S1206]);
    float3  tb_2 = float3 {_S1212.x, _S1212.y, _S1212.z} + float3 {_S1213.x, _S1213.y, _S1213.z};
    float4  _S1214 = __ldg(&_S1194->rb_0);
    float3  _S1215 = cross_0(tb_2, float3 {_S1214.x, _S1214.y, _S1214.z});
    float4  _S1216 = __ldg(&_S1194->ra_0);
    float3  _S1217 = to_local_0(_S1191, du_0 + (_S1215 - cross_0(ta_2, float3 {_S1216.x, _S1216.y, _S1216.z})));
    *_S1192 = _S1217;
    float3  _S1218 = to_local_0(_S1191, dth_0);
    *_S1193 = _S1218;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_15)
{
    BondStatic_0 * _S1219 = (&(globalParams_0->bonds_0)[i_15]);
    float3  d_lin_3;
    float3  d_ang_3;
    static_kinematics_0(i_15, &d_lin_3, &d_ang_3);
    JointBond_0 _S1220 = slang_ldg_0(&_S1219->law_0);
    JointBond_0 _S1221 = _S1220;
    JointState_0 _S1222 = (&(globalParams_0->bond_dyn_0)[i_15])->js_0;
    JointResponse_0 _S1223 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1220.ids_0.x], &_S1221, &_S1222, d_lin_3, d_ang_3, 0.0f, false);
    return _S1223;
}

static __device__ void gather_loads_0(uint c_20, float3  * fi_1, float3  * mi_0)
{
    float3  _S1224 = make_float3 (0.0f);
    *fi_1 = _S1224;
    *mi_0 = _S1224;
    uint _S1225 = __ldg((&(globalParams_0->index_0)[c_20]));
    uint e_3 = _S1225;
    for(;;)
    {
        uint _S1226 = __ldg((&(globalParams_0->index_0)[c_20 + 1U]));
        if(e_3 < _S1226)
        {
        }
        else
        {
            break;
        }
        uint _S1227 = __ldg((&(globalParams_0->index_0)[e_3]));
        uint bond_1 = _S1227 >> int(1);
        if((_S1227 & 1U) == 0U)
        {
            uint _S1228 = 3U * bond_1;
            float4  _S1229 = *(&(globalParams_0->scratch_0)[_S1228]);
            *fi_1 = *fi_1 + float3 {_S1229.x, _S1229.y, _S1229.z};
            float4  _S1230 = *(&(globalParams_0->scratch_0)[_S1228 + 1U]);
            *mi_0 = *mi_0 + float3 {_S1230.x, _S1230.y, _S1230.z};
        }
        else
        {
            uint _S1231 = 3U * bond_1;
            float4  _S1232 = *(&(globalParams_0->scratch_0)[_S1231]);
            *fi_1 = *fi_1 - float3 {_S1232.x, _S1232.y, _S1232.z};
            float4  _S1233 = *(&(globalParams_0->scratch_0)[_S1231 + 2U]);
            *mi_0 = *mi_0 + float3 {_S1233.x, _S1233.y, _S1233.z};
        }
        e_3 = e_3 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_21)
{
    uint _S1234 = __ldg((&(globalParams_0->index_0)[c_21]));
    uint e_4 = _S1234;
    float m_4 = 0.0f;
    for(;;)
    {
        uint _S1235 = __ldg((&(globalParams_0->index_0)[c_21 + 1U]));
        if(e_4 < _S1235)
        {
        }
        else
        {
            break;
        }
        uint _S1236 = __ldg((&(globalParams_0->index_0)[e_4]));
        uint _S1237 = 3U * (_S1236 >> int(1));
        float4  _S1238 = *(&(globalParams_0->scratch_0)[_S1237]);
        float3  f_13 = float3 {_S1238.x, _S1238.y, _S1238.z};
        float3  t_12;
        if((_S1236 & 1U) == 0U)
        {
            float4  _S1239 = *(&(globalParams_0->scratch_0)[_S1237 + 1U]);
            t_12 = float3 {_S1239.x, _S1239.y, _S1239.z};
        }
        else
        {
            float4  _S1240 = *(&(globalParams_0->scratch_0)[_S1237 + 2U]);
            t_12 = float3 {_S1240.x, _S1240.y, _S1240.z};
        }
        float m_5 = m_4 + (dot_0(f_13, f_13) + dot_0(t_12, t_12));
        e_4 = e_4 + 1U;
        m_4 = m_5;
    }
    return m_4;
}

static __device__ uint fixed_mask_0(uint c_22)
{
    uint4  _S1241 = __ldg(&(&(globalParams_0->chunks_0)[c_22])->info_0);
    uint support_0 = _S1241.x;
    uint _S1242;
    if(support_0 == 1U)
    {
        _S1242 = 63U;
    }
    else
    {
        if(support_0 == 2U)
        {
            _S1242 = 7U;
        }
        else
        {
            _S1242 = 0U;
        }
    }
    return _S1242;
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
    float _S1243 = st_2->damage_0;
    bool compressed_0 = (d_lin_4.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S1243;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S1244 = 1.0f - _S1243;
    float _S1245 = (F32_max((_S1244 + contact_3), (9.99999997475242708e-07f)));
    float normal_4;
    if(compressed_0)
    {
        normal_4 = (F32_max((1.0f - st_2->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_4 = (F32_max((_S1244), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S1245, _S1245, normal_4);
    *f_ang_0 = make_float3 (_S1245);
    bool _S1246;
    if((b_30->stiff1_0.w) != 0.0f)
    {
        _S1246 = (st_2->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S1246 = false;
    }
    if(_S1246)
    {
        float4  _S1247 = b_30->rebar0_0;
        float4  _S1248 = b_30->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_30->rebar0_0.x, b_30->stiff0_0.x);
        float _S1249 = fdiv_0(_S1247.y, _S1248.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S1249;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S1249;
    }
    return;
}

static __device__ uint statics_bond_slot_0(uint i_16)
{
    uint _S1250 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1251 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1250 + 23U * _S1251 + 2U * i_16;
}

static __device__ void store_inverse_0(uint c_23, FixedArray<float, 36>  * a_17)
{
    uint j_8;
    float sum_4;
    FixedArray<float, 36>  l_4;
    uint k_17 = 0U;
    for(;;)
    {
        if(k_17 < 36U)
        {
        }
        else
        {
            break;
        }
        l_4[k_17] = 0.0f;
        k_17 = k_17 + 1U;
    }
    bool spd_0 = true;
    uint i_17 = 0U;
    for(;;)
    {
        bool _S1252;
        if(i_17 < 6U)
        {
            _S1252 = spd_0;
        }
        else
        {
            _S1252 = false;
        }
        if(_S1252)
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
            uint _S1253 = i_17 * 6U;
            uint _S1254 = _S1253 + j_8;
            k_17 = 0U;
            sum_4 = (*a_17)[_S1254];
            for(;;)
            {
                if(k_17 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_4[_S1253 + k_17] * l_4[j_8 * 6U + k_17];
                k_17 = k_17 + 1U;
                sum_4 = sum_5;
            }
            if(i_17 == j_8)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S1253 + i_17] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_4[_S1254] = sum_4 / l_4[j_8 * 6U + j_8];
            }
            j_8 = j_8 + 1U;
        }
        i_17 = i_17 + 1U;
    }
    FixedArray<float, 36>  inv_0;
    if(!spd_0)
    {
        k_17 = 0U;
        for(;;)
        {
            if(k_17 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_17] = 0.0f;
            k_17 = k_17 + 1U;
        }
        k_17 = 0U;
        for(;;)
        {
            if(k_17 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1255 = k_17 * 6U + k_17;
            float _S1256 = (*a_17)[_S1255];
            if(((*a_17)[_S1255]) > 0.0f)
            {
                sum_4 = 1.0f / _S1256;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1255] = sum_4;
            k_17 = k_17 + 1U;
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
                k_17 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_17 < i_17)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_4[i_17 * 6U + k_17] * y_6[k_17];
                    k_17 = k_17 + 1U;
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
                k_17 = i_18 + 1U;
                sum_4 = y_6[i_18];
                for(;;)
                {
                    if(k_17 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_4[k_17 * 6U + i_18] * x_25[k_17];
                    k_17 = k_17 + 1U;
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
        uint _S1257 = 4U * j_8;
        *(&(globalParams_0->scratch_0)[sv_0(c_23, 12U + j_8)]) = make_float4 (inv_0[_S1257], inv_0[_S1257 + 1U], inv_0[_S1257 + 2U], inv_0[_S1257 + 3U]);
        j_8 = j_8 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_24)
{
    uint p_14;
    uint r_11;
    FixedArray<float, 36>  a_18;
    uint k_18 = 0U;
    for(;;)
    {
        if(k_18 < 36U)
        {
        }
        else
        {
            break;
        }
        a_18[k_18] = 0.0f;
        k_18 = k_18 + 1U;
    }
    uint _S1258 = __ldg((&(globalParams_0->index_0)[c_24]));
    uint e_5 = _S1258;
    for(;;)
    {
        uint _S1259 = __ldg((&(globalParams_0->index_0)[c_24 + 1U]));
        if(e_5 < _S1259)
        {
        }
        else
        {
            break;
        }
        uint _S1260 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint i_20 = _S1260 >> int(1);
        bool _S1261 = (_S1260 & 1U) != 0U;
        BondStatic_0 * _S1262 = (&(globalParams_0->bonds_0)[i_20]);
        uint _S1263 = statics_bond_slot_0(i_20);
        float4  _S1264 = *(&(globalParams_0->scratch_0)[_S1263]);
        float4  _S1265 = *(&(globalParams_0->scratch_0)[_S1263 + 1U]);
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
            uint _S1266 = p_14 % 3U;
            float3  t_13;
            if(_S1266 == 0U)
            {
                float4  _S1267 = __ldg(&_S1262->t1_0);
                t_13 = float3 {_S1267.x, _S1267.y, _S1267.z};
            }
            else
            {
                if(_S1266 == 1U)
                {
                    float4  _S1268 = __ldg(&_S1262->t2_0);
                    t_13 = float3 {_S1268.x, _S1268.y, _S1268.z};
                }
                else
                {
                    float4  _S1269 = __ldg(&_S1262->normal_0);
                    t_13 = float3 {_S1269.x, _S1269.y, _S1269.z};
                }
            }
            bool _S1270 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1270)
            {
                if(_S1261)
                {
                    row_u_0 = t_13;
                }
                else
                {
                    row_u_0 = - t_13;
                }
                if(_S1261)
                {
                    float4  _S1271 = __ldg(&_S1262->rb_0);
                    row_t_0 = cross_0(float3 {_S1271.x, _S1271.y, _S1271.z}, t_13);
                }
                else
                {
                    float4  _S1272 = __ldg(&_S1262->ra_0);
                    row_t_0 = - cross_0(float3 {_S1272.x, _S1272.y, _S1272.z}, t_13);
                }
            }
            else
            {
                float3  _S1273 = make_float3 (0.0f);
                if(_S1261)
                {
                    row_u_0 = t_13;
                }
                else
                {
                    row_u_0 = - t_13;
                }
                float3  _S1274 = row_u_0;
                row_u_0 = _S1273;
                row_t_0 = _S1274;
            }
            float kp_0;
            if(_S1270)
            {
                kp_0 = _slang_vector_get_element(_S1264, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1265, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1275 = { {
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
                    a_18[r_11 * 6U + q_12] = a_18[r_11 * 6U + q_12] + kp_0 * _S1275[r_11] * _S1275[q_12];
                    q_12 = q_12 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_5 = e_5 + 1U;
    }
    uint _S1276 = fixed_mask_0(c_24);
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
        if((_S1276 & (1U << p_14)) != 0U)
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
    FixedArray<float, 36>  _S1277 = a_18;
    store_inverse_0(c_24, &_S1277);
    return;
}

static __device__ float block_get_0(uint c_25, uint i_21, uint j_9)
{
    uint k_19 = i_21 * 6U + j_9;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_25, 12U + k_19 / 4U)]), k_19 % 4U);
}

static __device__ void precondition_0(uint c_26)
{
    float4  * _S1278 = (&(globalParams_0->scratch_0)[sv_0(c_26, 4U)]);
    float4  * _S1279 = (&(globalParams_0->scratch_0)[sv_0(c_26, 5U)]);
    FixedArray<float, 6>  _S1280 = { {
        (*_S1278).x, (*_S1278).y, (*_S1278).z, (*_S1279).x, (*_S1279).y, (*_S1279).z
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
            float s_10 = s_9 + block_get_0(c_26, i_22, j_10) * _S1280[j_10];
            j_10 = j_10 + 1U;
            s_9 = s_10;
        }
        z_1[i_22] = s_9;
        i_22 = i_22 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_26, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_26, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_14, Island_0 * isl_16, uint slot_4, uint _S1281)
{
    uint _S1282;
    uint _S1283;
    float3  _S1284 = make_float3 (0.0f);
    float3  p_15 = _S1284;
    float3  l_5 = _S1284;
    uint4  _S1285 = isl_16->range_0;
    uint _S1286 = isl_16->range_0.x + tid_14;
    uint c_27 = _S1286;
    uint _S1287 = _S1281;
    for(;;)
    {
        uint _S1288 = _S1285.y;
        _S1282 = _S1288;
        bool _S1289 = c_27 < _S1288;
        uint _S1290 = __ballot_sync(_S1287, _S1289);
        if(_S1289)
        {
            uint _S1291 = __ballot_sync(_S1287, true);
        }
        else
        {
            uint _S1292 = __ballot_sync(_S1287, false);
            uint _S1293 = __ballot_sync(_S1287, false);
            uint _S1294 = __ballot_sync(_S1281, true);
            _S1283 = _S1294;
            break;
        }
        float4  _S1295 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_4)]);
        float3  u_0 = float3 {_S1295.x, _S1295.y, _S1295.z};
        float4  _S1296 = *(&(globalParams_0->scratch_0)[sv_0(c_27, slot_4 + 1U)]);
        float3  th_2 = float3 {_S1296.x, _S1296.y, _S1296.z};
        float4  _S1297 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float4  _S1298 = isl_16->com_0;
        float3  r_12 = float3 {_S1297.x, _S1297.y, _S1297.z} - float3 {_S1298.x, _S1298.y, _S1298.z};
        float4  _S1299 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        p_15 = p_15 + u_0 * make_float3 (_S1299.w);
        float3  _S1300 = cross_0(r_12, u_0);
        float4  _S1301 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        float3  _S1302 = _S1300 * make_float3 (_S1301.w);
        float4  _S1303 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->inertia0_0);
        float4  _S1304 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->inertia1_0);
        float4  _S1305 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->inertia2_0);
        l_5 = l_5 + (_S1302 + rows_mul_0(_S1303, _S1304, _S1305, th_2));
        uint _S1306 = __ballot_sync(_S1287, true);
        c_27 = c_27 + 256U;
        _S1287 = _S1306;
    }
    group_sum3_0(tid_14, &p_15, &l_5, _S1283);
    float4  _S1307 = isl_16->com_0;
    float3  _S1308 = p_15 / make_float3 (isl_16->com_0.w);
    float3  _S1309 = rows_mul_0(isl_16->inv0_1, isl_16->inv1_1, isl_16->inv2_1, l_5);
    c_27 = _S1286;
    for(;;)
    {
        if(c_27 < _S1282)
        {
        }
        else
        {
            break;
        }
        float4  _S1310 = __ldg(&(&(globalParams_0->chunks_0)[c_27])->center_0);
        uint _S1311 = sv_0(c_27, slot_4);
        float4  _S1312 = *(&(globalParams_0->scratch_0)[_S1311]);
        *(&(globalParams_0->scratch_0)[_S1311]) = make_float4 ((float3 {_S1312.x, _S1312.y, _S1312.z} - _S1308 - cross_0(_S1309, float3 {_S1310.x, _S1310.y, _S1310.z} - float3 {_S1307.x, _S1307.y, _S1307.z})).x, (float3 {_S1312.x, _S1312.y, _S1312.z} - _S1308 - cross_0(_S1309, float3 {_S1310.x, _S1310.y, _S1310.z} - float3 {_S1307.x, _S1307.y, _S1307.z})).y, (float3 {_S1312.x, _S1312.y, _S1312.z} - _S1308 - cross_0(_S1309, float3 {_S1310.x, _S1310.y, _S1310.z} - float3 {_S1307.x, _S1307.y, _S1307.z})).z, 0.0f);
        uint _S1313 = sv_0(c_27, slot_4 + 1U);
        float4  _S1314 = *(&(globalParams_0->scratch_0)[_S1313]);
        *(&(globalParams_0->scratch_0)[_S1313]) = make_float4 ((float3 {_S1314.x, _S1314.y, _S1314.z} - _S1309).x, (float3 {_S1314.x, _S1314.y, _S1314.z} - _S1309).y, (float3 {_S1314.x, _S1314.y, _S1314.z} - _S1309).z, 0.0f);
        c_27 = c_27 + 256U;
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
    uint c_28;
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
    uint c_29 = _S1375;
    uint newton_0;
    newton_0 = _S1354;
    for(;;)
    {
        bool _S1376 = c_29 < c1_1;
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
        *(&(globalParams_0->scratch_0)[sv_0(c_29, 21U)]) = _S1382;
        *(&(globalParams_0->scratch_0)[sv_0(c_29, 22U)]) = _S1382;
        uint _S1383 = __ballot_sync(newton_0, true);
        c_29 = c_29 + 256U;
        newton_0 = _S1383;
    }
    __syncthreads();
    uint _S1384 = __ballot_sync(_S1355, free_0);
    if(free_0)
    {
        Island_0 _S1385 = isl_17;
        project_load_slot_0(tid_15, &_S1385, 0U, _S1384);
        uint _S1386 = __ballot_sync(_S1355, true);
        c_29 = _S1386;
    }
    else
    {
        uint _S1387 = __ballot_sync(_S1355, true);
        c_29 = _S1387;
    }
    float _S1388 = island_dot_0(tid_15, c0_1, c1_1, 0U, 0U, c_29);
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
        uint _S1396 = __ballot_sync(c_29, _S1395);
        if(_S1395)
        {
            uint _S1397 = __ballot_sync(c_29, true);
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
        uint c_30 = _S1375;
        uint _S1408 = _S1356;
        for(;;)
        {
            bool _S1409 = c_30 < c1_1;
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
            gather_loads_0(c_30, &fi_2, &mi_1);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_30);
            float4  _S1415 = *(&(globalParams_0->scratch_0)[sv_0(c_30, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S1415.x, _S1415.y, _S1415.z} + fi_2).x, (float3 {_S1415.x, _S1415.y, _S1415.z} + fi_2).y, (float3 {_S1415.x, _S1415.y, _S1415.z} + fi_2).z, 0.0f);
            float4  _S1416 = *(&(globalParams_0->scratch_0)[sv_0(c_30, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S1416.x, _S1416.y, _S1416.z} + mi_1).x, (float3 {_S1416.x, _S1416.y, _S1416.z} + mi_1).y, (float3 {_S1416.x, _S1416.y, _S1416.z} + mi_1).z, 0.0f);
            hold_0(fixed_mask_0(c_30), &r_lin_0, &r_ang_0, _S1407, _S1407);
            *(&(globalParams_0->scratch_0)[sv_0(c_30, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_30, 5U)]) = r_ang_0;
            uint _S1417 = __ballot_sync(_S1408, true);
            c_30 = c_30 + 256U;
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
        uint c_31 = _S1375;
        uint _S1453 = _S1358;
        for(;;)
        {
            bool _S1454 = c_31 < c1_1;
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
            assemble_block_0(c_31);
            *(&(globalParams_0->scratch_0)[sv_0(c_31, 2U)]) = _S1407;
            *(&(globalParams_0->scratch_0)[sv_0(c_31, 3U)]) = _S1407;
            uint _S1460 = __ballot_sync(_S1453, true);
            c_31 = c_31 + 256U;
            _S1453 = _S1460;
        }
        __syncthreads();
        uint c_32 = _S1375;
        uint _S1461 = _S1359;
        for(;;)
        {
            bool _S1462 = c_32 < c1_1;
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
            precondition_0(c_32);
            uint _S1468 = __ballot_sync(_S1461, true);
            c_32 = c_32 + 256U;
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
        uint c_33 = _S1375;
        uint _S1474 = _S1470;
        for(;;)
        {
            bool _S1475 = c_33 < c1_1;
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
            *(&(globalParams_0->scratch_0)[sv_0(c_33, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_33, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_33, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_33, 7U)]);
            uint _S1481 = __ballot_sync(_S1474, true);
            c_33 = c_33 + 256U;
            _S1474 = _S1481;
        }
        __syncthreads();
        float _S1482 = island_dot_0(tid_15, c0_1, c1_1, 4U, 6U, _S1361);
        float _S1483 = island_dot_0(tid_15, c0_1, c1_1, 4U, 4U, _S1361);
        float _S1484 = (F32_sqrt((_S1483)));
        float rz_0 = _S1482;
        uint k_20 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S1485 = _S1361;
        for(;;)
        {
            bool _S1486 = k_20 < _S1392;
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
            c_28 = _S1375;
            uint _S1514 = _S1363;
            for(;;)
            {
                bool _S1515 = c_28 < c1_1;
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
                gather_loads_0(c_28, &fi_3, &mi_2);
                float4  ap_lin_0 = make_float4 ((- fi_3).x, (- fi_3).y, (- fi_3).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_2).x, (- mi_2).y, (- mi_2).z, 0.0f);
                hold_0(fixed_mask_0(c_28), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_28, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_28, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_28, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_28, 11U)]) = ap_ang_0;
                uint _S1521 = __ballot_sync(_S1514, true);
                c_28 = c_28 + 256U;
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
            uint c_34 = _S1375;
            uint _S1532;
            _S1532 = _S1522;
            for(;;)
            {
                bool _S1533 = c_34 < c1_1;
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
                uint _S1539 = sv_0(c_34, 2U);
                float4  _S1540 = *(&(globalParams_0->scratch_0)[_S1539]);
                float4  _S1541 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 8U)]);
                *(&(globalParams_0->scratch_0)[_S1539]) = make_float4 ((float3 {_S1540.x, _S1540.y, _S1540.z} + make_float3 (_S1531) * float3 {_S1541.x, _S1541.y, _S1541.z}).x, (float3 {_S1540.x, _S1540.y, _S1540.z} + make_float3 (_S1531) * float3 {_S1541.x, _S1541.y, _S1541.z}).y, (float3 {_S1540.x, _S1540.y, _S1540.z} + make_float3 (_S1531) * float3 {_S1541.x, _S1541.y, _S1541.z}).z, 0.0f);
                uint _S1542 = sv_0(c_34, 3U);
                float4  _S1543 = *(&(globalParams_0->scratch_0)[_S1542]);
                float4  _S1544 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 9U)]);
                *(&(globalParams_0->scratch_0)[_S1542]) = make_float4 ((float3 {_S1543.x, _S1543.y, _S1543.z} + make_float3 (_S1531) * float3 {_S1544.x, _S1544.y, _S1544.z}).x, (float3 {_S1543.x, _S1543.y, _S1543.z} + make_float3 (_S1531) * float3 {_S1544.x, _S1544.y, _S1544.z}).y, (float3 {_S1543.x, _S1543.y, _S1543.z} + make_float3 (_S1531) * float3 {_S1544.x, _S1544.y, _S1544.z}).z, 0.0f);
                uint _S1545 = sv_0(c_34, 4U);
                float4  _S1546 = *(&(globalParams_0->scratch_0)[_S1545]);
                float4  _S1547 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 10U)]);
                *(&(globalParams_0->scratch_0)[_S1545]) = make_float4 ((float3 {_S1546.x, _S1546.y, _S1546.z} - make_float3 (_S1531) * float3 {_S1547.x, _S1547.y, _S1547.z}).x, (float3 {_S1546.x, _S1546.y, _S1546.z} - make_float3 (_S1531) * float3 {_S1547.x, _S1547.y, _S1547.z}).y, (float3 {_S1546.x, _S1546.y, _S1546.z} - make_float3 (_S1531) * float3 {_S1547.x, _S1547.y, _S1547.z}).z, 0.0f);
                uint _S1548 = sv_0(c_34, 5U);
                float4  _S1549 = *(&(globalParams_0->scratch_0)[_S1548]);
                float4  _S1550 = *(&(globalParams_0->scratch_0)[sv_0(c_34, 11U)]);
                *(&(globalParams_0->scratch_0)[_S1548]) = make_float4 ((float3 {_S1549.x, _S1549.y, _S1549.z} - make_float3 (_S1531) * float3 {_S1550.x, _S1550.y, _S1550.z}).x, (float3 {_S1549.x, _S1549.y, _S1549.z} - make_float3 (_S1531) * float3 {_S1550.x, _S1550.y, _S1550.z}).y, (float3 {_S1549.x, _S1549.y, _S1549.z} - make_float3 (_S1531) * float3 {_S1550.x, _S1550.y, _S1550.z}).z, 0.0f);
                uint _S1551 = __ballot_sync(_S1532, true);
                c_34 = c_34 + 256U;
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
            uint c_35 = _S1375;
            uint _S1560;
            _S1560 = _S1552;
            for(;;)
            {
                bool _S1561 = c_35 < c1_1;
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
                precondition_0(c_35);
                uint _S1567 = __ballot_sync(_S1560, true);
                c_35 = c_35 + 256U;
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
            uint c_36 = _S1375;
            uint _S1575 = _S1569;
            for(;;)
            {
                bool _S1576 = c_36 < c1_1;
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
                uint _S1582 = sv_0(c_36, 8U);
                float4  _S1583 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 6U)]);
                float4  _S1584 = *(&(globalParams_0->scratch_0)[_S1582]);
                *(&(globalParams_0->scratch_0)[_S1582]) = make_float4 ((float3 {_S1583.x, _S1583.y, _S1583.z} + make_float3 (_S1574) * float3 {_S1584.x, _S1584.y, _S1584.z}).x, (float3 {_S1583.x, _S1583.y, _S1583.z} + make_float3 (_S1574) * float3 {_S1584.x, _S1584.y, _S1584.z}).y, (float3 {_S1583.x, _S1583.y, _S1583.z} + make_float3 (_S1574) * float3 {_S1584.x, _S1584.y, _S1584.z}).z, 0.0f);
                uint _S1585 = sv_0(c_36, 9U);
                float4  _S1586 = *(&(globalParams_0->scratch_0)[sv_0(c_36, 7U)]);
                float4  _S1587 = *(&(globalParams_0->scratch_0)[_S1585]);
                *(&(globalParams_0->scratch_0)[_S1585]) = make_float4 ((float3 {_S1586.x, _S1586.y, _S1586.z} + make_float3 (_S1574) * float3 {_S1587.x, _S1587.y, _S1587.z}).x, (float3 {_S1586.x, _S1586.y, _S1586.z} + make_float3 (_S1574) * float3 {_S1587.x, _S1587.y, _S1587.z}).y, (float3 {_S1586.x, _S1586.y, _S1586.z} + make_float3 (_S1574) * float3 {_S1587.x, _S1587.y, _S1587.z}).z, 0.0f);
                uint _S1588 = __ballot_sync(_S1575, true);
                c_36 = c_36 + 256U;
                _S1575 = _S1588;
            }
            __syncthreads();
            uint _S1589 = __ballot_sync(_S1485, true);
            uint _S1590 = k_20 + 1U;
            rz_0 = _S1573;
            k_20 = _S1590;
            cg_total_1 = _S1524;
            _S1485 = _S1589;
        }
        c_28 = _S1375;
        _S1362 = i_24;
        for(;;)
        {
            bool _S1591 = c_28 < c1_1;
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
            uint _S1597 = 4U * c_28;
            float4  _S1598 = *(&(globalParams_0->state_0)[_S1597]);
            float3  u_1 = float3 {_S1598.x, _S1598.y, _S1598.z};
            uint _S1599 = sv_0(c_28, 21U);
            float4  _S1600 = *(&(globalParams_0->scratch_0)[_S1599]);
            float3  u_lo_0 = float3 {_S1600.x, _S1600.y, _S1600.z};
            uint _S1601 = _S1597 + 1U;
            float4  _S1602 = *(&(globalParams_0->state_0)[_S1601]);
            float3  th_3 = float3 {_S1602.x, _S1602.y, _S1602.z};
            uint _S1603 = sv_0(c_28, 22U);
            float4  _S1604 = *(&(globalParams_0->scratch_0)[_S1603]);
            float3  th_lo_0 = float3 {_S1604.x, _S1604.y, _S1604.z};
            float4  _S1605 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 2U)]);
            comp_add_0(&u_1, &u_lo_0, float3 {_S1605.x, _S1605.y, _S1605.z});
            float4  _S1606 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 3U)]);
            comp_add_0(&th_3, &th_lo_0, float3 {_S1606.x, _S1606.y, _S1606.z});
            *(&(globalParams_0->state_0)[_S1597]) = make_float4 (u_1.x, u_1.y, u_1.z, (*(&(globalParams_0->state_0)[_S1597])).w);
            *(&(globalParams_0->state_0)[_S1601]) = make_float4 (th_3.x, th_3.y, th_3.z, (*(&(globalParams_0->state_0)[_S1601])).w);
            *(&(globalParams_0->scratch_0)[_S1599]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S1603]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S1607 = __ballot_sync(_S1362, true);
            c_28 = c_28 + 256U;
            _S1362 = _S1607;
        }
        __syncthreads();
        uint _S1608 = newton_0 + 1U;
        uint _S1609 = __ballot_sync(c_29, true);
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S1608;
        c_29 = _S1609;
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
    c_28 = _S1375;
    for(;;)
    {
        if(c_28 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_4;
        float3  mi_3;
        gather_loads_0(c_28, &fi_4, &mi_3);
        float3  reaction_0;
        if((fixed_mask_0(c_28)) != 0U)
        {
            float4  _S1610 = *(&(globalParams_0->scratch_0)[sv_0(c_28, 0U)]);
            reaction_0 = - (float3 {_S1610.x, _S1610.y, _S1610.z} + fi_4);
        }
        else
        {
            uint _S1611 = 4U * c_28;
            reaction_0 = make_float3 ((*(&(globalParams_0->state_0)[_S1611 + 1U])).w, (*(&(globalParams_0->state_0)[_S1611 + 2U])).w, (*(&(globalParams_0->state_0)[_S1611 + 3U])).w);
        }
        uint _S1612 = 4U * c_28;
        uint _S1613 = _S1612 + 1U;
        float4  _S1614 = *(&(globalParams_0->state_0)[_S1613]);
        *(&(globalParams_0->state_0)[_S1613]) = make_float4 (float3 {_S1614.x, _S1614.y, _S1614.z}.x, float3 {_S1614.x, _S1614.y, _S1614.z}.y, float3 {_S1614.x, _S1614.y, _S1614.z}.z, reaction_0.x);
        *(&(globalParams_0->state_0)[_S1612 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.y);
        *(&(globalParams_0->state_0)[_S1612 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_0.z);
        c_28 = c_28 + 256U;
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
    uint k_21;
    if(_S1662)
    {
        uint _S1665 = __ballot_sync(_S1653, true);
        _S1664 = true;
        k_21 = _S1665;
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
        k_21 = _S1673;
    }
    uint _S1674 = 0U;
    uint _S1675 = __ballot_sync(k_21, _S1664);
    if(_S1664)
    {
        return;
    }
    else
    {
        uint _S1676 = __ballot_sync(k_21, true);
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
    float4  rf_2 = _S1681;
    float4  rt_0 = _S1681;
    k_21 = (&imp_6)->cand_0.x + tid_17;
    uint total_points_0;
    total_points_0 = _S1677;
    for(;;)
    {
        bool _S1682 = k_21 < ((&imp_6)->cand_0.y);
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
        uint _S1689 = 3U * k_21;
        rf_2 = rf_2 + *(&(globalParams_0->scratch_0)[_S1688 + _S1689 + 1U]);
        uint _S1690 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S1690 + _S1689 + 2U]);
        uint _S1691 = __ballot_sync(total_points_0, true);
        k_21 = k_21 + 256U;
        total_points_0 = _S1691;
    }
    group_sum2_0(tid_17, &rf_2, &rt_0, _S1654);
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
            float3  f_14 = penalty_force_0(_S1716, _S1722, _S1723, depth_3, _S1706, v_9, _S1694, below_0, &stored_7, &diss_5);
            float3  load_f_1 = load_f_0 + f_14;
            float3  load_t_1 = load_t_0 + cross_0(p_16, f_14);
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
    float4  _S1724 = rf_2;
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
    uint k_22 = _S1741 - _S1742;
    uint _S1743 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_22 < _S1743)
    {
        uint _S1744 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S1745 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_7 = _S1744 + 2U * (ii_2 * _S1745 + k_22);
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

static __device__ void ground_contact_0(uint c_37, bool account_0, float3  * f_15, float3  * t_14)
{
    WorldPoint_0 wp_1 = chunk_world_0(c_37);
    float _S1747 = wp_1.hi_0.z;
    float _S1748 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S1749 = _S1747 - _S1748;
    float _S1750 = wp_1.lo_0.z;
    float _S1751 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S1749 + (_S1750 - _S1751) + wp_1.rel_0.z;
    float4  _S1752 = __ldg(&(&(globalParams_0->chunks_0)[c_37])->half_0);
    if((above_0 - _S1752.w) > 0.0f)
    {
        return;
    }
    Box_0 b_31 = chunk_box_0(c_37, make_float3 (0.0f));
    float _S1753 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S1754 = __ldg(&(&(globalParams_0->chunks_0)[c_37])->cmat_0);
    float _S1755 = _S1754.x;
    float3  _S1756 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S1757 = b_31;
    Box_0 _S1758 = b_31;
    float _S1759 = contact_stiffness_0(_S1753, &_S1757, _S1755, &_S1758, _S1756);
    Box_0 _S1760 = b_31;
    uint _S1761 = sample_count_0(&_S1760);
    uint s_12 = 0U;
    uint n_9 = 0U;
    for(;;)
    {
        if(s_12 < _S1761)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1762 = b_31;
        float3  _S1763 = sample_point_0(&_S1762, s_12);
        if((above_0 + _S1763.z) < 0.0f)
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
    chunk_velocity_0(c_37, &vc_1, &wc_1);
    uint _S1764 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S1765 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S1764 + _S1765 + c_37]);
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S1761)
        {
        }
        else
        {
            break;
        }
        Box_0 _S1766 = b_31;
        float3  _S1767 = sample_point_0(&_S1766, s_12);
        float _S1768 = above_0 + _S1767.z;
        if(!(_S1768 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        float depth_4 = - _S1768;
        float3  v_10 = vc_1 + cross_0(wc_1, _S1767);
        float _S1769 = _S1759 / float((U32_max((n_9), (5U))));
        float4  _S1770 = __ldg(&(&(globalParams_0->chunks_0)[c_37])->center_0);
        float _S1771 = _S1770.w;
        float _S1772 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S1773 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_8;
        float diss_6;
        float3  g_2 = penalty_force_0(_S1769, _S1771, _S1772, depth_4, _S1756, v_10, _S1773, n_9, &stored_8, &diss_6);
        *f_15 = *f_15 + g_2;
        *t_14 = *t_14 + cross_0(_S1767, g_2);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_6);
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        uint _S1774 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S1775 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S1774 + _S1775 + c_37]) = ledger_2;
    }
    return;
}

static __device__ void contact_sum_at_0(uint g_3)
{
    uint _S1776 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S1777;
    if(g_3 >= _S1776)
    {
        _S1777 = true;
    }
    else
    {
        _S1777 = stopped_0();
    }
    if(_S1777)
    {
        return;
    }
    uint _S1778 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1779 = 3U * g_3;
    uint _S1780 = __ldg((&(globalParams_0->index_0)[_S1778 + _S1779]));
    uint _S1781 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1782 = __ldg((&(globalParams_0->index_0)[_S1781 + _S1779 + 1U]));
    uint _S1783 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S1784 = __ldg((&(globalParams_0->index_0)[_S1783 + _S1779 + 2U]));
    float3  _S1785 = make_float3 (0.0f);
    float3  f_16 = _S1785;
    float3  t_15 = _S1785;
    uint e_6 = _S1782;
    for(;;)
    {
        if(e_6 < _S1784)
        {
        }
        else
        {
            break;
        }
        uint _S1786 = __ldg((&(globalParams_0->index_0)[e_6]));
        if(_S1786 == 2147483648U)
        {
            ground_contact_0(_S1780, true, &f_16, &t_15);
            e_6 = e_6 + 1U;
            continue;
        }
        uint _S1787 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S1788 = 2U * _S1786;
        float4  _S1789 = *(&(globalParams_0->scratch_0)[_S1787 + _S1788]);
        f_16 = f_16 + float3 {_S1789.x, _S1789.y, _S1789.z};
        uint _S1790 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S1791 = *(&(globalParams_0->scratch_0)[_S1790 + _S1788 + 1U]);
        t_15 = t_15 + float3 {_S1791.x, _S1791.y, _S1791.z};
        e_6 = e_6 + 1U;
    }
    uint _S1792 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S1793 = 2U * g_3;
    *(&(globalParams_0->scratch_0)[_S1792 + _S1793]) = make_float4 (f_16.x, f_16.y, f_16.z, 0.0f);
    uint _S1794 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S1794 + _S1793 + 1U]) = make_float4 (t_15.x, t_15.y, t_15.z, 0.0f);
    return;
}

extern "C" __global__ void contact_sums()
{
    contact_sum_at_0((blockIdx * blockDim + threadIdx).x);
    return;
}

static __device__ void net_load_0(uint c_38, Island_0 * isl_19, Rigid_0 * rg_7, uint k_23, float dt_11, bool contact_4, float3  * f_17, float3  * t_16)
{
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_38, &rg_7->rot_3, k_23, dt_11, contact_4, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S1795 = fl_0;
    float4  _S1796 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S1797 = float3 {_S1796.x, _S1796.y, _S1796.z};
    float4  _S1798 = __ldg(&(&(globalParams_0->chunks_0)[c_38])->center_0);
    float3  fc_3 = _S1795 + _S1797 * make_float3 (_S1798.w);
    float4  _S1799 = __ldg(&(&(globalParams_0->chunks_0)[c_38])->center_0);
    float4  _S1800 = *(&(globalParams_0->state_0)[4U * c_38]);
    float4  _S1801 = isl_19->com_0;
    float3  _S1802 = float3 {_S1801.x, _S1801.y, _S1801.z};
    float3  _S1803 = rotate_0(&rg_7->rot_3, float3 {_S1799.x, _S1799.y, _S1799.z} + float3 {_S1800.x, _S1800.y, _S1800.z} - _S1802);
    *f_17 = *f_17 + fc_3;
    *t_16 = *t_16 + (cross_0(_S1803, fc_3) + tl_0);
    uint4  _S1804 = __ldg(&(&(globalParams_0->chunks_0)[c_38])->load_range_0);
    uint _S1805 = _S1804.y;
    uint4  _S1806 = __ldg(&(&(globalParams_0->chunks_0)[c_38])->load_range_0);
    if(_S1805 > (_S1806.x))
    {
        float3  _S1807 = rotate_0(&rg_7->rot_3, rep_f_0);
        *f_17 = *f_17 + _S1807;
        float4  _S1808 = __ldg(&(&(globalParams_0->chunks_0)[c_38])->center_0);
        float3  _S1809 = rotate_0(&rg_7->rot_3, float3 {_S1808.x, _S1808.y, _S1808.z} - _S1802);
        float3  _S1810 = cross_0(_S1809, _S1807);
        float3  _S1811 = rotate_0(&rg_7->rot_3, rep_m_0);
        *t_16 = *t_16 + (_S1810 + _S1811);
    }
    return;
}

static __device__ bool bond_update_0(uint i_27, float dt_12, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S1812 = (&(globalParams_0->bonds_0)[i_27]);
    JointBond_0 _S1813 = slang_ldg_0(&_S1812->law_0);
    uint ca_2 = _S1813.ids_0.y;
    uint cb_2 = _S1813.ids_0.z;
    float4  _S1814 = __ldg(&_S1812->ra_0);
    float3  ra_1 = float3 {_S1814.x, _S1814.y, _S1814.z};
    float4  _S1815 = __ldg(&_S1812->rb_0);
    float3  rb_1 = float3 {_S1815.x, _S1815.y, _S1815.z};
    uint _S1816 = 4U * ca_2;
    float4  _S1817 = *(&(globalParams_0->state_0)[_S1816]);
    float4  _S1818 = *(&(globalParams_0->state_0)[_S1816 + 1U]);
    float3  ta_3 = float3 {_S1818.x, _S1818.y, _S1818.z};
    float4  _S1819 = *(&(globalParams_0->state_0)[_S1816 + 2U]);
    float3  va_0 = float3 {_S1819.x, _S1819.y, _S1819.z};
    float4  _S1820 = *(&(globalParams_0->state_0)[_S1816 + 3U]);
    float3  wa_1 = float3 {_S1820.x, _S1820.y, _S1820.z};
    uint _S1821 = 4U * cb_2;
    float4  _S1822 = *(&(globalParams_0->state_0)[_S1821]);
    float4  _S1823 = *(&(globalParams_0->state_0)[_S1821 + 1U]);
    float3  tb_3 = float3 {_S1823.x, _S1823.y, _S1823.z};
    float4  _S1824 = *(&(globalParams_0->state_0)[_S1821 + 2U]);
    float3  vb_0 = float3 {_S1824.x, _S1824.y, _S1824.z};
    float4  _S1825 = *(&(globalParams_0->state_0)[_S1821 + 3U]);
    float3  wb_0 = float3 {_S1825.x, _S1825.y, _S1825.z};
    float3  _S1826 = to_local_0(i_27, float3 {_S1822.x, _S1822.y, _S1822.z} + cross_0(tb_3, rb_1) - (float3 {_S1817.x, _S1817.y, _S1817.z} + cross_0(ta_3, ra_1)));
    float3  _S1827 = to_local_0(i_27, tb_3 - ta_3);
    float3  _S1828 = to_local_0(i_27, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_1, ra_1)));
    float3  _S1829 = to_local_0(i_27, wb_0 - wa_1);
    JointBond_0 _S1830 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
    JointState_0 previous_3 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
    JointState_0 _S1831 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
    bool _S1832 = is_damaged_0(&_S1831);
    JointBond_0 _S1833 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
    JointBond_0 _S1834 = _S1833;
    JointState_0 _S1835 = (&(globalParams_0->bond_dyn_0)[i_27])->js_0;
    JointResponse_0 _S1836 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1830.ids_0.x], &_S1834, &_S1835, _S1826, _S1827, dt_12, fracture_2);
    BondStatic_0 * _S1837 = (&(globalParams_0->bonds_0)[i_27]);
    BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_27]);
    float4  _S1838 = __ldg(&_S1837->ra_0);
    float3  ra_2 = float3 {_S1838.x, _S1838.y, _S1838.z};
    float4  _S1839 = __ldg(&_S1837->rb_0);
    float3  rb_2 = float3 {_S1839.x, _S1839.y, _S1839.z};
    JointBond_0 _S1840 = slang_ldg_0(&_S1837->law_0);
    JointBond_0 _S1841 = _S1840;
    JointState_0 _S1842 = _S1836.state_1;
    float3  f_lin_2;
    float3  f_ang_2;
    secant_factors_0(&_S1841, &_S1842, _S1826, &f_lin_2, &f_ang_2);
    float4  _S1843 = __ldg(&_S1837->c_lin_0);
    float3  qd_lin_0 = _S1828 * float3 {_S1843.x, _S1843.y, _S1843.z} * f_lin_2;
    float4  _S1844 = __ldg(&_S1837->c_ang_0);
    float3  qd_ang_0 = _S1829 * float3 {_S1844.x, _S1844.y, _S1844.z} * f_ang_2;
    float3  q_lin_2 = _S1836.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S1836.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S1828) + dot_0(qd_ang_0, _S1829)) * dt_12;
    float3  _S1845 = to_body_0(i_27, q_lin_2);
    float3  _S1846 = to_body_0(i_27, q_ang_2);
    uint _S1847 = 3U * i_27;
    *(&(globalParams_0->scratch_0)[_S1847]) = make_float4 (_S1845.x, _S1845.y, _S1845.z, (F32_max((_S1836.measures_0.tension_0), (_S1836.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S1847 + 1U]) = make_float4 ((_S1846 + cross_0(ra_2, _S1845)).x, (_S1846 + cross_0(ra_2, _S1845)).y, (_S1846 + cross_0(ra_2, _S1845)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S1847 + 2U]) = make_float4 ((- _S1846 + cross_0(rb_2, - _S1845)).x, (- _S1846 + cross_0(rb_2, - _S1845)).y, (- _S1846 + cross_0(rb_2, - _S1845)).z, 0.0f);
    comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S1836.dissipated_2);
    comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S1836.overshoot_0);
    comp_add1_0(&((&(&bd_2)->sums_0)->z), &((&(&bd_2)->comps_0)->z), damped_0);
    (&bd_2)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S1836.stored_3);
    (&bd_2)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_2)->force_ang_0.w), (_S1836.state_1.utilization_0))));
    bool _S1848;
    if(!_S1832)
    {
        JointState_0 _S1849 = _S1836.state_1;
        bool _S1850 = is_damaged_0(&_S1849);
        _S1848 = _S1850;
    }
    else
    {
        _S1848 = false;
    }
    if(_S1848)
    {
        _S1848 = ((&bd_2)->events_0.x) == 0U;
    }
    else
    {
        _S1848 = false;
    }
    if(_S1848)
    {
        *&((&(&bd_2)->events_0)->x) = abs_step_0;
        *&((&(&bd_2)->events_0)->w) = _S1836.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S1840.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_2)->events_0.y) == 0U)
    {
        _S1848 = (_S1836.state_1.life_0) != (previous_3.life_0);
    }
    else
    {
        _S1848 = false;
    }
    if(_S1848)
    {
        _S1848 = (_S1836.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S1848 = false;
    }
    if(_S1848)
    {
        float _S1851 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S1830.ids_0.x], _S1836.state_1.life_0);
        _S1848 = _S1851 <= 0.99000000953674316f;
    }
    else
    {
        _S1848 = false;
    }
    if(_S1848)
    {
        *&((&(&bd_2)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S1840.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S1836.disconnected_0)
    {
        *&((&(&bd_2)->events_0)->z) = abs_step_0;
    }
    (&bd_2)->js_0 = _S1836.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_27]) = bd_2;
    return _S1836.disconnected_0;
}

static __device__ void chunk_update_0(uint c_39, Island_0 * isl_20, Rigid_0 * rg_8, float dt_13, bool rml_0, uint step_0, bool contact_5, float * work_2, float * work_err_0)
{
    float3  _S1852 = make_float3 (0.0f);
    uint _S1853 = __ldg((&(globalParams_0->index_0)[c_39]));
    float peak_0 = 0.0f;
    uint e_7 = _S1853;
    float3  fi_5 = _S1852;
    float3  mi_4 = _S1852;
    for(;;)
    {
        uint _S1854 = __ldg((&(globalParams_0->index_0)[c_39 + 1U]));
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
    uint _S1861 = 4U * c_39;
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
    float4  _S1869 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->center_0);
    float mass_0 = _S1869.w;
    float4  _S1870 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->center_0);
    float4  _S1871 = isl_20->com_0;
    float3  _S1872 = float3 {_S1871.x, _S1871.y, _S1871.z};
    float3  _S1873 = rotate_0(&rg_8->rot_3, float3 {_S1870.x, _S1870.y, _S1870.z} + u_2 - _S1872);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_39, &rg_8->rot_3, step_0, dt_13, contact_5, dt_13, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_39, f_load_0, t_load_0);
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
        float4  _S1878 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia0_0);
        float4  _S1879 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia1_0);
        float4  _S1880 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia2_0);
        float3  _S1881 = world_mul_0(&rg_8->rot_3, _S1878, _S1879, _S1880, _S1876);
        float4  _S1882 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia0_0);
        float4  _S1883 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia1_0);
        float4  _S1884 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia2_0);
        float3  _S1885 = world_mul_0(&rg_8->rot_3, _S1882, _S1883, _S1884, _S1877);
        float3  t_world_2 = t_world_0 - (_S1881 + cross_0(_S1877, _S1885));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S1886 = inverse_rotate_0(&rg_8->rot_3, f_world_1);
    float3  _S1887 = inverse_rotate_0(&rg_8->rot_3, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S1888 = inverse_rotate_0(&rg_8->rot_3, rg_8->w_5);
        float3  f_ext_1 = _S1886 - cross_0(_S1888, v_11) * make_float3 (2.0f * mass_0);
        float4  _S1889 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia0_0);
        float4  _S1890 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia1_0);
        float4  _S1891 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S1889, _S1890, _S1891, w_6);
        float4  _S1892 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia0_0);
        float4  _S1893 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia1_0);
        float4  _S1894 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inertia2_0);
        float3  m_ext_1 = _S1887 - (cross_0(_S1888, i_w_0) + cross_0(w_6, rows_mul_0(_S1892, _S1893, _S1894, _S1888)) + cross_0(w_6, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S1886;
        m_ext_0 = _S1887;
    }
    float3  f_18 = f_ext_0 + rep_f_1 + fi_5;
    float3  m_7 = m_ext_0 + rep_m_1 + mi_4;
    uint4  _S1895 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->info_0);
    uint support_1 = _S1895.x;
    float3  _S1896 = make_float3 ((*(&(globalParams_0->state_0)[_S1863])).w, (*(&(globalParams_0->state_0)[_S1865])).w, (*(&(globalParams_0->state_0)[_S1867])).w);
    float3  reaction_1;
    float3  u_3;
    float3  th_5;
    float3  v_12;
    float3  w_7;
    if(support_1 == 1U)
    {
        reaction_1 = - f_18;
        u_3 = u_2;
        th_5 = th_4;
        v_12 = _S1852;
        w_7 = _S1852;
    }
    else
    {
        float4  _S1897 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inv0_0);
        float4  _S1898 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inv1_0);
        float4  _S1899 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->inv2_0);
        float3  _S1900 = rows_mul_0(_S1897, _S1898, _S1899, m_7);
        float4  _S1901 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->scale_0);
        float3  w_8 = w_6 + _S1900 * make_float3 (dt_13 * _S1901.z);
        float3  th_6 = th_4 + w_8 * make_float3 (dt_13);
        if(support_1 == 2U)
        {
            reaction_1 = - f_18;
            u_3 = u_2;
            th_5 = _S1852;
        }
        else
        {
            float4  _S1902 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->scale_0);
            float3  v_13 = v_11 + f_18 * make_float3 (dt_13 * _S1902.y);
            float3  u_4 = u_2 + v_13 * make_float3 (dt_13);
            reaction_1 = _S1896;
            u_3 = u_4;
            th_5 = v_13;
        }
        float3  _S1903 = th_5;
        th_5 = th_6;
        v_12 = _S1903;
        w_7 = w_8;
    }
    *(&(globalParams_0->state_0)[_S1861]) = make_float4 (u_3.x, u_3.y, u_3.z, peak_0);
    *(&(globalParams_0->state_0)[_S1863]) = make_float4 (th_5.x, th_5.y, th_5.z, reaction_1.x);
    *(&(globalParams_0->state_0)[_S1865]) = make_float4 (v_12.x, v_12.y, v_12.z, reaction_1.y);
    *(&(globalParams_0->state_0)[_S1867]) = make_float4 (w_7.x, w_7.y, w_7.z, reaction_1.z);
    float4  _S1904 = __ldg(&(&(globalParams_0->chunks_0)[c_39])->center_0);
    float3  _S1905 = rotate_0(&rg_8->rot_3, float3 {_S1904.x, _S1904.y, _S1904.z} + u_3 - _S1872);
    float3  _S1906 = rg_8->vel_0 + rg_8->vel_err_0 + cross_0(rg_8->w_5, _S1905);
    float3  _S1907 = rotate_0(&rg_8->rot_3, v_12);
    float3  v_world_0 = _S1906 + _S1907;
    float3  _S1908 = rotate_0(&rg_8->rot_3, w_7);
    comp_add1_0(work_2, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_8->w_5 + _S1908)) * dt_13);
    return;
}

static __device__ void drift_moments_0(uint c_40, float3  * tu_2, float3  * pv_2)
{
    float4  _S1909 = __ldg(&(&(globalParams_0->chunks_0)[c_40])->center_0);
    float _S1910 = _S1909.w;
    float4  _S1911 = __ldg(&(&(globalParams_0->chunks_0)[c_40])->scale_0);
    float m_8 = _S1910 * _S1911.x;
    uint _S1912 = 4U * c_40;
    float4  _S1913 = *(&(globalParams_0->state_0)[_S1912]);
    *tu_2 = *tu_2 + float3 {_S1913.x, _S1913.y, _S1913.z} * make_float3 (m_8);
    float4  _S1914 = *(&(globalParams_0->state_0)[_S1912 + 2U]);
    *pv_2 = *pv_2 + float3 {_S1914.x, _S1914.y, _S1914.z} * make_float3 (m_8);
    return;
}

__device__ __shared__ FixedArray<uint, 512>  g_label_narrow_0;

__device__ __shared__ uint g_changed_narrow_0;

static __device__ bool island_connected_narrow_0(uint tid_18, Island_0 * isl_21)
{
    uint _S1915 = isl_21->range_0.x;
    uint n_10 = isl_21->range_0.y - _S1915;
    bool converged_3;
    if(n_10 > 512U)
    {
        converged_3 = true;
    }
    else
    {
        uint _S1916 = __ldg(&globalParams_0->params_0->device_connect_0);
        converged_3 = _S1916 == 0U;
    }
    if(converged_3)
    {
        return false;
    }
    uint c_41 = tid_18;
    for(;;)
    {
        if(c_41 < n_10)
        {
        }
        else
        {
            break;
        }
        (*&g_label_narrow_0)[c_41] = c_41;
        c_41 = c_41 + 256U;
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
        c_41 = tid_18;
        for(;;)
        {
            if(c_41 < n_10)
            {
            }
            else
            {
                break;
            }
            uint _S1917 = (*&g_label_narrow_0)[c_41];
            uint gc_1 = _S1915 + c_41;
            uint _S1918 = __ldg((&(globalParams_0->index_0)[gc_1]));
            uint l_7 = _S1917;
            uint e_8 = _S1918;
            for(;;)
            {
                uint _S1919 = __ldg((&(globalParams_0->index_0)[gc_1 + 1U]));
                if(e_8 < _S1919)
                {
                }
                else
                {
                    break;
                }
                uint _S1920 = __ldg((&(globalParams_0->index_0)[e_8]));
                uint bond_2 = _S1920 >> int(1);
                JointBond_0 _S1921 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                bool _S1922 = (_S1921.stiff1_0.w) != 0.0f;
                JointState_0 _S1923 = (&(globalParams_0->bond_dyn_0)[bond_2])->js_0;
                bool _S1924 = connected_0(&_S1923, _S1922);
                if(!_S1924)
                {
                    e_8 = e_8 + 1U;
                    continue;
                }
                uint other_1;
                if((_S1920 & 1U) == 0U)
                {
                    JointBond_0 _S1925 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                    other_1 = _S1925.ids_0.z;
                }
                else
                {
                    JointBond_0 _S1926 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_2])->law_0);
                    other_1 = _S1926.ids_0.y;
                }
                l_7 = (U32_min((l_7), ((*&g_label_narrow_0)[other_1 - _S1915])));
                e_8 = e_8 + 1U;
            }
            uint _S1927 = (U32_min((l_7), ((*&g_label_narrow_0)[l_7])));
            if(_S1927 < (*&g_label_narrow_0)[c_41])
            {
                (*&g_label_narrow_0)[c_41] = _S1927;
                *&g_changed_narrow_0 = 1U;
            }
            c_41 = c_41 + 256U;
        }
        __syncthreads();
        bool converged_4 = (*&g_changed_narrow_0) == 0U;
        __syncthreads();
        if(converged_4)
        {
            converged_3 = converged_4;
            break;
        }
        uint _S1928 = pass_1 + 1U;
        converged_3 = converged_4;
        pass_1 = _S1928;
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
    c_41 = tid_18;
    for(;;)
    {
        if(c_41 < n_10)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_narrow_0)[c_41]) != 0U)
        {
            *&g_changed_narrow_0 = 1U;
        }
        c_41 = c_41 + 256U;
    }
    __syncthreads();
    return (*&g_changed_narrow_0) == 0U;
}

static __device__ void island_frame_at_0(uint gi_0, uint tid_19, uint _S1929)
{
    bool woke_0;
    uint _S1930;
    uint _S1931;
    uint _S1932;
    uint _S1933;
    uint _S1934;
    uint _S1935;
    Island_0 isl_22 = *(&(globalParams_0->islands_0)[gi_0]);
    bool driven_0 = (((&isl_22)->info_1.x) & 2U) != 0U;
    bool _S1936 = !((((&isl_22)->info_1.x) & 1U) != 0U);
    uint _S1937 = __ballot_sync(_S1929, _S1936);
    bool _S1938;
    uint cov_2;
    if(_S1936)
    {
        bool _S1939 = !driven_0;
        uint _S1940 = __ballot_sync(_S1929, true);
        _S1938 = _S1939;
        cov_2 = _S1940;
    }
    else
    {
        uint _S1941 = __ballot_sync(_S1929, true);
        _S1938 = false;
        cov_2 = _S1941;
    }
    bool contact_island_0 = (((&isl_22)->info_1.x) & 4U) != 0U;
    bool _S1942 = (((&isl_22)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_19);
    bool _S1943 = tid_19 == 0U;
    uint _S1944 = __ballot_sync(cov_2, _S1943);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S1943)
    {
        uint _S1945 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S1946 = contact_island_0 != (_S1945 == 1U);
        uint _S1947 = __ballot_sync(_S1944, _S1946);
        if(_S1946)
        {
            uint _S1948 = __ballot_sync(_S1944, true);
            settled_0 = true;
            run_0 = _S1948;
        }
        else
        {
            bool _S1949 = (((&isl_22)->info_1.x) & 8U) != 0U;
            uint _S1950 = __ballot_sync(_S1944, true);
            settled_0 = _S1949;
            run_0 = _S1950;
        }
        uint _S1951 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S1952 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S1952;
        }
        else
        {
            uint _S1953 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S1953;
        }
        uint _S1954 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S1955 = isl_22;
            bool _S1956 = contact_stopped_0(&_S1955);
            uint _S1957 = __ballot_sync(done_1, true);
            settled_0 = _S1956;
            done_1 = _S1957;
        }
        else
        {
            uint _S1958 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S1958;
        }
        uint _S1959 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S1960 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S1961 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S1962 = __ballot_sync(cov_2, true);
        cov_2 = _S1962;
    }
    else
    {
        uint _S1963 = __ballot_sync(cov_2, true);
        cov_2 = _S1963;
    }
    __syncthreads();
    bool _S1964 = (((&isl_22)->info_1.z) & 1U) != 0U;
    uint _S1965 = __ballot_sync(cov_2, _S1964);
    if(_S1964)
    {
        uint _S1966 = __ballot_sync(cov_2, true);
        settled_0 = true;
        cov_2 = _S1966;
    }
    else
    {
        bool _S1967 = (*&g_run_0) == 0U;
        uint _S1968 = __ballot_sync(cov_2, true);
        settled_0 = _S1967;
        cov_2 = _S1968;
    }
    uint _S1969 = __ballot_sync(cov_2, settled_0);
    if(settled_0)
    {
        uint _S1970 = __ballot_sync(cov_2, true);
        cov_2 = 0U;
        run_0 = _S1970;
    }
    else
    {
        uint _S1971 = (&isl_22)->info_1.y;
        uint _S1972 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S1973 = (U32_min((_S1971), (_S1972)));
        uint _S1974 = __ballot_sync(cov_2, true);
        cov_2 = _S1973;
        run_0 = _S1974;
    }
    float _S1975 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1976 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S1977 = _S1976 != 0U;
    uint _S1978 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S1979 = _S1978 != 0U;
    Island_0 _S1980 = isl_22;
    Rigid_0 _S1981 = rigid_of_0(&_S1980);
    Rigid_0 rg_9 = _S1981;
    float work_3 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S1942;
    done_1 = 0U;
    bool woke_1 = false;
    bool resumed_0 = false;
    uint _S1982 = run_0;
    for(;;)
    {
        uint _S1983 = 0U;
        bool _S1984 = done_1 < cov_2;
        uint _S1985 = __ballot_sync(_S1982, _S1984);
        if(_S1984)
        {
            uint _S1986 = __ballot_sync(_S1982, true);
            _S1983 = _S1986;
        }
        else
        {
            uint _S1987 = __ballot_sync(_S1982, false);
            uint _S1988 = __ballot_sync(_S1982, false);
            uint _S1989 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_2 = _S1989;
            break;
        }
        uint abs_step_1 = (&isl_22)->info_1.w + done_1 + 1U;
        uint _S1990 = abs_step_1 - 1U;
        uint _S1991 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_24 = _S1990 - _S1991;
        bool quiet_0 = (((&isl_22)->info_1.x) & 32U) != 0U;
        uint _S1992 = __ballot_sync(_S1983, settled_0);
        bool _S1993;
        uint _S1994;
        if(settled_0)
        {
            bool _S1995 = !quiet_0;
            uint _S1996 = __ballot_sync(_S1983, true);
            _S1993 = _S1995;
            _S1994 = _S1996;
        }
        else
        {
            uint _S1997 = __ballot_sync(_S1983, true);
            _S1993 = false;
            _S1994 = _S1997;
        }
        uint _S1998 = __ballot_sync(_S1994, _S1993);
        bool _S1999;
        bool explicit_step_0;
        uint c_42;
        uint _S2000;
        uint c_43;
        if(_S1993)
        {
            float3  _S2001 = make_float3 (0.0f);
            float3  norm_1 = _S2001;
            float3  unused0_0 = _S2001;
            c_42 = (&isl_22)->range_0.x + tid_19;
            _S2000 = _S1998;
            for(;;)
            {
                bool _S2002 = c_42 < ((&isl_22)->range_0.y);
                uint _S2003 = __ballot_sync(_S2000, _S2002);
                if(_S2002)
                {
                    uint _S2004 = __ballot_sync(_S2000, true);
                }
                else
                {
                    uint _S2005 = __ballot_sync(_S2000, false);
                    uint _S2006 = __ballot_sync(_S2000, false);
                    uint _S2007 = __ballot_sync(_S1998, true);
                    _S1930 = _S2007;
                    break;
                }
                Quat_0 _S2008 = (&rg_9)->rot_3;
                float _S2009 = settled_chunk_load_0(c_42, &_S2008, k_24, _S1975, contact_island_0);
                *&((&norm_1)->x) = *&((&norm_1)->x) + _S2009;
                uint _S2010 = __ballot_sync(_S2000, true);
                c_42 = c_42 + 256U;
                _S2000 = _S2010;
            }
            group_sum3_0(tid_19, &norm_1, &unused0_0, _S1930);
            uint _S2011 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S2012 = _S2011 == 1U;
            uint _S2013 = __ballot_sync(_S1930, _S2012);
            if(_S2012)
            {
                bool _S2014 = (F32_abs((norm_1.x - (&isl_22)->energy_1.z))) > ((&isl_22)->energy_1.w);
                uint _S2015 = __ballot_sync(_S1930, true);
                _S1999 = _S2014;
                c_43 = _S2015;
            }
            else
            {
                uint _S2016 = __ballot_sync(_S1930, true);
                _S1999 = false;
                c_43 = _S2016;
            }
            uint _S2017 = __ballot_sync(c_43, _S1999);
            if(_S1999)
            {
                uint _S2018 = __ballot_sync(c_43, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S2019 = __ballot_sync(c_43, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S2020 = __ballot_sync(_S1994, true);
            settled_0 = explicit_step_0;
            c_42 = _S2020;
        }
        else
        {
            uint _S2021 = __ballot_sync(_S1994, true);
            woke_0 = woke_1;
            c_42 = _S2021;
        }
        uint _S2022 = __ballot_sync(c_42, _S1936);
        if(_S1936)
        {
            bool _S2023 = !quiet_0;
            uint _S2024 = __ballot_sync(c_42, true);
            _S1999 = _S2023;
            _S2000 = _S2024;
        }
        else
        {
            uint _S2025 = __ballot_sync(c_42, true);
            _S1999 = false;
            _S2000 = _S2025;
        }
        uint _S2026 = __ballot_sync(_S2000, _S1999);
        uint _S2027;
        if(_S1999)
        {
            float3  _S2028 = make_float3 (0.0f);
            float3  f_19 = _S2028;
            float3  t_17 = _S2028;
            c_43 = (&isl_22)->range_0.x + tid_19;
            _S2027 = _S2026;
            for(;;)
            {
                bool _S2029 = c_43 < ((&isl_22)->range_0.y);
                uint _S2030 = __ballot_sync(_S2027, _S2029);
                if(_S2029)
                {
                    uint _S2031 = __ballot_sync(_S2027, true);
                }
                else
                {
                    uint _S2032 = __ballot_sync(_S2027, false);
                    uint _S2033 = __ballot_sync(_S2027, false);
                    uint _S2034 = __ballot_sync(_S2026, true);
                    _S1931 = _S2034;
                    break;
                }
                Island_0 _S2035 = isl_22;
                Rigid_0 _S2036 = rg_9;
                net_load_0(c_43, &_S2035, &_S2036, k_24, _S1975, contact_island_0, &f_19, &t_17);
                uint _S2037 = __ballot_sync(_S2027, true);
                c_43 = c_43 + 256U;
                _S2027 = _S2037;
            }
            group_sum3_0(tid_19, &f_19, &t_17, _S1931);
            Island_0 _S2038 = isl_22;
            rigid_acceleration_0(&_S2038, &rg_9, f_19, t_17);
            uint _S2039 = __ballot_sync(_S2000, true);
            c_43 = _S2039;
        }
        else
        {
            uint _S2040 = __ballot_sync(_S2000, true);
            c_43 = _S2040;
        }
        bool _S2041 = !settled_0;
        uint _S2042 = __ballot_sync(c_43, _S2041);
        if(_S2041)
        {
            bool _S2043 = !quiet_0;
            uint _S2044 = __ballot_sync(c_43, true);
            explicit_step_0 = _S2043;
            _S2027 = _S2044;
        }
        else
        {
            uint _S2045 = __ballot_sync(c_43, true);
            explicit_step_0 = false;
            _S2027 = _S2045;
        }
        uint _S2046 = __ballot_sync(_S2027, explicit_step_0);
        uint i_28;
        uint _S2047;
        uint c_44;
        uint _S2048;
        if(explicit_step_0)
        {
            i_28 = (&isl_22)->range_0.z + tid_19;
            _S2047 = _S2046;
            for(;;)
            {
                uint _S2049 = 0U;
                bool _S2050 = i_28 < ((&isl_22)->range_0.w);
                uint _S2051 = __ballot_sync(_S2047, _S2050);
                if(_S2050)
                {
                    uint _S2052 = __ballot_sync(_S2047, true);
                    _S2049 = _S2052;
                }
                else
                {
                    uint _S2053 = __ballot_sync(_S2047, false);
                    uint _S2054 = __ballot_sync(_S2047, false);
                    uint _S2055 = __ballot_sync(_S2046, true);
                    _S1932 = _S2055;
                    break;
                }
                bool _S2056 = bond_update_0(i_28, _S1975, _S1977, abs_step_1, false);
                uint _S2057 = __ballot_sync(_S2049, _S2056);
                if(_S2056)
                {
                    *&g_halt_0 = 1U;
                    uint _S2058 = __ballot_sync(_S2049, true);
                }
                else
                {
                    uint _S2059 = __ballot_sync(_S2049, true);
                }
                uint _S2060 = __ballot_sync(_S2047, true);
                i_28 = i_28 + 256U;
                _S2047 = _S2060;
            }
            __syncthreads();
            c_44 = (&isl_22)->range_0.x + tid_19;
            _S2048 = _S1932;
            for(;;)
            {
                bool _S2061 = c_44 < ((&isl_22)->range_0.y);
                uint _S2062 = __ballot_sync(_S2048, _S2061);
                if(_S2061)
                {
                    uint _S2063 = __ballot_sync(_S2048, true);
                }
                else
                {
                    uint _S2064 = __ballot_sync(_S2048, false);
                    uint _S2065 = __ballot_sync(_S2048, false);
                    uint _S2066 = __ballot_sync(_S1932, true);
                    break;
                }
                Island_0 _S2067 = isl_22;
                Rigid_0 _S2068 = rg_9;
                chunk_update_0(c_44, &_S2067, &_S2068, _S1975, _S1979, k_24, contact_island_0, &work_3, &work_err_1);
                uint _S2069 = __ballot_sync(_S2048, true);
                c_44 = c_44 + 256U;
                _S2048 = _S2069;
            }
            __syncthreads();
            uint _S2070 = __ballot_sync(_S2027, true);
            i_28 = _S2070;
        }
        else
        {
            uint _S2071 = __ballot_sync(_S2027, true);
            i_28 = _S2071;
        }
        uint _S2072 = __ballot_sync(i_28, _S1938);
        bool _S2073;
        if(_S1938)
        {
            bool _S2074 = !quiet_0;
            uint _S2075 = __ballot_sync(i_28, true);
            _S2073 = _S2074;
            _S2047 = _S2075;
        }
        else
        {
            uint _S2076 = __ballot_sync(i_28, true);
            _S2073 = false;
            _S2047 = _S2076;
        }
        uint _S2077 = __ballot_sync(_S2047, _S2073);
        if(_S2073)
        {
            Island_0 _S2078 = isl_22;
            integrate_rigid_0(&_S2078, &rg_9, _S1975);
            uint _S2079 = __ballot_sync(_S2047, true);
            c_44 = _S2079;
        }
        else
        {
            uint _S2080 = __ballot_sync(_S2047, true);
            c_44 = _S2080;
        }
        uint _S2081 = __ballot_sync(c_44, _S1936);
        bool _S2082;
        if(_S1936)
        {
            uint _S2083 = __ballot_sync(c_44, true);
            _S2082 = explicit_step_0;
            _S2048 = _S2083;
        }
        else
        {
            uint _S2084 = __ballot_sync(c_44, true);
            _S2082 = false;
            _S2048 = _S2084;
        }
        uint _S2085 = __ballot_sync(_S2048, _S2082);
        uint c_45;
        uint _S2086;
        uint c_46;
        uint _S2087;
        uint c_47;
        if(_S2082)
        {
            float4  _S2088 = (&isl_22)->wcom_0;
            float3  _S2089 = float3 {_S2088.x, _S2088.y, _S2088.z};
            float3  _S2090 = make_float3 (0.0f);
            float3  tu_3 = _S2090;
            float3  pv_3 = _S2090;
            c_45 = (&isl_22)->range_0.x + tid_19;
            _S2086 = _S2085;
            for(;;)
            {
                bool _S2091 = c_45 < ((&isl_22)->range_0.y);
                uint _S2092 = __ballot_sync(_S2086, _S2091);
                if(_S2091)
                {
                    uint _S2093 = __ballot_sync(_S2086, true);
                }
                else
                {
                    uint _S2094 = __ballot_sync(_S2086, false);
                    uint _S2095 = __ballot_sync(_S2086, false);
                    uint _S2096 = __ballot_sync(_S2085, true);
                    _S1933 = _S2096;
                    break;
                }
                drift_moments_0(c_45, &tu_3, &pv_3);
                uint _S2097 = __ballot_sync(_S2086, true);
                c_45 = c_45 + 256U;
                _S2086 = _S2097;
            }
            group_sum3_0(tid_19, &tu_3, &pv_3, _S1933);
            float3  tr_5 = tu_3 / make_float3 ((&isl_22)->wcom_0.w);
            float3  dv_5 = pv_3 / make_float3 ((&isl_22)->wcom_0.w);
            float3  lu_3 = _S2090;
            float3  lv_3 = _S2090;
            c_46 = (&isl_22)->range_0.x + tid_19;
            _S2087 = _S1933;
            for(;;)
            {
                bool _S2098 = c_46 < ((&isl_22)->range_0.y);
                uint _S2099 = __ballot_sync(_S2087, _S2098);
                if(_S2098)
                {
                    uint _S2100 = __ballot_sync(_S2087, true);
                }
                else
                {
                    uint _S2101 = __ballot_sync(_S2087, false);
                    uint _S2102 = __ballot_sync(_S2087, false);
                    uint _S2103 = __ballot_sync(_S1933, true);
                    _S1934 = _S2103;
                    break;
                }
                drift_angular_0(c_46, _S2089, tr_5, dv_5, &lu_3, &lv_3);
                uint _S2104 = __ballot_sync(_S2087, true);
                c_46 = c_46 + 256U;
                _S2087 = _S2104;
            }
            group_sum3_0(tid_19, &lu_3, &lv_3, _S1934);
            float3  phi_4 = rows_mul_0((&isl_22)->winv0_0, (&isl_22)->winv1_0, (&isl_22)->winv2_0, lu_3);
            float3  dw_3 = rows_mul_0((&isl_22)->winv0_0, (&isl_22)->winv1_0, (&isl_22)->winv2_0, lv_3);
            c_47 = (&isl_22)->range_0.x + tid_19;
            uint _S2105 = _S1934;
            for(;;)
            {
                bool _S2106 = c_47 < ((&isl_22)->range_0.y);
                uint _S2107 = __ballot_sync(_S2105, _S2106);
                if(_S2106)
                {
                    uint _S2108 = __ballot_sync(_S2105, true);
                }
                else
                {
                    uint _S2109 = __ballot_sync(_S2105, false);
                    uint _S2110 = __ballot_sync(_S2105, false);
                    uint _S2111 = __ballot_sync(_S1934, true);
                    _S1935 = _S2111;
                    break;
                }
                drift_apply_0(c_47, _S2089, tr_5, phi_4, dv_5, dw_3);
                uint _S2112 = __ballot_sync(_S2105, true);
                c_47 = c_47 + 256U;
                _S2105 = _S2112;
            }
            bool _S2113 = !driven_0;
            uint _S2114 = __ballot_sync(_S1935, _S2113);
            if(_S2113)
            {
                Island_0 _S2115 = isl_22;
                drift_rigid_0(&_S2115, &rg_9, tr_5, phi_4, dv_5, dw_3);
                uint _S2116 = __ballot_sync(_S1935, true);
            }
            else
            {
                uint _S2117 = __ballot_sync(_S1935, true);
            }
            __syncthreads();
            uint _S2118 = __ballot_sync(_S2048, true);
            c_45 = _S2118;
        }
        else
        {
            uint _S2119 = __ballot_sync(_S2048, true);
            c_45 = _S2119;
        }
        uint _S2120 = __ballot_sync(c_45, _S1943);
        bool _S2121;
        if(_S1943)
        {
            bool _S2122 = ((&isl_22)->probes_0.y) > ((&isl_22)->probes_0.x);
            uint _S2123 = __ballot_sync(c_45, true);
            _S2121 = _S2122;
            _S2086 = _S2123;
        }
        else
        {
            uint _S2124 = __ballot_sync(c_45, true);
            _S2121 = false;
            _S2086 = _S2124;
        }
        uint _S2125 = __ballot_sync(_S2086, _S2121);
        if(_S2121)
        {
            Island_0 _S2126 = isl_22;
            Rigid_0 _S2127 = rg_9;
            record_probes_0(&_S2126, &_S2127, k_24);
            uint _S2128 = __ballot_sync(_S2086, true);
            c_46 = _S2128;
        }
        else
        {
            uint _S2129 = __ballot_sync(_S2086, true);
            c_46 = _S2129;
        }
        uint _S2130 = done_1 + 1U;
        bool _S2131 = (*&g_halt_0) != 0U;
        uint _S2132 = __ballot_sync(c_46, _S2131);
        bool _S2133;
        if(_S2131)
        {
            Island_0 _S2134 = isl_22;
            bool _S2135 = island_connected_narrow_0(tid_19, &_S2134);
            uint _S2136 = __ballot_sync(c_46, true);
            _S2133 = _S2135;
            _S2087 = _S2136;
        }
        else
        {
            uint _S2137 = __ballot_sync(c_46, true);
            _S2133 = false;
            _S2087 = _S2137;
        }
        uint _S2138 = __ballot_sync(_S2087, _S2133);
        bool resumed_1;
        if(_S2133)
        {
            uint _S2139 = __ballot_sync(_S2138, _S1943);
            if(_S1943)
            {
                *&g_halt_0 = 0U;
                uint _S2140 = __ballot_sync(_S2138, true);
            }
            else
            {
                uint _S2141 = __ballot_sync(_S2138, true);
            }
            __syncthreads();
            uint _S2142 = __ballot_sync(_S2087, true);
            resumed_1 = true;
            c_47 = _S2142;
        }
        else
        {
            uint _S2143 = __ballot_sync(_S2087, true);
            resumed_1 = resumed_0;
            c_47 = _S2143;
        }
        bool _S2144 = (*&g_halt_0) != 0U;
        uint _S2145 = __ballot_sync(c_47, _S2144);
        if(_S2144)
        {
            uint _S2146 = __ballot_sync(c_47, false);
            uint _S2147 = __ballot_sync(_S1982, false);
            uint _S2148 = __ballot_sync(run_0, true);
            done_1 = _S2130;
            resumed_0 = resumed_1;
            cov_2 = _S2148;
            break;
        }
        else
        {
            uint _S2149 = __ballot_sync(c_47, true);
        }
        uint _S2150 = __ballot_sync(_S1982, true);
        done_1 = _S2130;
        woke_1 = woke_0;
        resumed_0 = resumed_1;
        _S1982 = _S2150;
    }
    float3  wsum_0 = make_float3 (work_3, work_err_1, 0.0f);
    float3  unused_3 = make_float3 (0.0f);
    group_sum3_0(tid_19, &wsum_0, &unused_3, cov_2);
    uint _S2151 = __ballot_sync(cov_2, _S1943);
    if(_S1943)
    {
        Quat_0 _S2152 = (&rg_9)->rot_3;
        float4  _S2153 = quat_vec_0(&_S2152);
        (&isl_22)->rotation_0 = _S2153;
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
            _S1938 = contact_island_0;
        }
        else
        {
            _S1938 = false;
        }
        if(_S1938)
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
        uint _S2154 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_2 = 128U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S2155 = _S2154 | cov_2;
        if(woke_0)
        {
            cov_2 = 2048U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint _S2156 = _S2155 | cov_2;
        if(resumed_0)
        {
            cov_2 = 2097280U;
        }
        else
        {
            cov_2 = 0U;
        }
        uint cov_3 = _S2156 | cov_2;
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
                _S1938 = !quiet_1;
            }
            else
            {
                _S1938 = false;
            }
            if(_S1938)
            {
                cov_2 = 512U;
            }
            else
            {
                cov_2 = 0U;
            }
            uint cov_5 = cov_4 | cov_2;
            uint _S2157 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S2157 == 1U)
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
    uint _S2158 = __ballot_sync(4294967295U, true);
    island_frame_at_0(blockIdx.x, threadIdx.x, _S2158);
    return;
}

static __device__ void wide_chunks_at_0(uint gx_0, uint tid_20, uint _S2159)
{
    uint _S2160 = 0U;
    uint _S2161 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    WideGroup_0 wg_5 = wide_group_0(_S2161, gx_0);
    Island_0 isl_23 = *(&(globalParams_0->islands_0)[wg_5.island_2]);
    bool _S2162 = wide_enter_1(tid_20, wg_5.island_2);
    bool _S2163 = !_S2162;
    uint _S2164 = __ballot_sync(_S2159, _S2163);
    if(_S2163)
    {
        return;
    }
    else
    {
        uint _S2165 = __ballot_sync(_S2159, true);
        _S2160 = _S2165;
    }
    uint _S2166 = 0U;
    uint _S2167 = isl_23.info_1.x;
    bool anchored_0 = (_S2167 & 1U) != 0U;
    bool _S2168 = (_S2167 & 16U) != 0U;
    uint _S2169 = __ballot_sync(_S2160, _S2168);
    if(_S2168)
    {
        if(tid_20 == 0U)
        {
            uint _S2170 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S2170 + 8U * gx_0 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S2171 = __ballot_sync(_S2160, true);
        _S2166 = _S2171;
    }
    Island_0 _S2172 = isl_23;
    WideGroup_0 _S2173 = wg_5;
    Rigid_0 _S2174 = wide_rigid_frame_0(tid_20, &_S2172, &_S2173, _S2166);
    float work_4 = 0.0f;
    float work_err_2 = 0.0f;
    float3  _S2175 = make_float3 (0.0f);
    float3  tu_4 = _S2175;
    float3  pv_4 = _S2175;
    uint c_48 = wg_5.begin_0 + tid_20;
    bool _S2176 = c_48 < (wg_5.end_0);
    uint _S2177 = __ballot_sync(_S2166, _S2176);
    uint _S2178;
    if(_S2176)
    {
        float _S2179 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2180 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S2181 = _S2180 != 0U;
        Island_0 _S2182 = isl_23;
        uint _S2183 = wide_step_0(&_S2182);
        bool _S2184 = (_S2167 & 4U) != 0U;
        Island_0 _S2185 = isl_23;
        Rigid_0 _S2186 = _S2174;
        chunk_update_0(c_48, &_S2185, &_S2186, _S2179, _S2181, _S2183, _S2184, &work_4, &work_err_2);
        bool _S2187 = !anchored_0;
        uint _S2188 = __ballot_sync(_S2177, _S2187);
        if(_S2187)
        {
            drift_moments_0(c_48, &tu_4, &pv_4);
            uint _S2189 = __ballot_sync(_S2177, true);
        }
        else
        {
            uint _S2190 = __ballot_sync(_S2177, true);
        }
        uint _S2191 = __ballot_sync(_S2166, true);
        _S2178 = _S2191;
    }
    else
    {
        uint _S2192 = __ballot_sync(_S2166, true);
        _S2178 = _S2192;
    }
    float3  wsum_1 = make_float3 (work_4, work_err_2, 0.0f);
    float3  unused_4 = _S2175;
    group_sum3_0(tid_20, &wsum_1, &unused_4, _S2178);
    bool _S2193 = !anchored_0;
    uint _S2194 = __ballot_sync(_S2178, _S2193);
    if(_S2193)
    {
        group_sum3_0(tid_20, &tu_4, &pv_4, _S2194);
        uint _S2195 = __ballot_sync(_S2178, true);
    }
    if(tid_20 == 0U)
    {
        uint _S2196 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S2197 = 8U * gx_0;
        *(&(globalParams_0->scratch_0)[_S2196 + _S2197 + 6U]) = make_float4 (wsum_1.x, wsum_1.y, wsum_1.z, 0.0f);
        if(_S2193)
        {
            wide_store_0(gx_0, 2U, tu_4, pv_4);
        }
        uint _S2198 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S2198 + _S2197 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_chunks()
{
    uint _S2199 = __ballot_sync(4294967295U, true);
    wide_chunks_at_0(blockIdx.x, threadIdx.x, _S2199);
    return;
}

extern "C" __global__ void sums_and_impactors()
{
    uint _S2200 = __ballot_sync(4294967295U, true);
    uint _S2201 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_0 = (_S2201 + 255U) / 256U;
    uint _S2202 = blockIdx.x;
    bool _S2203 = _S2202 < sums_groups_0;
    uint _S2204 = __ballot_sync(_S2200, _S2203);
    if(_S2203)
    {
        contact_sum_at_0(_S2202 * 256U + threadIdx.x);
    }
    else
    {
        impactor_integrate_at_0(_S2202 - sums_groups_0, threadIdx.x, _S2200 & (~_S2204));
        uint _S2205 = __ballot_sync(_S2200, true);
    }
    return;
}

extern "C" __global__ void islands_and_wide_chunks()
{
    uint _S2206 = __ballot_sync(4294967295U, true);
    uint _S2207 = blockIdx.x;
    uint _S2208 = __ldg(&globalParams_0->params_0->halt_index_0);
    bool _S2209 = _S2207 < _S2208;
    uint _S2210 = __ballot_sync(_S2206, _S2209);
    if(_S2209)
    {
        island_frame_at_0(_S2207, threadIdx.x, _S2210);
        uint _S2211 = __ballot_sync(_S2206, true);
    }
    else
    {
        uint _S2212 = _S2206 & (~_S2210);
        uint _S2213 = __ldg(&globalParams_0->params_0->halt_index_0);
        wide_chunks_at_0(_S2207 - _S2213, threadIdx.x, _S2212);
        uint _S2214 = __ballot_sync(_S2206, true);
    }
    return;
}

static __device__ void wide_bonds_at_0(uint gx_1, uint tid_21, uint _S2215)
{
    uint _S2216 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = gx_1 < _S2216;
    uint _S2217 = __ballot_sync(_S2215, bond_group_0);
    WideGroup_0 wg_6;
    uint _S2218;
    if(bond_group_0)
    {
        uint _S2219 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S2220 = wide_group_0(_S2219, gx_1);
        uint _S2221 = __ballot_sync(_S2215, true);
        wg_6 = _S2220;
        _S2218 = _S2221;
    }
    else
    {
        uint _S2222 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S2223 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S2224 = wide_group_0(_S2222, gx_1 - _S2223);
        uint _S2225 = __ballot_sync(_S2215, true);
        wg_6 = _S2224;
        _S2218 = _S2225;
    }
    uint _S2226 = 0U;
    WideGroup_0 _S2227 = wg_6;
    Island_0 isl_24 = *(&(globalParams_0->islands_0)[wg_6.island_2]);
    bool _S2228 = wide_enter_1(tid_21, wg_6.island_2);
    bool _S2229 = !_S2228;
    uint _S2230 = __ballot_sync(_S2218, _S2229);
    if(_S2229)
    {
        return;
    }
    else
    {
        uint _S2231 = __ballot_sync(_S2218, true);
        _S2226 = _S2231;
    }
    uint _S2232 = 0U;
    Island_0 _S2233 = isl_24;
    uint _S2234 = wide_step_0(&_S2233);
    uint _S2235 = __ballot_sync(_S2226, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_24.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_29 = wg_6.begin_0 + tid_21;
        bool _S2236;
        if(i_29 < (wg_6.end_0))
        {
            float _S2237 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S2238 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S2239 = bond_update_0(i_29, _S2237, _S2238 != 0U, isl_24.info_1.w + 1U, true);
            _S2236 = _S2239;
        }
        else
        {
            _S2236 = false;
        }
        if(_S2236)
        {
            *&((&(&(globalParams_0->islands_0)[_S2227.island_2])->info_1)->z) = (isl_24.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S2240 = __ballot_sync(_S2226, true);
        _S2232 = _S2240;
    }
    uint _S2241 = 0U;
    uint _S2242 = isl_24.info_1.x;
    bool _S2243 = (_S2242 & 1U) != 0U;
    uint _S2244 = __ballot_sync(_S2232, _S2243);
    if(_S2243)
    {
        return;
    }
    else
    {
        uint _S2245 = __ballot_sync(_S2232, true);
        _S2241 = _S2245;
    }
    float3  _S2246 = make_float3 (0.0f);
    float3  f_20 = _S2246;
    float3  t_18 = _S2246;
    uint c_49 = wg_6.begin_0 + tid_21;
    bool _S2247 = c_49 < (wg_6.end_0);
    uint _S2248 = __ballot_sync(_S2241, _S2247);
    if(_S2247)
    {
        Island_0 _S2249 = isl_24;
        Rigid_0 _S2250 = rigid_of_0(&_S2249);
        float _S2251 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S2252 = (_S2242 & 4U) != 0U;
        Island_0 _S2253 = isl_24;
        Rigid_0 _S2254 = _S2250;
        net_load_0(c_49, &_S2253, &_S2254, _S2234, _S2251, _S2252, &f_20, &t_18);
        uint _S2255 = __ballot_sync(_S2241, true);
        _S2218 = _S2255;
    }
    else
    {
        uint _S2256 = __ballot_sync(_S2241, true);
        _S2218 = _S2256;
    }
    group_sum3_0(tid_21, &f_20, &t_18, _S2218);
    bool _S2257 = tid_21 == 0U;
    uint _S2258 = __ballot_sync(_S2218, _S2257);
    if(_S2257)
    {
        uint _S2259 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(gx_1 - _S2259, 0U, f_20, t_18);
    }
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S2260 = __ballot_sync(4294967295U, true);
    wide_bonds_at_0(blockIdx.x, threadIdx.x, _S2260);
    return;
}

extern "C" __global__ void sums_impactors_bonds()
{
    uint _S2261 = __ballot_sync(4294967295U, true);
    uint _S2262 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_1 = (_S2262 + 255U) / 256U;
    uint _S2263 = __ldg(&globalParams_0->params_0->impactor_count_0);
    uint _S2264 = (U32_max((_S2263), (1U)));
    uint _S2265 = blockIdx.x;
    bool _S2266 = _S2265 < sums_groups_1;
    uint _S2267 = __ballot_sync(_S2261, _S2266);
    if(_S2266)
    {
        contact_sum_at_0(_S2265 * 256U + threadIdx.x);
    }
    else
    {
        uint _S2268 = _S2261 & (~_S2267);
        bool _S2269 = _S2265 < (sums_groups_1 + _S2264);
        uint _S2270 = __ballot_sync(_S2268, _S2269);
        if(_S2269)
        {
            impactor_integrate_at_0(_S2265 - sums_groups_1, threadIdx.x, _S2270);
            uint _S2271 = __ballot_sync(_S2268, true);
        }
        else
        {
            wide_bonds_at_0(_S2265 - sums_groups_1 - _S2264, threadIdx.x, _S2268 & (~_S2270));
            uint _S2272 = __ballot_sync(_S2268, true);
        }
    }
    return;
}

