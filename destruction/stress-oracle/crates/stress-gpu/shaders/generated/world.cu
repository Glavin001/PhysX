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
    uint iplan_base_0;
    uint contact_bond_groups_0;
    uint contact_bond_table_0;
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

__device__ __shared__ FixedArray<uint, 5>  g_seen_0;

static __device__ void seen_clear_0(uint tid_0)
{
    if(tid_0 < 5U)
    {
        (*&g_seen_0)[tid_0] = 0U;
    }
    return;
}

static __device__ bool contact_stopped_0(Island_0 * isl_0)
{
    uint _S1 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S2 = (&(globalParams_0->islands_0)[_S1])->info_1;
    bool _S3;
    if((((&(globalParams_0->islands_0)[_S1])->info_1.z) & 1U) != 0U)
    {
        _S3 = true;
    }
    else
    {
        uint _S4 = _S2.y;
        if(_S4 != 0U)
        {
            _S3 = _S4 <= (isl_0->info_1.w);
        }
        else
        {
            _S3 = false;
        }
    }
    return _S3;
}

__device__ __shared__ uint g_run_0;

__device__ __shared__ uint g_halt_0;

struct Quat_0
{
    float w_0;
    float x_1;
    float y_1;
    float z_0;
};

struct Rigid_0
{
    Quat_0 rot_0;
    float4  rot_err_0;
    float3  pos_0;
    float3  pos_err_0;
    float3  vel_0;
    float3  vel_err_0;
    float3  w_1;
    float3  l_0;
    float3  l_err_0;
    float3  torque_0;
    float3  a_0;
    float3  alpha_0;
};

static __device__ Quat_0 quat_of_0(float4  q_0)
{
    Quat_0 r_0;
    (&r_0)->x_1 = q_0.x;
    (&r_0)->y_1 = q_0.y;
    (&r_0)->z_0 = q_0.z;
    (&r_0)->w_0 = q_0.w;
    return r_0;
}

static __device__ Rigid_0 rigid_of_0(Island_0 * isl_1)
{
    Rigid_0 rg_0;
    (&rg_0)->rot_0 = quat_of_0(isl_1->rotation_0);
    (&rg_0)->rot_err_0 = isl_1->rotation_err_0;
    float4  _S5 = isl_1->position_0;
    (&rg_0)->pos_0 = float3 {_S5.x, _S5.y, _S5.z};
    float4  _S6 = isl_1->position_err_0;
    (&rg_0)->pos_err_0 = float3 {_S6.x, _S6.y, _S6.z};
    float4  _S7 = isl_1->velocity_0;
    (&rg_0)->vel_0 = float3 {_S7.x, _S7.y, _S7.z};
    float4  _S8 = isl_1->velocity_err_0;
    (&rg_0)->vel_err_0 = float3 {_S8.x, _S8.y, _S8.z};
    float4  _S9 = isl_1->angular_velocity_0;
    (&rg_0)->w_1 = float3 {_S9.x, _S9.y, _S9.z};
    float4  _S10 = isl_1->momentum_0;
    (&rg_0)->l_0 = float3 {_S10.x, _S10.y, _S10.z};
    float4  _S11 = isl_1->momentum_err_0;
    (&rg_0)->l_err_0 = float3 {_S11.x, _S11.y, _S11.z};
    float3  _S12 = make_float3 (0.0f);
    (&rg_0)->torque_0 = _S12;
    (&rg_0)->a_0 = _S12;
    (&rg_0)->alpha_0 = _S12;
    return rg_0;
}

static __device__ uint4  asuint_0(float4  x_2)
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
        *_slang_vector_get_element_ptr(&result_1, i_1) = (F32_asuint((_slang_vector_get_element(x_2, i_1))));
        i_1 = i_1 + int(1);
    }
    return result_1;
}

static __device__ float time_since_0(float4  origin_0, uint k_0, float dt_1)
{
    float _S13 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S14 = _S13 - origin_0.x;
    float _S15 = __ldg(&globalParams_0->params_0->t_lo_0);
    return _S14 + (_S15 - origin_0.y) + float(k_0) * dt_1;
}

static __device__ float table_eval_0(uint offset_0, uint count_0, float tau_0)
{
    float4  _S16 = __ldg((&(globalParams_0->loads_0)[offset_0]));
    if(tau_0 <= (_S16.x))
    {
        return _S16.y;
    }
    uint i_2 = 1U;
    for(;;)
    {
        if(i_2 < count_0)
        {
        }
        else
        {
            break;
        }
        uint _S17 = offset_0 + i_2;
        float4  _S18 = __ldg((&(globalParams_0->loads_0)[_S17]));
        float _S19 = _S18.x;
        if(tau_0 <= _S19)
        {
            float4  _S20 = __ldg((&(globalParams_0->loads_0)[_S17 - 1U]));
            float _S21 = _S20.x;
            float _S22 = _S20.y;
            return _S22 + (tau_0 - _S21) / (F32_max((_S19 - _S21), (1.00000000317107685e-30f))) * (_S18.y - _S22);
        }
        i_2 = i_2 + 1U;
    }
    float4  _S23 = __ldg((&(globalParams_0->loads_0)[offset_0 + count_0 - 1U]));
    return _S23.y;
}

static __device__ float clamp_0(float x_3, float minBound_0, float maxBound_0)
{
    return (F32_min(((F32_max((x_3), (minBound_0)))), (maxBound_0)));
}

static __device__ float eval_function_0(uint term_0, uint k_1, float dt_2, float shift_0)
{
    uint _S24 = 5U * term_0;
    float4  _S25 = __ldg((&(globalParams_0->loads_0)[_S24]));
    uint4  info_2 = asuint_0(_S25);
    float4  _S26 = __ldg((&(globalParams_0->loads_0)[_S24 + 3U]));
    float4  _S27 = __ldg((&(globalParams_0->loads_0)[_S24 + 4U]));
    uint kind_0 = info_2.z;
    if(kind_0 == 0U)
    {
        return _S26.z;
    }
    float tau_1 = time_since_0(_S26, k_1, dt_2) + shift_0;
    float shape_1;
    if(kind_0 == 1U)
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            float _S28 = _S27.x;
            if(tau_1 >= _S28)
            {
                shape_1 = _S27.y;
            }
            else
            {
                shape_1 = _S27.y * tau_1 / _S28;
            }
        }
        return shape_1;
    }
    bool _S29;
    if(kind_0 == 2U)
    {
        if(tau_1 < 0.0f)
        {
            _S29 = true;
        }
        else
        {
            _S29 = tau_1 > (_S27.x);
        }
        if(_S29)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S27.y * (F32_sin((3.14159274101257324f * tau_1 / _S27.x)));
        }
        return shape_1;
    }
    if(kind_0 == 3U)
    {
        float sn_0 = tau_1 / _S27.y;
        if(sn_0 < 0.0f)
        {
            _S29 = true;
        }
        else
        {
            _S29 = sn_0 > 1.0f;
        }
        if(_S29)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S27.x * (1.0f - sn_0) * (F32_exp((- _S27.z * sn_0)));
        }
        return shape_1;
    }
    if(kind_0 == 4U)
    {
        return table_eval_0(info_2.w, (F32_asuint((_S27.x))), tau_1);
    }
    if(kind_0 == 5U)
    {
        (*&g_seen_0)[1U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float sn_1 = tau_1 / _S27.x;
        if(sn_1 < 0.0f)
        {
            _S29 = true;
        }
        else
        {
            _S29 = sn_1 > 1.0f;
        }
        if(_S29)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * (F32_exp((- _S27.y * sn_1)));
        }
        float clearing_0 = _S26.w;
        float relax_0;
        if(clearing_0 > 0.0f)
        {
            relax_0 = (F32_max((1.0f - tau_1 / clearing_0), (0.0f)));
        }
        else
        {
            relax_0 = 0.0f;
        }
        float _S30 = _S27.w;
        return (_S30 + (_S27.z - _S30) * relax_0) * shape_1;
    }
    if(kind_0 == 7U)
    {
        (*&g_seen_0)[2U] = 1U;
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        float _S31 = _S27.y;
        if(tau_1 < _S31)
        {
            return _S27.x;
        }
        float s_0 = tau_1 - _S31;
        float _S32 = _S27.w;
        if(s_0 > _S32)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = _S27.z * (F32_sin((3.14159274101257324f * s_0 / _S32)));
        }
        return shape_1;
    }
    float _S33 = _S27.x;
    if(_S33 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp_0(1.0f - tau_1 / _S33, 0.0f, 1.0f);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S34 = left_0.y;
    float _S35 = right_0.z;
    float _S36 = left_0.z;
    float _S37 = right_0.y;
    float _S38 = right_0.x;
    float _S39 = left_0.x;
    return make_float3 (_S34 * _S35 - _S36 * _S37, _S36 * _S38 - _S39 * _S35, _S39 * _S37 - _S34 * _S38);
}

static __device__ float3  rotate_0(Quat_0 * q_1, float3  v_0)
{
    float3  qv_0 = make_float3 (q_1->x_1, q_1->y_1, q_1->z_0);
    float3  t_0 = cross_0(qv_0, v_0) * make_float3 (2.0f);
    return v_0 + t_0 * make_float3 (q_1->w_0) + cross_0(qv_0, t_0);
}

static __device__ void chunk_loads_0(uint _S40, uint _S41, Quat_0 * _S42, uint _S43, float _S44, bool _S45, float _S46, float3  * _S47, float3  * _S48, float3  * _S49, float3  * _S50)
{
    bool _S51;
    ChunkStatic_0 * _S52 = (&(globalParams_0->chunks_0)[_S41]);
    float3  _S53 = make_float3 (0.0f);
    *_S47 = _S53;
    *_S48 = _S53;
    *_S49 = _S53;
    *_S50 = _S53;
    uint4  _S54 = __ldg(&_S52->load_range_0);
    uint term_1 = _S54.x;
    for(;;)
    {
        if(term_1 < (_S54.y))
        {
        }
        else
        {
            break;
        }
        (*&g_seen_0)[0U] = 1U;
        uint _S55 = 5U * term_1;
        float4  _S56 = __ldg((&(globalParams_0->loads_0)[_S55]));
        uint _S57 = asuint_0(_S56).y;
        bool replacement_0 = _S57 == 2U;
        float4  _S58 = __ldg((&(globalParams_0->loads_0)[_S55 + 1U]));
        float4  _S59 = __ldg((&(globalParams_0->loads_0)[_S55 + 2U]));
        float _S60;
        if(replacement_0)
        {
            _S60 = _S46;
        }
        else
        {
            _S60 = 0.0f;
        }
        float value_0 = eval_function_0(term_1, _S43, _S44, _S60);
        if(replacement_0)
        {
            *_S49 = *_S49 + float3 {_S58.x, _S58.y, _S58.z} * make_float3 (value_0);
            *_S50 = *_S50 + float3 {_S59.x, _S59.y, _S59.z} * make_float3 (value_0);
            term_1 = term_1 + 1U;
            continue;
        }
        if(_S57 == 0U)
        {
            _S51 = true;
        }
        else
        {
            _S51 = _S57 == 3U;
        }
        float3  fw_0;
        if(_S51)
        {
            fw_0 = float3 {_S58.x, _S58.y, _S58.z} * make_float3 (value_0);
        }
        else
        {
            float3  _S61 = rotate_0(_S42, float3 {_S58.x, _S58.y, _S58.z});
            fw_0 = _S61 * make_float3 (- value_0 * _S58.w);
        }
        float3  lever_0;
        if(_S57 == 3U)
        {
            float4  _S62 = *(&(globalParams_0->state_0)[4U * _S40]);
            lever_0 = float3 {_S59.x, _S59.y, _S59.z} - float3 {_S62.x, _S62.y, _S62.z};
        }
        else
        {
            lever_0 = float3 {_S59.x, _S59.y, _S59.z};
        }
        *_S47 = *_S47 + fw_0;
        float3  _S63 = rotate_0(_S42, lever_0);
        *_S48 = *_S48 + cross_0(_S63, fw_0);
        term_1 = term_1 + 1U;
    }
    if(_S45)
    {
        uint4  _S64 = __ldg(&_S52->cinfo_0);
        _S51 = (_S64.z) != 0U;
    }
    else
    {
        _S51 = false;
    }
    if(_S51)
    {
        uint4  _S65 = __ldg(&_S52->cinfo_0);
        uint g_0 = _S65.x;
        for(;;)
        {
            if(g_0 < (_S65.y))
            {
            }
            else
            {
                break;
            }
            uint _S66 = __ldg(&globalParams_0->params_0->seg_base_0);
            uint _S67 = 2U * g_0;
            float4  _S68 = *(&(globalParams_0->scratch_0)[_S66 + _S67]);
            *_S47 = *_S47 + float3 {_S68.x, _S68.y, _S68.z};
            uint _S69 = __ldg(&globalParams_0->params_0->seg_base_0);
            float4  _S70 = *(&(globalParams_0->scratch_0)[_S69 + _S67 + 1U]);
            *_S48 = *_S48 + float3 {_S70.x, _S70.y, _S70.z};
            g_0 = g_0 + 1U;
        }
    }
    return;
}

static __device__ void chunk_external_0(uint _S71, uint _S72, Quat_0 * _S73, uint _S74, float _S75, bool _S76, float3  * _S77, float3  * _S78)
{
    float3  rf_0;
    float3  rm_0;
    chunk_loads_0(_S71, _S72, _S73, _S74, _S75, _S76, 0.0f, _S77, _S78, &rf_0, &rm_0);
    return;
}

static __device__ void record_chunk_load_0(uint c_0, float3  f_0, float3  t_1)
{
    uint _S79 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S79 == 0U)
    {
        return;
    }
    uint _S80 = __ldg(&globalParams_0->params_0->cload_base_0);
    uint _S81 = 2U * c_0;
    *(&(globalParams_0->scratch_0)[_S80 + _S81]) = make_float4 (f_0.x, f_0.y, f_0.z, 0.0f);
    uint _S82 = __ldg(&globalParams_0->params_0->cload_base_0);
    *(&(globalParams_0->scratch_0)[_S82 + _S81 + 1U]) = make_float4 (t_1.x, t_1.y, t_1.z, 0.0f);
    uint _S83 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S84 = (&(globalParams_0->scratch_0)[_S83 + _S81]);
    uint _S85 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S86 = *(&(globalParams_0->scratch_0)[_S85 + _S81]);
    *_S84 = make_float4 ((float3 {_S86.x, _S86.y, _S86.z} + f_0).x, (float3 {_S86.x, _S86.y, _S86.z} + f_0).y, (float3 {_S86.x, _S86.y, _S86.z} + f_0).z, 0.0f);
    uint _S87 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  * _S88 = (&(globalParams_0->scratch_0)[_S87 + _S81 + 1U]);
    uint _S89 = __ldg(&globalParams_0->params_0->cframe_base_0);
    float4  _S90 = *(&(globalParams_0->scratch_0)[_S89 + _S81 + 1U]);
    *_S88 = make_float4 ((float3 {_S90.x, _S90.y, _S90.z} + t_1).x, (float3 {_S90.x, _S90.y, _S90.z} + t_1).y, (float3 {_S90.x, _S90.y, _S90.z} + t_1).z, 0.0f);
    return;
}

static __device__ float dot_0(float3  x_4, float3  y_2)
{
    return x_4.x * y_2.x + x_4.y * y_2.y + x_4.z * y_2.z;
}

static __device__ float length_0(float3  x_5)
{
    return (F32_sqrt((dot_0(x_5, x_5))));
}

static __device__ float settled_chunk_load_0(uint c_1, Quat_0 * rot_1, uint k_2, float dt_3, bool contact_0)
{
    float3  f_1;
    float3  t_2;
    chunk_external_0(c_1, c_1, rot_1, k_2, dt_3, contact_0, &f_1, &t_2);
    record_chunk_load_0(c_1, f_1, t_2);
    return length_0(f_1);
}

static __device__ uint WaveGetActiveMask_0(uint _S91)
{
    return _S91;
}

static __device__ float4  WaveActiveSum_0(float4  expr_0, uint _S92)
{
    float4  _S93 = (_waveSumMultiple((make_uint4 (WaveGetActiveMask_0(_S92), 0U, 0U, 0U)).x, (expr_0)));
    return _S93;
}

__device__ __shared__ FixedArray<float4 , 32>  g_part_a_0;

__device__ __shared__ FixedArray<float4 , 32>  g_part_b_0;

static __device__ void group_sum2_0(uint tid_1, float4  * a_1, float4  * b_0, uint _S94)
{
    float4  _S95 = WaveActiveSum_0(*a_1, _S94);
    float4  _S96 = WaveActiveSum_0(*b_0, _S94);
    bool _S97 = (tid_1 % 32U) == 0U;
    uint _S98 = __ballot_sync(_S94, _S97);
    if(_S97)
    {
        (*&g_part_a_0)[tid_1 / 32U] = _S95;
        (*&g_part_b_0)[tid_1 / 32U] = _S96;
    }
    __syncthreads();
    uint w_2 = 1U;
    float4  sa_0 = (*&g_part_a_0)[int(0)];
    float4  sb_0 = (*&g_part_b_0)[int(0)];
    for(;;)
    {
        if(w_2 < 8U)
        {
        }
        else
        {
            break;
        }
        float4  sa_1 = sa_0 + (*&g_part_a_0)[w_2];
        float4  sb_1 = sb_0 + (*&g_part_b_0)[w_2];
        w_2 = w_2 + 1U;
        sa_0 = sa_1;
        sb_0 = sb_1;
    }
    __syncthreads();
    *a_1 = sa_0;
    *b_0 = sb_0;
    return;
}

static __device__ void group_sum3_0(uint tid_2, float3  * a_2, float3  * b_1, uint _S99)
{
    float4  x_6 = make_float4 ((*a_2).x, (*a_2).y, (*a_2).z, 0.0f);
    float4  y_3 = make_float4 ((*b_1).x, (*b_1).y, (*b_1).z, 0.0f);
    group_sum2_0(tid_2, &x_6, &y_3, _S99);
    float4  _S100 = x_6;
    *a_2 = float3 {_S100.x, _S100.y, _S100.z};
    float4  _S101 = y_3;
    *b_1 = float3 {_S101.x, _S101.y, _S101.z};
    return;
}

static __device__ void net_load_0(uint c_2, Island_0 * isl_2, Rigid_0 * rg_1, uint k_3, float dt_4, bool contact_1, float3  * f_2, float3  * t_3)
{
    ChunkStatic_0 * _S102 = (&(globalParams_0->chunks_0)[c_2]);
    float3  fl_0;
    float3  tl_0;
    float3  rep_f_0;
    float3  rep_m_0;
    chunk_loads_0(c_2, c_2, &rg_1->rot_0, k_3, dt_4, contact_1, 0.0f, &fl_0, &tl_0, &rep_f_0, &rep_m_0);
    float3  _S103 = fl_0;
    float4  _S104 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  _S105 = float3 {_S104.x, _S104.y, _S104.z};
    float4  _S106 = __ldg(&_S102->center_0);
    float3  fc_0 = _S103 + _S105 * make_float3 (_S106.w);
    float3  _S107 = float3 {_S106.x, _S106.y, _S106.z};
    float4  _S108 = *(&(globalParams_0->state_0)[4U * c_2]);
    float4  _S109 = isl_2->com_0;
    float3  _S110 = float3 {_S109.x, _S109.y, _S109.z};
    float3  _S111 = rotate_0(&rg_1->rot_0, _S107 + float3 {_S108.x, _S108.y, _S108.z} - _S110);
    *f_2 = *f_2 + fc_0;
    *t_3 = *t_3 + (cross_0(_S111, fc_0) + tl_0);
    uint4  _S112 = __ldg(&_S102->load_range_0);
    if((_S112.y) > (_S112.x))
    {
        float3  _S113 = rotate_0(&rg_1->rot_0, rep_f_0);
        *f_2 = *f_2 + _S113;
        float3  _S114 = rotate_0(&rg_1->rot_0, _S107 - _S110);
        float3  _S115 = cross_0(_S114, _S113);
        float3  _S116 = rotate_0(&rg_1->rot_0, rep_m_0);
        *t_3 = *t_3 + (_S115 + _S116);
    }
    return;
}

static __device__ float3  inverse_rotate_0(Quat_0 * q_2, float3  v_1)
{
    Quat_0 c_3;
    (&c_3)->w_0 = q_2->w_0;
    (&c_3)->x_1 = - q_2->x_1;
    (&c_3)->y_1 = - q_2->y_1;
    (&c_3)->z_0 = - q_2->z_0;
    Quat_0 _S117 = c_3;
    float3  _S118 = rotate_0(&_S117, v_1);
    return _S118;
}

static __device__ float3  rows_mul_0(float4  r0_0, float4  r1_0, float4  r2_0, float3  v_2)
{
    return make_float3 (dot_0(float3 {r0_0.x, r0_0.y, r0_0.z}, v_2), dot_0(float3 {r1_0.x, r1_0.y, r1_0.z}, v_2), dot_0(float3 {r2_0.x, r2_0.y, r2_0.z}, v_2));
}

static __device__ float3  world_mul_0(Quat_0 * q_3, float4  r0_1, float4  r1_1, float4  r2_1, float3  v_3)
{
    float3  _S119 = inverse_rotate_0(q_3, v_3);
    float3  _S120 = rotate_0(q_3, rows_mul_0(r0_1, r1_1, r2_1, _S119));
    return _S120;
}

static __device__ void rigid_acceleration_0(Island_0 * isl_3, Rigid_0 * rg_2, float3  f_3, float3  t_4)
{
    Quat_0 _S121 = rg_2->rot_0;
    float3  _S122 = world_mul_0(&_S121, isl_3->inertia0_1, isl_3->inertia1_1, isl_3->inertia2_1, rg_2->w_1);
    rg_2->a_0 = f_3 / make_float3 (isl_3->com_0.w);
    float3  _S123 = t_4 - cross_0(rg_2->w_1, _S122);
    Quat_0 _S124 = rg_2->rot_0;
    float3  _S125 = world_mul_0(&_S124, isl_3->inv0_1, isl_3->inv1_1, isl_3->inv2_1, _S123);
    rg_2->alpha_0 = _S125;
    rg_2->torque_0 = t_4;
    return;
}

static __device__ void comp_add1_0(float * sum_0, float * err_0, float x_7)
{
    float t_5 = *sum_0 + x_7;
    if((F32_abs((*sum_0))) >= (F32_abs((x_7))))
    {
        *err_0 = *err_0 + (*sum_0 - t_5 + x_7);
    }
    else
    {
        *err_0 = *err_0 + (x_7 - t_5 + *sum_0);
    }
    *sum_0 = t_5;
    return;
}

static __device__ void chunk_update_0(uint c_4, Island_0 * isl_4, Rigid_0 * rg_3, float dt_5, bool rml_0, uint step_0, bool contact_2, float * work_0, float * work_err_0)
{
    ChunkStatic_0 * _S126 = (&(globalParams_0->chunks_0)[c_4]);
    float3  _S127 = make_float3 (0.0f);
    uint _S128 = __ldg((&(globalParams_0->index_0)[c_4]));
    float peak_0 = 0.0f;
    uint e_0 = _S128;
    float3  fi_0 = _S127;
    float3  mi_0 = _S127;
    for(;;)
    {
        uint _S129 = __ldg((&(globalParams_0->index_0)[c_4 + 1U]));
        if(e_0 < _S129)
        {
        }
        else
        {
            break;
        }
        uint _S130 = __ldg((&(globalParams_0->index_0)[e_0]));
        uint _S131 = 3U * (_S130 >> int(1));
        float4  fa_0 = *(&(globalParams_0->scratch_0)[_S131]);
        if((_S130 & 1U) == 0U)
        {
            float4  _S132 = *(&(globalParams_0->scratch_0)[_S131 + 1U]);
            float3  mi_1 = mi_0 + float3 {_S132.x, _S132.y, _S132.z};
            fi_0 = fi_0 + float3 {fa_0.x, fa_0.y, fa_0.z};
            mi_0 = mi_1;
        }
        else
        {
            float4  _S133 = *(&(globalParams_0->scratch_0)[_S131 + 2U]);
            float3  mi_2 = mi_0 + float3 {_S133.x, _S133.y, _S133.z};
            fi_0 = fi_0 + - float3 {fa_0.x, fa_0.y, fa_0.z};
            mi_0 = mi_2;
        }
        float _S134 = (F32_max((peak_0), (fa_0.w)));
        uint _S135 = e_0 + 1U;
        peak_0 = _S134;
        e_0 = _S135;
    }
    uint _S136 = 4U * c_4;
    float4  _S137 = *(&(globalParams_0->state_0)[_S136]);
    float3  u_0 = float3 {_S137.x, _S137.y, _S137.z};
    uint _S138 = _S136 + 1U;
    float4  _S139 = *(&(globalParams_0->state_0)[_S138]);
    float3  th_0 = float3 {_S139.x, _S139.y, _S139.z};
    uint _S140 = _S136 + 2U;
    float4  _S141 = *(&(globalParams_0->state_0)[_S140]);
    float3  v_4 = float3 {_S141.x, _S141.y, _S141.z};
    uint _S142 = _S136 + 3U;
    float4  _S143 = *(&(globalParams_0->state_0)[_S142]);
    float3  w_3 = float3 {_S143.x, _S143.y, _S143.z};
    float4  _S144 = __ldg(&_S126->center_0);
    float mass_0 = _S144.w;
    float3  _S145 = float3 {_S144.x, _S144.y, _S144.z};
    float4  _S146 = isl_4->com_0;
    float3  _S147 = float3 {_S146.x, _S146.y, _S146.z};
    float3  _S148 = rotate_0(&rg_3->rot_0, _S145 + u_0 - _S147);
    float3  f_load_0;
    float3  t_load_0;
    float3  rep_f_1;
    float3  rep_m_1;
    chunk_loads_0(c_4, c_4, &rg_3->rot_0, step_0, dt_5, contact_2, dt_5, &f_load_0, &t_load_0, &rep_f_1, &rep_m_1);
    record_chunk_load_0(c_4, f_load_0, t_load_0);
    float3  _S149 = f_load_0;
    float4  _S150 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  f_world_0 = _S149 + float3 {_S150.x, _S150.y, _S150.z} * make_float3 (mass_0);
    float3  t_world_0 = t_load_0;
    float3  f_world_1;
    float3  t_world_1;
    if(rml_0)
    {
        float3  _S151 = rg_3->alpha_0;
        float3  _S152 = rg_3->w_1;
        float3  f_world_2 = f_world_0 - (rg_3->a_0 + cross_0(rg_3->alpha_0, _S148) + cross_0(rg_3->w_1, cross_0(rg_3->w_1, _S148))) * make_float3 (mass_0);
        float4  _S153 = __ldg(&_S126->inertia0_0);
        float4  _S154 = __ldg(&_S126->inertia1_0);
        float4  _S155 = __ldg(&_S126->inertia2_0);
        float3  _S156 = world_mul_0(&rg_3->rot_0, _S153, _S154, _S155, _S151);
        float3  _S157 = world_mul_0(&rg_3->rot_0, _S153, _S154, _S155, _S152);
        float3  t_world_2 = t_world_0 - (_S156 + cross_0(_S152, _S157));
        f_world_1 = f_world_2;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    float3  _S158 = inverse_rotate_0(&rg_3->rot_0, f_world_1);
    float3  _S159 = inverse_rotate_0(&rg_3->rot_0, t_world_1);
    float3  f_ext_0;
    float3  m_ext_0;
    if(rml_0)
    {
        float3  _S160 = inverse_rotate_0(&rg_3->rot_0, rg_3->w_1);
        float3  f_ext_1 = _S158 - cross_0(_S160, v_4) * make_float3 (2.0f * mass_0);
        float4  _S161 = __ldg(&_S126->inertia0_0);
        float4  _S162 = __ldg(&_S126->inertia1_0);
        float4  _S163 = __ldg(&_S126->inertia2_0);
        float3  i_w_0 = rows_mul_0(_S161, _S162, _S163, w_3);
        float3  m_ext_1 = _S159 - (cross_0(_S160, i_w_0) + cross_0(w_3, rows_mul_0(_S161, _S162, _S163, _S160)) + cross_0(w_3, i_w_0));
        f_ext_0 = f_ext_1;
        m_ext_0 = m_ext_1;
    }
    else
    {
        f_ext_0 = _S158;
        m_ext_0 = _S159;
    }
    float3  f_4 = f_ext_0 + rep_f_1 + fi_0;
    float3  m_1 = m_ext_0 + rep_m_1 + mi_0;
    uint4  _S164 = __ldg(&_S126->info_0);
    uint support_0 = _S164.x;
    float3  _S165 = make_float3 ((*(&(globalParams_0->state_0)[_S138])).w, (*(&(globalParams_0->state_0)[_S140])).w, (*(&(globalParams_0->state_0)[_S142])).w);
    float3  reaction_0;
    float3  u_1;
    float3  th_1;
    float3  v_5;
    float3  w_4;
    if(support_0 == 1U)
    {
        reaction_0 = - f_4;
        u_1 = u_0;
        th_1 = th_0;
        v_5 = _S127;
        w_4 = _S127;
    }
    else
    {
        float4  _S166 = __ldg(&_S126->inv0_0);
        float4  _S167 = __ldg(&_S126->inv1_0);
        float4  _S168 = __ldg(&_S126->inv2_0);
        float3  _S169 = rows_mul_0(_S166, _S167, _S168, m_1);
        float4  _S170 = __ldg(&_S126->scale_0);
        float3  w_5 = w_3 + _S169 * make_float3 (dt_5 * _S170.z);
        float3  th_2 = th_0 + w_5 * make_float3 (dt_5);
        if(support_0 == 2U)
        {
            reaction_0 = - f_4;
            u_1 = u_0;
            th_1 = _S127;
        }
        else
        {
            float3  v_6 = v_4 + f_4 * make_float3 (dt_5 * _S170.y);
            float3  u_2 = u_0 + v_6 * make_float3 (dt_5);
            reaction_0 = _S165;
            u_1 = u_2;
            th_1 = v_6;
        }
        float3  _S171 = th_1;
        th_1 = th_2;
        v_5 = _S171;
        w_4 = w_5;
    }
    *(&(globalParams_0->state_0)[_S136]) = make_float4 (u_1.x, u_1.y, u_1.z, peak_0);
    *(&(globalParams_0->state_0)[_S138]) = make_float4 (th_1.x, th_1.y, th_1.z, reaction_0.x);
    *(&(globalParams_0->state_0)[_S140]) = make_float4 (v_5.x, v_5.y, v_5.z, reaction_0.y);
    *(&(globalParams_0->state_0)[_S142]) = make_float4 (w_4.x, w_4.y, w_4.z, reaction_0.z);
    float3  _S172 = rotate_0(&rg_3->rot_0, _S145 + u_1 - _S147);
    float3  _S173 = rg_3->vel_0 + rg_3->vel_err_0 + cross_0(rg_3->w_1, _S172);
    float3  _S174 = rotate_0(&rg_3->rot_0, v_5);
    float3  v_world_0 = _S173 + _S174;
    float3  _S175 = rotate_0(&rg_3->rot_0, w_4);
    comp_add1_0(work_0, work_err_0, (dot_0(f_load_0, v_world_0) + dot_0(t_load_0, rg_3->w_1 + _S175)) * dt_5);
    return;
}

static __device__ float3  abs_0(float3  x_8)
{
    float3  result_2;
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
        *_slang_vector_get_element_ptr(&result_2, i_3) = (F32_abs((_slang_vector_get_element(x_8, i_3))));
        i_3 = i_3 + int(1);
    }
    return result_2;
}

static __device__ void comp_add_0(float3  * sum_1, float3  * err_1, float3  x_9)
{
    float3  t_6 = *sum_1 + x_9;
    float3  _S176 = abs_0(x_9);
    *err_1 = *err_1 + (_slang_select((abs_0(*sum_1)) >= _S176, *sum_1,x_9) - t_6 + _slang_select((abs_0(*sum_1)) >= _S176, x_9,*sum_1));
    *sum_1 = t_6;
    return;
}

static __device__ float3  turn_difference_0(float3  omega_0, float dt_6, float3  v_7)
{
    float _S177 = length_0(omega_0);
    float angle_0 = _S177 * dt_6;
    if(angle_0 < 1.00000000317107685e-30f)
    {
        return make_float3 (0.0f);
    }
    float3  a_3 = omega_0 / make_float3 (_S177);
    float s_1 = (F32_sin((0.5f * angle_0)));
    float3  av_0 = cross_0(a_3, v_7);
    return av_0 * make_float3 ((F32_sin((angle_0)))) + cross_0(a_3, av_0) * make_float3 (2.0f * s_1 * s_1);
}

static __device__ float4  turn_minus_one_0(float3  axis_0, float angle_1)
{
    float s_2 = (F32_sin((0.25f * angle_1)));
    return make_float4 ((axis_0 * make_float3 ((F32_sin((0.5f * angle_1))))).x, (axis_0 * make_float3 ((F32_sin((0.5f * angle_1))))).y, (axis_0 * make_float3 ((F32_sin((0.5f * angle_1))))).z, -2.0f * s_2 * s_2);
}

static __device__ Quat_0 quat_mul_0(Quat_0 * a_4, Quat_0 * o_0)
{
    Quat_0 r_1;
    (&r_1)->w_0 = a_4->w_0 * o_0->w_0 - a_4->x_1 * o_0->x_1 - a_4->y_1 * o_0->y_1 - a_4->z_0 * o_0->z_0;
    (&r_1)->x_1 = a_4->w_0 * o_0->x_1 + a_4->x_1 * o_0->w_0 + a_4->y_1 * o_0->z_0 - a_4->z_0 * o_0->y_1;
    (&r_1)->y_1 = a_4->w_0 * o_0->y_1 - a_4->x_1 * o_0->z_0 + a_4->y_1 * o_0->w_0 + a_4->z_0 * o_0->x_1;
    (&r_1)->z_0 = a_4->w_0 * o_0->z_0 + a_4->x_1 * o_0->y_1 - a_4->y_1 * o_0->x_1 + a_4->z_0 * o_0->w_0;
    return r_1;
}

static __device__ float4  quat_vec_0(Quat_0 * q_4)
{
    return make_float4 (q_4->x_1, q_4->y_1, q_4->z_0, q_4->w_0);
}

static __device__ float4  abs_1(float4  x_10)
{
    float4  result_3;
    int i_4 = int(0);
    for(;;)
    {
        if(i_4 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_3, i_4) = (F32_abs((_slang_vector_get_element(x_10, i_4))));
        i_4 = i_4 + int(1);
    }
    return result_3;
}

static __device__ void comp_add4_0(float4  * sum_2, float4  * err_2, float4  x_11)
{
    float4  t_7 = *sum_2 + x_11;
    float4  _S178 = abs_1(x_11);
    *err_2 = *err_2 + (_slang_select((abs_1(*sum_2)) >= _S178, *sum_2,x_11) - t_7 + _slang_select((abs_1(*sum_2)) >= _S178, x_11,*sum_2));
    *sum_2 = t_7;
    return;
}

static __device__ void quat_accumulate_0(Quat_0 * hi_0, float4  * lo_0, float4  x_12)
{
    Quat_0 _S179 = *hi_0;
    float4  _S180 = quat_vec_0(&_S179);
    float4  sum_3 = _S180;
    comp_add4_0(&sum_3, lo_0, x_12);
    float4  t_8 = sum_3 + *lo_0;
    *lo_0 = *lo_0 - (t_8 - sum_3);
    *hi_0 = quat_of_0(t_8);
    return;
}

static __device__ void turn_left_0(Quat_0 * hi_1, float4  * lo_1, float3  omega_1, float dt_7)
{
    float _S181 = length_0(omega_1);
    float angle_2 = _S181 * dt_7;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_0 = turn_minus_one_0(omega_1 / make_float3 (_S181), angle_2);
    Quat_0 dq_0;
    (&dq_0)->x_1 = d_0.x;
    (&dq_0)->y_1 = d_0.y;
    (&dq_0)->z_0 = d_0.z;
    (&dq_0)->w_0 = d_0.w;
    Quat_0 _S182 = dq_0;
    Quat_0 _S183 = *hi_1;
    Quat_0 _S184 = quat_mul_0(&_S182, &_S183);
    Quat_0 _S185 = _S184;
    float4  _S186 = quat_vec_0(&_S185);
    quat_accumulate_0(hi_1, lo_1, _S186);
    return;
}

static __device__ void integrate_rigid_0(Island_0 * isl_5, Rigid_0 * rg_4, float dt_8)
{
    comp_add_0(&rg_4->l_0, &rg_4->l_err_0, rg_4->torque_0 * make_float3 (dt_8));
    float3  l_1 = rg_4->l_0 + rg_4->l_err_0;
    comp_add_0(&rg_4->vel_0, &rg_4->vel_err_0, rg_4->a_0 * make_float3 (dt_8));
    float3  vel_1 = rg_4->vel_0 + rg_4->vel_err_0;
    float4  _S187 = isl_5->inv0_1;
    float4  _S188 = isl_5->inv1_1;
    float4  _S189 = isl_5->inv2_1;
    Quat_0 _S190 = rg_4->rot_0;
    float3  _S191 = world_mul_0(&_S190, isl_5->inv0_1, isl_5->inv1_1, isl_5->inv2_1, l_1);
    float3  _S192 = vel_1 * make_float3 (dt_8);
    float4  _S193 = isl_5->com_0;
    float3  _S194 = float3 {_S193.x, _S193.y, _S193.z};
    Quat_0 _S195 = rg_4->rot_0;
    float3  _S196 = rotate_0(&_S195, _S194);
    comp_add_0(&rg_4->pos_0, &rg_4->pos_err_0, _S192 - turn_difference_0(_S191, dt_8, _S196));
    turn_left_0(&rg_4->rot_0, &rg_4->rot_err_0, _S191, dt_8);
    Quat_0 _S197 = rg_4->rot_0;
    float3  _S198 = world_mul_0(&_S197, _S187, _S188, _S189, l_1);
    rg_4->w_1 = _S198;
    return;
}

static __device__ void drift_moments_0(uint c_5, float3  * tu_0, float3  * pv_0)
{
    ChunkStatic_0 * _S199 = (&(globalParams_0->chunks_0)[c_5]);
    float4  _S200 = __ldg(&_S199->center_0);
    float _S201 = _S200.w;
    float4  _S202 = __ldg(&_S199->scale_0);
    float m_2 = _S201 * _S202.x;
    uint _S203 = 4U * c_5;
    float4  _S204 = *(&(globalParams_0->state_0)[_S203]);
    *tu_0 = *tu_0 + float3 {_S204.x, _S204.y, _S204.z} * make_float3 (m_2);
    float4  _S205 = *(&(globalParams_0->state_0)[_S203 + 2U]);
    *pv_0 = *pv_0 + float3 {_S205.x, _S205.y, _S205.z} * make_float3 (m_2);
    return;
}

static __device__ void drift_angular_0(uint c_6, float3  wcom_1, float3  tr_0, float3  dv_0, float3  * lu_0, float3  * lv_0)
{
    ChunkStatic_0 * _S206 = (&(globalParams_0->chunks_0)[c_6]);
    float4  _S207 = __ldg(&_S206->center_0);
    float3  r_2 = float3 {_S207.x, _S207.y, _S207.z} - wcom_1;
    float4  _S208 = __ldg(&_S206->scale_0);
    float kw_0 = _S208.x;
    uint _S209 = 4U * c_6;
    float4  _S210 = *(&(globalParams_0->state_0)[_S209]);
    float _S211 = _S207.w;
    float3  _S212 = cross_0(r_2, float3 {_S210.x, _S210.y, _S210.z} - tr_0) * make_float3 (_S211);
    float4  _S213 = __ldg(&_S206->inertia0_0);
    float4  _S214 = __ldg(&_S206->inertia1_0);
    float4  _S215 = __ldg(&_S206->inertia2_0);
    float4  _S216 = *(&(globalParams_0->state_0)[_S209 + 1U]);
    *lu_0 = *lu_0 + (_S212 + rows_mul_0(_S213, _S214, _S215, float3 {_S216.x, _S216.y, _S216.z})) * make_float3 (kw_0);
    float4  _S217 = *(&(globalParams_0->state_0)[_S209 + 2U]);
    float4  _S218 = *(&(globalParams_0->state_0)[_S209 + 3U]);
    *lv_0 = *lv_0 + (cross_0(r_2, float3 {_S217.x, _S217.y, _S217.z} - dv_0) * make_float3 (_S211) + rows_mul_0(_S213, _S214, _S215, float3 {_S218.x, _S218.y, _S218.z})) * make_float3 (kw_0);
    return;
}

static __device__ void drift_apply_0(uint c_7, float3  wcom_2, float3  tr_1, float3  phi_0, float3  dv_1, float3  dw_0)
{
    float4  _S219 = __ldg(&(&(globalParams_0->chunks_0)[c_7])->center_0);
    float3  r_3 = float3 {_S219.x, _S219.y, _S219.z} - wcom_2;
    uint _S220 = 4U * c_7;
    float4  _S221 = *(&(globalParams_0->state_0)[_S220]);
    *(&(globalParams_0->state_0)[_S220]) = make_float4 ((float3 {_S221.x, _S221.y, _S221.z} - (tr_1 + cross_0(phi_0, r_3))).x, (float3 {_S221.x, _S221.y, _S221.z} - (tr_1 + cross_0(phi_0, r_3))).y, (float3 {_S221.x, _S221.y, _S221.z} - (tr_1 + cross_0(phi_0, r_3))).z, (*(&(globalParams_0->state_0)[_S220])).w);
    uint _S222 = _S220 + 1U;
    float4  _S223 = *(&(globalParams_0->state_0)[_S222]);
    *(&(globalParams_0->state_0)[_S222]) = make_float4 ((float3 {_S223.x, _S223.y, _S223.z} - phi_0).x, (float3 {_S223.x, _S223.y, _S223.z} - phi_0).y, (float3 {_S223.x, _S223.y, _S223.z} - phi_0).z, (*(&(globalParams_0->state_0)[_S222])).w);
    uint _S224 = _S220 + 2U;
    float4  _S225 = *(&(globalParams_0->state_0)[_S224]);
    *(&(globalParams_0->state_0)[_S224]) = make_float4 ((float3 {_S225.x, _S225.y, _S225.z} - (dv_1 + cross_0(dw_0, r_3))).x, (float3 {_S225.x, _S225.y, _S225.z} - (dv_1 + cross_0(dw_0, r_3))).y, (float3 {_S225.x, _S225.y, _S225.z} - (dv_1 + cross_0(dw_0, r_3))).z, (*(&(globalParams_0->state_0)[_S224])).w);
    uint _S226 = _S220 + 3U;
    float4  _S227 = *(&(globalParams_0->state_0)[_S226]);
    *(&(globalParams_0->state_0)[_S226]) = make_float4 ((float3 {_S227.x, _S227.y, _S227.z} - dw_0).x, (float3 {_S227.x, _S227.y, _S227.z} - dw_0).y, (float3 {_S227.x, _S227.y, _S227.z} - dw_0).z, (*(&(globalParams_0->state_0)[_S226])).w);
    return;
}

static __device__ void turn_right_0(Quat_0 * hi_2, float4  * lo_2, float3  phi_1)
{
    float angle_3 = length_0(phi_1);
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    float4  d_1 = turn_minus_one_0(phi_1 / make_float3 (angle_3), angle_3);
    Quat_0 dq_1;
    (&dq_1)->x_1 = d_1.x;
    (&dq_1)->y_1 = d_1.y;
    (&dq_1)->z_0 = d_1.z;
    (&dq_1)->w_0 = d_1.w;
    Quat_0 _S228 = *hi_2;
    Quat_0 _S229 = dq_1;
    Quat_0 _S230 = quat_mul_0(&_S228, &_S229);
    Quat_0 _S231 = _S230;
    float4  _S232 = quat_vec_0(&_S231);
    quat_accumulate_0(hi_2, lo_2, _S232);
    return;
}

static __device__ void drift_rigid_0(Island_0 * isl_6, Rigid_0 * rg_5, float3  tr_2, float3  phi_2, float3  dv_2, float3  dw_1)
{
    float4  _S233 = isl_6->wcom_0;
    float3  wcom_3 = float3 {_S233.x, _S233.y, _S233.z};
    Quat_0 rot_2 = rg_5->rot_0;
    float3  _S234 = tr_2 - cross_0(phi_2, wcom_3);
    Quat_0 _S235 = rg_5->rot_0;
    float3  _S236 = rotate_0(&_S235, _S234);
    comp_add_0(&rg_5->pos_0, &rg_5->pos_err_0, _S236);
    Quat_0 _S237 = rg_5->rot_0;
    float3  _S238 = inverse_rotate_0(&_S237, rg_5->w_1);
    float4  _S239 = isl_6->inertia0_1;
    float4  _S240 = isl_6->inertia1_1;
    float4  _S241 = isl_6->inertia2_1;
    float3  _S242 = cross_0(phi_2, rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, _S238)) - rows_mul_0(isl_6->inertia0_1, isl_6->inertia1_1, isl_6->inertia2_1, cross_0(phi_2, _S238));
    Quat_0 _S243 = rg_5->rot_0;
    float3  _S244 = rotate_0(&_S243, _S242);
    turn_right_0(&rg_5->rot_0, &rg_5->rot_err_0, phi_2);
    float4  _S245 = isl_6->com_0;
    float3  _S246 = dv_2 + cross_0(dw_1, float3 {_S245.x, _S245.y, _S245.z} - wcom_3);
    Quat_0 _S247 = rot_2;
    float3  _S248 = rotate_0(&_S247, _S246);
    comp_add_0(&rg_5->vel_0, &rg_5->vel_err_0, _S248);
    Quat_0 _S249 = rot_2;
    float3  _S250 = rotate_0(&_S249, dw_1);
    rg_5->w_1 = rg_5->w_1 + _S250;
    Quat_0 _S251 = rg_5->rot_0;
    float3  _S252 = world_mul_0(&_S251, _S239, _S240, _S241, _S250);
    comp_add_0(&rg_5->l_0, &rg_5->l_err_0, _S244 + _S252);
    return;
}

static __device__ void write_probe_0(uint slot_0, uint k_4, float value_1)
{
    uint _S253 = __ldg(&globalParams_0->params_0->probe_base_0);
    uint _S254 = _S253 * 4U;
    uint _S255 = __ldg(&globalParams_0->params_0->probe_stride_0);
    uint at_0 = _S254 + slot_0 * _S255 + k_4;
    float4  v_8 = *(&(globalParams_0->scratch_0)[at_0 / 4U]);
    *_slang_vector_get_element_ptr(&v_8, at_0 % 4U) = value_1;
    *(&(globalParams_0->scratch_0)[at_0 / 4U]) = v_8;
    return;
}

static __device__ void record_probes_0(Island_0 * isl_7, Rigid_0 * rg_6, uint k_5)
{
    uint4  _S256 = isl_7->probes_0;
    uint at_1 = isl_7->probes_0.x;
    for(;;)
    {
        if(at_1 < (_S256.y))
        {
        }
        else
        {
            break;
        }
        float4  _S257 = __ldg((&(globalParams_0->loads_0)[at_1]));
        uint4  info_3 = asuint_0(_S257);
        float4  _S258 = __ldg((&(globalParams_0->loads_0)[at_1 + 1U]));
        float4  _S259 = __ldg((&(globalParams_0->loads_0)[at_1 + 2U]));
        float4  _S260 = __ldg((&(globalParams_0->loads_0)[at_1 + 3U]));
        uint kind_1 = info_3.x;
        uint i_5 = info_3.y;
        float value_2;
        if(kind_1 == 0U)
        {
            float4  _S261 = *(&(globalParams_0->state_0)[4U * i_5]);
            float3  small_0 = float3 {_S261.x, _S261.y, _S261.z} + make_float3 (_S258.w, _S259.w, _S260.w);
            float3  _S262 = rg_6->pos_0 - float3 {_S259.x, _S259.y, _S259.z};
            float4  _S263 = __ldg(&(&(globalParams_0->chunks_0)[i_5])->center_0);
            float3  _S264 = rotate_0(&rg_6->rot_0, float3 {_S263.x, _S263.y, _S263.z});
            float3  _S265 = _S262 + _S264;
            float3  _S266 = rg_6->pos_err_0 - float3 {_S260.x, _S260.y, _S260.z};
            float3  _S267 = rotate_0(&rg_6->rot_0, small_0);
            value_2 = dot_0(_S265 + (_S266 + _S267), float3 {_S258.x, _S258.y, _S258.z});
        }
        else
        {
            if(kind_1 == 1U)
            {
                float4  _S268 = __ldg(&(&(globalParams_0->chunks_0)[i_5])->center_0);
                uint _S269 = 4U * i_5;
                float4  _S270 = *(&(globalParams_0->state_0)[_S269]);
                float4  _S271 = isl_7->com_0;
                float3  _S272 = rotate_0(&rg_6->rot_0, float3 {_S268.x, _S268.y, _S268.z} + float3 {_S270.x, _S270.y, _S270.z} - float3 {_S271.x, _S271.y, _S271.z});
                float3  _S273 = rg_6->vel_0 + rg_6->vel_err_0 + cross_0(rg_6->w_1, _S272);
                float4  _S274 = *(&(globalParams_0->state_0)[_S269 + 2U]);
                float3  _S275 = rotate_0(&rg_6->rot_0, float3 {_S274.x, _S274.y, _S274.z});
                value_2 = dot_0(_S273 + _S275, float3 {_S258.x, _S258.y, _S258.z});
            }
            else
            {
                if(kind_1 == 2U)
                {
                    uint _S276 = 3U * i_5;
                    float4  _S277 = *(&(globalParams_0->scratch_0)[_S276]);
                    float3  f_5 = float3 {_S277.x, _S277.y, _S277.z};
                    bool _S278 = (info_3.z) == 0U;
                    float3  mc_0;
                    if(_S278)
                    {
                        float4  _S279 = *(&(globalParams_0->scratch_0)[_S276 + 1U]);
                        mc_0 = float3 {_S279.x, _S279.y, _S279.z};
                    }
                    else
                    {
                        float4  _S280 = *(&(globalParams_0->scratch_0)[_S276 + 2U]);
                        mc_0 = float3 {_S280.x, _S280.y, _S280.z};
                    }
                    float3  fc_1;
                    if(_S278)
                    {
                        fc_1 = f_5;
                    }
                    else
                    {
                        fc_1 = - f_5;
                    }
                    value_2 = dot_0(fc_1, float3 {_S258.x, _S258.y, _S258.z}) + dot_0(mc_0, float3 {_S259.x, _S259.y, _S259.z});
                }
                else
                {
                    uint _S281 = 4U * i_5;
                    float3  _S282 = rotate_0(&rg_6->rot_0, make_float3 ((*(&(globalParams_0->state_0)[_S281 + 1U])).w, (*(&(globalParams_0->state_0)[_S281 + 2U])).w, (*(&(globalParams_0->state_0)[_S281 + 3U])).w));
                    value_2 = dot_0(_S282, float3 {_S258.x, _S258.y, _S258.z});
                }
            }
        }
        write_probe_0(info_3.w, k_5, value_2);
        at_1 = at_1 + 4U;
    }
    return;
}

__device__ __shared__ FixedArray<uint, 512>  g_label_narrow_0;

__device__ __shared__ uint g_changed_narrow_0;

static __device__ JointBond_0 slang_ldg_0(JointBond_0 * ptr_0)
{
    float4  _S283 = __ldg(&ptr_0->geom0_0);
    float4  _S284 = __ldg(&ptr_0->geom1_0);
    float4  _S285 = __ldg(&ptr_0->stiff0_0);
    float4  _S286 = __ldg(&ptr_0->stiff1_0);
    float4  _S287 = __ldg(&ptr_0->rebar0_0);
    float4  _S288 = __ldg(&ptr_0->rebar1_0);
    uint4  _S289 = __ldg(&ptr_0->ids_0);
    JointBond_0 _S290 = { _S283, _S284, _S285, _S286, _S287, _S288, _S289 };
    return _S290;
}

static __device__ bool connected_0(JointState_0 * st_0, bool has_rebar_0)
{
    bool _S291;
    if((st_0->damage_0) < 1.0f)
    {
        _S291 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S291 = (st_0->rebar_broken_0) == 0.0f;
        }
        else
        {
            _S291 = false;
        }
    }
    return _S291;
}

static __device__ bool island_connected_narrow_0(uint tid_3, Island_0 * isl_8)
{
    uint _S292 = isl_8->range_0.x;
    uint n_0 = isl_8->range_0.y - _S292;
    bool converged_0;
    if(n_0 > 512U)
    {
        converged_0 = true;
    }
    else
    {
        uint _S293 = __ldg(&globalParams_0->params_0->device_connect_0);
        converged_0 = _S293 == 0U;
    }
    if(converged_0)
    {
        return false;
    }
    uint c_8 = tid_3;
    for(;;)
    {
        if(c_8 < n_0)
        {
        }
        else
        {
            break;
        }
        (*&g_label_narrow_0)[c_8] = c_8;
        c_8 = c_8 + 256U;
    }
    __syncthreads();
    converged_0 = false;
    uint pass_0 = 0U;
    for(;;)
    {
        if(pass_0 <= n_0)
        {
        }
        else
        {
            break;
        }
        if(tid_3 == 0U)
        {
            *&g_changed_narrow_0 = 0U;
        }
        __syncthreads();
        c_8 = tid_3;
        for(;;)
        {
            if(c_8 < n_0)
            {
            }
            else
            {
                break;
            }
            uint _S294 = (*&g_label_narrow_0)[c_8];
            uint gc_0 = _S292 + c_8;
            uint _S295 = __ldg((&(globalParams_0->index_0)[gc_0]));
            uint l_2 = _S294;
            uint e_1 = _S295;
            for(;;)
            {
                uint _S296 = __ldg((&(globalParams_0->index_0)[gc_0 + 1U]));
                if(e_1 < _S296)
                {
                }
                else
                {
                    break;
                }
                uint _S297 = __ldg((&(globalParams_0->index_0)[e_1]));
                uint bond_0 = _S297 >> int(1);
                JointBond_0 _S298 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                bool _S299 = (_S298.stiff1_0.w) != 0.0f;
                JointState_0 _S300 = (&(globalParams_0->bond_dyn_0)[bond_0])->js_0;
                bool _S301 = connected_0(&_S300, _S299);
                if(!_S301)
                {
                    e_1 = e_1 + 1U;
                    continue;
                }
                uint other_0;
                if((_S297 & 1U) == 0U)
                {
                    JointBond_0 _S302 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S302.ids_0.z;
                }
                else
                {
                    JointBond_0 _S303 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_0])->law_0);
                    other_0 = _S303.ids_0.y;
                }
                l_2 = (U32_min((l_2), ((*&g_label_narrow_0)[other_0 - _S292])));
                e_1 = e_1 + 1U;
            }
            uint _S304 = (U32_min((l_2), ((*&g_label_narrow_0)[l_2])));
            if(_S304 < (*&g_label_narrow_0)[c_8])
            {
                (*&g_label_narrow_0)[c_8] = _S304;
                *&g_changed_narrow_0 = 1U;
            }
            c_8 = c_8 + 256U;
        }
        __syncthreads();
        bool converged_1 = (*&g_changed_narrow_0) == 0U;
        __syncthreads();
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        uint _S305 = pass_0 + 1U;
        converged_0 = converged_1;
        pass_0 = _S305;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_3 == 0U)
    {
        *&g_changed_narrow_0 = 0U;
    }
    __syncthreads();
    c_8 = tid_3;
    for(;;)
    {
        if(c_8 < n_0)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_narrow_0)[c_8]) != 0U)
        {
            *&g_changed_narrow_0 = 1U;
        }
        c_8 = c_8 + 256U;
    }
    __syncthreads();
    return (*&g_changed_narrow_0) == 0U;
}

static __device__ void contact_split_at_0(uint at_2)
{
    uint _S306 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint previous_0 = (&(globalParams_0->islands_0)[_S306])->info_1.y;
    uint _S307 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S308;
    if(previous_0 == 0U)
    {
        _S308 = at_2;
    }
    else
    {
        _S308 = (U32_min((previous_0), (at_2)));
    }
    *&((&(&(globalParams_0->islands_0)[_S307])->info_1)->y) = _S308;
    return;
}

static __device__ uint seen_bits_0()
{
    uint _S309;
    if(((*&g_seen_0)[0U]) != 0U)
    {
        _S309 = 32768U;
    }
    else
    {
        _S309 = 0U;
    }
    uint _S310;
    if(((*&g_seen_0)[1U]) != 0U)
    {
        _S310 = 65536U;
    }
    else
    {
        _S310 = 0U;
    }
    uint _S311 = _S309 | _S310;
    if(((*&g_seen_0)[2U]) != 0U)
    {
        _S309 = 131072U;
    }
    else
    {
        _S309 = 0U;
    }
    uint _S312 = _S311 | _S309;
    if(((*&g_seen_0)[3U]) != 0U)
    {
        _S309 = 32U;
    }
    else
    {
        _S309 = 0U;
    }
    uint _S313 = _S312 | _S309;
    if(((*&g_seen_0)[4U]) != 0U)
    {
        _S309 = 64U;
    }
    else
    {
        _S309 = 0U;
    }
    return _S313 | _S309;
}

static __device__ void island_frame_at_0(uint gi_0, uint tid_4, uint _S314)
{
    bool woke_0;
    uint _S315;
    uint _S316;
    uint _S317;
    uint _S318;
    uint _S319;
    Island_0 isl_9 = *(&(globalParams_0->islands_0)[gi_0]);
    bool driven_0 = (((&isl_9)->info_1.x) & 2U) != 0U;
    bool _S320 = !((((&isl_9)->info_1.x) & 1U) != 0U);
    uint _S321 = __ballot_sync(_S314, _S320);
    bool _S322;
    uint cov_0;
    if(_S320)
    {
        bool _S323 = !driven_0;
        uint _S324 = __ballot_sync(_S314, true);
        _S322 = _S323;
        cov_0 = _S324;
    }
    else
    {
        uint _S325 = __ballot_sync(_S314, true);
        _S322 = false;
        cov_0 = _S325;
    }
    bool contact_island_0 = (((&isl_9)->info_1.x) & 4U) != 0U;
    bool _S326 = (((&isl_9)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_4);
    bool _S327 = tid_4 == 0U;
    uint _S328 = __ballot_sync(cov_0, _S327);
    bool settled_0;
    uint run_0;
    uint done_1;
    if(_S327)
    {
        uint _S329 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S330 = contact_island_0 != (_S329 == 1U);
        uint _S331 = __ballot_sync(_S328, _S330);
        if(_S330)
        {
            uint _S332 = __ballot_sync(_S328, true);
            settled_0 = true;
            run_0 = _S332;
        }
        else
        {
            bool _S333 = (((&isl_9)->info_1.x) & 8U) != 0U;
            uint _S334 = __ballot_sync(_S328, true);
            settled_0 = _S333;
            run_0 = _S334;
        }
        uint _S335 = __ballot_sync(run_0, settled_0);
        if(settled_0)
        {
            uint _S336 = __ballot_sync(run_0, true);
            run_0 = 0U;
            done_1 = _S336;
        }
        else
        {
            uint _S337 = __ballot_sync(run_0, true);
            run_0 = 1U;
            done_1 = _S337;
        }
        uint _S338 = __ballot_sync(done_1, contact_island_0);
        if(contact_island_0)
        {
            Island_0 _S339 = isl_9;
            bool _S340 = contact_stopped_0(&_S339);
            uint _S341 = __ballot_sync(done_1, true);
            settled_0 = _S340;
            done_1 = _S341;
        }
        else
        {
            uint _S342 = __ballot_sync(done_1, true);
            settled_0 = false;
            done_1 = _S342;
        }
        uint _S343 = __ballot_sync(done_1, settled_0);
        if(settled_0)
        {
            uint _S344 = __ballot_sync(done_1, true);
            run_0 = 0U;
        }
        else
        {
            uint _S345 = __ballot_sync(done_1, true);
        }
        *&g_run_0 = run_0;
        *&g_halt_0 = 0U;
        uint _S346 = __ballot_sync(cov_0, true);
        cov_0 = _S346;
    }
    else
    {
        uint _S347 = __ballot_sync(cov_0, true);
        cov_0 = _S347;
    }
    __syncthreads();
    bool _S348 = (((&isl_9)->info_1.z) & 1U) != 0U;
    uint _S349 = __ballot_sync(cov_0, _S348);
    if(_S348)
    {
        uint _S350 = __ballot_sync(cov_0, true);
        settled_0 = true;
        cov_0 = _S350;
    }
    else
    {
        bool _S351 = (*&g_run_0) == 0U;
        uint _S352 = __ballot_sync(cov_0, true);
        settled_0 = _S351;
        cov_0 = _S352;
    }
    uint _S353 = __ballot_sync(cov_0, settled_0);
    if(settled_0)
    {
        uint _S354 = __ballot_sync(cov_0, true);
        cov_0 = 0U;
        run_0 = _S354;
    }
    else
    {
        uint _S355 = (&isl_9)->info_1.y;
        uint _S356 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S357 = (U32_min((_S355), (_S356)));
        uint _S358 = __ballot_sync(cov_0, true);
        cov_0 = _S357;
        run_0 = _S358;
    }
    float _S359 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S360 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S361 = _S360 != 0U;
    Island_0 _S362 = isl_9;
    Rigid_0 _S363 = rigid_of_0(&_S362);
    Rigid_0 rg_7 = _S363;
    float work_1 = 0.0f;
    float work_err_1 = 0.0f;
    settled_0 = _S326;
    done_1 = 0U;
    bool woke_1 = false;
    bool resumed_0 = false;
    uint _S364 = run_0;
    for(;;)
    {
        uint _S365 = 0U;
        bool _S366 = done_1 < cov_0;
        uint _S367 = __ballot_sync(_S364, _S366);
        if(_S366)
        {
            uint _S368 = __ballot_sync(_S364, true);
            _S365 = _S368;
        }
        else
        {
            uint _S369 = __ballot_sync(_S364, false);
            uint _S370 = __ballot_sync(_S364, false);
            uint _S371 = __ballot_sync(run_0, true);
            woke_0 = woke_1;
            cov_0 = _S371;
            break;
        }
        uint _S372 = (&isl_9)->info_1.w + done_1 + 1U - 1U;
        uint _S373 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_6 = _S372 - _S373;
        bool quiet_0 = (((&isl_9)->info_1.x) & 32U) != 0U;
        uint _S374 = __ballot_sync(_S365, settled_0);
        bool _S375;
        uint _S376;
        if(settled_0)
        {
            bool _S377 = !quiet_0;
            uint _S378 = __ballot_sync(_S365, true);
            _S375 = _S377;
            _S376 = _S378;
        }
        else
        {
            uint _S379 = __ballot_sync(_S365, true);
            _S375 = false;
            _S376 = _S379;
        }
        uint _S380 = __ballot_sync(_S376, _S375);
        bool _S381;
        bool explicit_step_0;
        uint c_9;
        uint _S382;
        uint c_10;
        if(_S375)
        {
            float3  _S383 = make_float3 (0.0f);
            float3  norm_0 = _S383;
            float3  unused0_0 = _S383;
            c_9 = (&isl_9)->range_0.x + tid_4;
            _S382 = _S380;
            for(;;)
            {
                bool _S384 = c_9 < ((&isl_9)->range_0.y);
                uint _S385 = __ballot_sync(_S382, _S384);
                if(_S384)
                {
                    uint _S386 = __ballot_sync(_S382, true);
                }
                else
                {
                    uint _S387 = __ballot_sync(_S382, false);
                    uint _S388 = __ballot_sync(_S382, false);
                    uint _S389 = __ballot_sync(_S380, true);
                    _S315 = _S389;
                    break;
                }
                Quat_0 _S390 = (&rg_7)->rot_0;
                float _S391 = settled_chunk_load_0(c_9, &_S390, k_6, _S359, contact_island_0);
                *&((&norm_0)->x) = *&((&norm_0)->x) + _S391;
                uint _S392 = __ballot_sync(_S382, true);
                c_9 = c_9 + 256U;
                _S382 = _S392;
            }
            group_sum3_0(tid_4, &norm_0, &unused0_0, _S315);
            uint _S393 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S394 = _S393 == 1U;
            uint _S395 = __ballot_sync(_S315, _S394);
            if(_S394)
            {
                bool _S396 = (F32_abs((norm_0.x - (&isl_9)->energy_1.z))) > ((&isl_9)->energy_1.w);
                uint _S397 = __ballot_sync(_S315, true);
                _S381 = _S396;
                c_10 = _S397;
            }
            else
            {
                uint _S398 = __ballot_sync(_S315, true);
                _S381 = false;
                c_10 = _S398;
            }
            uint _S399 = __ballot_sync(c_10, _S381);
            if(_S381)
            {
                uint _S400 = __ballot_sync(c_10, true);
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                uint _S401 = __ballot_sync(c_10, true);
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            uint _S402 = __ballot_sync(_S376, true);
            settled_0 = explicit_step_0;
            c_9 = _S402;
        }
        else
        {
            uint _S403 = __ballot_sync(_S376, true);
            woke_0 = woke_1;
            c_9 = _S403;
        }
        uint _S404 = __ballot_sync(c_9, _S320);
        if(_S320)
        {
            bool _S405 = !quiet_0;
            uint _S406 = __ballot_sync(c_9, true);
            _S381 = _S405;
            _S382 = _S406;
        }
        else
        {
            uint _S407 = __ballot_sync(c_9, true);
            _S381 = false;
            _S382 = _S407;
        }
        uint _S408 = __ballot_sync(_S382, _S381);
        uint _S409;
        if(_S381)
        {
            float3  _S410 = make_float3 (0.0f);
            float3  f_6 = _S410;
            float3  t_9 = _S410;
            c_10 = (&isl_9)->range_0.x + tid_4;
            _S409 = _S408;
            for(;;)
            {
                bool _S411 = c_10 < ((&isl_9)->range_0.y);
                uint _S412 = __ballot_sync(_S409, _S411);
                if(_S411)
                {
                    uint _S413 = __ballot_sync(_S409, true);
                }
                else
                {
                    uint _S414 = __ballot_sync(_S409, false);
                    uint _S415 = __ballot_sync(_S409, false);
                    uint _S416 = __ballot_sync(_S408, true);
                    _S316 = _S416;
                    break;
                }
                Island_0 _S417 = isl_9;
                Rigid_0 _S418 = rg_7;
                net_load_0(c_10, &_S417, &_S418, k_6, _S359, contact_island_0, &f_6, &t_9);
                uint _S419 = __ballot_sync(_S409, true);
                c_10 = c_10 + 256U;
                _S409 = _S419;
            }
            group_sum3_0(tid_4, &f_6, &t_9, _S316);
            Island_0 _S420 = isl_9;
            rigid_acceleration_0(&_S420, &rg_7, f_6, t_9);
            uint _S421 = __ballot_sync(_S382, true);
            c_10 = _S421;
        }
        else
        {
            uint _S422 = __ballot_sync(_S382, true);
            c_10 = _S422;
        }
        bool _S423 = !settled_0;
        uint _S424 = __ballot_sync(c_10, _S423);
        if(_S423)
        {
            bool _S425 = !quiet_0;
            uint _S426 = __ballot_sync(c_10, true);
            explicit_step_0 = _S425;
            _S409 = _S426;
        }
        else
        {
            uint _S427 = __ballot_sync(c_10, true);
            explicit_step_0 = false;
            _S409 = _S427;
        }
        uint _S428 = __ballot_sync(_S409, explicit_step_0);
        bool _S429;
        uint _S430;
        uint _S431;
        uint c_11;
        uint _S432;
        if(explicit_step_0)
        {
            uint _S433 = __ballot_sync(_S428, _S327);
            if(_S327)
            {
                bool _S434 = (((&(globalParams_0->islands_0)[gi_0])->info_1.z) & 2U) != 0U;
                uint _S435 = __ballot_sync(_S428, true);
                _S429 = _S434;
                _S430 = _S435;
            }
            else
            {
                uint _S436 = __ballot_sync(_S428, true);
                _S429 = false;
                _S430 = _S436;
            }
            uint _S437 = __ballot_sync(_S430, _S429);
            if(_S429)
            {
                *&g_halt_0 = 1U;
                uint _S438 = __ballot_sync(_S430, true);
                _S431 = _S438;
            }
            else
            {
                uint _S439 = __ballot_sync(_S430, true);
                _S431 = _S439;
            }
            __syncthreads();
            c_11 = (&isl_9)->range_0.x + tid_4;
            _S432 = _S431;
            for(;;)
            {
                bool _S440 = c_11 < ((&isl_9)->range_0.y);
                uint _S441 = __ballot_sync(_S432, _S440);
                if(_S440)
                {
                    uint _S442 = __ballot_sync(_S432, true);
                }
                else
                {
                    uint _S443 = __ballot_sync(_S432, false);
                    uint _S444 = __ballot_sync(_S432, false);
                    uint _S445 = __ballot_sync(_S431, true);
                    break;
                }
                Island_0 _S446 = isl_9;
                Rigid_0 _S447 = rg_7;
                chunk_update_0(c_11, &_S446, &_S447, _S359, _S361, k_6, contact_island_0, &work_1, &work_err_1);
                uint _S448 = __ballot_sync(_S432, true);
                c_11 = c_11 + 256U;
                _S432 = _S448;
            }
            __syncthreads();
            uint _S449 = __ballot_sync(_S409, true);
            _S430 = _S449;
        }
        else
        {
            uint _S450 = __ballot_sync(_S409, true);
            _S430 = _S450;
        }
        uint _S451 = __ballot_sync(_S430, _S322);
        if(_S322)
        {
            bool _S452 = !quiet_0;
            uint _S453 = __ballot_sync(_S430, true);
            _S429 = _S452;
            _S431 = _S453;
        }
        else
        {
            uint _S454 = __ballot_sync(_S430, true);
            _S429 = false;
            _S431 = _S454;
        }
        uint _S455 = __ballot_sync(_S431, _S429);
        if(_S429)
        {
            Island_0 _S456 = isl_9;
            integrate_rigid_0(&_S456, &rg_7, _S359);
            uint _S457 = __ballot_sync(_S431, true);
            c_11 = _S457;
        }
        else
        {
            uint _S458 = __ballot_sync(_S431, true);
            c_11 = _S458;
        }
        uint _S459 = __ballot_sync(c_11, _S320);
        bool _S460;
        if(_S320)
        {
            uint _S461 = __ballot_sync(c_11, true);
            _S460 = explicit_step_0;
            _S432 = _S461;
        }
        else
        {
            uint _S462 = __ballot_sync(c_11, true);
            _S460 = false;
            _S432 = _S462;
        }
        uint _S463 = __ballot_sync(_S432, _S460);
        uint c_12;
        uint _S464;
        uint c_13;
        uint _S465;
        uint c_14;
        if(_S460)
        {
            float4  _S466 = (&isl_9)->wcom_0;
            float3  _S467 = float3 {_S466.x, _S466.y, _S466.z};
            float3  _S468 = make_float3 (0.0f);
            float3  tu_1 = _S468;
            float3  pv_1 = _S468;
            c_12 = (&isl_9)->range_0.x + tid_4;
            _S464 = _S463;
            for(;;)
            {
                bool _S469 = c_12 < ((&isl_9)->range_0.y);
                uint _S470 = __ballot_sync(_S464, _S469);
                if(_S469)
                {
                    uint _S471 = __ballot_sync(_S464, true);
                }
                else
                {
                    uint _S472 = __ballot_sync(_S464, false);
                    uint _S473 = __ballot_sync(_S464, false);
                    uint _S474 = __ballot_sync(_S463, true);
                    _S317 = _S474;
                    break;
                }
                drift_moments_0(c_12, &tu_1, &pv_1);
                uint _S475 = __ballot_sync(_S464, true);
                c_12 = c_12 + 256U;
                _S464 = _S475;
            }
            group_sum3_0(tid_4, &tu_1, &pv_1, _S317);
            float3  tr_3 = tu_1 / make_float3 ((&isl_9)->wcom_0.w);
            float3  dv_3 = pv_1 / make_float3 ((&isl_9)->wcom_0.w);
            float3  lu_1 = _S468;
            float3  lv_1 = _S468;
            c_13 = (&isl_9)->range_0.x + tid_4;
            _S465 = _S317;
            for(;;)
            {
                bool _S476 = c_13 < ((&isl_9)->range_0.y);
                uint _S477 = __ballot_sync(_S465, _S476);
                if(_S476)
                {
                    uint _S478 = __ballot_sync(_S465, true);
                }
                else
                {
                    uint _S479 = __ballot_sync(_S465, false);
                    uint _S480 = __ballot_sync(_S465, false);
                    uint _S481 = __ballot_sync(_S317, true);
                    _S318 = _S481;
                    break;
                }
                drift_angular_0(c_13, _S467, tr_3, dv_3, &lu_1, &lv_1);
                uint _S482 = __ballot_sync(_S465, true);
                c_13 = c_13 + 256U;
                _S465 = _S482;
            }
            group_sum3_0(tid_4, &lu_1, &lv_1, _S318);
            float3  phi_3 = rows_mul_0((&isl_9)->winv0_0, (&isl_9)->winv1_0, (&isl_9)->winv2_0, lu_1);
            float3  dw_2 = rows_mul_0((&isl_9)->winv0_0, (&isl_9)->winv1_0, (&isl_9)->winv2_0, lv_1);
            c_14 = (&isl_9)->range_0.x + tid_4;
            uint _S483 = _S318;
            for(;;)
            {
                bool _S484 = c_14 < ((&isl_9)->range_0.y);
                uint _S485 = __ballot_sync(_S483, _S484);
                if(_S484)
                {
                    uint _S486 = __ballot_sync(_S483, true);
                }
                else
                {
                    uint _S487 = __ballot_sync(_S483, false);
                    uint _S488 = __ballot_sync(_S483, false);
                    uint _S489 = __ballot_sync(_S318, true);
                    _S319 = _S489;
                    break;
                }
                drift_apply_0(c_14, _S467, tr_3, phi_3, dv_3, dw_2);
                uint _S490 = __ballot_sync(_S483, true);
                c_14 = c_14 + 256U;
                _S483 = _S490;
            }
            bool _S491 = !driven_0;
            uint _S492 = __ballot_sync(_S319, _S491);
            if(_S491)
            {
                Island_0 _S493 = isl_9;
                drift_rigid_0(&_S493, &rg_7, tr_3, phi_3, dv_3, dw_2);
                uint _S494 = __ballot_sync(_S319, true);
            }
            else
            {
                uint _S495 = __ballot_sync(_S319, true);
            }
            __syncthreads();
            uint _S496 = __ballot_sync(_S432, true);
            c_12 = _S496;
        }
        else
        {
            uint _S497 = __ballot_sync(_S432, true);
            c_12 = _S497;
        }
        uint _S498 = __ballot_sync(c_12, _S327);
        bool _S499;
        if(_S327)
        {
            bool _S500 = ((&isl_9)->probes_0.y) > ((&isl_9)->probes_0.x);
            uint _S501 = __ballot_sync(c_12, true);
            _S499 = _S500;
            _S464 = _S501;
        }
        else
        {
            uint _S502 = __ballot_sync(c_12, true);
            _S499 = false;
            _S464 = _S502;
        }
        uint _S503 = __ballot_sync(_S464, _S499);
        if(_S499)
        {
            Island_0 _S504 = isl_9;
            Rigid_0 _S505 = rg_7;
            record_probes_0(&_S504, &_S505, k_6);
            uint _S506 = __ballot_sync(_S464, true);
            c_13 = _S506;
        }
        else
        {
            uint _S507 = __ballot_sync(_S464, true);
            c_13 = _S507;
        }
        uint _S508 = done_1 + 1U;
        bool _S509 = (*&g_halt_0) != 0U;
        uint _S510 = __ballot_sync(c_13, _S509);
        bool _S511;
        if(_S509)
        {
            Island_0 _S512 = isl_9;
            bool _S513 = island_connected_narrow_0(tid_4, &_S512);
            uint _S514 = __ballot_sync(c_13, true);
            _S511 = _S513;
            _S465 = _S514;
        }
        else
        {
            uint _S515 = __ballot_sync(c_13, true);
            _S511 = false;
            _S465 = _S515;
        }
        uint _S516 = __ballot_sync(_S465, _S511);
        bool resumed_1;
        if(_S511)
        {
            uint _S517 = __ballot_sync(_S516, _S327);
            if(_S327)
            {
                *&g_halt_0 = 0U;
                uint _S518 = __ballot_sync(_S516, true);
            }
            else
            {
                uint _S519 = __ballot_sync(_S516, true);
            }
            __syncthreads();
            uint _S520 = __ballot_sync(_S465, true);
            resumed_1 = true;
            c_14 = _S520;
        }
        else
        {
            uint _S521 = __ballot_sync(_S465, true);
            resumed_1 = resumed_0;
            c_14 = _S521;
        }
        bool _S522 = (*&g_halt_0) != 0U;
        uint _S523 = __ballot_sync(c_14, _S522);
        if(_S522)
        {
            uint _S524 = __ballot_sync(c_14, false);
            uint _S525 = __ballot_sync(_S364, false);
            uint _S526 = __ballot_sync(run_0, true);
            done_1 = _S508;
            resumed_0 = resumed_1;
            cov_0 = _S526;
            break;
        }
        else
        {
            uint _S527 = __ballot_sync(c_14, true);
        }
        uint _S528 = __ballot_sync(_S364, true);
        done_1 = _S508;
        woke_1 = woke_0;
        resumed_0 = resumed_1;
        _S364 = _S528;
    }
    float3  wsum_0 = make_float3 (work_1, work_err_1, 0.0f);
    float3  unused_0 = make_float3 (0.0f);
    group_sum3_0(tid_4, &wsum_0, &unused_0, cov_0);
    uint _S529 = __ballot_sync(cov_0, _S327);
    if(_S327)
    {
        Quat_0 _S530 = (&rg_7)->rot_0;
        float4  _S531 = quat_vec_0(&_S530);
        (&isl_9)->rotation_0 = _S531;
        (&isl_9)->rotation_err_0 = (&rg_7)->rot_err_0;
        (&isl_9)->position_0 = make_float4 ((&rg_7)->pos_0.x, (&rg_7)->pos_0.y, (&rg_7)->pos_0.z, 0.0f);
        (&isl_9)->position_err_0 = make_float4 ((&rg_7)->pos_err_0.x, (&rg_7)->pos_err_0.y, (&rg_7)->pos_err_0.z, 0.0f);
        (&isl_9)->velocity_0 = make_float4 ((&rg_7)->vel_0.x, (&rg_7)->vel_0.y, (&rg_7)->vel_0.z, 0.0f);
        (&isl_9)->velocity_err_0 = make_float4 ((&rg_7)->vel_err_0.x, (&rg_7)->vel_err_0.y, (&rg_7)->vel_err_0.z, 0.0f);
        (&isl_9)->angular_velocity_0 = make_float4 ((&rg_7)->w_1.x, (&rg_7)->w_1.y, (&rg_7)->w_1.z, 0.0f);
        (&isl_9)->momentum_0 = make_float4 ((&rg_7)->l_0.x, (&rg_7)->l_0.y, (&rg_7)->l_0.z, 0.0f);
        (&isl_9)->momentum_err_0 = make_float4 ((&rg_7)->l_err_0.x, (&rg_7)->l_err_0.y, (&rg_7)->l_err_0.z, 0.0f);
        (&isl_9)->done_0 = done_1;
        *&((&(&isl_9)->info_1)->y) = *&((&(&isl_9)->info_1)->y) - done_1;
        if((*&g_halt_0) != 0U)
        {
            _S322 = contact_island_0;
        }
        else
        {
            _S322 = false;
        }
        if(_S322)
        {
            contact_split_at_0((&isl_9)->info_1.w + done_1);
        }
        comp_add1_0(&((&(&isl_9)->energy_1)->x), &((&(&isl_9)->energy_1)->y), wsum_0.x);
        *&((&(&isl_9)->energy_1)->y) = *&((&(&isl_9)->energy_1)->y) + wsum_0.y;
        *&((&(&isl_9)->info_1)->w) = *&((&(&isl_9)->info_1)->w) + done_1;
        if((((&isl_9)->info_1.x) & 8U) == 0U)
        {
            *&((&(&isl_9)->info_1)->z) = (*&((&(&isl_9)->info_1)->z)) & 4294967293U;
        }
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_9)->info_1)->z) = (*&((&(&isl_9)->info_1)->z)) | 1U;
        }
        uint _S532 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_0 = 128U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S533 = _S532 | cov_0;
        if(woke_0)
        {
            cov_0 = 2048U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint _S534 = _S533 | cov_0;
        if(resumed_0)
        {
            cov_0 = 2097280U;
        }
        else
        {
            cov_0 = 0U;
        }
        uint cov_1 = _S534 | cov_0;
        if(done_1 > 0U)
        {
            bool quiet_1 = (((&isl_9)->info_1.x) & 32U) != 0U;
            if(quiet_1)
            {
                cov_0 = 4096U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_2 = cov_1 | cov_0;
            if((((&isl_9)->info_1.x) & 16U) != 0U)
            {
                _S322 = !quiet_1;
            }
            else
            {
                _S322 = false;
            }
            if(_S322)
            {
                cov_0 = 512U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_3 = cov_2 | cov_0;
            uint _S535 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S535 == 1U)
            {
                cov_0 = 524288U;
            }
            else
            {
                cov_0 = 0U;
            }
            uint cov_4 = cov_3 | cov_0;
            if(((&isl_9)->probes_0.y) > ((&isl_9)->probes_0.x))
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
        (&isl_9)->coverage_0 = ((&isl_9)->coverage_0) | cov_0;
        if(woke_0)
        {
            *&((&(&isl_9)->info_1)->x) = (*&((&(&isl_9)->info_1)->x)) & 4294967279U;
            *&((&(&isl_9)->info_1)->z) = (*&((&(&isl_9)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[gi_0]) = isl_9;
    }
    return;
}

static __device__ float3  to_local_0(uint _S536, float3  _S537)
{
    BondStatic_0 * _S538 = (&(globalParams_0->bonds_0)[_S536]);
    float4  _S539 = __ldg(&_S538->t1_0);
    float _S540 = dot_0(_S537, float3 {_S539.x, _S539.y, _S539.z});
    float4  _S541 = __ldg(&_S538->t2_0);
    float _S542 = dot_0(_S537, float3 {_S541.x, _S541.y, _S541.z});
    float4  _S543 = __ldg(&_S538->normal_0);
    return make_float3 (_S540, _S542, dot_0(_S537, float3 {_S543.x, _S543.y, _S543.z}));
}

static __device__ bool is_damaged_0(JointState_0 * st_1)
{
    bool _S544;
    if((st_1->damage_0) > 0.0f)
    {
        _S544 = true;
    }
    else
    {
        _S544 = (st_1->crush_0) > 0.0f;
    }
    return _S544;
}

struct Measures_0
{
    float tension_0;
    float shear_0;
    float normal_compression_0;
    float compression_0;
    float compressive_force_0;
};

struct JointResponse_0
{
    float3  force_lin_1;
    float3  force_ang_1;
    JointState_0 state_1;
    float dissipated_1;
    float overshoot_0;
    float stored_0;
    bool disconnected_0;
    float fatigue_before_0;
    Measures_0 measures_0;
};

static __device__ float fdiv_0(float a_5, float b_2)
{
    return a_5 / b_2;
}

static __device__ float fsqrt_0(float a_6)
{
    return (F32_sqrt((a_6)));
}

static __device__ Measures_0 stress_measures_0(JointBond_0 * b_3, float3  q_lin_0, float3  q_ang_0)
{
    float area_0 = b_3->geom0_0.x;
    float _S545 = q_lin_0.z;
    float axial_0 = fdiv_0(_S545, area_0);
    float bending_0 = fdiv_0((F32_abs((q_ang_0.x))), b_3->geom1_0.x) + fdiv_0((F32_abs((q_ang_0.y))), b_3->geom1_0.y);
    float _S546 = q_lin_0.x;
    float _S547 = q_lin_0.y;
    float shear_1 = fdiv_0(fsqrt_0(_S546 * _S546 + _S547 * _S547), area_0) + fdiv_0((F32_abs((q_ang_0.z))), b_3->geom0_0.w);
    Measures_0 m_3;
    (&m_3)->tension_0 = axial_0 + bending_0;
    (&m_3)->shear_0 = shear_1;
    float _S548 = - axial_0;
    (&m_3)->normal_compression_0 = (F32_max((_S548), (0.0f)));
    (&m_3)->compression_0 = _S548 + bending_0;
    (&m_3)->compressive_force_0 = (F32_max((- _S545), (0.0f)));
    return m_3;
}

static __device__ float expm1_accurate_0(float x_13)
{
    if((F32_abs((x_13))) < 0.00100000004749745f)
    {
        return x_13 * (1.0f + x_13 * (0.5f + x_13 * 0.1666666716337204f));
    }
    return (F32_exp((x_13))) - 1.0f;
}

static __device__ float fpow_0(float a_7, float b_4)
{
    return (F32_pow((a_7), (b_4)));
}

static __device__ float dif_factor_0(JointMaterial_0 * mat_1, float strain_rate_1)
{
    float r_4 = (F32_abs((strain_rate_1)));
    float4  _S549 = mat_1->dif_0;
    float ref_0 = mat_1->dif_0.x;
    if(r_4 <= ref_0)
    {
        return 1.0f;
    }
    float _S550 = _S549.z;
    float f_7;
    if(r_4 <= _S550)
    {
        f_7 = fpow_0(fdiv_0(r_4, ref_0), _S549.y);
    }
    else
    {
        f_7 = fpow_0(fdiv_0(_S550, ref_0), _S549.y) * fpow_0(fdiv_0(r_4, _S550), _S549.w);
    }
    return clamp_0(f_7, 1.0f, mat_1->misc_0.x);
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

static __device__ float4  failure_indices_0(JointMaterial_0 * mat_3, JointBond_0 * b_5, Measures_0 * m_4, float multiplier_0)
{
    float fc_2 = mat_3->strength_0.y * multiplier_0;
    float _S551 = (F32_min((mat_3->strength_0.z * multiplier_0 + mat_3->strength_0.w * m_4->normal_compression_0), (mat_3->energy_0.x * multiplier_0)));
    float4  idx_0;
    *&((&idx_0)->x) = (F32_max((fdiv_0(m_4->tension_0, mat_3->strength_0.x * multiplier_0)), (0.0f)));
    float _S552;
    if(_S551 > 0.0f)
    {
        _S552 = fdiv_0(m_4->shear_0, _S551);
    }
    else
    {
        _S552 = infinity_0();
    }
    *&((&idx_0)->y) = _S552;
    *&((&idx_0)->z) = (F32_max((fdiv_0(m_4->compression_0, fc_2)), (0.0f)));
    float _S553 = b_5->stiff1_0.y;
    if(_S553 > 0.0f)
    {
        _S552 = fdiv_0(m_4->compressive_force_0, _S553);
    }
    else
    {
        _S552 = 0.0f;
    }
    *&((&idx_0)->w) = _S552;
    return idx_0;
}

static __device__ float sq_0(float x_14)
{
    return x_14 * x_14;
}

static __device__ float damage_law_0(uint kind_2, float kappa_1, float r_5)
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == 0U)
    {
        if(r_5 <= 1.0f)
        {
            return 1.0f;
        }
        return (F32_min((fdiv_0(r_5 * (kappa_1 - 1.0f), kappa_1 * (r_5 - 1.0f))), (1.0f)));
    }
    if(kappa_1 >= (0.5f * (r_5 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

static __device__ __noinline__ float2  damage_increment_0(uint kind_3, float kappa_old_0, float lambda_0, float r_6, float d_old_0, float psi_0)
{
    float _S554 = (F32_max((damage_law_0(kind_3, lambda_0, r_6)), (d_old_0)));
    bool _S555;
    if(_S554 <= d_old_0)
    {
        _S555 = true;
    }
    else
    {
        _S555 = d_old_0 >= 1.0f;
    }
    if(_S555)
    {
        return make_float2 (d_old_0, 0.0f);
    }
    float u0_0 = fdiv_0(psi_0, lambda_0 * lambda_0);
    float _S556 = (F32_max((kappa_old_0), (1.0f)));
    if(kind_3 == 0U)
    {
        if(r_6 > 1.0f)
        {
            return make_float2 (_S554, fdiv_0(u0_0 * r_6, r_6 - 1.0f) * (F32_max(((F32_min((lambda_0), (r_6))) - (F32_min((_S556), (r_6)))), (0.0f))));
        }
        return make_float2 (_S554, (1.0f - d_old_0) * psi_0);
    }
    float ku_0 = 0.5f * (r_6 + 1.0f);
    float plateau_0 = u0_0 * (F32_max(((F32_min((lambda_0), (ku_0))) - (F32_min((_S556), (ku_0)))), (0.0f)));
    float snap_0;
    if(_S554 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return make_float2 (_S554, plateau_0 + snap_0);
}

struct Contact_0
{
    float3  q_lin_1;
    float3  q_ang_1;
    float energy_2;
    float diss_0;
    float3  plastic_0;
};

static __device__ void compressed_region_0(float w0_0, float w1_0, float dz_0, float ax_0, float ay_0, FixedArray<float, 6>  * region_0)
{
    uint count_1;
    float h0_0 = 0.5f * w0_0;
    float h1_0 = 0.5f * w1_0;
    float _S557 = - h0_0;
    float _S558 = - h1_0;
    FixedArray<float2 , 4>  _S559 = { {
        float2 {
            _S557, _S558
        }, float2 {
            h0_0, _S558
        }, float2 {
            h0_0, h1_0
        }, float2 {
            _S557, h1_0
        }
    } };
    FixedArray<float2 , 8>  poly_0;
    uint i_6 = 0U;
    uint count_2 = 0U;
    for(;;)
    {
        if(i_6 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S560 = i_6;
        uint _S561 = i_6 + 1U;
        uint _S562 = _S561 % 4U;
        float _S563 = _S559[i_6].y;
        float _S564 = _S559[i_6].x;
        float fp_0 = dz_0 + ax_0 * _S563 - ay_0 * _S564;
        float _S565 = _S559[_S562].y;
        float _S566 = _S559[_S562].x;
        float fq_0 = dz_0 + ax_0 * _S565 - ay_0 * _S566;
        bool _S567 = fp_0 < 0.0f;
        if(_S567)
        {
            uint _S568 = count_2 + 1U;
            poly_0[count_2] = _S559[_S560];
            count_1 = _S568;
        }
        else
        {
            count_1 = count_2;
        }
        if(_S567 != (fq_0 < 0.0f))
        {
            float t_10 = fp_0 / (fp_0 - fq_0);
            uint _S569 = count_1 + 1U;
            poly_0[count_1] = make_float2 (_S564 + t_10 * (_S566 - _S564), _S563 + t_10 * (_S565 - _S563));
            count_2 = _S569;
        }
        else
        {
            count_2 = count_1;
        }
        i_6 = _S561;
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
    float2  o_1 = poly_0[int(0)];
    i_6 = 0U;
    float a_8 = 0.0f;
    float sx_0 = 0.0f;
    float sy_0 = 0.0f;
    float ixx_0 = 0.0f;
    float iyy_0 = 0.0f;
    float ixy_0 = 0.0f;
    for(;;)
    {
        if(i_6 < count_2)
        {
        }
        else
        {
            break;
        }
        float _S570 = o_1.x;
        float x0_0 = poly_0[i_6].x - _S570;
        float _S571 = o_1.y;
        float y0_0 = poly_0[i_6].y - _S571;
        uint _S572 = i_6 + 1U;
        uint _S573 = _S572 % count_2;
        float x1_0 = poly_0[_S573].x - _S570;
        float y1_0 = poly_0[_S573].y - _S571;
        float _S574 = x0_0 * y1_0;
        float _S575 = x1_0 * y0_0;
        float cr_0 = _S574 - _S575;
        float a_9 = a_8 + cr_0 / 2.0f;
        float sx_1 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        float sy_1 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        float ixx_1 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        float iyy_1 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        float ixy_1 = ixy_0 + (_S574 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S575) * cr_0 / 24.0f;
        i_6 = _S572;
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
    float _S576 = a_8 * cx_0;
    (*region_0)[int(3)] = ixx_0 - _S576 * cx_0;
    (*region_0)[int(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[int(5)] = ixy_0 - _S576 * cy_0;
    return;
}

static __device__ __noinline__ float4  no_tension_patch_0(float kn_0, float w0_1, float w1_1, float dz_1, float ax_1, float ay_1)
{
    FixedArray<float, 6>  r_7;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &r_7);
    float a_10 = r_7[int(0)];
    if((r_7[int(0)]) == 0.0f)
    {
        return make_float4 (0.0f);
    }
    float k_7 = kn_0 / (w0_1 * w1_1);
    float fc_3 = dz_1 + ax_1 * r_7[int(2)] - ay_1 * r_7[int(1)];
    float _S577 = a_10 * fc_3;
    float _S578 = - ay_1;
    return make_float4 (k_7 * a_10 * fc_3, k_7 * (_S577 * r_7[int(2)] + (_S578 * r_7[int(5)] + ax_1 * r_7[int(4)])), - k_7 * (_S577 * r_7[int(1)] + (_S578 * r_7[int(3)] + ax_1 * r_7[int(5)])), 0.5f * k_7 * (_S577 * fc_3 + ay_1 * ay_1 * r_7[int(3)] + ax_1 * ax_1 * r_7[int(4)] - 2.0f * ax_1 * ay_1 * r_7[int(5)]));
}

__device__ static const FixedArray<float, 6>  SPRING_AT_0 = { {
    -0.4166666567325592f, -0.25f, -0.0833333358168602f, 0.0833333358168602f, 0.25f, 0.4166666567325592f
} };
static __device__ float signum_0(float x_15)
{
    float _S579;
    if(((F32_asuint((x_15))) & 2147483648U) != 0U)
    {
        _S579 = -1.0f;
    }
    else
    {
        _S579 = 1.0f;
    }
    return _S579;
}

static __device__ float2  return_map_0(float k_8, float total_0, float plastic_1, float cap_0)
{
    float trial_0 = k_8 * (total_0 - plastic_1);
    if((F32_abs((trial_0))) <= cap_0)
    {
        return make_float2 (trial_0, 0.0f);
    }
    float f_8 = cap_0 * signum_0(trial_0);
    return make_float2 (f_8, fdiv_0(trial_0 - f_8, k_8));
}

static __device__ __noinline__ Contact_0 contact_part_0(JointMaterial_0 * mat_4, JointBond_0 * b_6, float crush_2, float3  plastic_2, float3  d_lin_0, float3  d_ang_0)
{
    Contact_0 c_15;
    float3  _S580 = make_float3 (0.0f);
    (&c_15)->q_lin_1 = _S580;
    (&c_15)->q_ang_1 = _S580;
    (&c_15)->energy_2 = 0.0f;
    (&c_15)->diss_0 = 0.0f;
    (&c_15)->plastic_0 = plastic_2;
    uint _S581 = mat_4->kind_flags_0.y;
    if((_S581 & 2U) == 0U)
    {
        return c_15;
    }
    float kn_1 = b_6->stiff0_0.x;
    float ks_0 = b_6->stiff0_0.y;
    float kt_0 = b_6->stiff1_0.x;
    float w0_2 = b_6->geom0_0.y;
    float w1_2 = b_6->geom0_0.z;
    float diss_1;
    float nc_sum_0;
    float m1_0;
    float m2_0;
    float energy_3;
    if((_S581 & 4U) != 0U)
    {
        float4  p_0 = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        float _S582 = p_0.y;
        float _S583 = p_0.z;
        float _S584 = p_0.w;
        nc_sum_0 = p_0.x;
        m1_0 = _S582;
        m2_0 = _S583;
        energy_3 = _S584;
    }
    else
    {
        float ki_0 = kn_1 * (1.0f - crush_2) / 36.0f;
        float _S585 = d_ang_0.x;
        float _S586 = d_ang_0.y;
        float spread_0 = (F32_abs((_S585))) * 0.4166666567325592f * w1_2 + (F32_abs((_S586))) * 0.4166666567325592f * w0_2;
        float _S587 = d_lin_0.z;
        float slack_0 = 9.99999997475242708e-07f * ((F32_abs((_S587))) + spread_0);
        if((_S587 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S587 + spread_0) < (- slack_0))
            {
                float i1_0 = 2.91666650772094727f * w0_2 * w0_2;
                float i2_0 = 2.91666650772094727f * w1_2 * w1_2;
                float _S588 = ki_0 * _S585 * i2_0;
                float _S589 = ki_0 * _S586 * i1_0;
                float _S590 = 0.5f * ki_0 * (36.0f * _S587 * _S587 + _S585 * _S585 * i2_0 + _S586 * _S586 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S587;
                m1_0 = _S588;
                m2_0 = _S589;
                energy_3 = _S590;
            }
            else
            {
                uint i_7 = 0U;
                diss_1 = 0.0f;
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
                    float _S591 = SPRING_AT_0[i_7] * w0_2;
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
                        float s2_0 = SPRING_AT_0[j_0] * w1_2;
                        float di_0 = _S587 + _S585 * s2_0 - _S586 * _S591;
                        if(di_0 < 0.0f)
                        {
                            float f_9 = ki_0 * di_0;
                            float m1_2 = m1_0 + f_9 * s2_0;
                            float m2_2 = m2_0 - f_9 * _S591;
                            float energy_5 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_9;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_0 = j_0 + 1U;
                    }
                    i_7 = i_7 + 1U;
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
        }
    }
    float nc_0 = - nc_sum_0;
    float3  p_1 = plastic_2;
    (&c_15)->q_lin_1 = make_float3 (0.0f, 0.0f, nc_sum_0);
    (&c_15)->q_ang_1 = make_float3 (m1_0, m2_0, 0.0f);
    float slide_cap_0 = mat_4->strength_0.w * nc_0;
    float _S592 = ks_0 * (d_lin_0.x - plastic_2.x);
    float _S593 = ks_0 * (d_lin_0.y - plastic_2.y);
    float tn_0 = fsqrt_0(_S592 * _S592 + _S593 * _S593);
    bool _S594;
    if(tn_0 > slide_cap_0)
    {
        _S594 = tn_0 > 0.0f;
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        float _S595 = fdiv_0(_S592, tn_0);
        float _S596 = fdiv_0(_S593, tn_0);
        float dslip_0 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        *&((&p_1)->x) = *&((&p_1)->x) + _S595 * dslip_0;
        *&((&p_1)->y) = *&((&p_1)->y) + _S596 * dslip_0;
        *&((&(&c_15)->q_lin_1)->x) = _S595 * slide_cap_0;
        *&((&(&c_15)->q_lin_1)->y) = _S596 * slide_cap_0;
        diss_1 = slide_cap_0 * dslip_0;
    }
    else
    {
        *&((&(&c_15)->q_lin_1)->x) = _S592;
        *&((&(&c_15)->q_lin_1)->y) = _S593;
        diss_1 = 0.0f;
    }
    float2  tq_0 = return_map_0(kt_0, d_ang_0.z, p_1.z, slide_cap_0 * b_6->geom1_0.z);
    float _S597 = tq_0.x;
    float _S598 = tq_0.y;
    float diss_2 = diss_1 + (F32_abs((_S597))) * (F32_abs((_S598)));
    *&((&p_1)->z) = *&((&p_1)->z) + _S598;
    *&((&(&c_15)->q_ang_1)->z) = _S597;
    (&c_15)->energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0((&c_15)->q_lin_1.x), ks_0) + fdiv_0(sq_0((&c_15)->q_lin_1.y), ks_0) + fdiv_0(sq_0(_S597), kt_0));
    (&c_15)->diss_0 = diss_2;
    (&c_15)->plastic_0 = p_1;
    return c_15;
}

static __device__ float3  contact_offsets_0(JointMaterial_0 * mat_5, JointBond_0 * b_7, float crush_3, float3  plastic_3, float3  d_lin_1, float3  d_ang_1)
{
    uint _S599 = mat_5->kind_flags_0.y;
    if((_S599 & 2U) == 0U)
    {
        return plastic_3;
    }
    float kn_2 = b_7->stiff0_0.x;
    float ks_1 = b_7->stiff0_0.y;
    float kt_1 = b_7->stiff1_0.x;
    float w0_3 = b_7->geom0_0.y;
    float w1_3 = b_7->geom0_0.z;
    float nc_sum_1;
    if((_S599 & 4U) != 0U)
    {
        float4  _S600 = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S600.x;
    }
    else
    {
        float ki_1 = kn_2 * (1.0f - crush_3) / 36.0f;
        float _S601 = d_ang_1.x;
        float _S602 = d_ang_1.y;
        float spread_1 = (F32_abs((_S601))) * 0.4166666567325592f * w1_3 + (F32_abs((_S602))) * 0.4166666567325592f * w0_3;
        float _S603 = d_lin_1.z;
        float slack_1 = 9.99999997475242708e-07f * ((F32_abs((_S603))) + spread_1);
        if((_S603 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S603 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S603;
            }
            else
            {
                uint i_8 = 0U;
                float nc_sum_2 = 0.0f;
                for(;;)
                {
                    if(i_8 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float _S604 = SPRING_AT_0[i_8] * w0_3;
                    uint j_1 = 0U;
                    nc_sum_1 = nc_sum_2;
                    for(;;)
                    {
                        if(j_1 < 6U)
                        {
                        }
                        else
                        {
                            break;
                        }
                        float di_1 = _S603 + _S601 * (SPRING_AT_0[j_1] * w1_3) - _S602 * _S604;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_1 = j_1 + 1U;
                    }
                    i_8 = i_8 + 1U;
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    float nc_1 = - nc_sum_1;
    float3  p_2 = plastic_3;
    float slide_cap_1 = mat_5->strength_0.w * nc_1;
    float _S605 = ks_1 * (d_lin_1.x - plastic_3.x);
    float _S606 = ks_1 * (d_lin_1.y - plastic_3.y);
    float tn_1 = fsqrt_0(_S605 * _S605 + _S606 * _S606);
    bool _S607;
    if(tn_1 > slide_cap_1)
    {
        _S607 = tn_1 > 0.0f;
    }
    else
    {
        _S607 = false;
    }
    if(_S607)
    {
        float _S608 = fdiv_0(_S606, tn_1);
        float dslip_1 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        *&((&p_2)->x) = *&((&p_2)->x) + fdiv_0(_S605, tn_1) * dslip_1;
        *&((&p_2)->y) = *&((&p_2)->y) + _S608 * dslip_1;
    }
    *&((&p_2)->z) = *&((&p_2)->z) + return_map_0(kt_1, d_ang_1.z, p_2.z, slide_cap_1 * b_7->geom1_0.z).y;
    return p_2;
}

static __device__ float life_rate_0(JointMaterial_0 * mat_6, float s_3)
{
    if(s_3 <= 0.0f)
    {
        return 0.0f;
    }
    float _S609 = mat_6->misc_0.y;
    return fdiv_0((_S609 + 1.0f) * fpow_0(s_3, _S609), mat_6->misc_0.z);
}

static __device__ JointResponse_0 joint_evaluate_0(JointMaterial_0 * mat_7, JointBond_0 * b_8, JointState_0 * state_2, float3  d_lin_2, float3  d_ang_2, float dt_9, bool fracture_1)
{
    float kn_3 = b_8->stiff0_0.x;
    float ks_2 = b_8->stiff0_0.y;
    float kb1_0 = b_8->stiff0_0.z;
    float kb2_0 = b_8->stiff0_0.w;
    float4  _S610 = b_8->stiff1_0;
    float kt_2 = b_8->stiff1_0.x;
    bool has_rebar_1 = (b_8->stiff1_0.w) != 0.0f;
    uint kind_4 = mat_7->kind_flags_0.x;
    uint flags_0 = mat_7->kind_flags_0.y;
    bool softening_0 = (flags_0 & 1U) != 0U;
    JointState_0 st_2 = *state_2;
    bool _S611 = connected_0(state_2, has_rebar_1);
    float3  qe_lin_0 = d_lin_2 * make_float3 (ks_2, ks_2, kn_3);
    float3  qe_ang_0 = d_ang_2 * make_float3 (kb1_0, kb2_0, kt_2);
    Measures_0 _S612 = stress_measures_0(b_8, qe_lin_0, qe_ang_0);
    float _S613 = (F32_max(((F32_max((_S612.tension_0), (_S612.shear_0)))), (_S612.compression_0)));
    bool _S614 = dt_9 > 0.0f;
    float dif_1;
    if(_S614)
    {
        float raw_0 = fdiv_0((F32_max((fdiv_0(_S613 - (&st_2)->governing_stress_0, dt_9)), (0.0f))), mat_7->misc_0.w);
        float tau_2 = _S610.z;
        if((flags_0 & 16U) != 0U)
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_9, tau_2));
        }
        else
        {
            dif_1 = (F32_min((fdiv_0(dt_9, tau_2)), (1.0f)));
        }
        (&st_2)->strain_rate_0 = (&st_2)->strain_rate_0 + (raw_0 - (&st_2)->strain_rate_0) * dif_1;
        (&st_2)->governing_stress_0 = _S613;
    }
    if((flags_0 & 32U) != 0U)
    {
        float _S615 = dif_factor_0(mat_7, (&st_2)->strain_rate_0);
        dif_1 = _S615;
    }
    else
    {
        dif_1 = 1.0f;
    }
    float weibull_0 = b_8->geom1_0.w;
    float _S616 = fatigue_factor_0(mat_7, (&st_2)->life_0);
    float multiplier_1 = weibull_0 * dif_1 * _S616;
    Measures_0 _S617 = _S612;
    float4  _S618 = failure_indices_0(mat_7, b_8, &_S617, multiplier_1);
    float _S619 = _S618.x;
    float _S620 = _S618.y;
    (&st_2)->utilization_0 = (F32_max(((F32_max((_S619), (_S620)))), ((F32_max((_S618.z), (_S618.w))))));
    float _S621 = d_lin_2.x;
    float _S622 = d_lin_2.y;
    float _S623 = ks_2 * (sq_0(_S621) + sq_0(_S622)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    float _S624 = d_lin_2.z;
    bool _S625 = _S624 > 0.0f;
    if(_S625)
    {
        dif_1 = kn_3 * sq_0(_S624);
    }
    else
    {
        dif_1 = 0.0f;
    }
    float psi_ts_0 = 0.5f * (_S623 + dif_1);
    float psi_c_0;
    if(_S624 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S624);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    float3  plastic_4 = make_float3 ((&st_2)->plastic_x_0, (&st_2)->plastic_y_0, (&st_2)->plastic_t_0);
    float diss_contact_0;
    float psi_contact_0;
    float intact_normal_0;
    float dissipated_2;
    float overshoot_1;
    bool _S626;
    float3  qc_lin_0;
    if(fracture_1)
    {
        bool _S627 = _S619 >= _S620;
        if(_S627)
        {
            diss_contact_0 = _S619;
        }
        else
        {
            diss_contact_0 = _S620;
        }
        uint mode_ts_0;
        if(_S627)
        {
            mode_ts_0 = 1U;
        }
        else
        {
            mode_ts_0 = 2U;
        }
        if(diss_contact_0 > ((&st_2)->kappa_0))
        {
            _S626 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S626 = false;
        }
        if(_S626)
        {
            _S626 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S626 = false;
        }
        uint mode_c_0;
        if(_S626)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * b_8->geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            (&st_2)->ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = 0U;
            }
            float2  inc_0 = damage_increment_0(mode_c_0, (&st_2)->kappa_0, diss_contact_0, intact_normal_0, (&st_2)->damage_0, psi_ts_0);
            float _S628 = inc_0.x;
            if(_S628 > ((&st_2)->damage_0))
            {
                Contact_0 _S629 = contact_part_0(mat_7, b_8, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
                float _S630 = (F32_max((_S629.energy_2 - (1.0f - (&st_2)->crush_0) * psi_c_0), (0.0f)));
                float _S631 = (F32_max((inc_0.y - _S630 * (_S628 - (&st_2)->damage_0)), (0.0f)));
                float _S632 = (F32_max(((psi_ts_0 - _S630) * (_S628 - (&st_2)->damage_0) - _S631), (0.0f)));
                (&st_2)->damage_0 = _S628;
                (&st_2)->mode_0 = mode_ts_0;
                dissipated_2 = _S631;
                overshoot_1 = _S632;
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
        (&st_2)->kappa_0 = (F32_max(((&st_2)->kappa_0), (diss_contact_0)));
        float _S633 = state_2->damage_0;
        if((state_2->damage_0) > 0.0f)
        {
            Contact_0 _S634 = contact_part_0(mat_7, b_8, state_2->crush_0, make_float3 (state_2->plastic_x_0, state_2->plastic_y_0, state_2->plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * make_float3 (1.0f - _S633) + _S634.q_ang_1 * make_float3 (_S633);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        Measures_0 _S635 = stress_measures_0(b_8, make_float3 (0.0f, 0.0f, (F32_min((qe_lin_0.z), (0.0f)))), qc_lin_0);
        Measures_0 _S636 = _S635;
        float4  _S637 = failure_indices_0(mat_7, b_8, &_S636, multiplier_1);
        float _S638 = _S637.z;
        float _S639 = _S637.w;
        bool _S640 = _S638 >= _S639;
        if(_S640)
        {
            psi_contact_0 = _S638;
        }
        else
        {
            psi_contact_0 = _S639;
        }
        if(_S640)
        {
            mode_c_0 = 3U;
        }
        else
        {
            mode_c_0 = 4U;
        }
        if(psi_contact_0 > ((&st_2)->kappa_c_0))
        {
            _S626 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S626 = false;
        }
        if(_S626)
        {
            _S626 = psi_c_0 > 0.0f;
        }
        else
        {
            _S626 = false;
        }
        if(_S626)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(mat_7->energy_0.w * b_8->geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
                    mode_ts_0 = kind_4;
                }
                law_1 = mode_ts_0;
            }
            float2  inc_1 = damage_increment_0(law_1, (&st_2)->kappa_c_0, psi_contact_0, intact_normal_0, (&st_2)->crush_0, psi_c_0);
            float _S641 = inc_1.x;
            if(_S641 > ((&st_2)->crush_0))
            {
                float _S642 = inc_1.y;
                float dissipated_3 = dissipated_2 + _S642;
                float overshoot_2 = overshoot_1 + (F32_max((psi_c_0 * (_S641 - (&st_2)->crush_0) - _S642), (0.0f)));
                (&st_2)->crush_0 = _S641;
                (&st_2)->mode_0 = mode_c_0;
                if(_S641 >= 1.0f)
                {
                    _S626 = ((&st_2)->damage_0) < 1.0f;
                }
                else
                {
                    _S626 = false;
                }
                if(_S626)
                {
                    float dissipated_4 = dissipated_3 + psi_ts_0 * (1.0f - (&st_2)->damage_0);
                    (&st_2)->damage_0 = 1.0f;
                    dissipated_2 = dissipated_4;
                }
                else
                {
                    dissipated_2 = dissipated_3;
                }
                overshoot_1 = overshoot_2;
            }
        }
        (&st_2)->kappa_c_0 = (F32_max(((&st_2)->kappa_c_0), (psi_contact_0)));
    }
    else
    {
        dissipated_2 = 0.0f;
        overshoot_1 = 0.0f;
    }
    float dmg_0 = (&st_2)->damage_0;
    float3  _S643 = make_float3 (0.0f);
    float3  qc_ang_0;
    if(((&st_2)->damage_0) == 0.0f)
    {
        if((flags_0 & 8U) == 0U)
        {
            float3  _S644 = contact_offsets_0(mat_7, b_8, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
            (&st_2)->plastic_x_0 = _S644.x;
            (&st_2)->plastic_y_0 = _S644.y;
            (&st_2)->plastic_t_0 = _S644.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S643;
        qc_ang_0 = _S643;
        psi_contact_0 = 0.0f;
    }
    else
    {
        Contact_0 _S645 = contact_part_0(mat_7, b_8, (&st_2)->crush_0, plastic_4, d_lin_2, d_ang_2);
        (&st_2)->plastic_x_0 = _S645.plastic_0.x;
        (&st_2)->plastic_y_0 = _S645.plastic_0.y;
        (&st_2)->plastic_t_0 = _S645.plastic_0.z;
        diss_contact_0 = _S645.diss_0;
        qc_lin_0 = _S645.q_lin_1;
        qc_ang_0 = _S645.q_ang_1;
        psi_contact_0 = _S645.energy_2;
    }
    float dissipated_5 = dissipated_2 + dmg_0 * diss_contact_0;
    if(_S625)
    {
        intact_normal_0 = kn_3 * _S624;
    }
    else
    {
        intact_normal_0 = (1.0f - (&st_2)->crush_0) * kn_3 * _S624;
    }
    float _S646 = 1.0f - dmg_0;
    float3  force_lin_2 = make_float3 (_S646 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S646 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S646 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    float3  force_ang_2 = qe_ang_0 * make_float3 (_S646) + qc_ang_0 * make_float3 (dmg_0);
    float stored_1 = _S646 * (psi_ts_0 + (1.0f - (&st_2)->crush_0) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S626 = ((&st_2)->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S626 = false;
    }
    float stored_2;
    float3  force_lin_3;
    if(_S626)
    {
        float k_axial_0 = b_8->rebar0_0.x;
        float k_dowel_0 = b_8->rebar0_0.y;
        float yield_force_0 = b_8->rebar0_0.z;
        float dowel_capacity_0 = b_8->rebar0_0.w;
        float2  nr_0 = return_map_0(k_axial_0, _S624, (&st_2)->rebar_plastic_0, yield_force_0);
        float2  v1_0 = return_map_0(k_dowel_0, _S621, (&st_2)->rebar_slip0_0, dowel_capacity_0);
        float2  v2_0 = return_map_0(k_dowel_0, _S622, (&st_2)->rebar_slip1_0, dowel_capacity_0);
        float _S647 = nr_0.y;
        float _S648 = v1_0.y;
        float _S649 = v2_0.y;
        float work_2 = yield_force_0 * (F32_abs((_S647))) + dowel_capacity_0 * ((F32_abs((_S648))) + (F32_abs((_S649))));
        (&st_2)->rebar_plastic_0 = (&st_2)->rebar_plastic_0 + _S647;
        (&st_2)->rebar_slip0_0 = (&st_2)->rebar_slip0_0 + _S648;
        (&st_2)->rebar_slip1_0 = (&st_2)->rebar_slip1_0 + _S649;
        (&st_2)->rebar_work_0 = (&st_2)->rebar_work_0 + work_2;
        float dissipated_6 = dissipated_5 + work_2;
        float _S650 = nr_0.x;
        float _S651 = v1_0.x;
        float _S652 = v2_0.x;
        float elastic_0 = 0.5f * (fdiv_0(sq_0(_S650), k_axial_0) + fdiv_0(sq_0(_S651) + sq_0(_S652), k_dowel_0));
        if(fracture_1)
        {
            _S626 = ((&st_2)->rebar_work_0) >= (b_8->rebar1_0.x);
        }
        else
        {
            _S626 = false;
        }
        if(_S626)
        {
            (&st_2)->rebar_broken_0 = 1.0f;
            float dissipated_7 = dissipated_6 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_2 = dissipated_7;
            stored_2 = stored_1;
        }
        else
        {
            float stored_3 = stored_1 + elastic_0;
            force_lin_3 = force_lin_2 + make_float3 (_S651, _S652, _S650);
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
        _S626 = _S614;
    }
    else
    {
        _S626 = false;
    }
    if(_S626)
    {
        _S626 = (flags_0 & 64U) != 0U;
    }
    else
    {
        _S626 = false;
    }
    if(_S626)
    {
        Measures_0 _S653 = stress_measures_0(b_8, force_lin_3, force_ang_2);
        Measures_0 _S654 = _S653;
        float4  _S655 = failure_indices_0(mat_7, b_8, &_S654, weibull_0);
        float _S656 = life_rate_0(mat_7, (F32_max(((F32_max((_S655.x), (_S655.y)))), (_S655.z))));
        (&st_2)->life_0 = (F32_max(((&st_2)->life_0 - _S656 * dt_9), (0.0f)));
    }
    (&st_2)->dissipated_0 = (&st_2)->dissipated_0 + dissipated_2;
    JointResponse_0 resp_0;
    (&resp_0)->force_lin_1 = force_lin_3;
    (&resp_0)->force_ang_1 = force_ang_2;
    (&resp_0)->state_1 = st_2;
    (&resp_0)->dissipated_1 = dissipated_2;
    (&resp_0)->overshoot_0 = overshoot_1;
    (&resp_0)->stored_0 = stored_2;
    if(_S611)
    {
        JointState_0 _S657 = st_2;
        bool _S658 = connected_0(&_S657, has_rebar_1);
        _S626 = !_S658;
    }
    else
    {
        _S626 = false;
    }
    (&resp_0)->disconnected_0 = _S626;
    (&resp_0)->fatigue_before_0 = _S616;
    (&resp_0)->measures_0 = _S612;
    return resp_0;
}

static __device__ void secant_factors_0(JointBond_0 * b_9, JointState_0 * st_3, float3  d_lin_3, float3  * f_lin_0, float3  * f_ang_0)
{
    float _S659 = st_3->damage_0;
    bool compressed_0 = (d_lin_3.z) < 0.0f;
    float contact_3;
    if(compressed_0)
    {
        contact_3 = _S659;
    }
    else
    {
        contact_3 = 0.0f;
    }
    float _S660 = 1.0f - _S659;
    float _S661 = (F32_max((_S660 + contact_3), (9.99999997475242708e-07f)));
    float normal_1;
    if(compressed_0)
    {
        normal_1 = (F32_max((1.0f - st_3->crush_0), (9.99999997475242708e-07f)));
    }
    else
    {
        normal_1 = (F32_max((_S660), (9.99999997475242708e-07f)));
    }
    *f_lin_0 = make_float3 (_S661, _S661, normal_1);
    *f_ang_0 = make_float3 (_S661);
    bool _S662;
    if((b_9->stiff1_0.w) != 0.0f)
    {
        _S662 = (st_3->rebar_broken_0) == 0.0f;
    }
    else
    {
        _S662 = false;
    }
    if(_S662)
    {
        float4  _S663 = b_9->rebar0_0;
        float4  _S664 = b_9->stiff0_0;
        *&(f_lin_0->z) = *&(f_lin_0->z) + fdiv_0(b_9->rebar0_0.x, b_9->stiff0_0.x);
        float _S665 = fdiv_0(_S663.y, _S664.y);
        *&(f_lin_0->x) = *&(f_lin_0->x) + _S665;
        *&(f_lin_0->y) = *&(f_lin_0->y) + _S665;
    }
    return;
}

static __device__ float3  to_body_0(uint _S666, float3  _S667)
{
    BondStatic_0 * _S668 = (&(globalParams_0->bonds_0)[_S666]);
    float4  _S669 = __ldg(&_S668->t1_0);
    float3  _S670 = float3 {_S669.x, _S669.y, _S669.z} * make_float3 (_S667.x);
    float4  _S671 = __ldg(&_S668->t2_0);
    float3  _S672 = _S670 + float3 {_S671.x, _S671.y, _S671.z} * make_float3 (_S667.y);
    float4  _S673 = __ldg(&_S668->normal_0);
    return _S672 + float3 {_S673.x, _S673.y, _S673.z} * make_float3 (_S667.z);
}

static __device__ void cov_or_0(uint island_0, uint bits_0)
{
    uint _S674 = atomicOr(&(&(globalParams_0->islands_0)[island_0])->coverage_0, bits_0);
    return;
}

static __device__ bool bond_update_0(uint i_9, float dt_10, bool fracture_2, uint abs_step_0, bool wide_0)
{
    BondStatic_0 * _S675 = (&(globalParams_0->bonds_0)[i_9]);
    JointBond_0 _S676 = slang_ldg_0(&_S675->law_0);
    uint ca_0 = _S676.ids_0.y;
    uint cb_0 = _S676.ids_0.z;
    float4  _S677 = __ldg(&_S675->ra_0);
    float3  ra_1 = float3 {_S677.x, _S677.y, _S677.z};
    float4  _S678 = __ldg(&_S675->rb_0);
    float3  rb_1 = float3 {_S678.x, _S678.y, _S678.z};
    uint _S679 = 4U * ca_0;
    float4  _S680 = *(&(globalParams_0->state_0)[_S679]);
    float4  _S681 = *(&(globalParams_0->state_0)[_S679 + 1U]);
    float3  ta_0 = float3 {_S681.x, _S681.y, _S681.z};
    float4  _S682 = *(&(globalParams_0->state_0)[_S679 + 2U]);
    float3  va_0 = float3 {_S682.x, _S682.y, _S682.z};
    float4  _S683 = *(&(globalParams_0->state_0)[_S679 + 3U]);
    float3  wa_0 = float3 {_S683.x, _S683.y, _S683.z};
    uint _S684 = 4U * cb_0;
    float4  _S685 = *(&(globalParams_0->state_0)[_S684]);
    float4  _S686 = *(&(globalParams_0->state_0)[_S684 + 1U]);
    float3  tb_0 = float3 {_S686.x, _S686.y, _S686.z};
    float4  _S687 = *(&(globalParams_0->state_0)[_S684 + 2U]);
    float3  vb_0 = float3 {_S687.x, _S687.y, _S687.z};
    float4  _S688 = *(&(globalParams_0->state_0)[_S684 + 3U]);
    float3  wb_0 = float3 {_S688.x, _S688.y, _S688.z};
    float3  _S689 = to_local_0(i_9, float3 {_S685.x, _S685.y, _S685.z} + cross_0(tb_0, rb_1) - (float3 {_S680.x, _S680.y, _S680.z} + cross_0(ta_0, ra_1)));
    float3  _S690 = to_local_0(i_9, tb_0 - ta_0);
    float3  _S691 = to_local_0(i_9, vb_0 + cross_0(wb_0, rb_1) - (va_0 + cross_0(wa_0, ra_1)));
    float3  _S692 = to_local_0(i_9, wb_0 - wa_0);
    JointBond_0 _S693 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_9])->law_0);
    JointState_0 previous_1 = (&(globalParams_0->bond_dyn_0)[i_9])->js_0;
    JointState_0 _S694 = (&(globalParams_0->bond_dyn_0)[i_9])->js_0;
    bool _S695 = is_damaged_0(&_S694);
    JointBond_0 _S696 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_9])->law_0);
    JointBond_0 _S697 = _S696;
    JointState_0 _S698 = (&(globalParams_0->bond_dyn_0)[i_9])->js_0;
    JointResponse_0 _S699 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S693.ids_0.x], &_S697, &_S698, _S689, _S690, dt_10, fracture_2);
    BondStatic_0 * _S700 = (&(globalParams_0->bonds_0)[i_9]);
    BondDyn_0 bd_0 = *(&(globalParams_0->bond_dyn_0)[i_9]);
    float4  _S701 = __ldg(&_S700->ra_0);
    float3  ra_2 = float3 {_S701.x, _S701.y, _S701.z};
    float4  _S702 = __ldg(&_S700->rb_0);
    float3  rb_2 = float3 {_S702.x, _S702.y, _S702.z};
    JointBond_0 _S703 = slang_ldg_0(&_S700->law_0);
    JointBond_0 _S704 = _S703;
    JointState_0 _S705 = _S699.state_1;
    float3  f_lin_1;
    float3  f_ang_1;
    secant_factors_0(&_S704, &_S705, _S689, &f_lin_1, &f_ang_1);
    float4  _S706 = __ldg(&_S700->c_lin_0);
    float3  qd_lin_0 = _S691 * float3 {_S706.x, _S706.y, _S706.z} * f_lin_1;
    float4  _S707 = __ldg(&_S700->c_ang_0);
    float3  qd_ang_0 = _S692 * float3 {_S707.x, _S707.y, _S707.z} * f_ang_1;
    float3  q_lin_2 = _S699.force_lin_1 + qd_lin_0;
    float3  q_ang_2 = _S699.force_ang_1 + qd_ang_0;
    float damped_0 = (dot_0(qd_lin_0, _S691) + dot_0(qd_ang_0, _S692)) * dt_10;
    float3  _S708 = to_body_0(i_9, q_lin_2);
    float3  _S709 = to_body_0(i_9, q_ang_2);
    uint _S710 = 3U * i_9;
    *(&(globalParams_0->scratch_0)[_S710]) = make_float4 (_S708.x, _S708.y, _S708.z, (F32_max((_S699.measures_0.tension_0), (_S699.measures_0.compression_0))));
    *(&(globalParams_0->scratch_0)[_S710 + 1U]) = make_float4 ((_S709 + cross_0(ra_2, _S708)).x, (_S709 + cross_0(ra_2, _S708)).y, (_S709 + cross_0(ra_2, _S708)).z, 0.0f);
    *(&(globalParams_0->scratch_0)[_S710 + 2U]) = make_float4 ((- _S709 + cross_0(rb_2, - _S708)).x, (- _S709 + cross_0(rb_2, - _S708)).y, (- _S709 + cross_0(rb_2, - _S708)).z, 0.0f);
    comp_add1_0(&((&(&bd_0)->sums_0)->x), &((&(&bd_0)->comps_0)->x), _S699.dissipated_1);
    comp_add1_0(&((&(&bd_0)->sums_0)->y), &((&(&bd_0)->comps_0)->y), _S699.overshoot_0);
    comp_add1_0(&((&(&bd_0)->sums_0)->z), &((&(&bd_0)->comps_0)->z), damped_0);
    (&bd_0)->force_lin_0 = make_float4 (q_lin_2.x, q_lin_2.y, q_lin_2.z, _S699.stored_0);
    (&bd_0)->force_ang_0 = make_float4 (q_ang_2.x, q_ang_2.y, q_ang_2.z, (F32_max(((&bd_0)->force_ang_0.w), (_S699.state_1.utilization_0))));
    bool _S711;
    if(!_S695)
    {
        JointState_0 _S712 = _S699.state_1;
        bool _S713 = is_damaged_0(&_S712);
        _S711 = _S713;
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        _S711 = ((&bd_0)->events_0.x) == 0U;
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        *&((&(&bd_0)->events_0)->x) = abs_step_0;
        *&((&(&bd_0)->events_0)->w) = _S699.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S703.ids_0.w, 32U);
        }
        else
        {
            (*&g_seen_0)[3U] = 1U;
        }
    }
    if(((&bd_0)->events_0.y) == 0U)
    {
        _S711 = (_S699.state_1.life_0) != (previous_1.life_0);
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        _S711 = (_S699.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        float _S714 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S693.ids_0.x], _S699.state_1.life_0);
        _S711 = _S714 <= 0.99000000953674316f;
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        *&((&(&bd_0)->events_0)->y) = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S703.ids_0.w, 64U);
        }
        else
        {
            (*&g_seen_0)[4U] = 1U;
        }
    }
    if(_S699.disconnected_0)
    {
        *&((&(&bd_0)->events_0)->z) = abs_step_0;
    }
    (&bd_0)->js_0 = _S699.state_1;
    *(&(globalParams_0->bond_dyn_0)[i_9]) = bd_0;
    return _S699.disconnected_0;
}

static __device__ void island_frame_at_1(uint gi_1, uint tid_5, uint _S715)
{
    bool woke_2;
    uint _S716;
    uint _S717;
    uint _S718;
    uint _S719;
    uint _S720;
    uint _S721;
    Island_0 isl_10 = *(&(globalParams_0->islands_0)[gi_1]);
    bool driven_1 = (((&isl_10)->info_1.x) & 2U) != 0U;
    bool _S722 = !((((&isl_10)->info_1.x) & 1U) != 0U);
    uint _S723 = __ballot_sync(_S715, _S722);
    bool _S724;
    uint cov_5;
    if(_S722)
    {
        bool _S725 = !driven_1;
        uint _S726 = __ballot_sync(_S715, true);
        _S724 = _S725;
        cov_5 = _S726;
    }
    else
    {
        uint _S727 = __ballot_sync(_S715, true);
        _S724 = false;
        cov_5 = _S727;
    }
    bool contact_island_1 = (((&isl_10)->info_1.x) & 4U) != 0U;
    bool _S728 = (((&isl_10)->info_1.x) & 16U) != 0U;
    seen_clear_0(tid_5);
    bool _S729 = tid_5 == 0U;
    uint _S730 = __ballot_sync(cov_5, _S729);
    bool settled_1;
    uint run_1;
    uint done_2;
    if(_S729)
    {
        uint _S731 = __ldg(&globalParams_0->params_0->contact_mode_0);
        bool _S732 = contact_island_1 != (_S731 == 1U);
        uint _S733 = __ballot_sync(_S730, _S732);
        if(_S732)
        {
            uint _S734 = __ballot_sync(_S730, true);
            settled_1 = true;
            run_1 = _S734;
        }
        else
        {
            bool _S735 = (((&isl_10)->info_1.x) & 8U) != 0U;
            uint _S736 = __ballot_sync(_S730, true);
            settled_1 = _S735;
            run_1 = _S736;
        }
        uint _S737 = __ballot_sync(run_1, settled_1);
        if(settled_1)
        {
            uint _S738 = __ballot_sync(run_1, true);
            run_1 = 0U;
            done_2 = _S738;
        }
        else
        {
            uint _S739 = __ballot_sync(run_1, true);
            run_1 = 1U;
            done_2 = _S739;
        }
        uint _S740 = __ballot_sync(done_2, contact_island_1);
        if(contact_island_1)
        {
            Island_0 _S741 = isl_10;
            bool _S742 = contact_stopped_0(&_S741);
            uint _S743 = __ballot_sync(done_2, true);
            settled_1 = _S742;
            done_2 = _S743;
        }
        else
        {
            uint _S744 = __ballot_sync(done_2, true);
            settled_1 = false;
            done_2 = _S744;
        }
        uint _S745 = __ballot_sync(done_2, settled_1);
        if(settled_1)
        {
            uint _S746 = __ballot_sync(done_2, true);
            run_1 = 0U;
        }
        else
        {
            uint _S747 = __ballot_sync(done_2, true);
        }
        *&g_run_0 = run_1;
        *&g_halt_0 = 0U;
        uint _S748 = __ballot_sync(cov_5, true);
        cov_5 = _S748;
    }
    else
    {
        uint _S749 = __ballot_sync(cov_5, true);
        cov_5 = _S749;
    }
    __syncthreads();
    bool _S750 = (((&isl_10)->info_1.z) & 1U) != 0U;
    uint _S751 = __ballot_sync(cov_5, _S750);
    if(_S750)
    {
        uint _S752 = __ballot_sync(cov_5, true);
        settled_1 = true;
        cov_5 = _S752;
    }
    else
    {
        bool _S753 = (*&g_run_0) == 0U;
        uint _S754 = __ballot_sync(cov_5, true);
        settled_1 = _S753;
        cov_5 = _S754;
    }
    uint _S755 = __ballot_sync(cov_5, settled_1);
    if(settled_1)
    {
        uint _S756 = __ballot_sync(cov_5, true);
        cov_5 = 0U;
        run_1 = _S756;
    }
    else
    {
        uint _S757 = (&isl_10)->info_1.y;
        uint _S758 = __ldg(&globalParams_0->params_0->max_steps_0);
        uint _S759 = (U32_min((_S757), (_S758)));
        uint _S760 = __ballot_sync(cov_5, true);
        cov_5 = _S759;
        run_1 = _S760;
    }
    float _S761 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S762 = __ldg(&globalParams_0->params_0->fracture_0);
    bool _S763 = _S762 != 0U;
    uint _S764 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
    bool _S765 = _S764 != 0U;
    Island_0 _S766 = isl_10;
    Rigid_0 _S767 = rigid_of_0(&_S766);
    Rigid_0 rg_8 = _S767;
    float work_3 = 0.0f;
    float work_err_2 = 0.0f;
    settled_1 = _S728;
    done_2 = 0U;
    bool woke_3 = false;
    bool resumed_2 = false;
    uint _S768 = run_1;
    for(;;)
    {
        uint _S769 = 0U;
        bool _S770 = done_2 < cov_5;
        uint _S771 = __ballot_sync(_S768, _S770);
        if(_S770)
        {
            uint _S772 = __ballot_sync(_S768, true);
            _S769 = _S772;
        }
        else
        {
            uint _S773 = __ballot_sync(_S768, false);
            uint _S774 = __ballot_sync(_S768, false);
            uint _S775 = __ballot_sync(run_1, true);
            woke_2 = woke_3;
            cov_5 = _S775;
            break;
        }
        uint abs_step_1 = (&isl_10)->info_1.w + done_2 + 1U;
        uint _S776 = abs_step_1 - 1U;
        uint _S777 = __ldg(&globalParams_0->params_0->step_start_0);
        uint k_9 = _S776 - _S777;
        bool quiet_2 = (((&isl_10)->info_1.x) & 32U) != 0U;
        uint _S778 = __ballot_sync(_S769, settled_1);
        bool _S779;
        uint _S780;
        if(settled_1)
        {
            bool _S781 = !quiet_2;
            uint _S782 = __ballot_sync(_S769, true);
            _S779 = _S781;
            _S780 = _S782;
        }
        else
        {
            uint _S783 = __ballot_sync(_S769, true);
            _S779 = false;
            _S780 = _S783;
        }
        uint _S784 = __ballot_sync(_S780, _S779);
        bool _S785;
        bool explicit_step_1;
        uint c_16;
        uint _S786;
        uint c_17;
        if(_S779)
        {
            float3  _S787 = make_float3 (0.0f);
            float3  norm_1 = _S787;
            float3  unused0_1 = _S787;
            c_16 = (&isl_10)->range_0.x + tid_5;
            _S786 = _S784;
            for(;;)
            {
                bool _S788 = c_16 < ((&isl_10)->range_0.y);
                uint _S789 = __ballot_sync(_S786, _S788);
                if(_S788)
                {
                    uint _S790 = __ballot_sync(_S786, true);
                }
                else
                {
                    uint _S791 = __ballot_sync(_S786, false);
                    uint _S792 = __ballot_sync(_S786, false);
                    uint _S793 = __ballot_sync(_S784, true);
                    _S716 = _S793;
                    break;
                }
                Quat_0 _S794 = (&rg_8)->rot_0;
                float _S795 = settled_chunk_load_0(c_16, &_S794, k_9, _S761, contact_island_1);
                *&((&norm_1)->x) = *&((&norm_1)->x) + _S795;
                uint _S796 = __ballot_sync(_S786, true);
                c_16 = c_16 + 256U;
                _S786 = _S796;
            }
            group_sum3_0(tid_5, &norm_1, &unused0_1, _S716);
            uint _S797 = __ldg(&globalParams_0->params_0->solve_mode_0);
            bool _S798 = _S797 == 1U;
            uint _S799 = __ballot_sync(_S716, _S798);
            if(_S798)
            {
                bool _S800 = (F32_abs((norm_1.x - (&isl_10)->energy_1.z))) > ((&isl_10)->energy_1.w);
                uint _S801 = __ballot_sync(_S716, true);
                _S785 = _S800;
                c_17 = _S801;
            }
            else
            {
                uint _S802 = __ballot_sync(_S716, true);
                _S785 = false;
                c_17 = _S802;
            }
            uint _S803 = __ballot_sync(c_17, _S785);
            if(_S785)
            {
                uint _S804 = __ballot_sync(c_17, true);
                explicit_step_1 = false;
                woke_2 = true;
            }
            else
            {
                uint _S805 = __ballot_sync(c_17, true);
                explicit_step_1 = settled_1;
                woke_2 = woke_3;
            }
            uint _S806 = __ballot_sync(_S780, true);
            settled_1 = explicit_step_1;
            c_16 = _S806;
        }
        else
        {
            uint _S807 = __ballot_sync(_S780, true);
            woke_2 = woke_3;
            c_16 = _S807;
        }
        uint _S808 = __ballot_sync(c_16, _S722);
        if(_S722)
        {
            bool _S809 = !quiet_2;
            uint _S810 = __ballot_sync(c_16, true);
            _S785 = _S809;
            _S786 = _S810;
        }
        else
        {
            uint _S811 = __ballot_sync(c_16, true);
            _S785 = false;
            _S786 = _S811;
        }
        uint _S812 = __ballot_sync(_S786, _S785);
        uint _S813;
        if(_S785)
        {
            float3  _S814 = make_float3 (0.0f);
            float3  f_10 = _S814;
            float3  t_11 = _S814;
            c_17 = (&isl_10)->range_0.x + tid_5;
            _S813 = _S812;
            for(;;)
            {
                bool _S815 = c_17 < ((&isl_10)->range_0.y);
                uint _S816 = __ballot_sync(_S813, _S815);
                if(_S815)
                {
                    uint _S817 = __ballot_sync(_S813, true);
                }
                else
                {
                    uint _S818 = __ballot_sync(_S813, false);
                    uint _S819 = __ballot_sync(_S813, false);
                    uint _S820 = __ballot_sync(_S812, true);
                    _S717 = _S820;
                    break;
                }
                Island_0 _S821 = isl_10;
                Rigid_0 _S822 = rg_8;
                net_load_0(c_17, &_S821, &_S822, k_9, _S761, contact_island_1, &f_10, &t_11);
                uint _S823 = __ballot_sync(_S813, true);
                c_17 = c_17 + 256U;
                _S813 = _S823;
            }
            group_sum3_0(tid_5, &f_10, &t_11, _S717);
            Island_0 _S824 = isl_10;
            rigid_acceleration_0(&_S824, &rg_8, f_10, t_11);
            uint _S825 = __ballot_sync(_S786, true);
            c_17 = _S825;
        }
        else
        {
            uint _S826 = __ballot_sync(_S786, true);
            c_17 = _S826;
        }
        bool _S827 = !settled_1;
        uint _S828 = __ballot_sync(c_17, _S827);
        if(_S827)
        {
            bool _S829 = !quiet_2;
            uint _S830 = __ballot_sync(c_17, true);
            explicit_step_1 = _S829;
            _S813 = _S830;
        }
        else
        {
            uint _S831 = __ballot_sync(c_17, true);
            explicit_step_1 = false;
            _S813 = _S831;
        }
        uint _S832 = __ballot_sync(_S813, explicit_step_1);
        uint i_10;
        uint _S833;
        uint c_18;
        uint _S834;
        if(explicit_step_1)
        {
            i_10 = (&isl_10)->range_0.z + tid_5;
            _S833 = _S832;
            for(;;)
            {
                uint _S835 = 0U;
                bool _S836 = i_10 < ((&isl_10)->range_0.w);
                uint _S837 = __ballot_sync(_S833, _S836);
                if(_S836)
                {
                    uint _S838 = __ballot_sync(_S833, true);
                    _S835 = _S838;
                }
                else
                {
                    uint _S839 = __ballot_sync(_S833, false);
                    uint _S840 = __ballot_sync(_S833, false);
                    uint _S841 = __ballot_sync(_S832, true);
                    _S718 = _S841;
                    break;
                }
                bool _S842 = bond_update_0(i_10, _S761, _S763, abs_step_1, false);
                uint _S843 = __ballot_sync(_S835, _S842);
                if(_S842)
                {
                    *&g_halt_0 = 1U;
                    uint _S844 = __ballot_sync(_S835, true);
                }
                else
                {
                    uint _S845 = __ballot_sync(_S835, true);
                }
                uint _S846 = __ballot_sync(_S833, true);
                i_10 = i_10 + 256U;
                _S833 = _S846;
            }
            __syncthreads();
            c_18 = (&isl_10)->range_0.x + tid_5;
            _S834 = _S718;
            for(;;)
            {
                bool _S847 = c_18 < ((&isl_10)->range_0.y);
                uint _S848 = __ballot_sync(_S834, _S847);
                if(_S847)
                {
                    uint _S849 = __ballot_sync(_S834, true);
                }
                else
                {
                    uint _S850 = __ballot_sync(_S834, false);
                    uint _S851 = __ballot_sync(_S834, false);
                    uint _S852 = __ballot_sync(_S718, true);
                    break;
                }
                Island_0 _S853 = isl_10;
                Rigid_0 _S854 = rg_8;
                chunk_update_0(c_18, &_S853, &_S854, _S761, _S765, k_9, contact_island_1, &work_3, &work_err_2);
                uint _S855 = __ballot_sync(_S834, true);
                c_18 = c_18 + 256U;
                _S834 = _S855;
            }
            __syncthreads();
            uint _S856 = __ballot_sync(_S813, true);
            i_10 = _S856;
        }
        else
        {
            uint _S857 = __ballot_sync(_S813, true);
            i_10 = _S857;
        }
        uint _S858 = __ballot_sync(i_10, _S724);
        bool _S859;
        if(_S724)
        {
            bool _S860 = !quiet_2;
            uint _S861 = __ballot_sync(i_10, true);
            _S859 = _S860;
            _S833 = _S861;
        }
        else
        {
            uint _S862 = __ballot_sync(i_10, true);
            _S859 = false;
            _S833 = _S862;
        }
        uint _S863 = __ballot_sync(_S833, _S859);
        if(_S859)
        {
            Island_0 _S864 = isl_10;
            integrate_rigid_0(&_S864, &rg_8, _S761);
            uint _S865 = __ballot_sync(_S833, true);
            c_18 = _S865;
        }
        else
        {
            uint _S866 = __ballot_sync(_S833, true);
            c_18 = _S866;
        }
        uint _S867 = __ballot_sync(c_18, _S722);
        bool _S868;
        if(_S722)
        {
            uint _S869 = __ballot_sync(c_18, true);
            _S868 = explicit_step_1;
            _S834 = _S869;
        }
        else
        {
            uint _S870 = __ballot_sync(c_18, true);
            _S868 = false;
            _S834 = _S870;
        }
        uint _S871 = __ballot_sync(_S834, _S868);
        uint c_19;
        uint _S872;
        uint c_20;
        uint _S873;
        uint c_21;
        if(_S868)
        {
            float4  _S874 = (&isl_10)->wcom_0;
            float3  _S875 = float3 {_S874.x, _S874.y, _S874.z};
            float3  _S876 = make_float3 (0.0f);
            float3  tu_2 = _S876;
            float3  pv_2 = _S876;
            c_19 = (&isl_10)->range_0.x + tid_5;
            _S872 = _S871;
            for(;;)
            {
                bool _S877 = c_19 < ((&isl_10)->range_0.y);
                uint _S878 = __ballot_sync(_S872, _S877);
                if(_S877)
                {
                    uint _S879 = __ballot_sync(_S872, true);
                }
                else
                {
                    uint _S880 = __ballot_sync(_S872, false);
                    uint _S881 = __ballot_sync(_S872, false);
                    uint _S882 = __ballot_sync(_S871, true);
                    _S719 = _S882;
                    break;
                }
                drift_moments_0(c_19, &tu_2, &pv_2);
                uint _S883 = __ballot_sync(_S872, true);
                c_19 = c_19 + 256U;
                _S872 = _S883;
            }
            group_sum3_0(tid_5, &tu_2, &pv_2, _S719);
            float3  tr_4 = tu_2 / make_float3 ((&isl_10)->wcom_0.w);
            float3  dv_4 = pv_2 / make_float3 ((&isl_10)->wcom_0.w);
            float3  lu_2 = _S876;
            float3  lv_2 = _S876;
            c_20 = (&isl_10)->range_0.x + tid_5;
            _S873 = _S719;
            for(;;)
            {
                bool _S884 = c_20 < ((&isl_10)->range_0.y);
                uint _S885 = __ballot_sync(_S873, _S884);
                if(_S884)
                {
                    uint _S886 = __ballot_sync(_S873, true);
                }
                else
                {
                    uint _S887 = __ballot_sync(_S873, false);
                    uint _S888 = __ballot_sync(_S873, false);
                    uint _S889 = __ballot_sync(_S719, true);
                    _S720 = _S889;
                    break;
                }
                drift_angular_0(c_20, _S875, tr_4, dv_4, &lu_2, &lv_2);
                uint _S890 = __ballot_sync(_S873, true);
                c_20 = c_20 + 256U;
                _S873 = _S890;
            }
            group_sum3_0(tid_5, &lu_2, &lv_2, _S720);
            float3  phi_4 = rows_mul_0((&isl_10)->winv0_0, (&isl_10)->winv1_0, (&isl_10)->winv2_0, lu_2);
            float3  dw_3 = rows_mul_0((&isl_10)->winv0_0, (&isl_10)->winv1_0, (&isl_10)->winv2_0, lv_2);
            c_21 = (&isl_10)->range_0.x + tid_5;
            uint _S891 = _S720;
            for(;;)
            {
                bool _S892 = c_21 < ((&isl_10)->range_0.y);
                uint _S893 = __ballot_sync(_S891, _S892);
                if(_S892)
                {
                    uint _S894 = __ballot_sync(_S891, true);
                }
                else
                {
                    uint _S895 = __ballot_sync(_S891, false);
                    uint _S896 = __ballot_sync(_S891, false);
                    uint _S897 = __ballot_sync(_S720, true);
                    _S721 = _S897;
                    break;
                }
                drift_apply_0(c_21, _S875, tr_4, phi_4, dv_4, dw_3);
                uint _S898 = __ballot_sync(_S891, true);
                c_21 = c_21 + 256U;
                _S891 = _S898;
            }
            bool _S899 = !driven_1;
            uint _S900 = __ballot_sync(_S721, _S899);
            if(_S899)
            {
                Island_0 _S901 = isl_10;
                drift_rigid_0(&_S901, &rg_8, tr_4, phi_4, dv_4, dw_3);
                uint _S902 = __ballot_sync(_S721, true);
            }
            else
            {
                uint _S903 = __ballot_sync(_S721, true);
            }
            __syncthreads();
            uint _S904 = __ballot_sync(_S834, true);
            c_19 = _S904;
        }
        else
        {
            uint _S905 = __ballot_sync(_S834, true);
            c_19 = _S905;
        }
        uint _S906 = __ballot_sync(c_19, _S729);
        bool _S907;
        if(_S729)
        {
            bool _S908 = ((&isl_10)->probes_0.y) > ((&isl_10)->probes_0.x);
            uint _S909 = __ballot_sync(c_19, true);
            _S907 = _S908;
            _S872 = _S909;
        }
        else
        {
            uint _S910 = __ballot_sync(c_19, true);
            _S907 = false;
            _S872 = _S910;
        }
        uint _S911 = __ballot_sync(_S872, _S907);
        if(_S907)
        {
            Island_0 _S912 = isl_10;
            Rigid_0 _S913 = rg_8;
            record_probes_0(&_S912, &_S913, k_9);
            uint _S914 = __ballot_sync(_S872, true);
            c_20 = _S914;
        }
        else
        {
            uint _S915 = __ballot_sync(_S872, true);
            c_20 = _S915;
        }
        uint _S916 = done_2 + 1U;
        bool _S917 = (*&g_halt_0) != 0U;
        uint _S918 = __ballot_sync(c_20, _S917);
        bool _S919;
        if(_S917)
        {
            Island_0 _S920 = isl_10;
            bool _S921 = island_connected_narrow_0(tid_5, &_S920);
            uint _S922 = __ballot_sync(c_20, true);
            _S919 = _S921;
            _S873 = _S922;
        }
        else
        {
            uint _S923 = __ballot_sync(c_20, true);
            _S919 = false;
            _S873 = _S923;
        }
        uint _S924 = __ballot_sync(_S873, _S919);
        bool resumed_3;
        if(_S919)
        {
            uint _S925 = __ballot_sync(_S924, _S729);
            if(_S729)
            {
                *&g_halt_0 = 0U;
                uint _S926 = __ballot_sync(_S924, true);
            }
            else
            {
                uint _S927 = __ballot_sync(_S924, true);
            }
            __syncthreads();
            uint _S928 = __ballot_sync(_S873, true);
            resumed_3 = true;
            c_21 = _S928;
        }
        else
        {
            uint _S929 = __ballot_sync(_S873, true);
            resumed_3 = resumed_2;
            c_21 = _S929;
        }
        bool _S930 = (*&g_halt_0) != 0U;
        uint _S931 = __ballot_sync(c_21, _S930);
        if(_S930)
        {
            uint _S932 = __ballot_sync(c_21, false);
            uint _S933 = __ballot_sync(_S768, false);
            uint _S934 = __ballot_sync(run_1, true);
            done_2 = _S916;
            resumed_2 = resumed_3;
            cov_5 = _S934;
            break;
        }
        else
        {
            uint _S935 = __ballot_sync(c_21, true);
        }
        uint _S936 = __ballot_sync(_S768, true);
        done_2 = _S916;
        woke_3 = woke_2;
        resumed_2 = resumed_3;
        _S768 = _S936;
    }
    float3  wsum_1 = make_float3 (work_3, work_err_2, 0.0f);
    float3  unused_1 = make_float3 (0.0f);
    group_sum3_0(tid_5, &wsum_1, &unused_1, cov_5);
    uint _S937 = __ballot_sync(cov_5, _S729);
    if(_S729)
    {
        Quat_0 _S938 = (&rg_8)->rot_0;
        float4  _S939 = quat_vec_0(&_S938);
        (&isl_10)->rotation_0 = _S939;
        (&isl_10)->rotation_err_0 = (&rg_8)->rot_err_0;
        (&isl_10)->position_0 = make_float4 ((&rg_8)->pos_0.x, (&rg_8)->pos_0.y, (&rg_8)->pos_0.z, 0.0f);
        (&isl_10)->position_err_0 = make_float4 ((&rg_8)->pos_err_0.x, (&rg_8)->pos_err_0.y, (&rg_8)->pos_err_0.z, 0.0f);
        (&isl_10)->velocity_0 = make_float4 ((&rg_8)->vel_0.x, (&rg_8)->vel_0.y, (&rg_8)->vel_0.z, 0.0f);
        (&isl_10)->velocity_err_0 = make_float4 ((&rg_8)->vel_err_0.x, (&rg_8)->vel_err_0.y, (&rg_8)->vel_err_0.z, 0.0f);
        (&isl_10)->angular_velocity_0 = make_float4 ((&rg_8)->w_1.x, (&rg_8)->w_1.y, (&rg_8)->w_1.z, 0.0f);
        (&isl_10)->momentum_0 = make_float4 ((&rg_8)->l_0.x, (&rg_8)->l_0.y, (&rg_8)->l_0.z, 0.0f);
        (&isl_10)->momentum_err_0 = make_float4 ((&rg_8)->l_err_0.x, (&rg_8)->l_err_0.y, (&rg_8)->l_err_0.z, 0.0f);
        (&isl_10)->done_0 = done_2;
        *&((&(&isl_10)->info_1)->y) = *&((&(&isl_10)->info_1)->y) - done_2;
        if((*&g_halt_0) != 0U)
        {
            _S724 = contact_island_1;
        }
        else
        {
            _S724 = false;
        }
        if(_S724)
        {
            contact_split_at_0((&isl_10)->info_1.w + done_2);
        }
        comp_add1_0(&((&(&isl_10)->energy_1)->x), &((&(&isl_10)->energy_1)->y), wsum_1.x);
        *&((&(&isl_10)->energy_1)->y) = *&((&(&isl_10)->energy_1)->y) + wsum_1.y;
        *&((&(&isl_10)->info_1)->w) = *&((&(&isl_10)->info_1)->w) + done_2;
        if((((&isl_10)->info_1.x) & 8U) == 0U)
        {
            *&((&(&isl_10)->info_1)->z) = (*&((&(&isl_10)->info_1)->z)) & 4294967293U;
        }
        if((*&g_halt_0) != 0U)
        {
            *&((&(&isl_10)->info_1)->z) = (*&((&(&isl_10)->info_1)->z)) | 1U;
        }
        uint _S940 = seen_bits_0();
        if((*&g_halt_0) != 0U)
        {
            cov_5 = 128U;
        }
        else
        {
            cov_5 = 0U;
        }
        uint _S941 = _S940 | cov_5;
        if(woke_2)
        {
            cov_5 = 2048U;
        }
        else
        {
            cov_5 = 0U;
        }
        uint _S942 = _S941 | cov_5;
        if(resumed_2)
        {
            cov_5 = 2097280U;
        }
        else
        {
            cov_5 = 0U;
        }
        uint cov_6 = _S942 | cov_5;
        if(done_2 > 0U)
        {
            bool quiet_3 = (((&isl_10)->info_1.x) & 32U) != 0U;
            if(quiet_3)
            {
                cov_5 = 4096U;
            }
            else
            {
                cov_5 = 0U;
            }
            uint cov_7 = cov_6 | cov_5;
            if((((&isl_10)->info_1.x) & 16U) != 0U)
            {
                _S724 = !quiet_3;
            }
            else
            {
                _S724 = false;
            }
            if(_S724)
            {
                cov_5 = 512U;
            }
            else
            {
                cov_5 = 0U;
            }
            uint cov_8 = cov_7 | cov_5;
            uint _S943 = __ldg(&globalParams_0->params_0->contact_mode_0);
            if(_S943 == 1U)
            {
                cov_5 = 524288U;
            }
            else
            {
                cov_5 = 0U;
            }
            uint cov_9 = cov_8 | cov_5;
            if(((&isl_10)->probes_0.y) > ((&isl_10)->probes_0.x))
            {
                cov_5 = 262144U;
            }
            else
            {
                cov_5 = 0U;
            }
            cov_5 = cov_9 | cov_5;
        }
        else
        {
            cov_5 = cov_6;
        }
        (&isl_10)->coverage_0 = ((&isl_10)->coverage_0) | cov_5;
        if(woke_2)
        {
            *&((&(&isl_10)->info_1)->x) = (*&((&(&isl_10)->info_1)->x)) & 4294967279U;
            *&((&(&isl_10)->info_1)->z) = (*&((&(&isl_10)->info_1)->z)) | 4U;
        }
        *(&(globalParams_0->islands_0)[gi_1]) = isl_10;
    }
    return;
}

static __device__ float3  min_0(float3  x_16, float3  y_4)
{
    float3  result_4;
    int i_11 = int(0);
    for(;;)
    {
        if(i_11 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_4, i_11) = (F32_min((_slang_vector_get_element(x_16, i_11)), (_slang_vector_get_element(y_4, i_11))));
        i_11 = i_11 + int(1);
    }
    return result_4;
}

static __device__ float3  clamp_1(float3  x_17, float3  minBound_1, float3  maxBound_1)
{
    return min_0(max_0(x_17, minBound_1), maxBound_1);
}

static __device__ bool any_0(bool3  x_18)
{
    bool result_5 = false;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(3))
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
            result_5 = (bool((_slang_vector_get_element(x_18, i_12))));
        }
        i_12 = i_12 + int(1);
    }
    return result_5;
}

static __device__ float WaveActiveSum_1(float expr_1, uint _S944)
{
    float _S945 = (_waveSum((make_uint4 (WaveGetActiveMask_0(_S944), 0U, 0U, 0U)).x, (expr_1)));
    return _S945;
}

static __device__ float3  WaveActiveSum_2(float3  expr_2, uint _S946)
{
    float3  _S947 = (_waveSumMultiple((make_uint4 (WaveGetActiveMask_0(_S946), 0U, 0U, 0U)).x, (expr_2)));
    return _S947;
}

static __device__ uint WaveActiveSum_3(uint expr_3, uint _S948)
{
    uint _S949 = (_waveSum((make_uint4 (WaveGetActiveMask_0(_S948), 0U, 0U, 0U)).x, (expr_3)));
    return _S949;
}

static __device__ uint pair_lane_count_0()
{
    uint _S950 = __ldg(&globalParams_0->params_0->pair_lanes_0);
    return (U32_max((_S950), (1U)));
}

static __device__ bool stopped_0()
{
    uint _S951 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint4  _S952 = (&(globalParams_0->islands_0)[_S951])->info_1;
    bool _S953;
    if((((&(globalParams_0->islands_0)[_S951])->info_1.z) & 1U) != 0U)
    {
        _S953 = true;
    }
    else
    {
        _S953 = (_S952.y) != 0U;
    }
    return _S953;
}

static __device__ bool WaveActiveAnyTrue_0(bool condition_0, uint _S954)
{
    bool _S955 = ((__any_sync((WaveGetActiveMask_0(_S954)), (condition_0)) != 0));
    return _S955;
}

static __device__ bool pair_any_0(bool x_19, uint lanes_0, uint _S956)
{
    bool _S957 = lanes_0 > 1U;
    uint _S958 = __ballot_sync(_S956, _S957);
    bool _S959;
    if(_S957)
    {
        bool _S960 = WaveActiveAnyTrue_0(x_19, _S958);
        uint _S961 = __ballot_sync(_S956, true);
        _S959 = _S960;
    }
    else
    {
        _S959 = x_19;
    }
    return _S959;
}

struct WorldPoint_0
{
    float3  hi_3;
    float3  lo_3;
    float3  rel_0;
};

static __device__ WorldPoint_0 chunk_world_0(uint c_22)
{
    ChunkStatic_0 * _S962 = (&(globalParams_0->chunks_0)[c_22]);
    uint4  _S963 = __ldg(&_S962->info_0);
    Island_0 * _S964 = (&(globalParams_0->islands_0)[_S963.y]);
    Quat_0 q_5 = quat_of_0(_S964->rotation_0);
    WorldPoint_0 w_6;
    float4  _S965 = _S964->position_0;
    (&w_6)->hi_3 = float3 {_S965.x, _S965.y, _S965.z};
    float4  _S966 = _S964->position_err_0;
    (&w_6)->lo_3 = float3 {_S966.x, _S966.y, _S966.z};
    float4  _S967 = __ldg(&_S962->center_0);
    float4  _S968 = *(&(globalParams_0->state_0)[4U * c_22]);
    float3  _S969 = float3 {_S967.x, _S967.y, _S967.z} + float3 {_S968.x, _S968.y, _S968.z};
    Quat_0 _S970 = q_5;
    float3  _S971 = rotate_0(&_S970, _S969);
    (&w_6)->rel_0 = _S971;
    return w_6;
}

static __device__ float3  world_diff_0(WorldPoint_0 * a_11, WorldPoint_0 * b_10)
{
    return a_11->hi_3 - b_10->hi_3 + (a_11->lo_3 - b_10->lo_3) + (a_11->rel_0 - b_10->rel_0);
}

static __device__ float3  safe_normalize_0(float3  v_9)
{
    float n_1 = length_0(v_9);
    float3  _S972;
    if(n_1 > 1.00000000317107685e-30f)
    {
        _S972 = v_9 / make_float3 (n_1);
    }
    else
    {
        _S972 = make_float3 (0.0f);
    }
    return _S972;
}

static __device__ Quat_0 from_axis_angle_0(float3  axis_1, float angle_4)
{
    float3  a_12 = safe_normalize_0(axis_1);
    float _S973 = 0.5f * angle_4;
    float s_4 = (F32_sin((_S973)));
    Quat_0 q_6;
    (&q_6)->w_0 = (F32_cos((_S973)));
    (&q_6)->x_1 = a_12.x * s_4;
    (&q_6)->y_1 = a_12.y * s_4;
    (&q_6)->z_0 = a_12.z * s_4;
    return q_6;
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

static __device__ Box_0 chunk_box_0(uint c_23, float3  center_2)
{
    ChunkStatic_0 * _S974 = (&(globalParams_0->chunks_0)[c_23]);
    uint4  _S975 = __ldg(&_S974->info_0);
    Quat_0 q_7 = quat_of_0((&(globalParams_0->islands_0)[_S975.y])->rotation_0);
    float4  _S976 = *(&(globalParams_0->state_0)[4U * c_23 + 1U]);
    float3  th_3 = float3 {_S976.x, _S976.y, _S976.z};
    Quat_0 hidden_0 = from_axis_angle_0(th_3, length_0(th_3));
    Box_0 b_11;
    (&b_11)->center_1 = center_2;
    float4  _S977 = __ldg(&_S974->crot0_0);
    float _S978 = _S977.x;
    float4  _S979 = __ldg(&_S974->crot1_0);
    float _S980 = _S979.x;
    float4  _S981 = __ldg(&_S974->crot2_0);
    float3  _S982 = make_float3 (_S978, _S980, _S981.x);
    Quat_0 _S983 = hidden_0;
    float3  _S984 = rotate_0(&_S983, _S982);
    Quat_0 _S985 = q_7;
    float3  _S986 = rotate_0(&_S985, _S984);
    (&b_11)->axis0_0 = _S986;
    float3  _S987 = make_float3 (_S977.y, _S979.y, _S981.y);
    Quat_0 _S988 = hidden_0;
    float3  _S989 = rotate_0(&_S988, _S987);
    Quat_0 _S990 = q_7;
    float3  _S991 = rotate_0(&_S990, _S989);
    (&b_11)->axis1_0 = _S991;
    float3  _S992 = make_float3 (_S977.z, _S979.z, _S981.z);
    Quat_0 _S993 = hidden_0;
    float3  _S994 = rotate_0(&_S993, _S992);
    Quat_0 _S995 = q_7;
    float3  _S996 = rotate_0(&_S995, _S994);
    (&b_11)->axis2_0 = _S996;
    float4  _S997 = __ldg(&_S974->half_0);
    (&b_11)->half_2 = float3 {_S997.x, _S997.y, _S997.z};
    float4  _S998 = __ldg(&_S974->cmat_0);
    (&b_11)->hull_at_0 = (F32_asuint((_S998.z)));
    uint _S999 = (F32_asuint((_S998.w)));
    (&b_11)->hull_v_0 = _S999 & 255U;
    (&b_11)->hull_f_0 = _S999 >> int(8);
    return b_11;
}

static __device__ uint sample_count_0(Box_0 * b_12)
{
    uint _S1000 = b_12->hull_v_0;
    uint _S1001;
    if((b_12->hull_v_0) == 0U)
    {
        _S1001 = 14U;
    }
    else
    {
        _S1001 = _S1000 + b_12->hull_f_0;
    }
    return _S1001;
}

static __device__ bool may_overlap_lanes_0(Box_0 * a_13, Box_0 * b_13, uint lane_0, uint lanes_1, uint _S1002)
{
    uint _S1003;
    bool separated_0 = false;
    uint i_13 = lane_0;
    uint _S1004 = _S1002;
    for(;;)
    {
        uint _S1005 = 0U;
        bool _S1006 = i_13 < 15U;
        uint _S1007 = __ballot_sync(_S1004, _S1006);
        if(_S1006)
        {
            uint _S1008 = __ballot_sync(_S1004, true);
            _S1005 = _S1008;
        }
        else
        {
            uint _S1009 = __ballot_sync(_S1004, false);
            uint _S1010 = __ballot_sync(_S1004, false);
            uint _S1011 = __ballot_sync(_S1002, true);
            _S1003 = _S1011;
            break;
        }
        float3  d_2 = b_13->center_1 - a_13->center_1;
        float3  _S1012 = a_13->half_2;
        float3  _S1013 = b_13->half_2;
        float margin_0 = 0.00000999999974738f * (length_0(a_13->half_2) + length_0(b_13->half_2));
        float3  _S1014 = a_13->axis0_0;
        float3  _S1015 = a_13->axis1_0;
        float3  _S1016 = a_13->axis2_0;
        float3  _S1017 = b_13->axis0_0;
        float3  _S1018 = b_13->axis1_0;
        float3  _S1019 = b_13->axis2_0;
        FixedArray<float3 , 6>  axes_0 = { {
            a_13->axis0_0, a_13->axis1_0, a_13->axis2_0, b_13->axis0_0, b_13->axis1_0, b_13->axis2_0
        } };
        bool _S1020 = i_13 < 6U;
        uint _S1021 = __ballot_sync(_S1005, _S1020);
        uint _S1022;
        float3  l_3;
        if(_S1020)
        {
            uint _S1023 = i_13;
            uint _S1024 = __ballot_sync(_S1005, true);
            l_3 = axes_0[_S1023];
            _S1022 = _S1024;
        }
        else
        {
            uint _S1025 = i_13 - 6U;
            float3  _S1026 = cross_0(axes_0[_S1025 / 3U], axes_0[3U + _S1025 % 3U]);
            uint _S1027 = __ballot_sync(_S1005, true);
            l_3 = _S1026;
            _S1022 = _S1027;
        }
        uint _S1028 = 0U;
        float len_0 = length_0(l_3);
        bool _S1029 = len_0 <= 9.99999997475242708e-07f;
        uint _S1030 = __ballot_sync(_S1022, _S1029);
        if(_S1029)
        {
            uint _S1031 = __ballot_sync(_S1022, false);
            uint _S1032 = __ballot_sync(_S1004, true);
            _S1004 = _S1032;
            i_13 = i_13 + lanes_1;
            continue;
        }
        else
        {
            uint _S1033 = __ballot_sync(_S1022, true);
            _S1028 = _S1033;
        }
        bool _S1034 = (F32_abs((dot_0(d_2, l_3)))) > (_S1012.x * (F32_abs((dot_0(_S1014, l_3)))) + _S1012.y * (F32_abs((dot_0(_S1015, l_3)))) + _S1012.z * (F32_abs((dot_0(_S1016, l_3)))) + (_S1013.x * (F32_abs((dot_0(_S1017, l_3)))) + _S1013.y * (F32_abs((dot_0(_S1018, l_3)))) + _S1013.z * (F32_abs((dot_0(_S1019, l_3))))) + margin_0 * len_0);
        uint _S1035 = __ballot_sync(_S1028, _S1034);
        bool separated_1;
        if(_S1034)
        {
            uint _S1036 = __ballot_sync(_S1028, true);
            separated_1 = true;
        }
        else
        {
            uint _S1037 = __ballot_sync(_S1028, true);
            separated_1 = separated_0;
        }
        uint _S1038 = __ballot_sync(_S1004, true);
        separated_0 = separated_1;
        _S1004 = _S1038;
        i_13 = i_13 + lanes_1;
    }
    bool _S1039 = pair_any_0(separated_0, lanes_1, _S1003);
    return !_S1039;
}

static __device__ bool may_overlap_0(Box_0 * a_14, Box_0 * b_14)
{
    float3  _S1040 = b_14->center_1 - a_14->center_1;
    float3  _S1041 = a_14->half_2;
    float3  _S1042 = b_14->half_2;
    float _S1043 = 0.00000999999974738f * (length_0(a_14->half_2) + length_0(b_14->half_2));
    float3  _S1044 = a_14->axis0_0;
    float3  _S1045 = a_14->axis1_0;
    float3  _S1046 = a_14->axis2_0;
    float3  _S1047 = b_14->axis0_0;
    float3  _S1048 = b_14->axis1_0;
    float3  _S1049 = b_14->axis2_0;
    FixedArray<float3 , 6>  _S1050 = { {
        a_14->axis0_0, a_14->axis1_0, a_14->axis2_0, b_14->axis0_0, b_14->axis1_0, b_14->axis2_0
    } };
    uint i_14 = 0U;
    for(;;)
    {
        if(i_14 < 15U)
        {
        }
        else
        {
            break;
        }
        float3  l_4;
        if(i_14 < 6U)
        {
            l_4 = _S1050[i_14];
        }
        else
        {
            uint _S1051 = i_14 - 6U;
            l_4 = cross_0(_S1050[_S1051 / 3U], _S1050[3U + _S1051 % 3U]);
        }
        float len_1 = length_0(l_4);
        if(len_1 <= 9.99999997475242708e-07f)
        {
            i_14 = i_14 + 1U;
            continue;
        }
        if((F32_abs((dot_0(_S1040, l_4)))) > (_S1041.x * (F32_abs((dot_0(_S1044, l_4)))) + _S1041.y * (F32_abs((dot_0(_S1045, l_4)))) + _S1041.z * (F32_abs((dot_0(_S1046, l_4)))) + (_S1042.x * (F32_abs((dot_0(_S1047, l_4)))) + _S1042.y * (F32_abs((dot_0(_S1048, l_4)))) + _S1042.z * (F32_abs((dot_0(_S1049, l_4))))) + _S1043 * len_1))
        {
            return false;
        }
        i_14 = i_14 + 1U;
    }
    return true;
}

static __device__ void chunk_velocity_0(uint c_24, float3  * v_10, float3  * w_7)
{
    ChunkStatic_0 * _S1052 = (&(globalParams_0->chunks_0)[c_24]);
    uint4  _S1053 = __ldg(&_S1052->info_0);
    Island_0 * _S1054 = (&(globalParams_0->islands_0)[_S1053.y]);
    Quat_0 q_8 = quat_of_0(_S1054->rotation_0);
    float4  _S1055 = __ldg(&_S1052->center_0);
    uint _S1056 = 4U * c_24;
    float4  _S1057 = *(&(globalParams_0->state_0)[_S1056]);
    float4  _S1058 = _S1054->com_0;
    float3  _S1059 = float3 {_S1055.x, _S1055.y, _S1055.z} + float3 {_S1057.x, _S1057.y, _S1057.z} - float3 {_S1058.x, _S1058.y, _S1058.z};
    Quat_0 _S1060 = q_8;
    float3  _S1061 = rotate_0(&_S1060, _S1059);
    float4  _S1062 = _S1054->velocity_0;
    float4  _S1063 = _S1054->velocity_err_0;
    float4  _S1064 = _S1054->angular_velocity_0;
    float3  _S1065 = float3 {_S1064.x, _S1064.y, _S1064.z};
    float3  _S1066 = float3 {_S1062.x, _S1062.y, _S1062.z} + float3 {_S1063.x, _S1063.y, _S1063.z} + cross_0(_S1065, _S1061);
    float4  _S1067 = *(&(globalParams_0->state_0)[_S1056 + 2U]);
    float3  _S1068 = float3 {_S1067.x, _S1067.y, _S1067.z};
    Quat_0 _S1069 = q_8;
    float3  _S1070 = rotate_0(&_S1069, _S1068);
    *v_10 = _S1066 + _S1070;
    float4  _S1071 = *(&(globalParams_0->state_0)[_S1056 + 3U]);
    float3  _S1072 = float3 {_S1071.x, _S1071.y, _S1071.z};
    Quat_0 _S1073 = q_8;
    float3  _S1074 = rotate_0(&_S1073, _S1072);
    *w_7 = _S1065 + _S1074;
    return;
}

static __device__ float3  box_to_world_0(Box_0 * b_15, float3  local_0)
{
    return b_15->axis0_0 * make_float3 (local_0.x) + b_15->axis1_0 * make_float3 (local_0.y) + b_15->axis2_0 * make_float3 (local_0.z);
}

static __device__ float3  box_axis_0(Box_0 * b_16, uint k_10)
{
    float3  _S1075;
    if(k_10 == 0U)
    {
        _S1075 = b_16->axis0_0;
    }
    else
    {
        if(k_10 == 1U)
        {
            _S1075 = b_16->axis1_0;
        }
        else
        {
            _S1075 = b_16->axis2_0;
        }
    }
    return _S1075;
}

static __device__ float comp3_0(float3  v_11, uint k_11)
{
    float _S1076;
    if(k_11 == 0U)
    {
        _S1076 = v_11.x;
    }
    else
    {
        if(k_11 == 1U)
        {
            _S1076 = v_11.y;
        }
        else
        {
            _S1076 = v_11.z;
        }
    }
    return _S1076;
}

static __device__ float3  sample_point_0(Box_0 * b_17, uint i_15)
{
    uint _S1077 = b_17->hull_v_0;
    if((b_17->hull_v_0) != 0U)
    {
        float3  local_1;
        if(i_15 < _S1077)
        {
            float4  _S1078 = __ldg((&(globalParams_0->loads_0)[b_17->hull_at_0 + i_15]));
            local_1 = float3 {_S1078.x, _S1078.y, _S1078.z} * make_float3 (0.89999997615814209f);
        }
        else
        {
            float4  _S1079 = __ldg((&(globalParams_0->loads_0)[b_17->hull_at_0 + _S1077 + b_17->hull_f_0 + (i_15 - _S1077)]));
            local_1 = float3 {_S1079.x, _S1079.y, _S1079.z};
        }
        float3  _S1080 = b_17->center_1;
        float3  _S1081 = box_to_world_0(b_17, local_1);
        return _S1080 + _S1081;
    }
    float sign_0;
    if(i_15 < 8U)
    {
        float3  h_0 = b_17->half_2 * make_float3 (0.89999997615814209f);
        if((i_15 & 1U) == 0U)
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        float _S1082;
        if((i_15 & 2U) == 0U)
        {
            _S1082 = - h_0.y;
        }
        else
        {
            _S1082 = h_0.y;
        }
        float _S1083;
        if((i_15 & 4U) == 0U)
        {
            _S1083 = - h_0.z;
        }
        else
        {
            _S1083 = h_0.z;
        }
        return b_17->center_1 + b_17->axis0_0 * make_float3 (sign_0) + b_17->axis1_0 * make_float3 (_S1082) + b_17->axis2_0 * make_float3 (_S1083);
    }
    uint _S1084 = i_15 - 8U;
    uint axis_2 = _S1084 / 2U;
    if((_S1084 % 2U) == 0U)
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    float3  _S1085 = b_17->center_1;
    float3  _S1086 = box_axis_0(b_17, axis_2);
    return _S1085 + _S1086 * make_float3 (sign_0 * comp3_0(b_17->half_2, axis_2));
}

static __device__ float3  box_to_local_0(Box_0 * b_18, float3  r_8)
{
    return make_float3 (dot_0(r_8, b_18->axis0_0), dot_0(r_8, b_18->axis1_0), dot_0(r_8, b_18->axis2_0));
}

static __device__ float hull_signed_distance_0(Box_0 * b_19, float3  local_2, uint * face_0)
{
    *face_0 = 0U;
    float best_0 = -1.00000001504746622e+30f;
    uint f_11 = 0U;
    for(;;)
    {
        if(f_11 < (b_19->hull_f_0))
        {
        }
        else
        {
            break;
        }
        float4  _S1087 = __ldg((&(globalParams_0->loads_0)[b_19->hull_at_0 + b_19->hull_v_0 + f_11]));
        float d_3 = dot_0(float3 {_S1087.x, _S1087.y, _S1087.z}, local_2) - _S1087.w;
        if(d_3 > best_0)
        {
            *face_0 = f_11;
            best_0 = d_3;
        }
        f_11 = f_11 + 1U;
    }
    return best_0;
}

static __device__ bool penetration_0(Box_0 * b_20, float3  p_3, float * depth_0, float3  * normal_2)
{
    *depth_0 = 0.0f;
    *normal_2 = make_float3 (0.0f);
    float3  r_9 = p_3 - b_20->center_1;
    float3  _S1088 = b_20->half_2;
    if((dot_0(r_9, r_9)) > (dot_0(b_20->half_2, b_20->half_2) * 1.00001001358032227f))
    {
        return false;
    }
    uint _S1089 = b_20->hull_v_0;
    if((b_20->hull_v_0) != 0U)
    {
        float3  _S1090 = box_to_local_0(b_20, r_9);
        uint face_1;
        float _S1091 = hull_signed_distance_0(b_20, _S1090, &face_1);
        if(!(_S1091 < 0.0f))
        {
            return false;
        }
        *depth_0 = - _S1091;
        float4  _S1092 = __ldg((&(globalParams_0->loads_0)[b_20->hull_at_0 + _S1089 + face_1]));
        float3  _S1093 = box_to_world_0(b_20, float3 {_S1092.x, _S1092.y, _S1092.z});
        *normal_2 = _S1093;
        return true;
    }
    float best_1 = 1.00000001504746622e+30f;
    uint axis_3 = 0U;
    float side_0 = 1.0f;
    uint k_12 = 0U;
    for(;;)
    {
        if(k_12 < 3U)
        {
        }
        else
        {
            break;
        }
        float3  _S1094 = box_axis_0(b_20, k_12);
        float local_3 = dot_0(r_9, _S1094);
        float d_4 = comp3_0(_S1088, k_12) - (F32_abs((local_3)));
        if(d_4 <= 0.0f)
        {
            return false;
        }
        if(d_4 < best_1)
        {
            float _S1095;
            if(local_3 >= 0.0f)
            {
                _S1095 = 1.0f;
            }
            else
            {
                _S1095 = -1.0f;
            }
            best_1 = d_4;
            axis_3 = k_12;
            side_0 = _S1095;
        }
        k_12 = k_12 + 1U;
    }
    *depth_0 = best_1;
    float3  _S1096 = box_axis_0(b_20, axis_3);
    *normal_2 = _S1096 * make_float3 (side_0);
    return true;
}

static __device__ bool pair_point_0(Box_0 * ba_0, Box_0 * bb_0, uint na_0, uint e_2, float3  * p_4, float3  * n_2, float * d_5)
{
    if(e_2 < na_0)
    {
        float3  _S1097 = sample_point_0(ba_0, e_2);
        *p_4 = _S1097;
        bool _S1098 = penetration_0(bb_0, _S1097, d_5, n_2);
        return _S1098;
    }
    float3  _S1099 = sample_point_0(bb_0, e_2 - na_0);
    *p_4 = _S1099;
    bool _S1100 = penetration_0(ba_0, _S1099, d_5, n_2);
    if(!_S1100)
    {
        return false;
    }
    *n_2 = - *n_2;
    return true;
}

static __device__ bool is_nan_0(float x_20)
{
    return ((F32_asuint((x_20))) & 2147483647U) > 2139095040U;
}

static __device__ uint pair_count_sum_0(uint x_21, uint lanes_2, uint _S1101)
{
    bool _S1102 = lanes_2 > 1U;
    uint _S1103 = __ballot_sync(_S1101, _S1102);
    uint _S1104;
    if(_S1102)
    {
        uint _S1105 = WaveActiveSum_3(x_21, _S1103);
        uint _S1106 = __ballot_sync(_S1101, true);
        _S1104 = _S1105;
    }
    else
    {
        _S1104 = x_21;
    }
    return _S1104;
}

static __device__ float2  half_thickness_and_area_0(Box_0 * b_21, float3  d_6)
{
    uint k_13 = 0U;
    float h_1 = 0.0f;
    float area_1 = 0.0f;
    for(;;)
    {
        if(k_13 < 3U)
        {
        }
        else
        {
            break;
        }
        float3  _S1107 = box_axis_0(b_21, k_13);
        float c_25 = (F32_abs((dot_0(d_6, _S1107))));
        float h_2 = h_1 + c_25 * comp3_0(b_21->half_2, k_13);
        uint _S1108 = k_13 + 1U;
        float area_2 = area_1 + c_25 * 4.0f * comp3_0(b_21->half_2, _S1108 % 3U) * comp3_0(b_21->half_2, (k_13 + 2U) % 3U);
        k_13 = _S1108;
        h_1 = h_2;
        area_1 = area_2;
    }
    return make_float2 (h_1, area_1);
}

static __device__ float contact_stiffness_0(float ea_0, Box_0 * a_15, float eb_0, Box_0 * b_22, float3  dir_0)
{
    float3  d_7 = safe_normalize_0(dir_0);
    float2  _S1109 = half_thickness_and_area_0(a_15, d_7);
    float2  _S1110 = half_thickness_and_area_0(b_22, d_7);
    return (F32_min((_S1109.y), (_S1110.y))) / (_S1109.x / ea_0 + _S1110.x / eb_0);
}

static __device__ float3  penalty_force_0(float k_14, float m_red_0, float friction_0, float depth_1, float3  normal_3, float3  rel_velocity_0, float dt_11, uint points_0, float * stored_4, float * dissipated_8)
{
    float c_max_0 = 1.0f / (F32_max((float(points_0)), (10.0f))) * m_red_0 / dt_11;
    float _S1111 = __ldg(&globalParams_0->params_0->zeta_0);
    float vn_0 = dot_0(rel_velocity_0, normal_3);
    float _S1112 = k_14 * depth_1;
    float _S1113 = (F32_min((2.0f * _S1111 * (F32_sqrt((k_14 * m_red_0)))), (c_max_0))) * vn_0;
    float _S1114 = _S1112 - _S1113;
    float _S1115 = (F32_max((_S1114), (0.0f)));
    float3  vt_0 = rel_velocity_0 - normal_3 * make_float3 (vn_0);
    float vt_mag_0 = length_0(vt_0);
    float _S1116 = friction_0 * _S1115;
    float _S1117 = (F32_min((_S1116), ((F32_min((c_max_0), (_S1116 / 0.00100000004749745f))) * vt_mag_0)));
    float3  ft_0;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = - vt_0 * make_float3 (_S1117 / vt_mag_0);
    }
    else
    {
        ft_0 = make_float3 (0.0f);
    }
    *stored_4 = 0.5f * k_14 * depth_1 * depth_1;
    float damping_power_0;
    if(_S1114 > 0.0f)
    {
        damping_power_0 = _S1113 * vn_0;
    }
    else
    {
        damping_power_0 = _S1112 * (F32_max((vn_0), (0.0f)));
    }
    *dissipated_8 = (damping_power_0 + length_0(ft_0) * vt_mag_0) * dt_11;
    return normal_3 * make_float3 (_S1115) + ft_0;
}

static __device__ float3  pair_sum3_0(float3  x_22, uint lanes_3, uint _S1118)
{
    bool _S1119 = lanes_3 > 1U;
    uint _S1120 = __ballot_sync(_S1118, _S1119);
    float3  _S1121;
    if(_S1119)
    {
        float3  _S1122 = WaveActiveSum_2(x_22, _S1120);
        uint _S1123 = __ballot_sync(_S1118, true);
        _S1121 = _S1122;
    }
    else
    {
        _S1121 = x_22;
    }
    return _S1121;
}

static __device__ float pair_sum_0(float x_23, uint lanes_4, uint _S1124)
{
    bool _S1125 = lanes_4 > 1U;
    uint _S1126 = __ballot_sync(_S1124, _S1125);
    float _S1127;
    if(_S1125)
    {
        float _S1128 = WaveActiveSum_1(x_23, _S1126);
        uint _S1129 = __ballot_sync(_S1124, true);
        _S1127 = _S1128;
    }
    else
    {
        _S1127 = x_23;
    }
    return _S1127;
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
    uint _S1130 = __ldg(&globalParams_0->params_0->halt_index_0);
    uint _S1131 = __ldg(&globalParams_0->params_0->halt_index_0);
    cov_mark_0(_S1130, (&(globalParams_0->islands_0)[_S1131])->coverage_0, bits_2);
    return;
}

static __device__ void pair_contact_0(uint i_16, uint lane_1, uint lanes_5, uint _S1132)
{
    uint _S1133 = 0U;
    uint _S1134;
    uint _S1135;
    uint _S1136 = __ldg(&globalParams_0->params_0->pair_index_0);
    uint at_3 = _S1136 + 6U * i_16;
    uint _S1137 = __ldg((&(globalParams_0->index_0)[at_3]));
    uint _S1138 = __ldg((&(globalParams_0->index_0)[at_3 + 1U]));
    uint _S1139 = __ldg((&(globalParams_0->index_0)[at_3 + 2U]));
    uint _S1140 = __ldg((&(globalParams_0->index_0)[at_3 + 3U]));
    uint _S1141 = __ldg((&(globalParams_0->index_0)[at_3 + 4U]));
    float _S1142 = (U32_asfloat((_S1141)));
    uint _S1143 = __ldg((&(globalParams_0->index_0)[at_3 + 5U]));
    float _S1144 = (U32_asfloat((_S1143)));
    float _S1145 = __ldg(&globalParams_0->params_0->dt_0);
    uint _S1146 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint out_0 = _S1146 + 2U * _S1139;
    WorldPoint_0 wa_1 = chunk_world_0(_S1137);
    WorldPoint_0 _S1147 = chunk_world_0(_S1138);
    WorldPoint_0 _S1148 = wa_1;
    float3  _S1149 = world_diff_0(&_S1147, &_S1148);
    float _S1150 = length_0(_S1149);
    float4  _S1151 = __ldg(&(&(globalParams_0->chunks_0)[_S1137])->half_0);
    float _S1152 = _S1151.w;
    float4  _S1153 = __ldg(&(&(globalParams_0->chunks_0)[_S1138])->half_0);
    bool touching_0 = !(_S1150 > (_S1152 + _S1153.w));
    uint _S1154 = __ldg(&globalParams_0->params_0->ledger_base_0);
    float4  * _S1155 = (&(globalParams_0->scratch_0)[_S1154 + i_16]);
    float4  ledger_1 = *_S1155;
    uint flags_1 = (F32_asuint(((*_S1155).w)));
    float3  _S1156 = make_float3 (0.0f);
    Box_0 ba_1 = chunk_box_0(_S1137, _S1156);
    Box_0 bb_1 = chunk_box_0(_S1138, _S1149);
    Box_0 _S1157 = ba_1;
    uint _S1158 = sample_count_0(&_S1157);
    Box_0 _S1159 = bb_1;
    uint _S1160 = sample_count_0(&_S1159);
    uint _S1161 = _S1158 + _S1160;
    bool _S1162 = !touching_0;
    uint _S1163 = __ballot_sync(_S1132, _S1162);
    bool has_state_0;
    uint e_3;
    if(_S1162)
    {
        if((flags_1 & 1U) != 0U)
        {
            e_3 = lane_1;
            for(;;)
            {
                if(e_3 < _S1161)
                {
                }
                else
                {
                    break;
                }
                *(&(globalParams_0->contact_state_0)[_S1140 + e_3]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                e_3 = e_3 + lanes_5;
            }
        }
        if(lane_1 == 0U)
        {
            if((flags_1 & 2U) != 0U)
            {
                e_3 = 0U;
                for(;;)
                {
                    if(e_3 < 4U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    *(&(globalParams_0->scratch_0)[out_0 + e_3]) = make_float4 (0.0f);
                    e_3 = e_3 + 1U;
                }
            }
            if(flags_1 != 0U)
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
                uint _S1164 = __ldg(&globalParams_0->params_0->ledger_base_0);
                *(&(globalParams_0->scratch_0)[_S1164 + i_16]) = ledger_1;
            }
        }
        return;
    }
    else
    {
        uint _S1165 = __ballot_sync(_S1132, true);
        _S1133 = _S1165;
    }
    bool _S1166 = lanes_5 > 1U;
    uint _S1167 = __ballot_sync(_S1133, _S1166);
    if(_S1166)
    {
        Box_0 _S1168 = ba_1;
        Box_0 _S1169 = bb_1;
        bool _S1170 = may_overlap_lanes_0(&_S1168, &_S1169, lane_1, lanes_5, _S1167);
        uint _S1171 = __ballot_sync(_S1133, true);
        has_state_0 = _S1170;
        e_3 = _S1171;
    }
    else
    {
        Box_0 _S1172 = ba_1;
        Box_0 _S1173 = bb_1;
        bool _S1174 = may_overlap_0(&_S1172, &_S1173);
        uint _S1175 = __ballot_sync(_S1133, true);
        has_state_0 = _S1174;
        e_3 = _S1175;
    }
    uint _S1176 = __ballot_sync(e_3, has_state_0);
    uint count_3;
    float3  fa_1;
    float3  ta_1;
    float3  fb_0;
    float3  tb_1;
    float stored_sum_0;
    float diss_sum_0;
    if(has_state_0)
    {
        float3  va0_0;
        float3  wa0_0;
        chunk_velocity_0(_S1137, &va0_0, &wa0_0);
        float3  vb0_0;
        float3  wb0_0;
        chunk_velocity_0(_S1138, &vb0_0, &wb0_0);
        e_3 = lane_1;
        count_3 = 0U;
        uint engaged_0 = 0U;
        uint _S1177 = _S1176;
        for(;;)
        {
            uint _S1178 = 0U;
            bool _S1179 = e_3 < _S1161;
            uint _S1180 = __ballot_sync(_S1177, _S1179);
            if(_S1179)
            {
                uint _S1181 = __ballot_sync(_S1177, true);
                _S1178 = _S1181;
            }
            else
            {
                uint _S1182 = __ballot_sync(_S1177, false);
                uint _S1183 = __ballot_sync(_S1177, false);
                uint _S1184 = __ballot_sync(_S1176, true);
                _S1134 = _S1184;
                break;
            }
            uint _S1185 = 0U;
            Box_0 _S1186 = ba_1;
            Box_0 _S1187 = bb_1;
            float3  p_5;
            float3  n_3;
            float d_8;
            bool _S1188 = pair_point_0(&_S1186, &_S1187, _S1158, e_3, &p_5, &n_3, &d_8);
            bool _S1189 = !_S1188;
            uint _S1190 = __ballot_sync(_S1178, _S1189);
            if(_S1189)
            {
                uint _S1191 = _S1140 + e_3;
                bool _S1192 = !is_nan_0((*(&(globalParams_0->contact_state_0)[_S1191])).x);
                uint _S1193 = __ballot_sync(_S1190, _S1192);
                if(_S1192)
                {
                    *(&(globalParams_0->contact_state_0)[_S1191]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
                    uint _S1194 = __ballot_sync(_S1190, true);
                }
                else
                {
                    uint _S1195 = __ballot_sync(_S1190, true);
                }
                uint _S1196 = __ballot_sync(_S1178, false);
                uint _S1197 = __ballot_sync(_S1177, true);
                _S1177 = _S1197;
                e_3 = e_3 + lanes_5;
                continue;
            }
            else
            {
                uint _S1198 = __ballot_sync(_S1178, true);
                _S1185 = _S1198;
            }
            uint _S1199 = count_3 + 1U;
            uint _S1200 = _S1140 + e_3;
            float4  * _S1201 = (&(globalParams_0->contact_state_0)[_S1200]);
            float4  entry_0 = *_S1201;
            bool _S1202 = is_nan_0((*_S1201).x);
            uint _S1203 = __ballot_sync(_S1185, _S1202);
            uint _S1204;
            if(_S1202)
            {
                uint _S1205 = __ballot_sync(_S1185, true);
                has_state_0 = true;
                _S1204 = _S1205;
            }
            else
            {
                float4  _S1206 = entry_0;
                bool _S1207 = (dot_0(float3 {_S1206.y, _S1206.z, _S1206.w}, n_3)) < 0.99000000953674316f;
                uint _S1208 = __ballot_sync(_S1185, true);
                has_state_0 = _S1207;
                _S1204 = _S1208;
            }
            uint _S1209 = __ballot_sync(_S1204, has_state_0);
            uint _S1210;
            if(has_state_0)
            {
                bool _S1211 = d_8 > (2.0f * (F32_abs((dot_0(va0_0 + cross_0(wa0_0, p_5) - (vb0_0 + cross_0(wb0_0, p_5 - bb_1.center_1)), n_3)))) * _S1145 + 9.99999971718068537e-10f);
                uint _S1212 = __ballot_sync(_S1209, _S1211);
                if(_S1211)
                {
                    float _S1213 = d_8;
                    uint _S1214 = __ballot_sync(_S1209, true);
                    stored_sum_0 = _S1213;
                }
                else
                {
                    uint _S1215 = __ballot_sync(_S1209, true);
                    stored_sum_0 = 0.0f;
                }
                entry_0 = make_float4 (stored_sum_0, n_3.x, n_3.y, n_3.z);
                uint _S1216 = __ballot_sync(_S1204, true);
                _S1210 = _S1216;
            }
            else
            {
                uint _S1217 = __ballot_sync(_S1204, true);
                _S1210 = _S1217;
            }
            *&((&entry_0)->x) = (F32_min((entry_0.x), (d_8)));
            *(&(globalParams_0->contact_state_0)[_S1200]) = entry_0;
            bool _S1218 = (d_8 - entry_0.x) > 0.0f;
            uint _S1219 = __ballot_sync(_S1210, _S1218);
            uint engaged_1;
            if(_S1218)
            {
                uint _S1220 = engaged_0 + 1U;
                uint _S1221 = __ballot_sync(_S1210, true);
                engaged_1 = _S1220;
            }
            else
            {
                uint _S1222 = __ballot_sync(_S1210, true);
                engaged_1 = engaged_0;
            }
            uint _S1223 = __ballot_sync(_S1177, true);
            count_3 = _S1199;
            engaged_0 = engaged_1;
            _S1177 = _S1223;
            e_3 = e_3 + lanes_5;
        }
        uint _S1224 = pair_count_sum_0(count_3, lanes_5, _S1134);
        uint _S1225 = pair_count_sum_0(engaged_0, lanes_5, _S1134);
        bool _S1226 = _S1224 > 0U;
        uint _S1227 = __ballot_sync(_S1134, _S1226);
        if(_S1226)
        {
            float4  _S1228 = __ldg(&(&(globalParams_0->chunks_0)[_S1137])->cmat_0);
            float _S1229 = _S1228.x;
            float4  _S1230 = __ldg(&(&(globalParams_0->chunks_0)[_S1138])->cmat_0);
            float _S1231 = _S1230.x;
            float3  _S1232 = bb_1.center_1 - ba_1.center_1;
            Box_0 _S1233 = ba_1;
            Box_0 _S1234 = bb_1;
            float _S1235 = contact_stiffness_0(_S1229, &_S1233, _S1231, &_S1234, _S1232);
            float _S1236 = _S1235 / (F32_max((float(_S1225)), (10.0f)));
            e_3 = lane_1;
            fa_1 = _S1156;
            ta_1 = _S1156;
            fb_0 = _S1156;
            tb_1 = _S1156;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            count_3 = _S1227;
            for(;;)
            {
                uint _S1237 = 0U;
                bool _S1238 = e_3 < _S1161;
                uint _S1239 = __ballot_sync(count_3, _S1238);
                if(_S1238)
                {
                    uint _S1240 = __ballot_sync(count_3, true);
                    _S1237 = _S1240;
                }
                else
                {
                    uint _S1241 = __ballot_sync(count_3, false);
                    uint _S1242 = __ballot_sync(count_3, false);
                    uint _S1243 = __ballot_sync(_S1227, true);
                    _S1135 = _S1243;
                    break;
                }
                uint _S1244 = 0U;
                Box_0 _S1245 = ba_1;
                Box_0 _S1246 = bb_1;
                float3  p_6;
                float3  n_4;
                float d_9;
                bool _S1247 = pair_point_0(&_S1245, &_S1246, _S1158, e_3, &p_6, &n_4, &d_9);
                bool _S1248 = !_S1247;
                uint _S1249 = __ballot_sync(_S1237, _S1248);
                if(_S1248)
                {
                    uint _S1250 = __ballot_sync(_S1237, false);
                    uint _S1251 = __ballot_sync(count_3, true);
                    count_3 = _S1251;
                    e_3 = e_3 + lanes_5;
                    continue;
                }
                else
                {
                    uint _S1252 = __ballot_sync(_S1237, true);
                    _S1244 = _S1252;
                }
                float eff_0 = d_9 - (*(&(globalParams_0->contact_state_0)[_S1140 + e_3])).x;
                bool _S1253 = eff_0 <= 0.0f;
                uint _S1254 = __ballot_sync(_S1244, _S1253);
                if(_S1253)
                {
                    uint _S1255 = __ballot_sync(_S1244, false);
                    uint _S1256 = __ballot_sync(count_3, true);
                    count_3 = _S1256;
                    e_3 = e_3 + lanes_5;
                    continue;
                }
                else
                {
                    uint _S1257 = __ballot_sync(_S1244, true);
                }
                float stored_5;
                float diss_3;
                float3  f_12 = penalty_force_0(_S1236, _S1142, _S1144, eff_0, n_4, va0_0 + cross_0(wa0_0, p_6) - (vb0_0 + cross_0(wb0_0, p_6 - bb_1.center_1)), _S1145, _S1225, &stored_5, &diss_3);
                float3  fa_2 = fa_1 + f_12;
                float3  ta_2 = ta_1 + cross_0(p_6, f_12);
                float3  _S1258 = - f_12;
                float3  fb_1 = fb_0 + _S1258;
                float3  tb_2 = tb_1 + cross_0(p_6 - bb_1.center_1, _S1258);
                float stored_sum_1 = stored_sum_0 + stored_5;
                float diss_sum_1 = diss_sum_0 + diss_3;
                uint _S1259 = __ballot_sync(count_3, true);
                fa_1 = fa_2;
                ta_1 = ta_2;
                fb_0 = fb_1;
                tb_1 = tb_2;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                count_3 = _S1259;
                e_3 = e_3 + lanes_5;
            }
            float3  _S1260 = pair_sum3_0(fa_1, lanes_5, _S1135);
            float3  _S1261 = pair_sum3_0(ta_1, lanes_5, _S1135);
            float3  _S1262 = pair_sum3_0(fb_0, lanes_5, _S1135);
            float3  _S1263 = pair_sum3_0(tb_1, lanes_5, _S1135);
            float _S1264 = pair_sum_0(stored_sum_0, lanes_5, _S1135);
            float _S1265 = pair_sum_0(diss_sum_0, lanes_5, _S1135);
            uint _S1266 = __ballot_sync(_S1134, true);
            has_state_0 = true;
            diss_sum_0 = _S1265;
            fa_1 = _S1260;
            ta_1 = _S1261;
            fb_0 = _S1262;
            tb_1 = _S1263;
            stored_sum_0 = _S1264;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_1 = _S1156;
            ta_1 = _S1156;
            fb_0 = _S1156;
            tb_1 = _S1156;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_1 = _S1156;
        ta_1 = _S1156;
        fb_0 = _S1156;
        tb_1 = _S1156;
        stored_sum_0 = 0.0f;
    }
    bool loaded_0;
    if(!has_state_0)
    {
        loaded_0 = (flags_1 & 1U) != 0U;
    }
    else
    {
        loaded_0 = false;
    }
    if(loaded_0)
    {
        e_3 = lane_1;
        for(;;)
        {
            if(e_3 < _S1161)
            {
            }
            else
            {
                break;
            }
            *(&(globalParams_0->contact_state_0)[_S1140 + e_3]) = make_float4 ((U32_asfloat((2143289344U))), 0.0f, 0.0f, 0.0f);
            e_3 = e_3 + lanes_5;
        }
    }
    if(lane_1 != 0U)
    {
        return;
    }
    if(has_state_0)
    {
        comp_add1_0(&((&ledger_1)->y), &((&ledger_1)->z), diss_sum_0);
    }
    if(any_0(fa_1 != make_float3 (0.0f)))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = any_0(ta_1 != make_float3 (0.0f));
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
        loaded_0 = any_0(tb_1 != make_float3 (0.0f));
    }
    bool _S1267;
    if(loaded_0)
    {
        _S1267 = true;
    }
    else
    {
        _S1267 = (flags_1 & 2U) != 0U;
    }
    if(_S1267)
    {
        *(&(globalParams_0->scratch_0)[out_0]) = make_float4 (fa_1.x, fa_1.y, fa_1.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 1U]) = make_float4 (ta_1.x, ta_1.y, ta_1.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 2U]) = make_float4 (fb_0.x, fb_0.y, fb_0.z, 0.0f);
        *(&(globalParams_0->scratch_0)[out_0 + 3U]) = make_float4 (tb_1.x, tb_1.y, tb_1.z, 0.0f);
    }
    *&((&ledger_1)->x) = stored_sum_0;
    if(has_state_0)
    {
        e_3 = 1U;
    }
    else
    {
        e_3 = 0U;
    }
    if(loaded_0)
    {
        count_3 = 2U;
    }
    else
    {
        count_3 = 0U;
    }
    *&((&ledger_1)->w) = (U32_asfloat((e_3 | count_3)));
    uint _S1268 = __ldg(&globalParams_0->params_0->ledger_base_0);
    *(&(globalParams_0->scratch_0)[_S1268 + i_16]) = ledger_1;
    if(loaded_0)
    {
        sentinel_mark_0(1U);
    }
    return;
}

static __device__ Box_0 impactor_box_0(Impactor_0 * imp_0, float3  center_3, float3  half_3)
{
    Quat_0 q_9 = quat_of_0(imp_0->rotation_1);
    Box_0 b_23;
    (&b_23)->center_1 = center_3;
    float3  _S1269 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S1270 = q_9;
    float3  _S1271 = rotate_0(&_S1270, _S1269);
    (&b_23)->axis0_0 = _S1271;
    float3  _S1272 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S1273 = q_9;
    float3  _S1274 = rotate_0(&_S1273, _S1272);
    (&b_23)->axis1_0 = _S1274;
    float3  _S1275 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S1276 = q_9;
    float3  _S1277 = rotate_0(&_S1276, _S1275);
    (&b_23)->axis2_0 = _S1277;
    (&b_23)->half_2 = half_3;
    (&b_23)->hull_at_0 = 0U;
    (&b_23)->hull_v_0 = 0U;
    (&b_23)->hull_f_0 = 0U;
    return b_23;
}

static __device__ uint impactor_slots_0(Impactor_0 * imp_1, Box_0 * b_24)
{
    uint _S1278;
    if((imp_1->shape_0.x) == 0.0f)
    {
        _S1278 = 1U;
    }
    else
    {
        uint _S1279 = sample_count_0(b_24);
        _S1278 = _S1279 + 14U;
    }
    return _S1278;
}

static __device__ bool sphere_contact_0(Box_0 * b_25, float3  center_4, float radius_0, float3  * point_0, float3  * normal_4, float * depth_2)
{
    float3  _S1280 = make_float3 (0.0f);
    *point_0 = _S1280;
    *normal_4 = _S1280;
    *depth_2 = 0.0f;
    float3  _S1281 = b_25->center_1;
    float3  r_10 = center_4 - b_25->center_1;
    float3  _S1282 = b_25->axis0_0;
    float3  _S1283 = b_25->axis1_0;
    float3  _S1284 = b_25->axis2_0;
    float3  local_4 = make_float3 (dot_0(r_10, b_25->axis0_0), dot_0(r_10, b_25->axis1_0), dot_0(r_10, b_25->axis2_0));
    uint _S1285 = b_25->hull_v_0;
    if((b_25->hull_v_0) != 0U)
    {
        uint face_2;
        float _S1286 = hull_signed_distance_0(b_25, local_4, &face_2);
        if(_S1286 >= radius_0)
        {
            return false;
        }
        float4  _S1287 = __ldg((&(globalParams_0->loads_0)[b_25->hull_at_0 + _S1285 + face_2]));
        float3  _S1288 = box_to_world_0(b_25, float3 {_S1287.x, _S1287.y, _S1287.z});
        *normal_4 = _S1288;
        *point_0 = center_4 - _S1288 * make_float3 ((F32_max((_S1286), (0.0f))));
        *depth_2 = radius_0 - _S1286;
        return true;
    }
    float3  q_10 = clamp_1(local_4, - b_25->half_2, b_25->half_2);
    float3  d_10 = local_4 - q_10;
    float dist_0 = length_0(d_10);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        float3  dn_0 = d_10 / make_float3 (dist_0);
        *normal_4 = _S1282 * make_float3 (dn_0.x) + _S1283 * make_float3 (dn_0.y) + _S1284 * make_float3 (dn_0.z);
        *point_0 = _S1281 + _S1282 * make_float3 (q_10.x) + _S1283 * make_float3 (q_10.y) + _S1284 * make_float3 (q_10.z);
        *depth_2 = radius_0 - dist_0;
        return true;
    }
    float inside_0;
    float3  n_5;
    bool _S1289 = penetration_0(b_25, center_4, &inside_0, &n_5);
    if(!_S1289)
    {
        return false;
    }
    *normal_4 = n_5;
    *point_0 = center_4 - n_5 * make_float3 ((F32_min((radius_0), (inside_0))));
    *depth_2 = radius_0 + inside_0;
    return true;
}

static __device__ bool impactor_contact_0(Impactor_0 * imp_2, float crush_depth_0, Box_0 * shrunk_0, Box_0 * b_26, uint j_2, float3  * p_7, float3  * n_6, float * d_11)
{
    float3  _S1290 = make_float3 (0.0f);
    *p_7 = _S1290;
    *n_6 = _S1290;
    *d_11 = 0.0f;
    float4  _S1291 = imp_2->shape_0;
    if((imp_2->shape_0.x) == 0.0f)
    {
        bool _S1292 = sphere_contact_0(b_26, _S1290, _S1291.y - crush_depth_0, p_7, n_6, d_11);
        if(!_S1292)
        {
            return false;
        }
        *n_6 = - *n_6;
        return true;
    }
    uint _S1293 = sample_count_0(b_26);
    if(j_2 < _S1293)
    {
        float3  _S1294 = sample_point_0(b_26, j_2);
        *p_7 = _S1294;
        bool _S1295 = penetration_0(shrunk_0, _S1294, d_11, n_6);
        return _S1295;
    }
    float3  _S1296 = sample_point_0(shrunk_0, j_2 - _S1293);
    *p_7 = _S1296;
    bool _S1297 = penetration_0(b_26, _S1296, d_11, n_6);
    if(!_S1297)
    {
        return false;
    }
    *n_6 = - *n_6;
    return true;
}

static __device__ WorldPoint_0 impactor_point_0(uint _S1298)
{
    Impactor_0 * _S1299 = (&(globalParams_0->impactors_0)[_S1298]);
    WorldPoint_0 wi_0;
    float4  _S1300 = _S1299->position_1;
    (&wi_0)->hi_3 = float3 {_S1300.x, _S1300.y, _S1300.z};
    float4  _S1301 = _S1299->position_err_1;
    (&wi_0)->lo_3 = float3 {_S1301.x, _S1301.y, _S1301.z};
    (&wi_0)->rel_0 = make_float3 (0.0f);
    return wi_0;
}

static __device__ Box_0 impactor_box_1(uint _S1302, float3  _S1303, float3  _S1304)
{
    Quat_0 q_11 = quat_of_0((&(globalParams_0->impactors_0)[_S1302])->rotation_1);
    Box_0 b_27;
    (&b_27)->center_1 = _S1303;
    float3  _S1305 = make_float3 (1.0f, 0.0f, 0.0f);
    Quat_0 _S1306 = q_11;
    float3  _S1307 = rotate_0(&_S1306, _S1305);
    (&b_27)->axis0_0 = _S1307;
    float3  _S1308 = make_float3 (0.0f, 1.0f, 0.0f);
    Quat_0 _S1309 = q_11;
    float3  _S1310 = rotate_0(&_S1309, _S1308);
    (&b_27)->axis1_0 = _S1310;
    float3  _S1311 = make_float3 (0.0f, 0.0f, 1.0f);
    Quat_0 _S1312 = q_11;
    float3  _S1313 = rotate_0(&_S1312, _S1311);
    (&b_27)->axis2_0 = _S1313;
    (&b_27)->half_2 = _S1304;
    (&b_27)->hull_at_0 = 0U;
    (&b_27)->hull_v_0 = 0U;
    (&b_27)->hull_f_0 = 0U;
    return b_27;
}

static __device__ Box_0 impactor_shrunk_0(uint _S1314, float _S1315, Box_0 * _S1316)
{
    Box_0 shrunk_1 = *_S1316;
    (&shrunk_1)->half_2 = _S1316->half_2 - min_0(make_float3 (_S1315), _S1316->half_2 * make_float3 (0.5f));
    return shrunk_1;
}

static __device__ bool impactor_contact_1(uint _S1317, float _S1318, Box_0 * _S1319, Box_0 * _S1320, uint _S1321, float3  * _S1322, float3  * _S1323, float * _S1324)
{
    Impactor_0 _S1325 = *(&(globalParams_0->impactors_0)[_S1317]);
    float3  _S1326 = make_float3 (0.0f);
    *_S1322 = _S1326;
    *_S1323 = _S1326;
    *_S1324 = 0.0f;
    if((_S1325.shape_0.x) == 0.0f)
    {
        bool _S1327 = sphere_contact_0(_S1320, _S1326, _S1325.shape_0.y - _S1318, _S1322, _S1323, _S1324);
        if(!_S1327)
        {
            return false;
        }
        *_S1323 = - *_S1323;
        return true;
    }
    uint _S1328 = sample_count_0(_S1320);
    if(_S1321 < _S1328)
    {
        float3  _S1329 = sample_point_0(_S1320, _S1321);
        *_S1322 = _S1329;
        bool _S1330 = penetration_0(_S1319, _S1329, _S1324, _S1323);
        return _S1330;
    }
    float3  _S1331 = sample_point_0(_S1319, _S1321 - _S1328);
    *_S1322 = _S1331;
    bool _S1332 = penetration_0(_S1320, _S1331, _S1324, _S1323);
    if(!_S1332)
    {
        return false;
    }
    *_S1323 = - *_S1323;
    return true;
}

static __device__ void impactor_candidate_forces_0(uint k_15, uint lane_2, uint lanes_6, uint _S1333)
{
    uint _S1334;
    uint _S1335;
    bool _S1336;
    uint _S1337;
    uint _S1338 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S1339 = 3U * k_15;
    uint at_4 = _S1338 + _S1339;
    uint _S1340 = __ldg((&(globalParams_0->index_0)[at_4]));
    uint _S1341 = __ldg((&(globalParams_0->index_0)[at_4 + 1U]));
    uint _S1342 = __ldg((&(globalParams_0->index_0)[at_4 + 2U]));
    Impactor_0 imp_3 = *(&(globalParams_0->impactors_0)[_S1342]);
    float _S1343 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S1344 = make_float3 (0.0f);
    uint _S1345 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_0 = *(&(globalParams_0->scratch_0)[_S1345 + _S1339]);
    bool _S1346 = (imp_3.cand_0.z) == 0U;
    uint _S1347 = __ballot_sync(_S1333, _S1346);
    bool hit_0;
    float3  f_sum_0;
    float3  t_sum_0;
    float3  imp_f_0;
    float3  imp_t_0;
    if(_S1346)
    {
        WorldPoint_0 _S1348 = impactor_point_0(_S1342);
        WorldPoint_0 _S1349 = chunk_world_0(_S1340);
        WorldPoint_0 _S1350 = _S1348;
        float3  _S1351 = world_diff_0(&_S1349, &_S1350);
        float _S1352 = length_0(_S1351);
        float _S1353 = imp_3.half_1.w;
        float4  _S1354 = __ldg(&(&(globalParams_0->chunks_0)[_S1340])->half_0);
        bool _S1355 = !(_S1352 > (_S1353 + _S1354.w));
        uint _S1356 = __ballot_sync(_S1347, _S1355);
        if(_S1355)
        {
            float4  _S1357 = imp_3.half_1;
            Box_0 _S1358 = impactor_box_1(_S1342, _S1344, float3 {_S1357.x, _S1357.y, _S1357.z});
            Box_0 b_28 = chunk_box_0(_S1340, _S1351);
            float _S1359 = imp_3.mat_0.x;
            float4  _S1360 = __ldg(&(&(globalParams_0->chunks_0)[_S1340])->cmat_0);
            float _S1361 = _S1360.x;
            float3  _S1362 = b_28.center_1 - _S1358.center_1;
            Box_0 _S1363 = _S1358;
            Box_0 _S1364 = b_28;
            float _S1365 = contact_stiffness_0(_S1359, &_S1363, _S1361, &_S1364, _S1362);
            float _S1366 = imp_3.geom_0.y;
            Box_0 _S1367 = _S1358;
            Box_0 _S1368 = impactor_shrunk_0(_S1342, _S1366, &_S1367);
            uint j_3 = lane_2;
            uint n_7 = 0U;
            uint j_4 = _S1356;
            for(;;)
            {
                uint _S1369 = 0U;
                Impactor_0 _S1370 = imp_3;
                Box_0 _S1371 = b_28;
                uint _S1372 = impactor_slots_0(&_S1370, &_S1371);
                _S1334 = _S1372;
                bool _S1373 = j_3 < _S1372;
                uint _S1374 = __ballot_sync(j_4, _S1373);
                if(_S1373)
                {
                    uint _S1375 = __ballot_sync(j_4, true);
                    _S1369 = _S1375;
                }
                else
                {
                    uint _S1376 = __ballot_sync(j_4, false);
                    uint _S1377 = __ballot_sync(j_4, false);
                    uint _S1378 = __ballot_sync(_S1356, true);
                    _S1335 = _S1378;
                    break;
                }
                Box_0 _S1379 = _S1368;
                Box_0 _S1380 = b_28;
                float3  p_8;
                float3  nrm_0;
                float dep_0;
                bool _S1381 = impactor_contact_1(_S1342, _S1366, &_S1379, &_S1380, j_3, &p_8, &nrm_0, &dep_0);
                uint _S1382 = __ballot_sync(_S1369, _S1381);
                if(_S1381)
                {
                    uint _S1383 = n_7 + 1U;
                    uint _S1384 = __ballot_sync(_S1369, true);
                    n_7 = _S1383;
                }
                else
                {
                    uint _S1385 = __ballot_sync(_S1369, true);
                }
                uint _S1386 = __ballot_sync(j_4, true);
                j_3 = j_3 + lanes_6;
                j_4 = _S1386;
            }
            uint _S1387 = pair_count_sum_0(n_7, lanes_6, _S1335);
            bool _S1388 = (imp_3.shape_0.x) == 0.0f;
            uint _S1389 = __ballot_sync(_S1335, _S1388);
            float _S1390;
            if(_S1388)
            {
                uint _S1391 = __ballot_sync(_S1335, true);
                _S1390 = _S1365;
                j_3 = _S1391;
            }
            else
            {
                float _S1392 = _S1365 / (F32_max((float(_S1387)), (10.0f)));
                uint _S1393 = __ballot_sync(_S1335, true);
                _S1390 = _S1392;
                j_3 = _S1393;
            }
            uint _S1394 = __ballot_sync(j_3, _S1388);
            if(_S1388)
            {
                uint _S1395 = __ballot_sync(j_3, true);
                j_3 = 1U;
                n_7 = _S1395;
            }
            else
            {
                uint _S1396 = __ballot_sync(j_3, true);
                j_3 = _S1387;
                n_7 = _S1396;
            }
            float4  _S1397 = __ldg(&(&(globalParams_0->chunks_0)[_S1340])->center_0);
            float m_5 = _S1397.w;
            float _S1398 = imp_3.mat_0.z;
            float _S1399 = m_5 * _S1398 / (m_5 + _S1398);
            float _S1400 = __ldg(&globalParams_0->params_0->pair_friction_0);
            bool _S1401 = _S1400 >= 0.0f;
            uint _S1402 = __ballot_sync(n_7, _S1401);
            float _S1403;
            if(_S1401)
            {
                float _S1404 = __ldg(&globalParams_0->params_0->pair_friction_0);
                uint _S1405 = __ballot_sync(n_7, true);
                _S1403 = _S1404;
                n_7 = _S1405;
            }
            else
            {
                float _S1406 = imp_3.mat_0.y;
                float4  _S1407 = __ldg(&(&(globalParams_0->chunks_0)[_S1340])->cmat_0);
                float _S1408 = (F32_min((_S1406), (_S1407.y)));
                uint _S1409 = __ballot_sync(n_7, true);
                _S1403 = _S1408;
                n_7 = _S1409;
            }
            float4  _S1410 = imp_3.velocity_1;
            float4  _S1411 = imp_3.velocity_err_1;
            float3  _S1412 = float3 {_S1410.x, _S1410.y, _S1410.z} + float3 {_S1411.x, _S1411.y, _S1411.z};
            float3  vc_0;
            float3  wc_0;
            chunk_velocity_0(_S1340, &vc_0, &wc_0);
            hit_0 = false;
            j_4 = lane_2;
            f_sum_0 = _S1344;
            t_sum_0 = _S1344;
            imp_f_0 = _S1344;
            imp_t_0 = _S1344;
            float diss_sum_2 = 0.0f;
            uint _S1413 = n_7;
            for(;;)
            {
                bool _S1414 = _S1387 > 0U;
                _S1336 = _S1414;
                uint _S1415 = __ballot_sync(_S1413, _S1414);
                uint _S1416;
                bool _S1417;
                if(_S1414)
                {
                    bool _S1418 = j_4 < _S1334;
                    uint _S1419 = __ballot_sync(_S1413, true);
                    _S1417 = _S1418;
                    _S1416 = _S1419;
                }
                else
                {
                    uint _S1420 = __ballot_sync(_S1413, true);
                    _S1417 = false;
                    _S1416 = _S1420;
                }
                uint _S1421 = 0U;
                uint _S1422 = __ballot_sync(_S1416, _S1417);
                if(_S1417)
                {
                    uint _S1423 = __ballot_sync(_S1416, true);
                    _S1421 = _S1423;
                }
                else
                {
                    uint _S1424 = __ballot_sync(_S1416, false);
                    uint _S1425 = __ballot_sync(_S1413, false);
                    uint _S1426 = __ballot_sync(n_7, true);
                    _S1337 = _S1426;
                    break;
                }
                Impactor_0 _S1427 = imp_3;
                Box_0 _S1428 = _S1368;
                Box_0 _S1429 = b_28;
                float3  p_9;
                float3  nrm_1;
                float dep_1;
                bool _S1430 = impactor_contact_0(&_S1427, _S1366, &_S1428, &_S1429, j_4, &p_9, &nrm_1, &dep_1);
                bool _S1431 = !_S1430;
                uint _S1432 = __ballot_sync(_S1421, _S1431);
                if(_S1431)
                {
                    uint _S1433 = __ballot_sync(_S1421, false);
                    uint _S1434 = __ballot_sync(_S1413, true);
                    _S1413 = _S1434;
                    j_4 = j_4 + lanes_6;
                    continue;
                }
                else
                {
                    uint _S1435 = __ballot_sync(_S1421, true);
                }
                float4  _S1436 = imp_3.angular_velocity_1;
                float stored_6;
                float diss_4;
                float3  f_13 = penalty_force_0(_S1390, _S1399, _S1403, dep_1 * imp_3.geom_0.x, nrm_1, vc_0 + cross_0(wc_0, p_9 - b_28.center_1) - (_S1412 + cross_0(float3 {_S1436.x, _S1436.y, _S1436.z}, p_9)), _S1343, j_3, &stored_6, &diss_4);
                float3  f_sum_1 = f_sum_0 + f_13;
                float3  t_sum_1 = t_sum_0 + cross_0(p_9 - b_28.center_1, f_13);
                float3  imp_f_1 = imp_f_0 - f_13;
                float3  imp_t_1 = imp_t_0 - cross_0(p_9, f_13);
                float diss_sum_3 = diss_sum_2 + diss_4;
                uint _S1437 = __ballot_sync(_S1413, true);
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                _S1413 = _S1437;
                j_4 = j_4 + lanes_6;
            }
            float3  _S1438 = pair_sum3_0(f_sum_0, lanes_6, _S1337);
            float3  _S1439 = pair_sum3_0(t_sum_0, lanes_6, _S1337);
            float3  _S1440 = pair_sum3_0(imp_f_0, lanes_6, _S1337);
            float3  _S1441 = pair_sum3_0(imp_t_0, lanes_6, _S1337);
            float _S1442 = pair_sum_0(diss_sum_2, lanes_6, _S1337);
            bool _S1443 = pair_any_0(hit_0, lanes_6, _S1337);
            uint _S1444 = __ballot_sync(_S1337, _S1336);
            if(_S1336)
            {
                comp_add1_0(&((&data_0)->z), &((&data_0)->w), _S1442);
            }
            hit_0 = _S1443;
            f_sum_0 = _S1438;
            t_sum_0 = _S1439;
            imp_f_0 = _S1440;
            imp_t_0 = _S1441;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S1344;
            t_sum_0 = _S1344;
            imp_f_0 = _S1344;
            imp_t_0 = _S1344;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S1344;
        t_sum_0 = _S1344;
        imp_f_0 = _S1344;
        imp_t_0 = _S1344;
    }
    if(lane_2 != 0U)
    {
        return;
    }
    uint _S1445 = __ldg(&globalParams_0->params_0->slot_base_0);
    uint _S1446 = 2U * _S1341;
    *(&(globalParams_0->scratch_0)[_S1445 + _S1446]) = make_float4 (f_sum_0.x, f_sum_0.y, f_sum_0.z, 0.0f);
    uint _S1447 = __ldg(&globalParams_0->params_0->slot_base_0);
    *(&(globalParams_0->scratch_0)[_S1447 + _S1446 + 1U]) = make_float4 (t_sum_0.x, t_sum_0.y, t_sum_0.z, 0.0f);
    uint _S1448 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S1448 + _S1339]) = data_0;
    uint _S1449 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S1449 + _S1339 + 1U]) = make_float4 (imp_f_0.x, imp_f_0.y, imp_f_0.z, 0.0f);
    uint _S1450 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S1450 + _S1339 + 2U]) = make_float4 (imp_t_0.x, imp_t_0.y, imp_t_0.z, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(2U);
    }
    return;
}

static __device__ void travel_check_0(uint c_26)
{
    ChunkStatic_0 * _S1451 = (&(globalParams_0->chunks_0)[c_26]);
    uint4  _S1452 = __ldg(&_S1451->cinfo_0);
    if((_S1452.z) == 0U)
    {
        return;
    }
    uint _S1453 = __ldg(&globalParams_0->params_0->cplan_base_0);
    uint _S1454 = 4U * c_26;
    uint at_5 = _S1453 + _S1454;
    float4  * _S1455 = (&(globalParams_0->scratch_0)[at_5]);
    float4  start_hi_0 = *_S1455;
    float4  * _S1456 = (&(globalParams_0->scratch_0)[at_5 + 1U]);
    float4  start_lo_0 = *_S1456;
    float4  start_rot_0 = *(&(globalParams_0->scratch_0)[at_5 + 2U]);
    float4  start_vel_0 = *(&(globalParams_0->scratch_0)[at_5 + 3U]);
    WorldPoint_0 wp_0 = chunk_world_0(c_26);
    float4  _S1457 = *_S1455;
    float4  _S1458 = *_S1456;
    float3  moved_0 = wp_0.hi_3 - float3 {_S1457.x, _S1457.y, _S1457.z} + (wp_0.lo_3 - float3 {_S1458.x, _S1458.y, _S1458.z}) + wp_0.rel_0;
    float _S1459 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S1460 = _S1459 - start_vel_0.w;
    float _S1461 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S1462 = _S1460 + (_S1461 - start_lo_0.w);
    uint4  _S1463 = __ldg(&_S1451->info_0);
    uint _S1464 = _S1463.y;
    uint _S1465 = (&(globalParams_0->islands_0)[_S1464])->info_1.w;
    uint _S1466 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S1467 = float(_S1465 - _S1466);
    float _S1468 = __ldg(&globalParams_0->params_0->dt_0);
    float since_0 = _S1462 + _S1467 * _S1468;
    float3  _S1469 = float3 {start_vel_0.x, start_vel_0.y, start_vel_0.z} * make_float3 (since_0);
    uint _S1470 = _S1452.w;
    float3  _S1471;
    if((_S1470 & 2U) != 0U)
    {
        float4  _S1472 = __ldg(&globalParams_0->params_0->gravity_0);
        _S1471 = make_float3 (0.5f) * float3 {_S1472.x, _S1472.y, _S1472.z} * make_float3 (since_0) * make_float3 (since_0);
    }
    else
    {
        _S1471 = make_float3 (0.0f);
    }
    float travel_0 = length_0(moved_0 - (_S1469 + _S1471));
    float travel_1;
    if((_S1470 & 1U) != 0U)
    {
        float4  _S1473 = *(&(globalParams_0->state_0)[_S1454 + 1U]);
        float3  th_4 = float3 {_S1473.x, _S1473.y, _S1473.z};
        Quat_0 _S1474 = from_axis_angle_0(th_4, length_0(th_4));
        Quat_0 _S1475 = quat_of_0((&(globalParams_0->islands_0)[_S1464])->rotation_0);
        Quat_0 _S1476 = _S1474;
        Quat_0 _S1477 = quat_mul_0(&_S1475, &_S1476);
        Quat_0 _S1478 = quat_of_0(make_float4 ((- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).x, (- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).y, (- float3 {start_rot_0.x, start_rot_0.y, start_rot_0.z}).z, start_rot_0.w));
        Quat_0 _S1479 = _S1477;
        Quat_0 _S1480 = quat_mul_0(&_S1478, &_S1479);
        float _S1481 = 2.0f * (F32_atan2((length_0(make_float3 (_S1480.x_1, _S1480.y_1, _S1480.z_0))), ((F32_abs((_S1480.w_0))))));
        float4  _S1482 = __ldg(&_S1451->half_0);
        travel_1 = travel_0 + _S1481 * _S1482.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (start_hi_0.w))
    {
        uint _S1483 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S1484 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S1483])->info_1)->z) = ((&(globalParams_0->islands_0)[_S1484])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

static __device__ void impactor_travel_check_0(uint ii_0)
{
    Impactor_0 * _S1485 = (&(globalParams_0->impactors_0)[ii_0]);
    uint _S1486 = __ldg(&globalParams_0->params_0->iplan_base_0);
    uint at_6 = _S1486 + 4U * ii_0;
    float4  start_hi_1 = *(&(globalParams_0->scratch_0)[at_6]);
    uint4  _S1487 = _S1485->cand_0;
    bool _S1488;
    if((_S1485->cand_0.z) != 0U)
    {
        _S1488 = true;
    }
    else
    {
        _S1488 = (start_hi_1.w) <= 0.0f;
    }
    if(_S1488)
    {
        return;
    }
    float4  start_lo_1 = *(&(globalParams_0->scratch_0)[at_6 + 1U]);
    float4  start_rot_1 = *(&(globalParams_0->scratch_0)[at_6 + 2U]);
    float4  start_vel_1 = *(&(globalParams_0->scratch_0)[at_6 + 3U]);
    float _S1489 = __ldg(&globalParams_0->params_0->t_hi_0);
    float _S1490 = _S1489 - start_vel_1.w;
    float _S1491 = __ldg(&globalParams_0->params_0->t_lo_0);
    float _S1492 = _S1490 + (_S1491 - start_lo_1.w);
    uint _S1493 = _S1487.w;
    uint _S1494 = __ldg(&globalParams_0->params_0->step_start_0);
    float _S1495 = float(_S1493 - _S1494);
    float _S1496 = __ldg(&globalParams_0->params_0->dt_0);
    float since_1 = _S1492 + _S1495 * _S1496;
    float4  _S1497 = _S1485->position_1;
    float4  _S1498 = _S1485->position_err_1;
    float3  moved_1 = float3 {_S1497.x, _S1497.y, _S1497.z} - float3 {start_hi_1.x, start_hi_1.y, start_hi_1.z} + (float3 {_S1498.x, _S1498.y, _S1498.z} - float3 {start_lo_1.x, start_lo_1.y, start_lo_1.z});
    float3  _S1499 = float3 {start_vel_1.x, start_vel_1.y, start_vel_1.z} * make_float3 (since_1);
    float4  _S1500 = __ldg(&globalParams_0->params_0->gravity_0);
    float3  expected_0 = _S1499 + make_float3 (0.5f) * float3 {_S1500.x, _S1500.y, _S1500.z} * make_float3 (since_1) * make_float3 (since_1);
    Quat_0 _S1501 = quat_of_0(_S1485->rotation_1);
    Quat_0 _S1502 = quat_of_0(make_float4 ((- float3 {start_rot_1.x, start_rot_1.y, start_rot_1.z}).x, (- float3 {start_rot_1.x, start_rot_1.y, start_rot_1.z}).y, (- float3 {start_rot_1.x, start_rot_1.y, start_rot_1.z}).z, start_rot_1.w));
    Quat_0 _S1503 = _S1501;
    Quat_0 _S1504 = quat_mul_0(&_S1502, &_S1503);
    if((length_0(moved_1 - expected_0) + 2.0f * (F32_atan2((length_0(make_float3 (_S1504.x_1, _S1504.y_1, _S1504.z_0))), ((F32_abs((_S1504.w_0)))))) * _S1485->half_1.w) > (start_hi_1.w))
    {
        uint _S1505 = __ldg(&globalParams_0->params_0->halt_index_0);
        uint _S1506 = __ldg(&globalParams_0->params_0->halt_index_0);
        *&((&(&(globalParams_0->islands_0)[_S1505])->info_1)->z) = ((&(globalParams_0->islands_0)[_S1506])->info_1.z) | 1U;
        sentinel_mark_0(1048576U);
    }
    return;
}

extern "C" __global__ void contact_forces()
{
    uint _S1507 = 0U;
    uint3  _S1508 = blockIdx * blockDim + threadIdx;
    uint _S1509 = __ballot_sync(4294967295U, true);
    uint i_17 = _S1508.x;
    uint lanes_7 = pair_lane_count_0();
    uint _S1510 = __ldg(&globalParams_0->params_0->pair_count_0);
    uint pair_threads_0 = _S1510 * lanes_7;
    bool _S1511 = i_17 < pair_threads_0;
    uint _S1512 = __ballot_sync(_S1509, _S1511);
    if(_S1511)
    {
        bool _S1513 = pair_any_0(stopped_0(), lanes_7, _S1512);
        bool _S1514 = !_S1513;
        uint _S1515 = __ballot_sync(_S1512, _S1514);
        if(_S1514)
        {
            uint _S1516 = i_17 / lanes_7;
            uint _S1517 = i_17 % lanes_7;
            pair_contact_0(_S1516, _S1517, lanes_7, _S1515);
            uint _S1518 = __ballot_sync(_S1512, true);
        }
        return;
    }
    else
    {
        uint _S1519 = __ballot_sync(_S1509, true);
        _S1507 = _S1519;
    }
    uint j_5 = i_17 - pair_threads_0;
    uint _S1520 = __ldg(&globalParams_0->params_0->cand_count_0);
    uint cand_threads_0 = _S1520 * lanes_7;
    bool _S1521 = j_5 < cand_threads_0;
    uint _S1522 = __ballot_sync(_S1507, _S1521);
    if(_S1521)
    {
        bool _S1523 = pair_any_0(stopped_0(), lanes_7, _S1522);
        bool _S1524 = !_S1523;
        uint _S1525 = __ballot_sync(_S1522, _S1524);
        if(_S1524)
        {
            uint _S1526 = j_5 / lanes_7;
            uint _S1527 = j_5 % lanes_7;
            impactor_candidate_forces_0(_S1526, _S1527, lanes_7, _S1525);
            uint _S1528 = __ballot_sync(_S1522, true);
        }
        return;
    }
    uint _S1529 = j_5 - cand_threads_0;
    uint _S1530 = __ldg(&globalParams_0->params_0->chunk_count_0);
    bool _S1531;
    if(_S1529 < _S1530)
    {
        _S1531 = !stopped_0();
    }
    else
    {
        _S1531 = false;
    }
    if(_S1531)
    {
        travel_check_0(_S1529);
    }
    else
    {
        uint _S1532 = __ldg(&globalParams_0->params_0->chunk_count_0);
        uint _S1533 = _S1529 - _S1532;
        uint _S1534 = __ldg(&globalParams_0->params_0->impactor_count_0);
        if(_S1533 < _S1534)
        {
            _S1531 = !stopped_0();
        }
        else
        {
            _S1531 = false;
        }
        if(_S1531)
        {
            uint _S1535 = __ldg(&globalParams_0->params_0->chunk_count_0);
            impactor_travel_check_0(_S1529 - _S1535);
        }
    }
    return;
}

static __device__ uint impactor_contact_count_0(uint _S1536, float _S1537, Box_0 * _S1538, Box_0 * _S1539)
{
    Impactor_0 _S1540 = *(&(globalParams_0->impactors_0)[_S1536]);
    uint j_6 = 0U;
    uint count_4 = 0U;
    for(;;)
    {
        Impactor_0 _S1541 = _S1540;
        uint _S1542 = impactor_slots_0(&_S1541, _S1539);
        if(j_6 < _S1542)
        {
        }
        else
        {
            break;
        }
        float3  p_10;
        float3  n_8;
        float d_12;
        bool _S1543 = impactor_contact_1(_S1536, _S1537, _S1538, _S1539, j_6, &p_10, &n_8, &d_12);
        if(_S1543)
        {
            count_4 = count_4 + 1U;
        }
        j_6 = j_6 + 1U;
    }
    return count_4;
}

extern "C" __global__ void impactor_shares()
{
    uint k_16 = (blockIdx * blockDim + threadIdx).x;
    uint _S1544 = __ldg(&globalParams_0->params_0->cand_count_0);
    bool _S1545;
    if(k_16 >= _S1544)
    {
        _S1545 = true;
    }
    else
    {
        _S1545 = stopped_0();
    }
    if(_S1545)
    {
        return;
    }
    uint _S1546 = __ldg(&globalParams_0->params_0->cand_index_0);
    uint _S1547 = 3U * k_16;
    uint at_7 = _S1546 + _S1547;
    uint _S1548 = __ldg((&(globalParams_0->index_0)[at_7]));
    uint _S1549 = __ldg((&(globalParams_0->index_0)[at_7 + 2U]));
    Impactor_0 * _S1550 = (&(globalParams_0->impactors_0)[_S1549]);
    Impactor_0 imp_4 = *_S1550;
    if(((*_S1550).cand_0.z) == 0U)
    {
        _S1545 = (imp_4.crush_1.x) > 0.0f;
    }
    else
    {
        _S1545 = false;
    }
    float total_1;
    float ksum_0;
    if(_S1545)
    {
        WorldPoint_0 _S1551 = impactor_point_0(_S1549);
        WorldPoint_0 _S1552 = chunk_world_0(_S1548);
        WorldPoint_0 _S1553 = _S1551;
        float3  _S1554 = world_diff_0(&_S1552, &_S1553);
        float _S1555 = length_0(_S1554);
        float _S1556 = imp_4.half_1.w;
        float4  _S1557 = __ldg(&(&(globalParams_0->chunks_0)[_S1548])->half_0);
        if(!(_S1555 > (_S1556 + _S1557.w)))
        {
            float4  _S1558 = imp_4.half_1;
            Box_0 _S1559 = impactor_box_1(_S1549, make_float3 (0.0f), float3 {_S1558.x, _S1558.y, _S1558.z});
            Box_0 b_29 = chunk_box_0(_S1548, _S1554);
            float _S1560 = imp_4.mat_0.x;
            float4  _S1561 = __ldg(&(&(globalParams_0->chunks_0)[_S1548])->cmat_0);
            float _S1562 = _S1561.x;
            float3  _S1563 = b_29.center_1 - _S1559.center_1;
            Box_0 _S1564 = _S1559;
            Box_0 _S1565 = b_29;
            float _S1566 = contact_stiffness_0(_S1560, &_S1564, _S1562, &_S1565, _S1563);
            float _S1567 = imp_4.crush_1.w;
            Box_0 _S1568 = _S1559;
            Box_0 _S1569 = impactor_shrunk_0(_S1549, _S1567, &_S1568);
            Box_0 _S1570 = _S1569;
            Box_0 _S1571 = b_29;
            uint _S1572 = impactor_contact_count_0(_S1549, _S1567, &_S1570, &_S1571);
            float _S1573;
            if((imp_4.shape_0.x) == 0.0f)
            {
                _S1573 = _S1566;
            }
            else
            {
                _S1573 = _S1566 / (F32_max((float(_S1572)), (10.0f)));
            }
            uint j_7 = 0U;
            total_1 = 0.0f;
            ksum_0 = 0.0f;
            for(;;)
            {
                if(_S1572 > 0U)
                {
                    Impactor_0 _S1574 = imp_4;
                    Box_0 _S1575 = b_29;
                    uint _S1576 = impactor_slots_0(&_S1574, &_S1575);
                    _S1545 = j_7 < _S1576;
                }
                else
                {
                    _S1545 = false;
                }
                if(_S1545)
                {
                }
                else
                {
                    break;
                }
                Impactor_0 _S1577 = imp_4;
                Box_0 _S1578 = _S1569;
                Box_0 _S1579 = b_29;
                float3  p_11;
                float3  nrm_2;
                float dep_2;
                bool _S1580 = impactor_contact_0(&_S1577, _S1567, &_S1578, &_S1579, j_7, &p_11, &nrm_2, &dep_2);
                if(!_S1580)
                {
                    j_7 = j_7 + 1U;
                    continue;
                }
                float ksum_1 = ksum_0 + _S1573;
                total_1 = total_1 + _S1573 * dep_2;
                ksum_0 = ksum_1;
                j_7 = j_7 + 1U;
            }
        }
        else
        {
            total_1 = 0.0f;
            ksum_0 = 0.0f;
        }
    }
    else
    {
        total_1 = 0.0f;
        ksum_0 = 0.0f;
    }
    uint _S1581 = __ldg(&globalParams_0->params_0->cand_base_0);
    float4  data_1 = *(&(globalParams_0->scratch_0)[_S1581 + _S1547]);
    uint _S1582 = __ldg(&globalParams_0->params_0->cand_base_0);
    *(&(globalParams_0->scratch_0)[_S1582 + _S1547]) = make_float4 (total_1, ksum_0, data_1.z, data_1.w);
    return;
}

extern "C" __global__ void impactor_crush()
{
    uint _S1583;
    uint _S1584 = __ballot_sync(4294967295U, true);
    uint ii_1 = blockIdx.x;
    uint tid_6 = threadIdx.x;
    uint _S1585 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S1586 = ii_1 >= _S1585;
    uint _S1587 = __ballot_sync(_S1584, _S1586);
    bool _S1588;
    uint k_17;
    if(_S1586)
    {
        uint _S1589 = __ballot_sync(_S1584, true);
        _S1588 = true;
        k_17 = _S1589;
    }
    else
    {
        bool _S1590 = stopped_0();
        uint _S1591 = __ballot_sync(_S1584, true);
        _S1588 = _S1590;
        k_17 = _S1591;
    }
    uint _S1592 = 0U;
    uint _S1593 = __ballot_sync(k_17, _S1588);
    if(_S1588)
    {
        return;
    }
    else
    {
        uint _S1594 = __ballot_sync(k_17, true);
        _S1592 = _S1594;
    }
    Impactor_0 imp_5 = *(&(globalParams_0->impactors_0)[ii_1]);
    float4  _S1595 = make_float4 (0.0f);
    float4  shares_0 = _S1595;
    float4  unused_2 = _S1595;
    k_17 = (&imp_5)->cand_0.x + tid_6;
    uint _S1596;
    _S1596 = _S1592;
    for(;;)
    {
        bool _S1597 = k_17 < ((&imp_5)->cand_0.y);
        uint _S1598 = __ballot_sync(_S1596, _S1597);
        if(_S1597)
        {
            uint _S1599 = __ballot_sync(_S1596, true);
        }
        else
        {
            uint _S1600 = __ballot_sync(_S1596, false);
            uint _S1601 = __ballot_sync(_S1596, false);
            uint _S1602 = __ballot_sync(_S1592, true);
            _S1583 = _S1602;
            break;
        }
        uint _S1603 = __ldg(&globalParams_0->params_0->cand_base_0);
        shares_0 = shares_0 + *(&(globalParams_0->scratch_0)[_S1603 + 3U * k_17]);
        uint _S1604 = __ballot_sync(_S1596, true);
        k_17 = k_17 + 256U;
        _S1596 = _S1604;
    }
    group_sum2_0(tid_6, &shares_0, &unused_2, _S1583);
    bool _S1605 = tid_6 != 0U;
    uint _S1606 = __ballot_sync(_S1583, _S1605);
    if(_S1605)
    {
        _S1588 = true;
    }
    else
    {
        _S1588 = ((&imp_5)->cand_0.z) != 0U;
    }
    if(_S1588)
    {
        return;
    }
    (&imp_5)->geom_0 = make_float4 (1.0f, (&imp_5)->crush_1.w, 0.0f, 0.0f);
    float total_2 = shares_0.x;
    if(((&imp_5)->crush_1.x) > 0.0f)
    {
        _S1588 = ((&imp_5)->crush_1.z) < ((&imp_5)->crush_1.y);
    }
    else
    {
        _S1588 = false;
    }
    if(_S1588)
    {
        _S1588 = total_2 > ((&imp_5)->crush_1.x);
    }
    else
    {
        _S1588 = false;
    }
    if(_S1588)
    {
        float extra_0 = (total_2 - (&imp_5)->crush_1.x) / shares_0.y;
        *&((&(&imp_5)->crush_1)->w) = *&((&(&imp_5)->crush_1)->w) + extra_0;
        *&((&(&imp_5)->crush_1)->z) = *&((&(&imp_5)->crush_1)->z) + (&imp_5)->crush_1.x * extra_0;
        comp_add1_0(&((&(&imp_5)->ledger_0)->z), &((&(&imp_5)->ledger_0)->w), (&imp_5)->crush_1.x * extra_0);
        comp_add1_0(&((&(&imp_5)->ledger_0)->x), &((&(&imp_5)->ledger_0)->y), (&imp_5)->crush_1.x * extra_0);
        *&((&(&imp_5)->geom_0)->x) = (&imp_5)->crush_1.x / total_2;
    }
    *(&(globalParams_0->impactors_0)[ii_1]) = imp_5;
    return;
}

struct WideGroup_0
{
    uint island_2;
    uint begin_0;
    uint end_0;
    uint first_0;
};

static __device__ WideGroup_0 wide_group_0(uint table_0, uint g_1)
{
    WideGroup_0 w_8;
    uint _S1607 = table_0 + 4U * g_1;
    uint _S1608 = __ldg((&(globalParams_0->index_0)[_S1607]));
    (&w_8)->island_2 = _S1608;
    uint _S1609 = __ldg((&(globalParams_0->index_0)[_S1607 + 1U]));
    (&w_8)->begin_0 = _S1609;
    uint _S1610 = __ldg((&(globalParams_0->index_0)[_S1607 + 2U]));
    (&w_8)->end_0 = _S1610;
    uint _S1611 = __ldg((&(globalParams_0->index_0)[_S1607 + 3U]));
    (&w_8)->first_0 = _S1611;
    return w_8;
}

static __device__ bool wide_runs_0(Island_0 * isl_11)
{
    uint4  _S1612 = isl_11->info_1;
    bool _S1613;
    if(((isl_11->info_1.z) & 1U) != 0U)
    {
        _S1613 = true;
    }
    else
    {
        _S1613 = (_S1612.y) == 0U;
    }
    if(_S1613)
    {
        return false;
    }
    if(((_S1612.x) & 4U) == 0U)
    {
        _S1613 = true;
    }
    else
    {
        bool _S1614 = contact_stopped_0(isl_11);
        _S1613 = !_S1614;
    }
    return _S1613;
}

__device__ __shared__ uint g_wide_run_0;

static __device__ bool wide_enter_0(uint tid_7, Island_0 * isl_12)
{
    seen_clear_0(tid_7);
    if(tid_7 == 0U)
    {
        bool _S1615 = wide_runs_0(isl_12);
        int _S1616;
        if(_S1615)
        {
            _S1616 = int(1);
        }
        else
        {
            _S1616 = int(0);
        }
        *&g_wide_run_0 = uint(_S1616);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

static __device__ uint wide_step_0(Island_0 * isl_13)
{
    uint _S1617 = isl_13->info_1.w;
    uint _S1618 = __ldg(&globalParams_0->params_0->step_start_0);
    return _S1617 - _S1618;
}

static __device__ bool wide_enter_1(uint _S1619, uint _S1620)
{
    Island_0 _S1621 = *(&(globalParams_0->islands_0)[_S1620]);
    seen_clear_0(_S1619);
    if(_S1619 == 0U)
    {
        Island_0 _S1622 = _S1621;
        bool _S1623 = wide_runs_0(&_S1622);
        int _S1624;
        if(_S1623)
        {
            _S1624 = int(1);
        }
        else
        {
            _S1624 = int(0);
        }
        *&g_wide_run_0 = uint(_S1624);
    }
    __syncthreads();
    return (*&g_wide_run_0) != 0U;
}

extern "C" __global__ void wide_wake()
{
    uint _S1625 = 0U;
    uint _S1626;
    uint _S1627 = __ballot_sync(4294967295U, true);
    uint tid_8 = threadIdx.x;
    uint _S1628 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1629 = blockIdx.x;
    WideGroup_0 wg_0 = wide_group_0(_S1628, _S1629);
    bool _S1630 = _S1629 != (wg_0.first_0);
    uint _S1631 = __ballot_sync(_S1627, _S1630);
    if(_S1630)
    {
        return;
    }
    else
    {
        uint _S1632 = __ballot_sync(_S1627, true);
        _S1625 = _S1632;
    }
    Island_0 * _S1633 = (&(globalParams_0->islands_0)[wg_0.island_2]);
    Island_0 isl_14 = *_S1633;
    uint _S1634 = (*_S1633).info_1.x;
    bool _S1635 = (_S1634 & 16U) == 0U;
    uint _S1636 = __ballot_sync(_S1625, _S1635);
    bool _S1637;
    uint c_27;
    if(_S1635)
    {
        uint _S1638 = __ballot_sync(_S1625, true);
        _S1637 = true;
        c_27 = _S1638;
    }
    else
    {
        bool _S1639 = wide_enter_1(tid_8, wg_0.island_2);
        bool _S1640 = !_S1639;
        uint _S1641 = __ballot_sync(_S1625, true);
        _S1637 = _S1640;
        c_27 = _S1641;
    }
    uint _S1642 = 0U;
    uint _S1643 = __ballot_sync(c_27, _S1637);
    if(_S1637)
    {
        return;
    }
    else
    {
        uint _S1644 = __ballot_sync(c_27, true);
        _S1642 = _S1644;
    }
    Quat_0 _S1645 = quat_of_0(isl_14.rotation_0);
    bool _S1646 = (_S1634 & 4U) != 0U;
    float3  _S1647 = make_float3 (0.0f);
    float3  norm_2 = _S1647;
    float3  unused_3 = _S1647;
    c_27 = isl_14.range_0.x + tid_8;
    uint cov_10;
    cov_10 = _S1642;
    for(;;)
    {
        bool _S1648 = c_27 < (isl_14.range_0.y);
        uint _S1649 = __ballot_sync(cov_10, _S1648);
        if(_S1648)
        {
            uint _S1650 = __ballot_sync(cov_10, true);
        }
        else
        {
            uint _S1651 = __ballot_sync(cov_10, false);
            uint _S1652 = __ballot_sync(cov_10, false);
            uint _S1653 = __ballot_sync(_S1642, true);
            _S1626 = _S1653;
            break;
        }
        Island_0 _S1654 = isl_14;
        uint _S1655 = wide_step_0(&_S1654);
        float _S1656 = __ldg(&globalParams_0->params_0->dt_0);
        Quat_0 _S1657 = _S1645;
        float _S1658 = settled_chunk_load_0(c_27, &_S1657, _S1655, _S1656, _S1646);
        *&((&norm_2)->x) = *&((&norm_2)->x) + _S1658;
        uint _S1659 = __ballot_sync(cov_10, true);
        c_27 = c_27 + 256U;
        cov_10 = _S1659;
    }
    group_sum3_0(tid_8, &norm_2, &unused_3, _S1626);
    bool _S1660 = tid_8 != 0U;
    uint _S1661 = __ballot_sync(_S1626, _S1660);
    if(_S1660)
    {
        return;
    }
    uint cov_11 = 1024U | (seen_bits_0());
    uint _S1662 = __ldg(&globalParams_0->params_0->solve_mode_0);
    if(_S1662 == 1U)
    {
        _S1637 = (F32_abs((norm_2.x - isl_14.energy_1.z))) > (isl_14.energy_1.w);
    }
    else
    {
        _S1637 = false;
    }
    if(_S1637)
    {
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->x) = _S1634 & 4294967279U;
        *&((&(&(globalParams_0->islands_0)[wg_0.island_2])->info_1)->z) = (isl_14.info_1.z) | 4U;
        cov_10 = cov_11 | 2048U;
    }
    else
    {
        cov_10 = cov_11;
    }
    cov_mark_0(wg_0.island_2, isl_14.coverage_0, cov_10);
    return;
}

static __device__ void wide_partials_0(uint tid_9, uint first_1, uint count_5, uint p_12, float3  * a_16, float3  * b_30, uint _S1663)
{
    uint _S1664;
    float4  _S1665 = make_float4 (0.0f);
    float4  x_24 = _S1665;
    float4  y_5 = _S1665;
    uint s_5 = tid_9;
    uint _S1666 = _S1663;
    for(;;)
    {
        bool _S1667 = s_5 < count_5;
        uint _S1668 = __ballot_sync(_S1666, _S1667);
        if(_S1667)
        {
            uint _S1669 = __ballot_sync(_S1666, true);
        }
        else
        {
            uint _S1670 = __ballot_sync(_S1666, false);
            uint _S1671 = __ballot_sync(_S1666, false);
            uint _S1672 = __ballot_sync(_S1663, true);
            _S1664 = _S1672;
            break;
        }
        uint _S1673 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S1674 = 8U * (first_1 + s_5);
        x_24 = x_24 + *(&(globalParams_0->scratch_0)[_S1673 + _S1674 + p_12]);
        uint _S1675 = __ldg(&globalParams_0->params_0->wide_base_0);
        y_5 = y_5 + *(&(globalParams_0->scratch_0)[_S1675 + _S1674 + p_12 + 1U]);
        uint _S1676 = __ballot_sync(_S1666, true);
        s_5 = s_5 + 256U;
        _S1666 = _S1676;
    }
    group_sum2_0(tid_9, &x_24, &y_5, _S1664);
    float4  _S1677 = x_24;
    *a_16 = float3 {_S1677.x, _S1677.y, _S1677.z};
    float4  _S1678 = y_5;
    *b_30 = float3 {_S1678.x, _S1678.y, _S1678.z};
    return;
}

static __device__ void wide_store_0(uint slot_1, uint p_13, float3  a_17, float3  b_31)
{
    uint _S1679 = __ldg(&globalParams_0->params_0->wide_base_0);
    uint _S1680 = 8U * slot_1;
    *(&(globalParams_0->scratch_0)[_S1679 + _S1680 + p_13]) = make_float4 (a_17.x, a_17.y, a_17.z, 0.0f);
    uint _S1681 = __ldg(&globalParams_0->params_0->wide_base_0);
    *(&(globalParams_0->scratch_0)[_S1681 + _S1680 + p_13 + 1U]) = make_float4 (b_31.x, b_31.y, b_31.z, 0.0f);
    return;
}

extern "C" __global__ void wide_drift()
{
    uint _S1682 = __ballot_sync(4294967295U, true);
    uint tid_10 = threadIdx.x;
    uint _S1683 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1684 = blockIdx.x;
    WideGroup_0 wg_1 = wide_group_0(_S1683, _S1684);
    Island_0 * _S1685 = (&(globalParams_0->islands_0)[wg_1.island_2]);
    Island_0 isl_15 = *_S1685;
    bool _S1686 = (((*_S1685).info_1.x) & 17U) != 0U;
    uint _S1687 = __ballot_sync(_S1682, _S1686);
    bool _S1688;
    uint _S1689;
    if(_S1686)
    {
        uint _S1690 = __ballot_sync(_S1682, true);
        _S1688 = true;
        _S1689 = _S1690;
    }
    else
    {
        bool _S1691 = wide_enter_1(tid_10, wg_1.island_2);
        bool _S1692 = !_S1691;
        uint _S1693 = __ballot_sync(_S1682, true);
        _S1688 = _S1692;
        _S1689 = _S1693;
    }
    uint _S1694 = 0U;
    uint _S1695 = __ballot_sync(_S1689, _S1688);
    if(_S1688)
    {
        return;
    }
    else
    {
        uint _S1696 = __ballot_sync(_S1689, true);
        _S1694 = _S1696;
    }
    float3  tu_3;
    float3  pv_3;
    wide_partials_0(tid_10, wg_1.first_0, isl_15.wide_groups_0, 2U, &tu_3, &pv_3, _S1694);
    float _S1697 = isl_15.wcom_0.w;
    float3  tr_5 = tu_3 / make_float3 (_S1697);
    float3  dv_5 = pv_3 / make_float3 (_S1697);
    float3  _S1698 = make_float3 (0.0f);
    float3  lu_3 = _S1698;
    float3  lv_3 = _S1698;
    uint c_28 = wg_1.begin_0 + tid_10;
    bool _S1699 = c_28 < (wg_1.end_0);
    uint _S1700 = __ballot_sync(_S1694, _S1699);
    if(_S1699)
    {
        float4  _S1701 = isl_15.wcom_0;
        drift_angular_0(c_28, float3 {_S1701.x, _S1701.y, _S1701.z}, tr_5, dv_5, &lu_3, &lv_3);
        uint _S1702 = __ballot_sync(_S1694, true);
        _S1689 = _S1702;
    }
    else
    {
        uint _S1703 = __ballot_sync(_S1694, true);
        _S1689 = _S1703;
    }
    group_sum3_0(tid_10, &lu_3, &lv_3, _S1689);
    bool _S1704 = tid_10 == 0U;
    uint _S1705 = __ballot_sync(_S1689, _S1704);
    if(_S1704)
    {
        wide_store_0(_S1684, 4U, lu_3, lv_3);
    }
    return;
}

static __device__ Rigid_0 wide_rigid_frame_0(uint tid_11, Island_0 * isl_16, WideGroup_0 * wg_2, uint _S1706)
{
    Rigid_0 _S1707 = rigid_of_0(isl_16);
    Rigid_0 rg_9 = _S1707;
    bool _S1708 = ((isl_16->info_1.x) & 1U) == 0U;
    uint _S1709 = __ballot_sync(_S1706, _S1708);
    if(_S1708)
    {
        float3  f_14;
        float3  t_12;
        wide_partials_0(tid_11, wg_2->first_0, isl_16->wide_groups_0, 0U, &f_14, &t_12, _S1709);
        rigid_acceleration_0(isl_16, &rg_9, f_14, t_12);
        uint _S1710 = __ballot_sync(_S1706, true);
    }
    return rg_9;
}

extern "C" __global__ void wide_rigid()
{
    uint _S1711 = __ballot_sync(4294967295U, true);
    uint tid_12 = threadIdx.x;
    uint _S1712 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1713 = blockIdx.x;
    WideGroup_0 wg_3 = wide_group_0(_S1712, _S1713);
    Island_0 * _S1714 = (&(globalParams_0->islands_0)[wg_3.island_2]);
    Island_0 isl_17 = *_S1714;
    uint _S1715 = (*_S1714).info_1.x;
    bool _S1716 = (_S1715 & 1U) != 0U;
    uint _S1717 = __ballot_sync(_S1711, _S1716);
    bool _S1718;
    uint _S1719;
    if(_S1716)
    {
        uint _S1720 = __ballot_sync(_S1711, true);
        _S1718 = true;
        _S1719 = _S1720;
    }
    else
    {
        bool _S1721 = wide_enter_1(tid_12, wg_3.island_2);
        bool _S1722 = !_S1721;
        uint _S1723 = __ballot_sync(_S1711, true);
        _S1718 = _S1722;
        _S1719 = _S1723;
    }
    uint _S1724 = 0U;
    uint _S1725 = __ballot_sync(_S1719, _S1718);
    if(_S1718)
    {
        return;
    }
    else
    {
        uint _S1726 = __ballot_sync(_S1719, true);
        _S1724 = _S1726;
    }
    uint _S1727 = 0U;
    bool _S1728 = (_S1715 & 16U) != 0U;
    uint _S1729 = __ballot_sync(_S1724, _S1728);
    if(_S1728)
    {
        uint _S1730 = 0U;
        bool _S1731 = _S1713 != (wg_3.first_0);
        uint _S1732 = __ballot_sync(_S1729, _S1731);
        if(_S1731)
        {
            return;
        }
        else
        {
            uint _S1733 = __ballot_sync(_S1729, true);
            _S1730 = _S1733;
        }
        Island_0 _S1734 = isl_17;
        WideGroup_0 _S1735 = wg_3;
        Rigid_0 _S1736 = wide_rigid_frame_0(tid_12, &_S1734, &_S1735, _S1730);
        Rigid_0 rs_0 = _S1736;
        bool _S1737 = tid_12 != 0U;
        uint _S1738 = __ballot_sync(_S1730, _S1737);
        if(_S1737)
        {
            _S1718 = true;
        }
        else
        {
            _S1718 = (_S1715 & 2U) != 0U;
        }
        if(_S1718)
        {
            return;
        }
        float _S1739 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1740 = isl_17;
        integrate_rigid_0(&_S1740, &rs_0, _S1739);
        Quat_0 _S1741 = (&rs_0)->rot_0;
        float4  _S1742 = quat_vec_0(&_S1741);
        (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_0 = _S1742;
        (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_err_0 = (&rs_0)->rot_err_0;
        (&(globalParams_0->islands_0)[wg_3.island_2])->position_0 = make_float4 ((&rs_0)->pos_0.x, (&rs_0)->pos_0.y, (&rs_0)->pos_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->position_err_0 = make_float4 ((&rs_0)->pos_err_0.x, (&rs_0)->pos_err_0.y, (&rs_0)->pos_err_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_0 = make_float4 ((&rs_0)->vel_0.x, (&rs_0)->vel_0.y, (&rs_0)->vel_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_err_0 = make_float4 ((&rs_0)->vel_err_0.x, (&rs_0)->vel_err_0.y, (&rs_0)->vel_err_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->angular_velocity_0 = make_float4 ((&rs_0)->w_1.x, (&rs_0)->w_1.y, (&rs_0)->w_1.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_0 = make_float4 ((&rs_0)->l_0.x, (&rs_0)->l_0.y, (&rs_0)->l_0.z, 0.0f);
        (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_err_0 = make_float4 ((&rs_0)->l_err_0.x, (&rs_0)->l_err_0.y, (&rs_0)->l_err_0.z, 0.0f);
        return;
    }
    else
    {
        uint _S1743 = __ballot_sync(_S1724, true);
        _S1727 = _S1743;
    }
    float3  tu_4;
    float3  pv_4;
    wide_partials_0(tid_12, wg_3.first_0, isl_17.wide_groups_0, 2U, &tu_4, &pv_4, _S1727);
    float3  lu_4;
    float3  lv_4;
    wide_partials_0(tid_12, wg_3.first_0, isl_17.wide_groups_0, 4U, &lu_4, &lv_4, _S1727);
    float _S1744 = isl_17.wcom_0.w;
    float3  tr_6 = tu_4 / make_float3 (_S1744);
    float3  dv_6 = pv_4 / make_float3 (_S1744);
    float3  phi_5 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lu_4);
    float3  dw_4 = rows_mul_0(isl_17.winv0_0, isl_17.winv1_0, isl_17.winv2_0, lv_4);
    uint c_29 = wg_3.begin_0 + tid_12;
    bool _S1745 = c_29 < (wg_3.end_0);
    uint _S1746 = __ballot_sync(_S1727, _S1745);
    if(_S1745)
    {
        float4  _S1747 = isl_17.wcom_0;
        drift_apply_0(c_29, float3 {_S1747.x, _S1747.y, _S1747.z}, tr_6, phi_5, dv_6, dw_4);
        uint _S1748 = __ballot_sync(_S1727, true);
        _S1719 = _S1748;
    }
    else
    {
        uint _S1749 = __ballot_sync(_S1727, true);
        _S1719 = _S1749;
    }
    uint _S1750 = 0U;
    bool _S1751 = _S1713 != (wg_3.first_0);
    uint _S1752 = __ballot_sync(_S1719, _S1751);
    if(_S1751)
    {
        return;
    }
    else
    {
        uint _S1753 = __ballot_sync(_S1719, true);
        _S1750 = _S1753;
    }
    Island_0 _S1754 = isl_17;
    WideGroup_0 _S1755 = wg_3;
    Rigid_0 _S1756 = wide_rigid_frame_0(tid_12, &_S1754, &_S1755, _S1750);
    Rigid_0 rg_10 = _S1756;
    bool _S1757 = tid_12 != 0U;
    uint _S1758 = __ballot_sync(_S1750, _S1757);
    if(_S1757)
    {
        return;
    }
    if(!((_S1715 & 2U) != 0U))
    {
        float _S1759 = __ldg(&globalParams_0->params_0->dt_0);
        Island_0 _S1760 = isl_17;
        integrate_rigid_0(&_S1760, &rg_10, _S1759);
        Island_0 _S1761 = isl_17;
        drift_rigid_0(&_S1761, &rg_10, tr_6, phi_5, dv_6, dw_4);
    }
    Quat_0 _S1762 = (&rg_10)->rot_0;
    float4  _S1763 = quat_vec_0(&_S1762);
    (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_0 = _S1763;
    (&(globalParams_0->islands_0)[wg_3.island_2])->rotation_err_0 = (&rg_10)->rot_err_0;
    (&(globalParams_0->islands_0)[wg_3.island_2])->position_0 = make_float4 ((&rg_10)->pos_0.x, (&rg_10)->pos_0.y, (&rg_10)->pos_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->position_err_0 = make_float4 ((&rg_10)->pos_err_0.x, (&rg_10)->pos_err_0.y, (&rg_10)->pos_err_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_0 = make_float4 ((&rg_10)->vel_0.x, (&rg_10)->vel_0.y, (&rg_10)->vel_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->velocity_err_0 = make_float4 ((&rg_10)->vel_err_0.x, (&rg_10)->vel_err_0.y, (&rg_10)->vel_err_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->angular_velocity_0 = make_float4 ((&rg_10)->w_1.x, (&rg_10)->w_1.y, (&rg_10)->w_1.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_0 = make_float4 ((&rg_10)->l_0.x, (&rg_10)->l_0.y, (&rg_10)->l_0.z, 0.0f);
    (&(globalParams_0->islands_0)[wg_3.island_2])->momentum_err_0 = make_float4 ((&rg_10)->l_err_0.x, (&rg_10)->l_err_0.y, (&rg_10)->l_err_0.z, 0.0f);
    return;
}

__device__ __shared__ FixedArray<uint, 4096>  g_label_0;

__device__ __shared__ uint g_changed_0;

static __device__ bool island_connected_0(uint tid_13, Island_0 * isl_18)
{
    uint _S1764 = isl_18->range_0.x;
    uint n_9 = isl_18->range_0.y - _S1764;
    bool converged_2;
    if(n_9 > 4096U)
    {
        converged_2 = true;
    }
    else
    {
        uint _S1765 = __ldg(&globalParams_0->params_0->device_connect_0);
        converged_2 = _S1765 == 0U;
    }
    if(converged_2)
    {
        return false;
    }
    uint c_30 = tid_13;
    for(;;)
    {
        if(c_30 < n_9)
        {
        }
        else
        {
            break;
        }
        (*&g_label_0)[c_30] = c_30;
        c_30 = c_30 + 256U;
    }
    __syncthreads();
    converged_2 = false;
    uint pass_1 = 0U;
    for(;;)
    {
        if(pass_1 <= n_9)
        {
        }
        else
        {
            break;
        }
        if(tid_13 == 0U)
        {
            *&g_changed_0 = 0U;
        }
        __syncthreads();
        c_30 = tid_13;
        for(;;)
        {
            if(c_30 < n_9)
            {
            }
            else
            {
                break;
            }
            uint _S1766 = (*&g_label_0)[c_30];
            uint gc_1 = _S1764 + c_30;
            uint _S1767 = __ldg((&(globalParams_0->index_0)[gc_1]));
            uint l_5 = _S1766;
            uint e_4 = _S1767;
            for(;;)
            {
                uint _S1768 = __ldg((&(globalParams_0->index_0)[gc_1 + 1U]));
                if(e_4 < _S1768)
                {
                }
                else
                {
                    break;
                }
                uint _S1769 = __ldg((&(globalParams_0->index_0)[e_4]));
                uint bond_1 = _S1769 >> int(1);
                JointBond_0 _S1770 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_1])->law_0);
                bool _S1771 = (_S1770.stiff1_0.w) != 0.0f;
                JointState_0 _S1772 = (&(globalParams_0->bond_dyn_0)[bond_1])->js_0;
                bool _S1773 = connected_0(&_S1772, _S1771);
                if(!_S1773)
                {
                    e_4 = e_4 + 1U;
                    continue;
                }
                uint other_1;
                if((_S1769 & 1U) == 0U)
                {
                    JointBond_0 _S1774 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_1])->law_0);
                    other_1 = _S1774.ids_0.z;
                }
                else
                {
                    JointBond_0 _S1775 = slang_ldg_0(&(&(globalParams_0->bonds_0)[bond_1])->law_0);
                    other_1 = _S1775.ids_0.y;
                }
                l_5 = (U32_min((l_5), ((*&g_label_0)[other_1 - _S1764])));
                e_4 = e_4 + 1U;
            }
            uint _S1776 = (U32_min((l_5), ((*&g_label_0)[l_5])));
            if(_S1776 < (*&g_label_0)[c_30])
            {
                (*&g_label_0)[c_30] = _S1776;
                *&g_changed_0 = 1U;
            }
            c_30 = c_30 + 256U;
        }
        __syncthreads();
        bool converged_3 = (*&g_changed_0) == 0U;
        __syncthreads();
        if(converged_3)
        {
            converged_2 = converged_3;
            break;
        }
        uint _S1777 = pass_1 + 1U;
        converged_2 = converged_3;
        pass_1 = _S1777;
    }
    if(!converged_2)
    {
        return false;
    }
    if(tid_13 == 0U)
    {
        *&g_changed_0 = 0U;
    }
    __syncthreads();
    c_30 = tid_13;
    for(;;)
    {
        if(c_30 < n_9)
        {
        }
        else
        {
            break;
        }
        if(((*&g_label_0)[c_30]) != 0U)
        {
            *&g_changed_0 = 1U;
        }
        c_30 = c_30 + 256U;
    }
    __syncthreads();
    return (*&g_changed_0) == 0U;
}

extern "C" __global__ void wide_end()
{
    uint _S1778 = 0U;
    uint _S1779 = __ballot_sync(4294967295U, true);
    uint tid_14 = threadIdx.x;
    uint _S1780 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    uint _S1781 = blockIdx.x;
    WideGroup_0 wg_4 = wide_group_0(_S1780, _S1781);
    bool _S1782 = _S1781 != (wg_4.first_0);
    uint _S1783 = __ballot_sync(_S1779, _S1782);
    if(_S1782)
    {
        return;
    }
    else
    {
        uint _S1784 = __ballot_sync(_S1779, true);
        _S1778 = _S1784;
    }
    uint _S1785 = 0U;
    Island_0 * _S1786 = (&(globalParams_0->islands_0)[wg_4.island_2]);
    Island_0 isl_19 = *_S1786;
    Island_0 _S1787 = *_S1786;
    bool _S1788 = wide_enter_0(tid_14, &_S1787);
    bool _S1789 = !_S1788;
    uint _S1790 = __ballot_sync(_S1778, _S1789);
    if(_S1789)
    {
        return;
    }
    else
    {
        uint _S1791 = __ballot_sync(_S1778, true);
        _S1785 = _S1791;
    }
    float3  work_4;
    float3  flags_2;
    wide_partials_0(tid_14, wg_4.first_0, (&isl_19)->wide_groups_0, 6U, &work_4, &flags_2, _S1785);
    bool halt_0 = (((&isl_19)->info_1.z) & 2U) != 0U;
    uint _S1792 = __ballot_sync(_S1785, halt_0);
    bool whole_0;
    if(halt_0)
    {
        Island_0 _S1793 = isl_19;
        bool _S1794 = island_connected_0(tid_14, &_S1793);
        whole_0 = _S1794;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_14 != 0U)
    {
        return;
    }
    bool halt_1;
    if(whole_0)
    {
        *&((&(&isl_19)->info_1)->z) = (*&((&(&isl_19)->info_1)->z)) & 4294967293U;
        (&isl_19)->coverage_0 = ((&isl_19)->coverage_0) | 2097280U;
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    Island_0 _S1795 = isl_19;
    uint _S1796 = wide_step_0(&_S1795);
    if(((&isl_19)->probes_0.y) > ((&isl_19)->probes_0.x))
    {
        Island_0 _S1797 = isl_19;
        Rigid_0 _S1798 = rigid_of_0(&_S1797);
        Island_0 _S1799 = isl_19;
        Rigid_0 _S1800 = _S1798;
        record_probes_0(&_S1799, &_S1800, _S1796);
    }
    if(halt_1)
    {
        whole_0 = (((&isl_19)->info_1.x) & 4U) != 0U;
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0((&isl_19)->info_1.w + 1U);
    }
    comp_add1_0(&((&(&isl_19)->energy_1)->x), &((&(&isl_19)->energy_1)->y), work_4.x);
    *&((&(&isl_19)->energy_1)->y) = *&((&(&isl_19)->energy_1)->y) + work_4.y;
    (&isl_19)->done_0 = (&isl_19)->done_0 + 1U;
    *&((&(&isl_19)->info_1)->y) = *&((&(&isl_19)->info_1)->y) - 1U;
    *&((&(&isl_19)->info_1)->w) = *&((&(&isl_19)->info_1)->w) + 1U;
    if(halt_1)
    {
        *&((&(&isl_19)->info_1)->z) = (((&isl_19)->info_1.z) & 4294967293U) | 1U;
    }
    uint _S1801;
    if(halt_1)
    {
        _S1801 = 128U;
    }
    else
    {
        _S1801 = 0U;
    }
    uint _S1802 = 256U | _S1801;
    if(((&isl_19)->probes_0.y) > ((&isl_19)->probes_0.x))
    {
        _S1801 = 262144U;
    }
    else
    {
        _S1801 = 0U;
    }
    uint _S1803 = _S1802 | _S1801;
    if((((&isl_19)->info_1.x) & 4U) != 0U)
    {
        _S1801 = 524288U;
    }
    else
    {
        _S1801 = 0U;
    }
    uint _S1804 = _S1803 | _S1801;
    if((flags_2.x) > 0.0f)
    {
        _S1801 = 32768U;
    }
    else
    {
        _S1801 = 0U;
    }
    uint _S1805 = _S1804 | _S1801;
    if((flags_2.y) > 0.0f)
    {
        _S1801 = 65536U;
    }
    else
    {
        _S1801 = 0U;
    }
    uint _S1806 = _S1805 | _S1801;
    if((flags_2.z) > 0.0f)
    {
        _S1801 = 131072U;
    }
    else
    {
        _S1801 = 0U;
    }
    (&isl_19)->coverage_0 = ((&isl_19)->coverage_0) | (_S1806 | _S1801);
    *(&(globalParams_0->islands_0)[wg_4.island_2]) = isl_19;
    return;
}

static __device__ uint sv_0(uint c_31, uint slot_2)
{
    uint _S1807 = __ldg(&globalParams_0->params_0->statics_base_0);
    return _S1807 + 23U * c_31 + slot_2;
}

static __device__ void project_load_slot_0(uint tid_15, Island_0 * isl_20, uint slot_3, uint _S1808)
{
    uint _S1809;
    uint _S1810;
    float3  _S1811 = make_float3 (0.0f);
    float3  net_f_0 = _S1811;
    float3  net_m_0 = _S1811;
    uint4  _S1812 = isl_20->range_0;
    uint _S1813 = isl_20->range_0.x + tid_15;
    uint c_32 = _S1813;
    uint _S1814 = _S1808;
    for(;;)
    {
        uint _S1815 = _S1812.y;
        _S1809 = _S1815;
        bool _S1816 = c_32 < _S1815;
        uint _S1817 = __ballot_sync(_S1814, _S1816);
        if(_S1816)
        {
            uint _S1818 = __ballot_sync(_S1814, true);
        }
        else
        {
            uint _S1819 = __ballot_sync(_S1814, false);
            uint _S1820 = __ballot_sync(_S1814, false);
            uint _S1821 = __ballot_sync(_S1808, true);
            _S1810 = _S1821;
            break;
        }
        float4  _S1822 = *(&(globalParams_0->scratch_0)[sv_0(c_32, slot_3)]);
        float3  fi_1 = float3 {_S1822.x, _S1822.y, _S1822.z};
        net_f_0 = net_f_0 + fi_1;
        float4  _S1823 = __ldg(&(&(globalParams_0->chunks_0)[c_32])->center_0);
        float4  _S1824 = isl_20->com_0;
        float4  _S1825 = *(&(globalParams_0->scratch_0)[sv_0(c_32, slot_3 + 1U)]);
        net_m_0 = net_m_0 + (cross_0(float3 {_S1823.x, _S1823.y, _S1823.z} - float3 {_S1824.x, _S1824.y, _S1824.z}, fi_1) + float3 {_S1825.x, _S1825.y, _S1825.z});
        uint _S1826 = __ballot_sync(_S1814, true);
        c_32 = c_32 + 256U;
        _S1814 = _S1826;
    }
    group_sum3_0(tid_15, &net_f_0, &net_m_0, _S1810);
    float4  _S1827 = isl_20->com_0;
    float3  _S1828 = net_f_0 / make_float3 (isl_20->com_0.w);
    float3  _S1829 = rows_mul_0(isl_20->inv0_1, isl_20->inv1_1, isl_20->inv2_1, net_m_0);
    c_32 = _S1813;
    for(;;)
    {
        if(c_32 < _S1809)
        {
        }
        else
        {
            break;
        }
        ChunkStatic_0 * _S1830 = (&(globalParams_0->chunks_0)[c_32]);
        float4  _S1831 = __ldg(&_S1830->center_0);
        uint _S1832 = sv_0(c_32, slot_3);
        float4  _S1833 = *(&(globalParams_0->scratch_0)[_S1832]);
        *(&(globalParams_0->scratch_0)[_S1832]) = make_float4 ((float3 {_S1833.x, _S1833.y, _S1833.z} - (_S1828 + cross_0(_S1829, float3 {_S1831.x, _S1831.y, _S1831.z} - float3 {_S1827.x, _S1827.y, _S1827.z})) * make_float3 (_S1831.w)).x, (float3 {_S1833.x, _S1833.y, _S1833.z} - (_S1828 + cross_0(_S1829, float3 {_S1831.x, _S1831.y, _S1831.z} - float3 {_S1827.x, _S1827.y, _S1827.z})) * make_float3 (_S1831.w)).y, (float3 {_S1833.x, _S1833.y, _S1833.z} - (_S1828 + cross_0(_S1829, float3 {_S1831.x, _S1831.y, _S1831.z} - float3 {_S1827.x, _S1827.y, _S1827.z})) * make_float3 (_S1831.w)).z, 0.0f);
        uint _S1834 = sv_0(c_32, slot_3 + 1U);
        float4  * _S1835 = (&(globalParams_0->scratch_0)[_S1834]);
        float4  _S1836 = *(&(globalParams_0->scratch_0)[_S1834]);
        float3  _S1837 = float3 {_S1836.x, _S1836.y, _S1836.z};
        float4  _S1838 = __ldg(&_S1830->inertia0_0);
        float4  _S1839 = __ldg(&_S1830->inertia1_0);
        float4  _S1840 = __ldg(&_S1830->inertia2_0);
        *_S1835 = make_float4 ((_S1837 - rows_mul_0(_S1838, _S1839, _S1840, _S1829)).x, (_S1837 - rows_mul_0(_S1838, _S1839, _S1840, _S1829)).y, (_S1837 - rows_mul_0(_S1838, _S1839, _S1840, _S1829)).z, 0.0f);
        c_32 = c_32 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ float island_dot_0(uint tid_16, uint c0_0, uint c1_0, uint sa_2, uint sb_2, uint _S1841)
{
    uint _S1842;
    float4  _S1843 = make_float4 (0.0f);
    float4  acc_0 = _S1843;
    float4  unused_4 = _S1843;
    uint c_33 = c0_0 + tid_16;
    uint _S1844 = _S1841;
    for(;;)
    {
        bool _S1845 = c_33 < c1_0;
        uint _S1846 = __ballot_sync(_S1844, _S1845);
        if(_S1845)
        {
            uint _S1847 = __ballot_sync(_S1844, true);
        }
        else
        {
            uint _S1848 = __ballot_sync(_S1844, false);
            uint _S1849 = __ballot_sync(_S1844, false);
            uint _S1850 = __ballot_sync(_S1841, true);
            _S1842 = _S1850;
            break;
        }
        float4  _S1851 = *(&(globalParams_0->scratch_0)[sv_0(c_33, sa_2)]);
        float4  _S1852 = *(&(globalParams_0->scratch_0)[sv_0(c_33, sb_2)]);
        float4  _S1853 = *(&(globalParams_0->scratch_0)[sv_0(c_33, sa_2 + 1U)]);
        float4  _S1854 = *(&(globalParams_0->scratch_0)[sv_0(c_33, sb_2 + 1U)]);
        *&((&acc_0)->x) = *&((&acc_0)->x) + (dot_0(float3 {_S1851.x, _S1851.y, _S1851.z}, float3 {_S1852.x, _S1852.y, _S1852.z}) + dot_0(float3 {_S1853.x, _S1853.y, _S1853.z}, float3 {_S1854.x, _S1854.y, _S1854.z}));
        uint _S1855 = __ballot_sync(_S1844, true);
        c_33 = c_33 + 256U;
        _S1844 = _S1855;
    }
    group_sum2_0(tid_16, &acc_0, &unused_4, _S1842);
    return acc_0.x;
}

static __device__ void static_kinematics_0(uint _S1856, float3  * _S1857, float3  * _S1858)
{
    BondStatic_0 * _S1859 = (&(globalParams_0->bonds_0)[_S1856]);
    JointBond_0 _S1860 = slang_ldg_0(&_S1859->law_0);
    uint ca_1 = _S1860.ids_0.y;
    uint cb_1 = _S1860.ids_0.z;
    uint _S1861 = 4U * cb_1;
    float4  _S1862 = *(&(globalParams_0->state_0)[_S1861]);
    uint _S1863 = 4U * ca_1;
    float4  _S1864 = *(&(globalParams_0->state_0)[_S1863]);
    float4  _S1865 = *(&(globalParams_0->scratch_0)[sv_0(cb_1, 21U)]);
    float4  _S1866 = *(&(globalParams_0->scratch_0)[sv_0(ca_1, 21U)]);
    float3  du_0 = float3 {_S1862.x, _S1862.y, _S1862.z} - float3 {_S1864.x, _S1864.y, _S1864.z} + (float3 {_S1865.x, _S1865.y, _S1865.z} - float3 {_S1866.x, _S1866.y, _S1866.z});
    uint _S1867 = _S1861 + 1U;
    float4  _S1868 = *(&(globalParams_0->state_0)[_S1867]);
    uint _S1869 = _S1863 + 1U;
    float4  _S1870 = *(&(globalParams_0->state_0)[_S1869]);
    uint _S1871 = sv_0(cb_1, 22U);
    float4  _S1872 = *(&(globalParams_0->scratch_0)[_S1871]);
    uint _S1873 = sv_0(ca_1, 22U);
    float4  _S1874 = *(&(globalParams_0->scratch_0)[_S1873]);
    float3  dth_0 = float3 {_S1868.x, _S1868.y, _S1868.z} - float3 {_S1870.x, _S1870.y, _S1870.z} + (float3 {_S1872.x, _S1872.y, _S1872.z} - float3 {_S1874.x, _S1874.y, _S1874.z});
    float4  _S1875 = *(&(globalParams_0->state_0)[_S1869]);
    float4  _S1876 = *(&(globalParams_0->scratch_0)[_S1873]);
    float3  ta_3 = float3 {_S1875.x, _S1875.y, _S1875.z} + float3 {_S1876.x, _S1876.y, _S1876.z};
    float4  _S1877 = *(&(globalParams_0->state_0)[_S1867]);
    float4  _S1878 = *(&(globalParams_0->scratch_0)[_S1871]);
    float3  tb_3 = float3 {_S1877.x, _S1877.y, _S1877.z} + float3 {_S1878.x, _S1878.y, _S1878.z};
    float4  _S1879 = __ldg(&_S1859->rb_0);
    float3  _S1880 = cross_0(tb_3, float3 {_S1879.x, _S1879.y, _S1879.z});
    float4  _S1881 = __ldg(&_S1859->ra_0);
    float3  _S1882 = to_local_0(_S1856, du_0 + (_S1880 - cross_0(ta_3, float3 {_S1881.x, _S1881.y, _S1881.z})));
    *_S1857 = _S1882;
    float3  _S1883 = to_local_0(_S1856, dth_0);
    *_S1858 = _S1883;
    return;
}

static __device__ JointResponse_0 static_response_0(uint i_18)
{
    BondStatic_0 * _S1884 = (&(globalParams_0->bonds_0)[i_18]);
    float3  d_lin_4;
    float3  d_ang_3;
    static_kinematics_0(i_18, &d_lin_4, &d_ang_3);
    JointBond_0 _S1885 = slang_ldg_0(&_S1884->law_0);
    JointBond_0 _S1886 = _S1885;
    JointState_0 _S1887 = (&(globalParams_0->bond_dyn_0)[i_18])->js_0;
    JointResponse_0 _S1888 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S1885.ids_0.x], &_S1886, &_S1887, d_lin_4, d_ang_3, 0.0f, false);
    return _S1888;
}

static __device__ void gather_loads_0(uint c_34, float3  * fi_2, float3  * mi_3)
{
    float3  _S1889 = make_float3 (0.0f);
    *fi_2 = _S1889;
    *mi_3 = _S1889;
    uint _S1890 = __ldg((&(globalParams_0->index_0)[c_34]));
    uint e_5 = _S1890;
    for(;;)
    {
        uint _S1891 = __ldg((&(globalParams_0->index_0)[c_34 + 1U]));
        if(e_5 < _S1891)
        {
        }
        else
        {
            break;
        }
        uint _S1892 = __ldg((&(globalParams_0->index_0)[e_5]));
        uint bond_2 = _S1892 >> int(1);
        if((_S1892 & 1U) == 0U)
        {
            uint _S1893 = 3U * bond_2;
            float4  _S1894 = *(&(globalParams_0->scratch_0)[_S1893]);
            *fi_2 = *fi_2 + float3 {_S1894.x, _S1894.y, _S1894.z};
            float4  _S1895 = *(&(globalParams_0->scratch_0)[_S1893 + 1U]);
            *mi_3 = *mi_3 + float3 {_S1895.x, _S1895.y, _S1895.z};
        }
        else
        {
            uint _S1896 = 3U * bond_2;
            float4  _S1897 = *(&(globalParams_0->scratch_0)[_S1896]);
            *fi_2 = *fi_2 - float3 {_S1897.x, _S1897.y, _S1897.z};
            float4  _S1898 = *(&(globalParams_0->scratch_0)[_S1896 + 2U]);
            *mi_3 = *mi_3 + float3 {_S1898.x, _S1898.y, _S1898.z};
        }
        e_5 = e_5 + 1U;
    }
    return;
}

static __device__ float bond_load_magnitude2_0(uint c_35)
{
    uint _S1899 = __ldg((&(globalParams_0->index_0)[c_35]));
    uint e_6 = _S1899;
    float m_6 = 0.0f;
    for(;;)
    {
        uint _S1900 = __ldg((&(globalParams_0->index_0)[c_35 + 1U]));
        if(e_6 < _S1900)
        {
        }
        else
        {
            break;
        }
        uint _S1901 = __ldg((&(globalParams_0->index_0)[e_6]));
        uint _S1902 = 3U * (_S1901 >> int(1));
        float4  _S1903 = *(&(globalParams_0->scratch_0)[_S1902]);
        float3  f_15 = float3 {_S1903.x, _S1903.y, _S1903.z};
        float3  t_13;
        if((_S1901 & 1U) == 0U)
        {
            float4  _S1904 = *(&(globalParams_0->scratch_0)[_S1902 + 1U]);
            t_13 = float3 {_S1904.x, _S1904.y, _S1904.z};
        }
        else
        {
            float4  _S1905 = *(&(globalParams_0->scratch_0)[_S1902 + 2U]);
            t_13 = float3 {_S1905.x, _S1905.y, _S1905.z};
        }
        float m_7 = m_6 + (dot_0(f_15, f_15) + dot_0(t_13, t_13));
        e_6 = e_6 + 1U;
        m_6 = m_7;
    }
    return m_6;
}

static __device__ uint fixed_mask_0(uint c_36)
{
    uint4  _S1906 = __ldg(&(&(globalParams_0->chunks_0)[c_36])->info_0);
    uint support_1 = _S1906.x;
    uint _S1907;
    if(support_1 == 1U)
    {
        _S1907 = 63U;
    }
    else
    {
        if(support_1 == 2U)
        {
            _S1907 = 7U;
        }
        else
        {
            _S1907 = 0U;
        }
    }
    return _S1907;
}

static __device__ void hold_0(uint mask_0, float4  * lin_0, float4  * ang_0, float4  keep_lin_0, float4  keep_ang_0)
{
    uint d_13 = 0U;
    for(;;)
    {
        if(d_13 < 3U)
        {
        }
        else
        {
            break;
        }
        if((mask_0 & (1U << d_13)) != 0U)
        {
            *_slang_vector_get_element_ptr(lin_0, d_13) = _slang_vector_get_element(keep_lin_0, d_13);
        }
        if((mask_0 & (1U << (d_13 + 3U))) != 0U)
        {
            *_slang_vector_get_element_ptr(ang_0, d_13) = _slang_vector_get_element(keep_ang_0, d_13);
        }
        d_13 = d_13 + 1U;
    }
    return;
}

static __device__ bool is_finite_0(float x_25)
{
    return ((F32_asuint((x_25))) & 2147483647U) < 2139095040U;
}

static __device__ uint statics_bond_slot_0(uint i_19)
{
    uint _S1908 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1909 = __ldg(&globalParams_0->params_0->chunk_count_0);
    return _S1908 + 23U * _S1909 + 2U * i_19;
}

static __device__ void store_inverse_0(uint c_37, FixedArray<float, 36>  * a_18)
{
    uint j_8;
    float sum_4;
    FixedArray<float, 36>  l_6;
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
        l_6[k_18] = 0.0f;
        k_18 = k_18 + 1U;
    }
    bool spd_0 = true;
    uint i_20 = 0U;
    for(;;)
    {
        bool _S1910;
        if(i_20 < 6U)
        {
            _S1910 = spd_0;
        }
        else
        {
            _S1910 = false;
        }
        if(_S1910)
        {
        }
        else
        {
            break;
        }
        j_8 = 0U;
        for(;;)
        {
            if(j_8 <= i_20)
            {
            }
            else
            {
                break;
            }
            uint _S1911 = i_20 * 6U;
            uint _S1912 = _S1911 + j_8;
            k_18 = 0U;
            sum_4 = (*a_18)[_S1912];
            for(;;)
            {
                if(k_18 < j_8)
                {
                }
                else
                {
                    break;
                }
                float sum_5 = sum_4 - l_6[_S1911 + k_18] * l_6[j_8 * 6U + k_18];
                k_18 = k_18 + 1U;
                sum_4 = sum_5;
            }
            if(i_20 == j_8)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_6[_S1911 + i_20] = (F32_sqrt((sum_4)));
            }
            else
            {
                l_6[_S1912] = sum_4 / l_6[j_8 * 6U + j_8];
            }
            j_8 = j_8 + 1U;
        }
        i_20 = i_20 + 1U;
    }
    FixedArray<float, 36>  inv_0;
    if(!spd_0)
    {
        k_18 = 0U;
        for(;;)
        {
            if(k_18 < 36U)
            {
            }
            else
            {
                break;
            }
            inv_0[k_18] = 0.0f;
            k_18 = k_18 + 1U;
        }
        k_18 = 0U;
        for(;;)
        {
            if(k_18 < 6U)
            {
            }
            else
            {
                break;
            }
            uint _S1913 = k_18 * 6U + k_18;
            float _S1914 = (*a_18)[_S1913];
            if(((*a_18)[_S1913]) > 0.0f)
            {
                sum_4 = 1.0f / _S1914;
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S1913] = sum_4;
            k_18 = k_18 + 1U;
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
                if(i_20 == j_8)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_18 = 0U;
                float s_6 = sum_4;
                for(;;)
                {
                    if(k_18 < i_20)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_7 = s_6 - l_6[i_20 * 6U + k_18] * y_6[k_18];
                    k_18 = k_18 + 1U;
                    s_6 = s_7;
                }
                y_6[i_20] = s_6 / l_6[i_20 * 6U + i_20];
                i_20 = i_20 + 1U;
            }
            FixedArray<float, 6>  x_26;
            x_26[int(0)] = 0.0f;
            x_26[int(1)] = 0.0f;
            x_26[int(2)] = 0.0f;
            x_26[int(3)] = 0.0f;
            x_26[int(4)] = 0.0f;
            x_26[int(5)] = 0.0f;
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
                k_18 = i_21 + 1U;
                sum_4 = y_6[i_21];
                for(;;)
                {
                    if(k_18 < 6U)
                    {
                    }
                    else
                    {
                        break;
                    }
                    float s_8 = sum_4 - l_6[k_18 * 6U + i_21] * x_26[k_18];
                    k_18 = k_18 + 1U;
                    sum_4 = s_8;
                }
                x_26[i_21] = sum_4 / l_6[i_21 * 6U + i_21];
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
                inv_0[i_22 * 6U + j_8] = x_26[i_22];
                i_22 = i_22 + 1U;
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
        uint _S1915 = 4U * j_8;
        *(&(globalParams_0->scratch_0)[sv_0(c_37, 12U + j_8)]) = make_float4 (inv_0[_S1915], inv_0[_S1915 + 1U], inv_0[_S1915 + 2U], inv_0[_S1915 + 3U]);
        j_8 = j_8 + 1U;
    }
    return;
}

static __device__ void assemble_block_0(uint c_38)
{
    uint p_14;
    uint r_11;
    FixedArray<float, 36>  a_19;
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
        a_19[k_19] = 0.0f;
        k_19 = k_19 + 1U;
    }
    uint _S1916 = __ldg((&(globalParams_0->index_0)[c_38]));
    uint e_7 = _S1916;
    for(;;)
    {
        uint _S1917 = __ldg((&(globalParams_0->index_0)[c_38 + 1U]));
        if(e_7 < _S1917)
        {
        }
        else
        {
            break;
        }
        uint _S1918 = __ldg((&(globalParams_0->index_0)[e_7]));
        uint i_23 = _S1918 >> int(1);
        bool _S1919 = (_S1918 & 1U) != 0U;
        BondStatic_0 * _S1920 = (&(globalParams_0->bonds_0)[i_23]);
        uint _S1921 = statics_bond_slot_0(i_23);
        float4  _S1922 = *(&(globalParams_0->scratch_0)[_S1921]);
        float4  _S1923 = *(&(globalParams_0->scratch_0)[_S1921 + 1U]);
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
            uint _S1924 = p_14 % 3U;
            float3  t_14;
            if(_S1924 == 0U)
            {
                float4  _S1925 = __ldg(&_S1920->t1_0);
                t_14 = float3 {_S1925.x, _S1925.y, _S1925.z};
            }
            else
            {
                if(_S1924 == 1U)
                {
                    float4  _S1926 = __ldg(&_S1920->t2_0);
                    t_14 = float3 {_S1926.x, _S1926.y, _S1926.z};
                }
                else
                {
                    float4  _S1927 = __ldg(&_S1920->normal_0);
                    t_14 = float3 {_S1927.x, _S1927.y, _S1927.z};
                }
            }
            bool _S1928 = p_14 < 3U;
            float3  row_u_0;
            float3  row_t_0;
            if(_S1928)
            {
                if(_S1919)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                if(_S1919)
                {
                    float4  _S1929 = __ldg(&_S1920->rb_0);
                    row_t_0 = cross_0(float3 {_S1929.x, _S1929.y, _S1929.z}, t_14);
                }
                else
                {
                    float4  _S1930 = __ldg(&_S1920->ra_0);
                    row_t_0 = - cross_0(float3 {_S1930.x, _S1930.y, _S1930.z}, t_14);
                }
            }
            else
            {
                float3  _S1931 = make_float3 (0.0f);
                if(_S1919)
                {
                    row_u_0 = t_14;
                }
                else
                {
                    row_u_0 = - t_14;
                }
                float3  _S1932 = row_u_0;
                row_u_0 = _S1931;
                row_t_0 = _S1932;
            }
            float kp_0;
            if(_S1928)
            {
                kp_0 = _slang_vector_get_element(_S1922, p_14);
            }
            else
            {
                kp_0 = _slang_vector_get_element(_S1923, p_14 - 3U);
            }
            if(kp_0 == 0.0f)
            {
                p_14 = p_14 + 1U;
                continue;
            }
            FixedArray<float, 6>  _S1933 = { {
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
                    a_19[r_11 * 6U + q_12] = a_19[r_11 * 6U + q_12] + kp_0 * _S1933[r_11] * _S1933[q_12];
                    q_12 = q_12 + 1U;
                }
                r_11 = r_11 + 1U;
            }
            p_14 = p_14 + 1U;
        }
        e_7 = e_7 + 1U;
    }
    uint _S1934 = fixed_mask_0(c_38);
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
        if((_S1934 & (1U << p_14)) != 0U)
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
                a_19[p_14 * 6U + r_11] = 0.0f;
                a_19[r_11 * 6U + p_14] = 0.0f;
                r_11 = r_11 + 1U;
            }
            a_19[p_14 * 6U + p_14] = 1.0f;
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
        if((a_19[p_14 * 6U + p_14]) == 0.0f)
        {
            a_19[p_14 * 6U + p_14] = 1.0f;
        }
        p_14 = p_14 + 1U;
    }
    FixedArray<float, 36>  _S1935 = a_19;
    store_inverse_0(c_38, &_S1935);
    return;
}

static __device__ float block_get_0(uint c_39, uint i_24, uint j_9)
{
    uint k_20 = i_24 * 6U + j_9;
    return *_slang_vector_get_element_ptr((&(globalParams_0->scratch_0)[sv_0(c_39, 12U + k_20 / 4U)]), k_20 % 4U);
}

static __device__ void precondition_0(uint c_40)
{
    float4  * _S1936 = (&(globalParams_0->scratch_0)[sv_0(c_40, 4U)]);
    float4  * _S1937 = (&(globalParams_0->scratch_0)[sv_0(c_40, 5U)]);
    FixedArray<float, 6>  _S1938 = { {
        (*_S1936).x, (*_S1936).y, (*_S1936).z, (*_S1937).x, (*_S1937).y, (*_S1937).z
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
            float s_10 = s_9 + block_get_0(c_40, i_25, j_10) * _S1938[j_10];
            j_10 = j_10 + 1U;
            s_9 = s_10;
        }
        z_1[i_25] = s_9;
        i_25 = i_25 + 1U;
    }
    *(&(globalParams_0->scratch_0)[sv_0(c_40, 6U)]) = make_float4 (z_1[int(0)], z_1[int(1)], z_1[int(2)], 0.0f);
    *(&(globalParams_0->scratch_0)[sv_0(c_40, 7U)]) = make_float4 (z_1[int(3)], z_1[int(4)], z_1[int(5)], 0.0f);
    return;
}

static __device__ void project_displacement_slot_0(uint tid_17, Island_0 * isl_21, uint slot_4, uint _S1939)
{
    uint _S1940;
    uint _S1941;
    float3  _S1942 = make_float3 (0.0f);
    float3  p_15 = _S1942;
    float3  l_7 = _S1942;
    uint4  _S1943 = isl_21->range_0;
    uint _S1944 = isl_21->range_0.x + tid_17;
    uint c_41 = _S1944;
    uint _S1945 = _S1939;
    for(;;)
    {
        uint _S1946 = _S1943.y;
        _S1940 = _S1946;
        bool _S1947 = c_41 < _S1946;
        uint _S1948 = __ballot_sync(_S1945, _S1947);
        if(_S1947)
        {
            uint _S1949 = __ballot_sync(_S1945, true);
        }
        else
        {
            uint _S1950 = __ballot_sync(_S1945, false);
            uint _S1951 = __ballot_sync(_S1945, false);
            uint _S1952 = __ballot_sync(_S1939, true);
            _S1941 = _S1952;
            break;
        }
        ChunkStatic_0 * _S1953 = (&(globalParams_0->chunks_0)[c_41]);
        float4  _S1954 = *(&(globalParams_0->scratch_0)[sv_0(c_41, slot_4)]);
        float3  u_3 = float3 {_S1954.x, _S1954.y, _S1954.z};
        float4  _S1955 = *(&(globalParams_0->scratch_0)[sv_0(c_41, slot_4 + 1U)]);
        float3  th_5 = float3 {_S1955.x, _S1955.y, _S1955.z};
        float4  _S1956 = __ldg(&_S1953->center_0);
        float4  _S1957 = isl_21->com_0;
        float3  r_12 = float3 {_S1956.x, _S1956.y, _S1956.z} - float3 {_S1957.x, _S1957.y, _S1957.z};
        float _S1958 = _S1956.w;
        p_15 = p_15 + u_3 * make_float3 (_S1958);
        float3  _S1959 = cross_0(r_12, u_3) * make_float3 (_S1958);
        float4  _S1960 = __ldg(&_S1953->inertia0_0);
        float4  _S1961 = __ldg(&_S1953->inertia1_0);
        float4  _S1962 = __ldg(&_S1953->inertia2_0);
        l_7 = l_7 + (_S1959 + rows_mul_0(_S1960, _S1961, _S1962, th_5));
        uint _S1963 = __ballot_sync(_S1945, true);
        c_41 = c_41 + 256U;
        _S1945 = _S1963;
    }
    group_sum3_0(tid_17, &p_15, &l_7, _S1941);
    float4  _S1964 = isl_21->com_0;
    float3  _S1965 = p_15 / make_float3 (isl_21->com_0.w);
    float3  _S1966 = rows_mul_0(isl_21->inv0_1, isl_21->inv1_1, isl_21->inv2_1, l_7);
    c_41 = _S1944;
    for(;;)
    {
        if(c_41 < _S1940)
        {
        }
        else
        {
            break;
        }
        float4  _S1967 = __ldg(&(&(globalParams_0->chunks_0)[c_41])->center_0);
        uint _S1968 = sv_0(c_41, slot_4);
        float4  _S1969 = *(&(globalParams_0->scratch_0)[_S1968]);
        *(&(globalParams_0->scratch_0)[_S1968]) = make_float4 ((float3 {_S1969.x, _S1969.y, _S1969.z} - _S1965 - cross_0(_S1966, float3 {_S1967.x, _S1967.y, _S1967.z} - float3 {_S1964.x, _S1964.y, _S1964.z})).x, (float3 {_S1969.x, _S1969.y, _S1969.z} - _S1965 - cross_0(_S1966, float3 {_S1967.x, _S1967.y, _S1967.z} - float3 {_S1964.x, _S1964.y, _S1964.z})).y, (float3 {_S1969.x, _S1969.y, _S1969.z} - _S1965 - cross_0(_S1966, float3 {_S1967.x, _S1967.y, _S1967.z} - float3 {_S1964.x, _S1964.y, _S1964.z})).z, 0.0f);
        uint _S1970 = sv_0(c_41, slot_4 + 1U);
        float4  _S1971 = *(&(globalParams_0->scratch_0)[_S1970]);
        *(&(globalParams_0->scratch_0)[_S1970]) = make_float4 ((float3 {_S1971.x, _S1971.y, _S1971.z} - _S1966).x, (float3 {_S1971.x, _S1971.y, _S1971.z} - _S1966).y, (float3 {_S1971.x, _S1971.y, _S1971.z} - _S1966).z, 0.0f);
        c_41 = c_41 + 256U;
    }
    __syncthreads();
    return;
}

static __device__ uint statics_result_slot_0(uint island_3)
{
    uint _S1972 = __ldg(&globalParams_0->params_0->statics_base_0);
    uint _S1973 = __ldg(&globalParams_0->params_0->chunk_count_0);
    uint _S1974 = _S1972 + 23U * _S1973;
    uint _S1975 = __ldg(&globalParams_0->params_0->statics_bonds_0);
    return _S1974 + 2U * _S1975 + island_3;
}

static __device__ void write_bond_loads_0(uint _S1976, uint _S1977, float3  _S1978, float3  _S1979, float _S1980)
{
    BondStatic_0 * _S1981 = (&(globalParams_0->bonds_0)[_S1977]);
    float3  _S1982 = to_body_0(_S1977, _S1978);
    float3  _S1983 = to_body_0(_S1977, _S1979);
    uint _S1984 = 3U * _S1976;
    *(&(globalParams_0->scratch_0)[_S1984]) = make_float4 (_S1982.x, _S1982.y, _S1982.z, _S1980);
    float4  * _S1985 = (&(globalParams_0->scratch_0)[_S1984 + 1U]);
    float4  _S1986 = __ldg(&_S1981->ra_0);
    *_S1985 = make_float4 ((_S1983 + cross_0(float3 {_S1986.x, _S1986.y, _S1986.z}, _S1982)).x, (_S1983 + cross_0(float3 {_S1986.x, _S1986.y, _S1986.z}, _S1982)).y, (_S1983 + cross_0(float3 {_S1986.x, _S1986.y, _S1986.z}, _S1982)).z, 0.0f);
    float4  * _S1987 = (&(globalParams_0->scratch_0)[_S1984 + 2U]);
    float3  _S1988 = - _S1983;
    float4  _S1989 = __ldg(&_S1981->rb_0);
    *_S1987 = make_float4 ((_S1988 + cross_0(float3 {_S1989.x, _S1989.y, _S1989.z}, - _S1982)).x, (_S1988 + cross_0(float3 {_S1989.x, _S1989.y, _S1989.z}, - _S1982)).y, (_S1988 + cross_0(float3 {_S1989.x, _S1989.y, _S1989.z}, - _S1982)).z, 0.0f);
    return;
}

static __device__ void bond_kinematics_0(uint _S1990, float3  _S1991, float3  _S1992, float3  _S1993, float3  _S1994, float3  * _S1995, float3  * _S1996)
{
    BondStatic_0 * _S1997 = (&(globalParams_0->bonds_0)[_S1990]);
    float4  _S1998 = __ldg(&_S1997->rb_0);
    float3  _S1999 = _S1993 + cross_0(_S1994, float3 {_S1998.x, _S1998.y, _S1998.z});
    float4  _S2000 = __ldg(&_S1997->ra_0);
    float3  _S2001 = to_local_0(_S1990, _S1999 - (_S1991 + cross_0(_S1992, float3 {_S2000.x, _S2000.y, _S2000.z})));
    *_S1995 = _S2001;
    float3  _S2002 = to_local_0(_S1990, _S1994 - _S1992);
    *_S1996 = _S2002;
    return;
}

extern "C" __global__ void island_statics()
{
    uint _S2003 = 0U;
    uint _S2004;
    uint i_26;
    uint c_42;
    bool converged_4;
    uint _S2005;
    uint _S2006;
    uint _S2007;
    uint _S2008;
    uint _S2009;
    uint _S2010;
    uint i_27;
    uint _S2011;
    uint _S2012;
    uint _S2013;
    uint _S2014;
    uint _S2015;
    uint _S2016 = __ballot_sync(4294967295U, true);
    uint tid_18 = threadIdx.x;
    uint _S2017 = blockIdx.x;
    Island_0 * _S2018 = (&(globalParams_0->islands_0)[_S2017]);
    Island_0 isl_22 = *_S2018;
    uint _S2019 = (*_S2018).info_1.z;
    bool _S2020 = (_S2019 & 8U) == 0U;
    uint _S2021 = __ballot_sync(_S2016, _S2020);
    if(_S2020)
    {
        return;
    }
    else
    {
        uint _S2022 = __ballot_sync(_S2016, true);
        _S2003 = _S2022;
    }
    bool free_0 = ((isl_22.info_1.x) & 1U) == 0U;
    uint c0_1 = isl_22.range_0.x;
    uint c1_1 = isl_22.range_0.y;
    uint b0_0 = isl_22.range_0.z;
    uint _S2023 = isl_22.range_0.w;
    uint _S2024 = c0_1 + tid_18;
    uint c_43 = _S2024;
    uint newton_0;
    newton_0 = _S2003;
    for(;;)
    {
        bool _S2025 = c_43 < c1_1;
        uint _S2026 = __ballot_sync(newton_0, _S2025);
        if(_S2025)
        {
            uint _S2027 = __ballot_sync(newton_0, true);
        }
        else
        {
            uint _S2028 = __ballot_sync(newton_0, false);
            uint _S2029 = __ballot_sync(newton_0, false);
            uint _S2030 = __ballot_sync(_S2003, true);
            _S2004 = _S2030;
            break;
        }
        float4  _S2031 = make_float4 (0.0f);
        *(&(globalParams_0->scratch_0)[sv_0(c_43, 21U)]) = _S2031;
        *(&(globalParams_0->scratch_0)[sv_0(c_43, 22U)]) = _S2031;
        uint _S2032 = __ballot_sync(newton_0, true);
        c_43 = c_43 + 256U;
        newton_0 = _S2032;
    }
    __syncthreads();
    uint _S2033 = __ballot_sync(_S2004, free_0);
    if(free_0)
    {
        Island_0 _S2034 = isl_22;
        project_load_slot_0(tid_18, &_S2034, 0U, _S2033);
        uint _S2035 = __ballot_sync(_S2004, true);
        c_43 = _S2035;
    }
    else
    {
        uint _S2036 = __ballot_sync(_S2004, true);
        c_43 = _S2036;
    }
    float _S2037 = island_dot_0(tid_18, c0_1, c1_1, 0U, 0U, c_43);
    float _S2038 = (F32_max(((F32_sqrt((_S2037)))), (1.00000000317107685e-30f)));
    float _S2039 = __ldg(&globalParams_0->params_0->statics_tol_0);
    uint _S2040 = __ldg(&globalParams_0->params_0->statics_cg_0);
    uint _S2041 = (U32_min((_S2040), (20U * (c1_1 - c0_1) * 6U + 200U)));
    float previous_2 = 1.00000001504746622e+30f;
    float start_0 = 1.00000001504746622e+30f;
    float residual_0 = 0.0f;
    newton_0 = 0U;
    uint cg_total_0 = 0U;
    for(;;)
    {
        uint _S2042 = 0U;
        uint _S2043 = __ldg(&globalParams_0->params_0->statics_newton_0);
        bool _S2044 = newton_0 < _S2043;
        uint _S2045 = __ballot_sync(c_43, _S2044);
        if(_S2044)
        {
            uint _S2046 = __ballot_sync(c_43, true);
            _S2042 = _S2046;
        }
        else
        {
            converged_4 = false;
            break;
        }
        uint _S2047 = b0_0 + tid_18;
        i_26 = _S2047;
        uint _S2048;
        _S2048 = _S2042;
        for(;;)
        {
            bool _S2049 = i_26 < _S2023;
            uint _S2050 = __ballot_sync(_S2048, _S2049);
            if(_S2049)
            {
                uint _S2051 = __ballot_sync(_S2048, true);
            }
            else
            {
                uint _S2052 = __ballot_sync(_S2048, false);
                uint _S2053 = __ballot_sync(_S2048, false);
                uint _S2054 = __ballot_sync(_S2042, true);
                _S2005 = _S2054;
                break;
            }
            JointResponse_0 resp_1 = static_response_0(i_26);
            write_bond_loads_0(i_26, i_26, resp_1.force_lin_1, resp_1.force_ang_1, 0.0f);
            uint _S2055 = __ballot_sync(_S2048, true);
            i_26 = i_26 + 256U;
            _S2048 = _S2055;
        }
        __syncthreads();
        float4  _S2056 = make_float4 (0.0f);
        float4  magnitude_0 = _S2056;
        float4  unused_m_0 = _S2056;
        uint c_44 = _S2024;
        uint _S2057 = _S2005;
        for(;;)
        {
            bool _S2058 = c_44 < c1_1;
            uint _S2059 = __ballot_sync(_S2057, _S2058);
            if(_S2058)
            {
                uint _S2060 = __ballot_sync(_S2057, true);
            }
            else
            {
                uint _S2061 = __ballot_sync(_S2057, false);
                uint _S2062 = __ballot_sync(_S2057, false);
                uint _S2063 = __ballot_sync(_S2005, true);
                _S2006 = _S2063;
                break;
            }
            float3  fi_3;
            float3  mi_4;
            gather_loads_0(c_44, &fi_3, &mi_4);
            *&((&magnitude_0)->x) = *&((&magnitude_0)->x) + bond_load_magnitude2_0(c_44);
            float4  _S2064 = *(&(globalParams_0->scratch_0)[sv_0(c_44, 0U)]);
            float4  r_lin_0 = make_float4 ((float3 {_S2064.x, _S2064.y, _S2064.z} + fi_3).x, (float3 {_S2064.x, _S2064.y, _S2064.z} + fi_3).y, (float3 {_S2064.x, _S2064.y, _S2064.z} + fi_3).z, 0.0f);
            float4  _S2065 = *(&(globalParams_0->scratch_0)[sv_0(c_44, 1U)]);
            float4  r_ang_0 = make_float4 ((float3 {_S2065.x, _S2065.y, _S2065.z} + mi_4).x, (float3 {_S2065.x, _S2065.y, _S2065.z} + mi_4).y, (float3 {_S2065.x, _S2065.y, _S2065.z} + mi_4).z, 0.0f);
            hold_0(fixed_mask_0(c_44), &r_lin_0, &r_ang_0, _S2056, _S2056);
            *(&(globalParams_0->scratch_0)[sv_0(c_44, 4U)]) = r_lin_0;
            *(&(globalParams_0->scratch_0)[sv_0(c_44, 5U)]) = r_ang_0;
            uint _S2066 = __ballot_sync(_S2057, true);
            c_44 = c_44 + 256U;
            _S2057 = _S2066;
        }
        __syncthreads();
        group_sum2_0(tid_18, &magnitude_0, &unused_m_0, _S2006);
        uint _S2067 = __ballot_sync(_S2006, free_0);
        uint _S2068;
        if(free_0)
        {
            Island_0 _S2069 = isl_22;
            project_load_slot_0(tid_18, &_S2069, 4U, _S2067);
            uint _S2070 = __ballot_sync(_S2006, true);
            _S2068 = _S2070;
        }
        else
        {
            uint _S2071 = __ballot_sync(_S2006, true);
            _S2068 = _S2071;
        }
        float _S2072 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S2068);
        float residual_1 = (F32_sqrt((_S2072))) / _S2038;
        float _S2073 = (F32_max((0.00100000004749745f), (3.83999986297567375e-06f * (F32_sqrt((magnitude_0.x))) / _S2038)));
        bool _S2074 = newton_0 == 0U;
        uint _S2075 = __ballot_sync(_S2068, _S2074);
        uint _S2076;
        if(_S2074)
        {
            uint _S2077 = __ballot_sync(_S2068, true);
            start_0 = residual_1;
            _S2076 = _S2077;
        }
        else
        {
            uint _S2078 = __ballot_sync(_S2068, true);
            _S2076 = _S2078;
        }
        bool _S2079 = is_finite_0(residual_1);
        uint _S2080 = __ballot_sync(_S2076, _S2079);
        uint _S2081;
        bool _S2082;
        if(_S2079)
        {
            bool _S2083 = residual_1 <= _S2039;
            uint _S2084 = __ballot_sync(_S2080, _S2083);
            if(_S2083)
            {
                uint _S2085 = __ballot_sync(_S2080, true);
                converged_4 = true;
            }
            else
            {
                uint _S2086 = _S2080 & (~_S2084);
                bool _S2087 = residual_1 <= _S2073;
                uint _S2088 = __ballot_sync(_S2086, _S2087);
                if(_S2087)
                {
                    bool _S2089 = residual_1 > (0.5f * previous_2);
                    uint _S2090 = __ballot_sync(_S2086, true);
                    converged_4 = _S2089;
                    _S2081 = _S2090;
                }
                else
                {
                    uint _S2091 = __ballot_sync(_S2086, true);
                    converged_4 = false;
                    _S2081 = _S2091;
                }
                uint _S2092 = __ballot_sync(_S2081, converged_4);
                if(converged_4)
                {
                    bool _S2093 = residual_1 <= start_0;
                    uint _S2094 = __ballot_sync(_S2081, true);
                    _S2082 = _S2093;
                }
                else
                {
                    uint _S2095 = __ballot_sync(_S2081, true);
                    _S2082 = false;
                }
                uint _S2096 = __ballot_sync(_S2080, true);
                converged_4 = _S2082;
            }
            uint _S2097 = __ballot_sync(_S2076, true);
            _S2081 = _S2097;
        }
        else
        {
            uint _S2098 = __ballot_sync(_S2076, true);
            converged_4 = false;
            _S2081 = _S2098;
        }
        uint _S2099 = 0U;
        uint _S2100 = __ballot_sync(_S2081, converged_4);
        if(converged_4)
        {
            residual_0 = residual_1;
            converged_4 = true;
            break;
        }
        else
        {
            uint _S2101 = __ballot_sync(_S2081, true);
            _S2099 = _S2101;
        }
        uint _S2102 = 0U;
        bool _S2103 = !_S2079;
        uint _S2104 = __ballot_sync(_S2099, _S2103);
        if(_S2103)
        {
            residual_0 = residual_1;
            converged_4 = false;
            break;
        }
        else
        {
            uint _S2105 = __ballot_sync(_S2099, true);
            _S2102 = _S2105;
        }
        uint i_28 = _S2047;
        uint _S2106;
        _S2106 = _S2102;
        for(;;)
        {
            bool _S2107 = i_28 < _S2023;
            uint _S2108 = __ballot_sync(_S2106, _S2107);
            if(_S2107)
            {
                uint _S2109 = __ballot_sync(_S2106, true);
            }
            else
            {
                uint _S2110 = __ballot_sync(_S2106, false);
                uint _S2111 = __ballot_sync(_S2106, false);
                uint _S2112 = __ballot_sync(_S2102, true);
                _S2007 = _S2112;
                break;
            }
            BondStatic_0 * _S2113 = (&(globalParams_0->bonds_0)[i_28]);
            float3  d_lin_5;
            float3  d_ang_4;
            static_kinematics_0(i_28, &d_lin_5, &d_ang_4);
            JointBond_0 _S2114 = slang_ldg_0(&_S2113->law_0);
            JointBond_0 _S2115 = _S2114;
            JointState_0 _S2116 = (&(globalParams_0->bond_dyn_0)[i_28])->js_0;
            float3  f_lin_2;
            float3  f_ang_2;
            secant_factors_0(&_S2115, &_S2116, d_lin_5, &f_lin_2, &f_ang_2);
            uint _S2117 = statics_bond_slot_0(i_28);
            float _S2118 = _S2114.stiff0_0.y;
            *(&(globalParams_0->scratch_0)[_S2117]) = make_float4 (_S2118 * f_lin_2.x, _S2118 * f_lin_2.y, _S2114.stiff0_0.x * f_lin_2.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S2117 + 1U]) = make_float4 (_S2114.stiff0_0.z * f_ang_2.x, _S2114.stiff0_0.w * f_ang_2.y, _S2114.stiff1_0.x * f_ang_2.z, 0.0f);
            uint _S2119 = __ballot_sync(_S2106, true);
            i_28 = i_28 + 256U;
            _S2106 = _S2119;
        }
        __syncthreads();
        uint c_45 = _S2024;
        uint _S2120 = _S2007;
        for(;;)
        {
            bool _S2121 = c_45 < c1_1;
            uint _S2122 = __ballot_sync(_S2120, _S2121);
            if(_S2121)
            {
                uint _S2123 = __ballot_sync(_S2120, true);
            }
            else
            {
                uint _S2124 = __ballot_sync(_S2120, false);
                uint _S2125 = __ballot_sync(_S2120, false);
                uint _S2126 = __ballot_sync(_S2007, true);
                _S2008 = _S2126;
                break;
            }
            assemble_block_0(c_45);
            *(&(globalParams_0->scratch_0)[sv_0(c_45, 2U)]) = _S2056;
            *(&(globalParams_0->scratch_0)[sv_0(c_45, 3U)]) = _S2056;
            uint _S2127 = __ballot_sync(_S2120, true);
            c_45 = c_45 + 256U;
            _S2120 = _S2127;
        }
        __syncthreads();
        uint c_46 = _S2024;
        uint _S2128 = _S2008;
        for(;;)
        {
            bool _S2129 = c_46 < c1_1;
            uint _S2130 = __ballot_sync(_S2128, _S2129);
            if(_S2129)
            {
                uint _S2131 = __ballot_sync(_S2128, true);
            }
            else
            {
                uint _S2132 = __ballot_sync(_S2128, false);
                uint _S2133 = __ballot_sync(_S2128, false);
                uint _S2134 = __ballot_sync(_S2008, true);
                _S2009 = _S2134;
                break;
            }
            precondition_0(c_46);
            uint _S2135 = __ballot_sync(_S2128, true);
            c_46 = c_46 + 256U;
            _S2128 = _S2135;
        }
        __syncthreads();
        uint _S2136 = __ballot_sync(_S2009, free_0);
        uint _S2137;
        if(free_0)
        {
            Island_0 _S2138 = isl_22;
            project_displacement_slot_0(tid_18, &_S2138, 6U, _S2136);
            uint _S2139 = __ballot_sync(_S2009, true);
            _S2137 = _S2139;
        }
        else
        {
            uint _S2140 = __ballot_sync(_S2009, true);
            _S2137 = _S2140;
        }
        uint c_47 = _S2024;
        uint _S2141 = _S2137;
        for(;;)
        {
            bool _S2142 = c_47 < c1_1;
            uint _S2143 = __ballot_sync(_S2141, _S2142);
            if(_S2142)
            {
                uint _S2144 = __ballot_sync(_S2141, true);
            }
            else
            {
                uint _S2145 = __ballot_sync(_S2141, false);
                uint _S2146 = __ballot_sync(_S2141, false);
                uint _S2147 = __ballot_sync(_S2137, true);
                _S2010 = _S2147;
                break;
            }
            *(&(globalParams_0->scratch_0)[sv_0(c_47, 8U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_47, 6U)]);
            *(&(globalParams_0->scratch_0)[sv_0(c_47, 9U)]) = *(&(globalParams_0->scratch_0)[sv_0(c_47, 7U)]);
            uint _S2148 = __ballot_sync(_S2141, true);
            c_47 = c_47 + 256U;
            _S2141 = _S2148;
        }
        __syncthreads();
        float _S2149 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S2010);
        float _S2150 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S2010);
        float _S2151 = (F32_sqrt((_S2150)));
        float rz_0 = _S2149;
        uint k_21 = 0U;
        uint cg_total_1 = cg_total_0;
        uint _S2152 = _S2010;
        for(;;)
        {
            bool _S2153 = k_21 < _S2041;
            uint _S2154 = __ballot_sync(_S2152, _S2153);
            uint _S2155;
            if(_S2153)
            {
                bool _S2156 = _S2151 > 0.0f;
                uint _S2157 = __ballot_sync(_S2152, true);
                _S2082 = _S2156;
                _S2155 = _S2157;
            }
            else
            {
                uint _S2158 = __ballot_sync(_S2152, true);
                _S2082 = false;
                _S2155 = _S2158;
            }
            uint _S2159 = 0U;
            uint _S2160 = __ballot_sync(_S2155, _S2082);
            if(_S2082)
            {
                uint _S2161 = __ballot_sync(_S2155, true);
                _S2159 = _S2161;
            }
            else
            {
                uint _S2162 = __ballot_sync(_S2155, false);
                uint _S2163 = __ballot_sync(_S2152, false);
                uint _S2164 = __ballot_sync(_S2010, true);
                cg_total_0 = cg_total_1;
                i_27 = _S2164;
                break;
            }
            i_27 = _S2047;
            _S2011 = _S2159;
            for(;;)
            {
                bool _S2165 = i_27 < _S2023;
                uint _S2166 = __ballot_sync(_S2011, _S2165);
                if(_S2165)
                {
                    uint _S2167 = __ballot_sync(_S2011, true);
                }
                else
                {
                    uint _S2168 = __ballot_sync(_S2011, false);
                    uint _S2169 = __ballot_sync(_S2011, false);
                    uint _S2170 = __ballot_sync(_S2159, true);
                    _S2012 = _S2170;
                    break;
                }
                JointBond_0 _S2171 = slang_ldg_0(&(&(globalParams_0->bonds_0)[i_27])->law_0);
                uint ca_2 = _S2171.ids_0.y;
                uint cb_2 = _S2171.ids_0.z;
                float4  _S2172 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 8U)]);
                float4  _S2173 = *(&(globalParams_0->scratch_0)[sv_0(ca_2, 9U)]);
                float4  _S2174 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 8U)]);
                float4  _S2175 = *(&(globalParams_0->scratch_0)[sv_0(cb_2, 9U)]);
                float3  d_lin_6;
                float3  d_ang_5;
                bond_kinematics_0(i_27, float3 {_S2172.x, _S2172.y, _S2172.z}, float3 {_S2173.x, _S2173.y, _S2173.z}, float3 {_S2174.x, _S2174.y, _S2174.z}, float3 {_S2175.x, _S2175.y, _S2175.z}, &d_lin_6, &d_ang_5);
                uint _S2176 = statics_bond_slot_0(i_27);
                float4  _S2177 = *(&(globalParams_0->scratch_0)[_S2176]);
                float4  _S2178 = *(&(globalParams_0->scratch_0)[_S2176 + 1U]);
                write_bond_loads_0(i_27, i_27, d_lin_6 * float3 {_S2177.x, _S2177.y, _S2177.z}, d_ang_5 * float3 {_S2178.x, _S2178.y, _S2178.z}, 0.0f);
                uint _S2179 = __ballot_sync(_S2011, true);
                i_27 = i_27 + 256U;
                _S2011 = _S2179;
            }
            __syncthreads();
            c_42 = _S2024;
            uint _S2180 = _S2012;
            for(;;)
            {
                bool _S2181 = c_42 < c1_1;
                uint _S2182 = __ballot_sync(_S2180, _S2181);
                if(_S2181)
                {
                    uint _S2183 = __ballot_sync(_S2180, true);
                }
                else
                {
                    uint _S2184 = __ballot_sync(_S2180, false);
                    uint _S2185 = __ballot_sync(_S2180, false);
                    uint _S2186 = __ballot_sync(_S2012, true);
                    _S2013 = _S2186;
                    break;
                }
                float3  fi_4;
                float3  mi_5;
                gather_loads_0(c_42, &fi_4, &mi_5);
                float4  ap_lin_0 = make_float4 ((- fi_4).x, (- fi_4).y, (- fi_4).z, 0.0f);
                float4  ap_ang_0 = make_float4 ((- mi_5).x, (- mi_5).y, (- mi_5).z, 0.0f);
                hold_0(fixed_mask_0(c_42), &ap_lin_0, &ap_ang_0, *(&(globalParams_0->scratch_0)[sv_0(c_42, 8U)]), *(&(globalParams_0->scratch_0)[sv_0(c_42, 9U)]));
                *(&(globalParams_0->scratch_0)[sv_0(c_42, 10U)]) = ap_lin_0;
                *(&(globalParams_0->scratch_0)[sv_0(c_42, 11U)]) = ap_ang_0;
                uint _S2187 = __ballot_sync(_S2180, true);
                c_42 = c_42 + 256U;
                _S2180 = _S2187;
            }
            uint _S2188 = 0U;
            __syncthreads();
            float _S2189 = island_dot_0(tid_18, c0_1, c1_1, 8U, 10U, _S2013);
            uint _S2190 = cg_total_1 + 1U;
            bool _S2191 = _S2189 <= 0.0f;
            uint _S2192 = __ballot_sync(_S2013, _S2191);
            if(_S2191)
            {
                uint _S2193 = __ballot_sync(_S2013, false);
                uint _S2194 = __ballot_sync(_S2152, false);
                uint _S2195 = __ballot_sync(_S2010, true);
                cg_total_0 = _S2190;
                i_27 = _S2195;
                break;
            }
            else
            {
                uint _S2196 = __ballot_sync(_S2013, true);
                _S2188 = _S2196;
            }
            float _S2197 = rz_0 / _S2189;
            uint c_48 = _S2024;
            uint _S2198;
            _S2198 = _S2188;
            for(;;)
            {
                bool _S2199 = c_48 < c1_1;
                uint _S2200 = __ballot_sync(_S2198, _S2199);
                if(_S2199)
                {
                    uint _S2201 = __ballot_sync(_S2198, true);
                }
                else
                {
                    uint _S2202 = __ballot_sync(_S2198, false);
                    uint _S2203 = __ballot_sync(_S2198, false);
                    uint _S2204 = __ballot_sync(_S2188, true);
                    _S2014 = _S2204;
                    break;
                }
                uint _S2205 = sv_0(c_48, 2U);
                float4  _S2206 = *(&(globalParams_0->scratch_0)[_S2205]);
                float4  _S2207 = *(&(globalParams_0->scratch_0)[sv_0(c_48, 8U)]);
                *(&(globalParams_0->scratch_0)[_S2205]) = make_float4 ((float3 {_S2206.x, _S2206.y, _S2206.z} + make_float3 (_S2197) * float3 {_S2207.x, _S2207.y, _S2207.z}).x, (float3 {_S2206.x, _S2206.y, _S2206.z} + make_float3 (_S2197) * float3 {_S2207.x, _S2207.y, _S2207.z}).y, (float3 {_S2206.x, _S2206.y, _S2206.z} + make_float3 (_S2197) * float3 {_S2207.x, _S2207.y, _S2207.z}).z, 0.0f);
                uint _S2208 = sv_0(c_48, 3U);
                float4  _S2209 = *(&(globalParams_0->scratch_0)[_S2208]);
                float4  _S2210 = *(&(globalParams_0->scratch_0)[sv_0(c_48, 9U)]);
                *(&(globalParams_0->scratch_0)[_S2208]) = make_float4 ((float3 {_S2209.x, _S2209.y, _S2209.z} + make_float3 (_S2197) * float3 {_S2210.x, _S2210.y, _S2210.z}).x, (float3 {_S2209.x, _S2209.y, _S2209.z} + make_float3 (_S2197) * float3 {_S2210.x, _S2210.y, _S2210.z}).y, (float3 {_S2209.x, _S2209.y, _S2209.z} + make_float3 (_S2197) * float3 {_S2210.x, _S2210.y, _S2210.z}).z, 0.0f);
                uint _S2211 = sv_0(c_48, 4U);
                float4  _S2212 = *(&(globalParams_0->scratch_0)[_S2211]);
                float4  _S2213 = *(&(globalParams_0->scratch_0)[sv_0(c_48, 10U)]);
                *(&(globalParams_0->scratch_0)[_S2211]) = make_float4 ((float3 {_S2212.x, _S2212.y, _S2212.z} - make_float3 (_S2197) * float3 {_S2213.x, _S2213.y, _S2213.z}).x, (float3 {_S2212.x, _S2212.y, _S2212.z} - make_float3 (_S2197) * float3 {_S2213.x, _S2213.y, _S2213.z}).y, (float3 {_S2212.x, _S2212.y, _S2212.z} - make_float3 (_S2197) * float3 {_S2213.x, _S2213.y, _S2213.z}).z, 0.0f);
                uint _S2214 = sv_0(c_48, 5U);
                float4  _S2215 = *(&(globalParams_0->scratch_0)[_S2214]);
                float4  _S2216 = *(&(globalParams_0->scratch_0)[sv_0(c_48, 11U)]);
                *(&(globalParams_0->scratch_0)[_S2214]) = make_float4 ((float3 {_S2215.x, _S2215.y, _S2215.z} - make_float3 (_S2197) * float3 {_S2216.x, _S2216.y, _S2216.z}).x, (float3 {_S2215.x, _S2215.y, _S2215.z} - make_float3 (_S2197) * float3 {_S2216.x, _S2216.y, _S2216.z}).y, (float3 {_S2215.x, _S2215.y, _S2215.z} - make_float3 (_S2197) * float3 {_S2216.x, _S2216.y, _S2216.z}).z, 0.0f);
                uint _S2217 = __ballot_sync(_S2198, true);
                c_48 = c_48 + 256U;
                _S2198 = _S2217;
            }
            uint _S2218 = 0U;
            __syncthreads();
            float _S2219 = island_dot_0(tid_18, c0_1, c1_1, 4U, 4U, _S2014);
            bool _S2220 = (F32_sqrt((_S2219))) <= (0.00009999999747379f * _S2151);
            uint _S2221 = __ballot_sync(_S2014, _S2220);
            if(_S2220)
            {
                uint _S2222 = __ballot_sync(_S2014, false);
                uint _S2223 = __ballot_sync(_S2152, false);
                uint _S2224 = __ballot_sync(_S2010, true);
                cg_total_0 = _S2190;
                i_27 = _S2224;
                break;
            }
            else
            {
                uint _S2225 = __ballot_sync(_S2014, true);
                _S2218 = _S2225;
            }
            uint c_49 = _S2024;
            uint _S2226;
            _S2226 = _S2218;
            for(;;)
            {
                bool _S2227 = c_49 < c1_1;
                uint _S2228 = __ballot_sync(_S2226, _S2227);
                if(_S2227)
                {
                    uint _S2229 = __ballot_sync(_S2226, true);
                }
                else
                {
                    uint _S2230 = __ballot_sync(_S2226, false);
                    uint _S2231 = __ballot_sync(_S2226, false);
                    uint _S2232 = __ballot_sync(_S2218, true);
                    _S2015 = _S2232;
                    break;
                }
                precondition_0(c_49);
                uint _S2233 = __ballot_sync(_S2226, true);
                c_49 = c_49 + 256U;
                _S2226 = _S2233;
            }
            __syncthreads();
            uint _S2234 = __ballot_sync(_S2015, free_0);
            uint _S2235;
            if(free_0)
            {
                Island_0 _S2236 = isl_22;
                project_displacement_slot_0(tid_18, &_S2236, 6U, _S2234);
                uint _S2237 = __ballot_sync(_S2015, true);
                _S2235 = _S2237;
            }
            else
            {
                uint _S2238 = __ballot_sync(_S2015, true);
                _S2235 = _S2238;
            }
            float _S2239 = island_dot_0(tid_18, c0_1, c1_1, 4U, 6U, _S2235);
            float _S2240 = _S2239 / rz_0;
            uint c_50 = _S2024;
            uint _S2241 = _S2235;
            for(;;)
            {
                bool _S2242 = c_50 < c1_1;
                uint _S2243 = __ballot_sync(_S2241, _S2242);
                if(_S2242)
                {
                    uint _S2244 = __ballot_sync(_S2241, true);
                }
                else
                {
                    uint _S2245 = __ballot_sync(_S2241, false);
                    uint _S2246 = __ballot_sync(_S2241, false);
                    uint _S2247 = __ballot_sync(_S2235, true);
                    break;
                }
                uint _S2248 = sv_0(c_50, 8U);
                float4  _S2249 = *(&(globalParams_0->scratch_0)[sv_0(c_50, 6U)]);
                float4  _S2250 = *(&(globalParams_0->scratch_0)[_S2248]);
                *(&(globalParams_0->scratch_0)[_S2248]) = make_float4 ((float3 {_S2249.x, _S2249.y, _S2249.z} + make_float3 (_S2240) * float3 {_S2250.x, _S2250.y, _S2250.z}).x, (float3 {_S2249.x, _S2249.y, _S2249.z} + make_float3 (_S2240) * float3 {_S2250.x, _S2250.y, _S2250.z}).y, (float3 {_S2249.x, _S2249.y, _S2249.z} + make_float3 (_S2240) * float3 {_S2250.x, _S2250.y, _S2250.z}).z, 0.0f);
                uint _S2251 = sv_0(c_50, 9U);
                float4  _S2252 = *(&(globalParams_0->scratch_0)[sv_0(c_50, 7U)]);
                float4  _S2253 = *(&(globalParams_0->scratch_0)[_S2251]);
                *(&(globalParams_0->scratch_0)[_S2251]) = make_float4 ((float3 {_S2252.x, _S2252.y, _S2252.z} + make_float3 (_S2240) * float3 {_S2253.x, _S2253.y, _S2253.z}).x, (float3 {_S2252.x, _S2252.y, _S2252.z} + make_float3 (_S2240) * float3 {_S2253.x, _S2253.y, _S2253.z}).y, (float3 {_S2252.x, _S2252.y, _S2252.z} + make_float3 (_S2240) * float3 {_S2253.x, _S2253.y, _S2253.z}).z, 0.0f);
                uint _S2254 = __ballot_sync(_S2241, true);
                c_50 = c_50 + 256U;
                _S2241 = _S2254;
            }
            __syncthreads();
            uint _S2255 = __ballot_sync(_S2152, true);
            uint _S2256 = k_21 + 1U;
            rz_0 = _S2239;
            k_21 = _S2256;
            cg_total_1 = _S2190;
            _S2152 = _S2255;
        }
        c_42 = _S2024;
        _S2011 = i_27;
        for(;;)
        {
            bool _S2257 = c_42 < c1_1;
            uint _S2258 = __ballot_sync(_S2011, _S2257);
            if(_S2257)
            {
                uint _S2259 = __ballot_sync(_S2011, true);
            }
            else
            {
                uint _S2260 = __ballot_sync(_S2011, false);
                uint _S2261 = __ballot_sync(_S2011, false);
                uint _S2262 = __ballot_sync(i_27, true);
                break;
            }
            uint _S2263 = 4U * c_42;
            float4  _S2264 = *(&(globalParams_0->state_0)[_S2263]);
            float3  u_4 = float3 {_S2264.x, _S2264.y, _S2264.z};
            uint _S2265 = sv_0(c_42, 21U);
            float4  _S2266 = *(&(globalParams_0->scratch_0)[_S2265]);
            float3  u_lo_0 = float3 {_S2266.x, _S2266.y, _S2266.z};
            uint _S2267 = _S2263 + 1U;
            float4  _S2268 = *(&(globalParams_0->state_0)[_S2267]);
            float3  th_6 = float3 {_S2268.x, _S2268.y, _S2268.z};
            uint _S2269 = sv_0(c_42, 22U);
            float4  _S2270 = *(&(globalParams_0->scratch_0)[_S2269]);
            float3  th_lo_0 = float3 {_S2270.x, _S2270.y, _S2270.z};
            float4  _S2271 = *(&(globalParams_0->scratch_0)[sv_0(c_42, 2U)]);
            comp_add_0(&u_4, &u_lo_0, float3 {_S2271.x, _S2271.y, _S2271.z});
            float4  _S2272 = *(&(globalParams_0->scratch_0)[sv_0(c_42, 3U)]);
            comp_add_0(&th_6, &th_lo_0, float3 {_S2272.x, _S2272.y, _S2272.z});
            *(&(globalParams_0->state_0)[_S2263]) = make_float4 (u_4.x, u_4.y, u_4.z, (*(&(globalParams_0->state_0)[_S2263])).w);
            *(&(globalParams_0->state_0)[_S2267]) = make_float4 (th_6.x, th_6.y, th_6.z, (*(&(globalParams_0->state_0)[_S2267])).w);
            *(&(globalParams_0->scratch_0)[_S2265]) = make_float4 (u_lo_0.x, u_lo_0.y, u_lo_0.z, 0.0f);
            *(&(globalParams_0->scratch_0)[_S2269]) = make_float4 (th_lo_0.x, th_lo_0.y, th_lo_0.z, 0.0f);
            uint _S2273 = __ballot_sync(_S2011, true);
            c_42 = c_42 + 256U;
            _S2011 = _S2273;
        }
        __syncthreads();
        uint _S2274 = newton_0 + 1U;
        uint _S2275 = __ballot_sync(c_43, true);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S2274;
        c_43 = _S2275;
    }
    i_26 = b0_0 + tid_18;
    for(;;)
    {
        if(i_26 < _S2023)
        {
        }
        else
        {
            break;
        }
        JointResponse_0 resp_2 = static_response_0(i_26);
        BondDyn_0 bd_1 = *(&(globalParams_0->bond_dyn_0)[i_26]);
        (&bd_1)->force_lin_0 = make_float4 (resp_2.force_lin_1.x, resp_2.force_lin_1.y, resp_2.force_lin_1.z, resp_2.stored_0);
        (&bd_1)->force_ang_0 = make_float4 (resp_2.force_ang_1.x, resp_2.force_ang_1.y, resp_2.force_ang_1.z, (&bd_1)->force_ang_0.w);
        *(&(globalParams_0->bond_dyn_0)[i_26]) = bd_1;
        write_bond_loads_0(i_26, i_26, resp_2.force_lin_1, resp_2.force_ang_1, (F32_max((resp_2.measures_0.tension_0), (resp_2.measures_0.compression_0))));
        i_26 = i_26 + 256U;
    }
    __syncthreads();
    c_42 = _S2024;
    for(;;)
    {
        if(c_42 < c1_1)
        {
        }
        else
        {
            break;
        }
        float3  fi_5;
        float3  mi_6;
        gather_loads_0(c_42, &fi_5, &mi_6);
        float3  reaction_1;
        if((fixed_mask_0(c_42)) != 0U)
        {
            float4  _S2276 = *(&(globalParams_0->scratch_0)[sv_0(c_42, 0U)]);
            reaction_1 = - (float3 {_S2276.x, _S2276.y, _S2276.z} + fi_5);
        }
        else
        {
            uint _S2277 = 4U * c_42;
            reaction_1 = make_float3 ((*(&(globalParams_0->state_0)[_S2277 + 1U])).w, (*(&(globalParams_0->state_0)[_S2277 + 2U])).w, (*(&(globalParams_0->state_0)[_S2277 + 3U])).w);
        }
        uint _S2278 = 4U * c_42;
        uint _S2279 = _S2278 + 1U;
        float4  _S2280 = *(&(globalParams_0->state_0)[_S2279]);
        *(&(globalParams_0->state_0)[_S2279]) = make_float4 (float3 {_S2280.x, _S2280.y, _S2280.z}.x, float3 {_S2280.x, _S2280.y, _S2280.z}.y, float3 {_S2280.x, _S2280.y, _S2280.z}.z, reaction_1.x);
        *(&(globalParams_0->state_0)[_S2278 + 2U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.y);
        *(&(globalParams_0->state_0)[_S2278 + 3U]) = make_float4 (0.0f, 0.0f, 0.0f, reaction_1.z);
        c_42 = c_42 + 256U;
    }
    if(tid_18 == 0U)
    {
        float4  * _S2281 = (&(globalParams_0->scratch_0)[statics_result_slot_0(_S2017)]);
        float _S2282 = (U32_asfloat((newton_0)));
        float _S2283 = (U32_asfloat((cg_total_0)));
        if(converged_4)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        *_S2281 = make_float4 (residual_0, _S2282, _S2283, previous_2);
        *&((&(&(globalParams_0->islands_0)[_S2017])->info_1)->z) = _S2019 & 4294967287U;
    }
    return;
}

extern "C" __global__ void settled_fatigue()
{
    uint tid_19 = threadIdx.x;
    uint _S2284 = blockIdx.x;
    Island_0 * _S2285 = (&(globalParams_0->islands_0)[_S2284]);
    Island_0 isl_23 = *_S2285;
    bool _S2286;
    if((((*_S2285).info_1.x) & 16U) == 0U)
    {
        _S2286 = true;
    }
    else
    {
        _S2286 = (isl_23.range_0.w) == (isl_23.range_0.z);
    }
    if(_S2286)
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
    uint _S2287 = isl_23.info_1.w;
    uint i_29 = isl_23.range_0.z + tid_19;
    for(;;)
    {
        if(i_29 < (isl_23.range_0.w))
        {
        }
        else
        {
            break;
        }
        BondStatic_0 * _S2288 = (&(globalParams_0->bonds_0)[i_29]);
        BondDyn_0 bd_2 = *(&(globalParams_0->bond_dyn_0)[i_29]);
        JointBond_0 _S2289 = slang_ldg_0(&_S2288->law_0);
        uint _S2290 = 4U * _S2289.ids_0.y;
        float4  _S2291 = *(&(globalParams_0->state_0)[_S2290]);
        float4  _S2292 = *(&(globalParams_0->state_0)[_S2290 + 1U]);
        uint _S2293 = 4U * _S2289.ids_0.z;
        float4  _S2294 = *(&(globalParams_0->state_0)[_S2293]);
        float4  _S2295 = *(&(globalParams_0->state_0)[_S2293 + 1U]);
        float3  d_lin_7;
        float3  d_ang_6;
        bond_kinematics_0(i_29, float3 {_S2291.x, _S2291.y, _S2291.z}, float3 {_S2292.x, _S2292.y, _S2292.z}, float3 {_S2294.x, _S2294.y, _S2294.z}, float3 {_S2295.x, _S2295.y, _S2295.z}, &d_lin_7, &d_ang_6);
        JointState_0 previous_3 = (&bd_2)->js_0;
        float3  _S2296 = d_lin_7;
        float3  _S2297 = d_ang_6;
        float _S2298 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2299 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S2300 = _S2299 != 0U;
        JointBond_0 _S2301 = _S2289;
        JointState_0 _S2302 = previous_3;
        JointResponse_0 _S2303 = joint_evaluate_0(&globalParams_0->materials_0->m_0[_S2289.ids_0.x], &_S2301, &_S2302, _S2296, _S2297, _S2298, _S2300);
        if((_S2303.state_1.damage_0) > (previous_3.damage_0 + 9.99999971718068537e-10f))
        {
            _S2286 = true;
        }
        else
        {
            _S2286 = (_S2303.state_1.crush_0) > (previous_3.crush_0 + 9.99999971718068537e-10f);
        }
        uint flags_3;
        if(_S2286)
        {
            flags_3 = 16U;
        }
        else
        {
            flags_3 = 0U;
        }
        comp_add1_0(&((&(&bd_2)->sums_0)->x), &((&(&bd_2)->comps_0)->x), _S2303.dissipated_1);
        comp_add1_0(&((&(&bd_2)->sums_0)->y), &((&(&bd_2)->comps_0)->y), _S2303.overshoot_0);
        (&bd_2)->force_lin_0 = make_float4 (_S2303.force_lin_1.x, _S2303.force_lin_1.y, _S2303.force_lin_1.z, _S2303.stored_0);
        (&bd_2)->force_ang_0 = make_float4 (_S2303.force_ang_1.x, _S2303.force_ang_1.y, _S2303.force_ang_1.z, (F32_max(((&bd_2)->force_ang_0.w), (_S2303.state_1.utilization_0))));
        JointState_0 _S2304 = previous_3;
        bool _S2305 = is_damaged_0(&_S2304);
        bool _S2306;
        if(!_S2305)
        {
            JointState_0 _S2307 = _S2303.state_1;
            bool _S2308 = is_damaged_0(&_S2307);
            _S2306 = _S2308;
        }
        else
        {
            _S2306 = false;
        }
        bool _S2309;
        if(_S2306)
        {
            _S2309 = ((&bd_2)->events_0.x) == 0U;
        }
        else
        {
            _S2309 = false;
        }
        if(_S2309)
        {
            *&((&(&bd_2)->events_0)->x) = _S2287;
            *&((&(&bd_2)->events_0)->w) = _S2303.state_1.mode_0;
            (*&g_seen_0)[3U] = 1U;
        }
        bool _S2310;
        if(((&bd_2)->events_0.y) == 0U)
        {
            _S2310 = (_S2303.state_1.life_0) != (previous_3.life_0);
        }
        else
        {
            _S2310 = false;
        }
        bool _S2311;
        if(_S2310)
        {
            _S2311 = (_S2303.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S2311 = false;
        }
        bool _S2312;
        if(_S2311)
        {
            float _S2313 = fatigue_factor_0(&globalParams_0->materials_0->m_0[_S2289.ids_0.x], _S2303.state_1.life_0);
            _S2312 = _S2313 <= 0.99000000953674316f;
        }
        else
        {
            _S2312 = false;
        }
        if(_S2312)
        {
            *&((&(&bd_2)->events_0)->y) = _S2287;
            (*&g_seen_0)[4U] = 1U;
        }
        uint flags_4;
        if(_S2303.disconnected_0)
        {
            *&((&(&bd_2)->events_0)->z) = _S2287;
            flags_4 = flags_3 | 32U;
        }
        else
        {
            flags_4 = flags_3;
        }
        (&bd_2)->js_0 = _S2303.state_1;
        *(&(globalParams_0->bond_dyn_0)[i_29]) = bd_2;
        write_bond_loads_0(i_29, i_29, _S2303.force_lin_1, _S2303.force_ang_1, (F32_max((_S2303.measures_0.tension_0), (_S2303.measures_0.compression_0))));
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
        uint _S2314 = isl_23.info_1.z;
        if((*&g_halt_0) != 0U)
        {
            i_29 = 16U;
        }
        else
        {
            i_29 = 0U;
        }
        uint _S2315 = _S2314 | i_29;
        if((*&g_run_0) != 0U)
        {
            i_29 = 32U;
        }
        else
        {
            i_29 = 0U;
        }
        *&((&(&(globalParams_0->islands_0)[_S2284])->info_1)->z) = _S2315 | i_29;
    }
    uint _S2316 = ((isl_23.coverage_0) | 16384U) | (seen_bits_0());
    if((*&g_run_0) != 0U)
    {
        i_29 = 128U;
    }
    else
    {
        i_29 = 0U;
    }
    (&(globalParams_0->islands_0)[_S2284])->coverage_0 = _S2316 | i_29;
    return;
}

static __device__ void impactor_integrate_at_0(uint ii_3, uint tid_20, uint _S2317)
{
    uint _S2318 = 0U;
    uint _S2319;
    float3  p_16;
    uint _S2320 = __ldg(&globalParams_0->params_0->impactor_count_0);
    bool _S2321 = ii_3 >= _S2320;
    uint _S2322 = __ballot_sync(_S2317, _S2321);
    if(_S2321)
    {
        return;
    }
    else
    {
        uint _S2323 = __ballot_sync(_S2317, true);
        _S2318 = _S2323;
    }
    uint _S2324 = __ldg(&globalParams_0->params_0->halt_index_0);
    Island_0 * _S2325 = (&(globalParams_0->islands_0)[_S2324]);
    Impactor_0 imp_6 = *(&(globalParams_0->impactors_0)[ii_3]);
    uint4  _S2326 = _S2325->info_1;
    bool _S2327 = ((_S2325->info_1.z) & 1U) != 0U;
    uint _S2328 = __ballot_sync(_S2318, _S2327);
    bool _S2329;
    uint k_22;
    if(_S2327)
    {
        uint _S2330 = __ballot_sync(_S2318, true);
        _S2329 = true;
        k_22 = _S2330;
    }
    else
    {
        uint _S2331 = _S2318 & (~_S2328);
        uint _S2332 = _S2326.y;
        bool _S2333 = _S2332 != 0U;
        uint _S2334 = __ballot_sync(_S2331, _S2333);
        if(_S2333)
        {
            bool _S2335 = ((&imp_6)->cand_0.w) >= _S2332;
            uint _S2336 = __ballot_sync(_S2331, true);
            _S2329 = _S2335;
        }
        else
        {
            uint _S2337 = __ballot_sync(_S2331, true);
            _S2329 = false;
        }
        uint _S2338 = __ballot_sync(_S2318, true);
        k_22 = _S2338;
    }
    uint _S2339 = 0U;
    uint _S2340 = __ballot_sync(k_22, _S2329);
    if(_S2329)
    {
        return;
    }
    else
    {
        uint _S2341 = __ballot_sync(k_22, true);
        _S2339 = _S2341;
    }
    uint _S2342 = 0U;
    bool _S2343 = ((&imp_6)->cand_0.z) != 0U;
    uint _S2344 = __ballot_sync(_S2339, _S2343);
    if(_S2343)
    {
        if(tid_20 == 0U)
        {
            *&((&(&(globalParams_0->impactors_0)[ii_3])->cand_0)->w) = (&imp_6)->cand_0.w + 1U;
        }
        return;
    }
    else
    {
        uint _S2345 = __ballot_sync(_S2339, true);
        _S2342 = _S2345;
    }
    float4  _S2346 = make_float4 (0.0f);
    float4  rf_1 = _S2346;
    float4  rt_0 = _S2346;
    k_22 = (&imp_6)->cand_0.x + tid_20;
    uint total_points_0;
    total_points_0 = _S2342;
    for(;;)
    {
        bool _S2347 = k_22 < ((&imp_6)->cand_0.y);
        uint _S2348 = __ballot_sync(total_points_0, _S2347);
        if(_S2347)
        {
            uint _S2349 = __ballot_sync(total_points_0, true);
        }
        else
        {
            uint _S2350 = __ballot_sync(total_points_0, false);
            uint _S2351 = __ballot_sync(total_points_0, false);
            uint _S2352 = __ballot_sync(_S2342, true);
            _S2319 = _S2352;
            break;
        }
        uint _S2353 = __ldg(&globalParams_0->params_0->cand_base_0);
        uint _S2354 = 3U * k_22;
        rf_1 = rf_1 + *(&(globalParams_0->scratch_0)[_S2353 + _S2354 + 1U]);
        uint _S2355 = __ldg(&globalParams_0->params_0->cand_base_0);
        rt_0 = rt_0 + *(&(globalParams_0->scratch_0)[_S2355 + _S2354 + 2U]);
        uint _S2356 = __ballot_sync(total_points_0, true);
        k_22 = k_22 + 256U;
        total_points_0 = _S2356;
    }
    group_sum2_0(tid_20, &rf_1, &rt_0, _S2319);
    bool _S2357 = tid_20 != 0U;
    uint _S2358 = __ballot_sync(_S2319, _S2357);
    if(_S2357)
    {
        return;
    }
    float _S2359 = __ldg(&globalParams_0->params_0->dt_0);
    float3  _S2360 = make_float3 (0.0f);
    uint _S2361 = __ldg(&globalParams_0->params_0->has_ground_0);
    float3  load_f_0;
    float3  load_t_0;
    if(_S2361 != 0U)
    {
        float4  _S2362 = (&imp_6)->half_1;
        float3  _S2363 = float3 {_S2362.x, _S2362.y, _S2362.z};
        Impactor_0 _S2364 = imp_6;
        Box_0 _S2365 = impactor_box_0(&_S2364, _S2360, _S2363);
        float4  _S2366 = (&imp_6)->velocity_1;
        float4  _S2367 = (&imp_6)->velocity_err_1;
        float3  _S2368 = float3 {_S2366.x, _S2366.y, _S2366.z} + float3 {_S2367.x, _S2367.y, _S2367.z};
        float _S2369 = __ldg(&globalParams_0->params_0->ground_modulus_0);
        float _S2370 = (&imp_6)->mat_0.x;
        float3  _S2371 = make_float3 (0.0f, 0.0f, 1.0f);
        Box_0 _S2372 = _S2365;
        Box_0 _S2373 = _S2365;
        float _S2374 = contact_stiffness_0(_S2369, &_S2372, _S2370, &_S2373, _S2371);
        float _S2375 = (&imp_6)->position_1.z;
        float _S2376 = __ldg(&globalParams_0->params_0->ground_hi_0);
        float _S2377 = _S2375 - _S2376;
        float _S2378 = (&imp_6)->position_err_1.z;
        float _S2379 = __ldg(&globalParams_0->params_0->ground_lo_0);
        float _S2380 = _S2377 + (_S2378 - _S2379);
        if(((&imp_6)->shape_0.x) == 0.0f)
        {
            total_points_0 = 1U;
        }
        else
        {
            total_points_0 = 14U;
        }
        float _S2381 = _S2374 / float((U32_min((total_points_0), (5U))));
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
                Box_0 _S2382 = _S2365;
                float3  _S2383 = sample_point_0(&_S2382, s_11);
                p_16 = _S2383;
            }
            if((_S2380 + p_16.z) < 0.0f)
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
        load_f_0 = _S2360;
        load_t_0 = _S2360;
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
                Box_0 _S2384 = _S2365;
                float3  _S2385 = sample_point_0(&_S2384, s_11);
                p_16 = _S2385;
            }
            float depth_3 = - (_S2380 + p_16.z);
            if(depth_3 <= 0.0f)
            {
                s_11 = s_11 + 1U;
                continue;
            }
            float4  _S2386 = (&imp_6)->angular_velocity_1;
            float3  v_12 = _S2368 + cross_0(float3 {_S2386.x, _S2386.y, _S2386.z}, p_16);
            float _S2387 = (&imp_6)->mat_0.z;
            float _S2388 = __ldg(&globalParams_0->params_0->ground_friction_0);
            float stored_7;
            float diss_5;
            float3  f_16 = penalty_force_0(_S2381, _S2387, _S2388, depth_3, _S2371, v_12, _S2359, below_0, &stored_7, &diss_5);
            float3  load_f_1 = load_f_0 + f_16;
            float3  load_t_1 = load_t_0 + cross_0(p_16, f_16);
            comp_add1_0(&((&(&imp_6)->ledger_0)->x), &((&(&imp_6)->ledger_0)->y), diss_5);
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_11 = s_11 + 1U;
        }
    }
    else
    {
        load_f_0 = _S2360;
        load_t_0 = _S2360;
    }
    float4  _S2389 = rf_1;
    float3  load_f_2 = float3 {_S2389.x, _S2389.y, _S2389.z} + load_f_0;
    float4  _S2390 = rt_0;
    float3  load_t_2 = float3 {_S2390.x, _S2390.y, _S2390.z} + load_t_0;
    float m_8 = (&imp_6)->mat_0.z;
    float4  _S2391 = (&imp_6)->velocity_1;
    float3  vel_2 = float3 {_S2391.x, _S2391.y, _S2391.z};
    float4  _S2392 = (&imp_6)->velocity_err_1;
    float3  vel_err_1 = float3 {_S2392.x, _S2392.y, _S2392.z};
    float3  _S2393 = load_f_2 / make_float3 (m_8);
    float4  _S2394 = __ldg(&globalParams_0->params_0->gravity_0);
    comp_add_0(&vel_2, &vel_err_1, (_S2393 + float3 {_S2394.x, _S2394.y, _S2394.z}) * make_float3 (_S2359));
    Quat_0 _S2395 = quat_of_0((&imp_6)->rotation_1);
    Quat_0 q_13 = _S2395;
    float4  q_err_0 = (&imp_6)->rotation_err_1;
    float4  _S2396 = (&imp_6)->momentum_1;
    float3  l_hi_0 = float3 {_S2396.x, _S2396.y, _S2396.z};
    float4  _S2397 = (&imp_6)->momentum_err_1;
    float3  l_err_1 = float3 {_S2397.x, _S2397.y, _S2397.z};
    comp_add_0(&l_hi_0, &l_err_1, load_t_2 * make_float3 (_S2359));
    float3  l_8 = l_hi_0 + l_err_1;
    Quat_0 _S2398 = _S2395;
    float3  _S2399 = world_mul_0(&_S2398, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_8);
    float4  _S2400 = (&imp_6)->position_1;
    float3  pos_1 = float3 {_S2400.x, _S2400.y, _S2400.z};
    float4  _S2401 = (&imp_6)->position_err_1;
    float3  pos_err_1 = float3 {_S2401.x, _S2401.y, _S2401.z};
    comp_add_0(&pos_1, &pos_err_1, (vel_2 + vel_err_1) * make_float3 (_S2359));
    turn_left_0(&q_13, &q_err_0, _S2399, _S2359);
    Quat_0 _S2402 = q_13;
    float3  _S2403 = world_mul_0(&_S2402, (&imp_6)->inv0_2, (&imp_6)->inv1_2, (&imp_6)->inv2_2, l_8);
    (&imp_6)->angular_velocity_1 = make_float4 (_S2403.x, _S2403.y, _S2403.z, 0.0f);
    Quat_0 _S2404 = q_13;
    float4  _S2405 = quat_vec_0(&_S2404);
    (&imp_6)->rotation_1 = _S2405;
    (&imp_6)->rotation_err_1 = q_err_0;
    (&imp_6)->momentum_1 = make_float4 (l_hi_0.x, l_hi_0.y, l_hi_0.z, 0.0f);
    (&imp_6)->momentum_err_1 = make_float4 (l_err_1.x, l_err_1.y, l_err_1.z, 0.0f);
    (&imp_6)->position_1 = make_float4 (pos_1.x, pos_1.y, pos_1.z, 0.0f);
    (&imp_6)->position_err_1 = make_float4 (pos_err_1.x, pos_err_1.y, pos_err_1.z, 0.0f);
    (&imp_6)->velocity_1 = make_float4 (vel_2.x, vel_2.y, vel_2.z, 0.0f);
    (&imp_6)->velocity_err_1 = make_float4 (vel_err_1.x, vel_err_1.y, vel_err_1.z, 0.0f);
    *&((&(&imp_6)->cand_0)->w) = *&((&(&imp_6)->cand_0)->w) + 1U;
    (&imp_6)->geom_0 = make_float4 (1.0f, (&imp_6)->crush_1.w, 0.0f, 0.0f);
    *(&(globalParams_0->impactors_0)[ii_3]) = imp_6;
    uint _S2406 = (&imp_6)->cand_0.w - 1U;
    uint _S2407 = __ldg(&globalParams_0->params_0->step_start_0);
    uint k_23 = _S2406 - _S2407;
    uint _S2408 = __ldg(&globalParams_0->params_0->record_stride_0);
    if(k_23 < _S2408)
    {
        uint _S2409 = __ldg(&globalParams_0->params_0->record_base_0);
        uint _S2410 = __ldg(&globalParams_0->params_0->record_stride_0);
        uint at_8 = _S2409 + 2U * (ii_3 * _S2410 + k_23);
        *(&(globalParams_0->scratch_0)[at_8]) = make_float4 ((vel_2 + vel_err_1).x, (vel_2 + vel_err_1).y, (vel_2 + vel_err_1).z, 0.0f);
        *(&(globalParams_0->scratch_0)[at_8 + 1U]) = make_float4 ((pos_1 + pos_err_1).x, (pos_1 + pos_err_1).y, (pos_1 + pos_err_1).z, 0.0f);
    }
    return;
}

extern "C" __global__ void impactor_integrate()
{
    uint _S2411 = __ballot_sync(4294967295U, true);
    impactor_integrate_at_0(blockIdx.x, threadIdx.x, _S2411);
    return;
}

static __device__ void ground_contact_0(uint c_51, bool account_0, float3  * f_17, float3  * t_15)
{
    ChunkStatic_0 * _S2412 = (&(globalParams_0->chunks_0)[c_51]);
    WorldPoint_0 wp_1 = chunk_world_0(c_51);
    float _S2413 = wp_1.hi_3.z;
    float _S2414 = __ldg(&globalParams_0->params_0->ground_hi_0);
    float _S2415 = _S2413 - _S2414;
    float _S2416 = wp_1.lo_3.z;
    float _S2417 = __ldg(&globalParams_0->params_0->ground_lo_0);
    float above_0 = _S2415 + (_S2416 - _S2417) + wp_1.rel_0.z;
    float4  _S2418 = __ldg(&_S2412->half_0);
    if((above_0 - _S2418.w) > 0.0f)
    {
        return;
    }
    Box_0 b_32 = chunk_box_0(c_51, make_float3 (0.0f));
    float _S2419 = __ldg(&globalParams_0->params_0->ground_modulus_0);
    float4  _S2420 = __ldg(&_S2412->cmat_0);
    float _S2421 = _S2420.x;
    float3  _S2422 = make_float3 (0.0f, 0.0f, 1.0f);
    Box_0 _S2423 = b_32;
    Box_0 _S2424 = b_32;
    float _S2425 = contact_stiffness_0(_S2419, &_S2423, _S2421, &_S2424, _S2422);
    Box_0 _S2426 = b_32;
    uint _S2427 = sample_count_0(&_S2426);
    uint s_12 = 0U;
    uint n_10 = 0U;
    for(;;)
    {
        if(s_12 < _S2427)
        {
        }
        else
        {
            break;
        }
        Box_0 _S2428 = b_32;
        float3  _S2429 = sample_point_0(&_S2428, s_12);
        if((above_0 + _S2429.z) < 0.0f)
        {
            n_10 = n_10 + 1U;
        }
        s_12 = s_12 + 1U;
    }
    if(n_10 == 0U)
    {
        return;
    }
    sentinel_mark_0(4U);
    float3  vc_1;
    float3  wc_1;
    chunk_velocity_0(c_51, &vc_1, &wc_1);
    uint _S2430 = __ldg(&globalParams_0->params_0->ledger_base_0);
    uint _S2431 = __ldg(&globalParams_0->params_0->pair_count_0);
    float4  ledger_2 = *(&(globalParams_0->scratch_0)[_S2430 + _S2431 + c_51]);
    s_12 = 0U;
    for(;;)
    {
        if(s_12 < _S2427)
        {
        }
        else
        {
            break;
        }
        Box_0 _S2432 = b_32;
        float3  _S2433 = sample_point_0(&_S2432, s_12);
        float _S2434 = above_0 + _S2433.z;
        if(!(_S2434 < 0.0f))
        {
            s_12 = s_12 + 1U;
            continue;
        }
        float depth_4 = - _S2434;
        float3  v_13 = vc_1 + cross_0(wc_1, _S2433);
        float _S2435 = _S2425 / float((U32_max((n_10), (5U))));
        float4  _S2436 = __ldg(&_S2412->center_0);
        float _S2437 = _S2436.w;
        float _S2438 = __ldg(&globalParams_0->params_0->ground_friction_0);
        float _S2439 = __ldg(&globalParams_0->params_0->dt_0);
        float stored_8;
        float diss_6;
        float3  g_2 = penalty_force_0(_S2435, _S2437, _S2438, depth_4, _S2422, v_13, _S2439, n_10, &stored_8, &diss_6);
        *f_17 = *f_17 + g_2;
        *t_15 = *t_15 + cross_0(_S2433, g_2);
        comp_add1_0(&((&ledger_2)->y), &((&ledger_2)->z), diss_6);
        s_12 = s_12 + 1U;
    }
    if(account_0)
    {
        uint _S2440 = __ldg(&globalParams_0->params_0->ledger_base_0);
        uint _S2441 = __ldg(&globalParams_0->params_0->pair_count_0);
        *(&(globalParams_0->scratch_0)[_S2440 + _S2441 + c_51]) = ledger_2;
    }
    return;
}

static __device__ void contact_sum_at_0(uint g_3)
{
    uint _S2442 = __ldg(&globalParams_0->params_0->seg_count_0);
    bool _S2443;
    if(g_3 >= _S2442)
    {
        _S2443 = true;
    }
    else
    {
        _S2443 = stopped_0();
    }
    if(_S2443)
    {
        return;
    }
    uint _S2444 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S2445 = 3U * g_3;
    uint _S2446 = __ldg((&(globalParams_0->index_0)[_S2444 + _S2445]));
    uint _S2447 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S2448 = __ldg((&(globalParams_0->index_0)[_S2447 + _S2445 + 1U]));
    uint _S2449 = __ldg(&globalParams_0->params_0->seg_index_0);
    uint _S2450 = __ldg((&(globalParams_0->index_0)[_S2449 + _S2445 + 2U]));
    float3  _S2451 = make_float3 (0.0f);
    float3  f_18 = _S2451;
    float3  t_16 = _S2451;
    uint e_8 = _S2448;
    for(;;)
    {
        if(e_8 < _S2450)
        {
        }
        else
        {
            break;
        }
        uint _S2452 = __ldg((&(globalParams_0->index_0)[e_8]));
        if(_S2452 == 2147483648U)
        {
            ground_contact_0(_S2446, true, &f_18, &t_16);
            e_8 = e_8 + 1U;
            continue;
        }
        uint _S2453 = __ldg(&globalParams_0->params_0->slot_base_0);
        uint _S2454 = 2U * _S2452;
        float4  _S2455 = *(&(globalParams_0->scratch_0)[_S2453 + _S2454]);
        f_18 = f_18 + float3 {_S2455.x, _S2455.y, _S2455.z};
        uint _S2456 = __ldg(&globalParams_0->params_0->slot_base_0);
        float4  _S2457 = *(&(globalParams_0->scratch_0)[_S2456 + _S2454 + 1U]);
        t_16 = t_16 + float3 {_S2457.x, _S2457.y, _S2457.z};
        e_8 = e_8 + 1U;
    }
    uint _S2458 = __ldg(&globalParams_0->params_0->seg_base_0);
    uint _S2459 = 2U * g_3;
    *(&(globalParams_0->scratch_0)[_S2458 + _S2459]) = make_float4 (f_18.x, f_18.y, f_18.z, 0.0f);
    uint _S2460 = __ldg(&globalParams_0->params_0->seg_base_0);
    *(&(globalParams_0->scratch_0)[_S2460 + _S2459 + 1U]) = make_float4 (t_16.x, t_16.y, t_16.z, 0.0f);
    return;
}

extern "C" __global__ void contact_sums()
{
    contact_sum_at_0((blockIdx * blockDim + threadIdx).x);
    return;
}

extern "C" __global__ void island_frame()
{
    uint _S2461 = __ballot_sync(4294967295U, true);
    island_frame_at_1(blockIdx.x, threadIdx.x, _S2461);
    return;
}

extern "C" __global__ void contact_islands()
{
    uint _S2462 = __ballot_sync(4294967295U, true);
    island_frame_at_0(blockIdx.x, threadIdx.x, _S2462);
    return;
}

static __device__ void wide_chunks_at_0(uint gx_0, uint tid_21, uint _S2463)
{
    uint _S2464 = 0U;
    uint _S2465 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
    WideGroup_0 wg_5 = wide_group_0(_S2465, gx_0);
    Island_0 isl_24 = *(&(globalParams_0->islands_0)[wg_5.island_2]);
    bool _S2466 = wide_enter_1(tid_21, wg_5.island_2);
    bool _S2467 = !_S2466;
    uint _S2468 = __ballot_sync(_S2463, _S2467);
    if(_S2467)
    {
        return;
    }
    else
    {
        uint _S2469 = __ballot_sync(_S2463, true);
        _S2464 = _S2469;
    }
    uint _S2470 = 0U;
    uint _S2471 = isl_24.info_1.x;
    bool anchored_0 = (_S2471 & 1U) != 0U;
    bool _S2472 = (_S2471 & 16U) != 0U;
    uint _S2473 = __ballot_sync(_S2464, _S2472);
    if(_S2472)
    {
        if(tid_21 == 0U)
        {
            uint _S2474 = __ldg(&globalParams_0->params_0->wide_base_0);
            *(&(globalParams_0->scratch_0)[_S2474 + 8U * gx_0 + 6U]) = make_float4 (0.0f);
        }
        return;
    }
    else
    {
        uint _S2475 = __ballot_sync(_S2464, true);
        _S2470 = _S2475;
    }
    Island_0 _S2476 = isl_24;
    WideGroup_0 _S2477 = wg_5;
    Rigid_0 _S2478 = wide_rigid_frame_0(tid_21, &_S2476, &_S2477, _S2470);
    float work_5 = 0.0f;
    float work_err_3 = 0.0f;
    float3  _S2479 = make_float3 (0.0f);
    float3  tu_5 = _S2479;
    float3  pv_5 = _S2479;
    uint c_52 = wg_5.begin_0 + tid_21;
    bool _S2480 = c_52 < (wg_5.end_0);
    uint _S2481 = __ballot_sync(_S2470, _S2480);
    uint _S2482;
    if(_S2480)
    {
        float _S2483 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2484 = __ldg(&globalParams_0->params_0->rigid_motion_loads_0);
        bool _S2485 = _S2484 != 0U;
        Island_0 _S2486 = isl_24;
        uint _S2487 = wide_step_0(&_S2486);
        bool _S2488 = (_S2471 & 4U) != 0U;
        Island_0 _S2489 = isl_24;
        Rigid_0 _S2490 = _S2478;
        chunk_update_0(c_52, &_S2489, &_S2490, _S2483, _S2485, _S2487, _S2488, &work_5, &work_err_3);
        bool _S2491 = !anchored_0;
        uint _S2492 = __ballot_sync(_S2481, _S2491);
        if(_S2491)
        {
            drift_moments_0(c_52, &tu_5, &pv_5);
            uint _S2493 = __ballot_sync(_S2481, true);
        }
        else
        {
            uint _S2494 = __ballot_sync(_S2481, true);
        }
        uint _S2495 = __ballot_sync(_S2470, true);
        _S2482 = _S2495;
    }
    else
    {
        uint _S2496 = __ballot_sync(_S2470, true);
        _S2482 = _S2496;
    }
    float3  wsum_2 = make_float3 (work_5, work_err_3, 0.0f);
    float3  unused_5 = _S2479;
    group_sum3_0(tid_21, &wsum_2, &unused_5, _S2482);
    bool _S2497 = !anchored_0;
    uint _S2498 = __ballot_sync(_S2482, _S2497);
    if(_S2497)
    {
        group_sum3_0(tid_21, &tu_5, &pv_5, _S2498);
        uint _S2499 = __ballot_sync(_S2482, true);
    }
    if(tid_21 == 0U)
    {
        uint _S2500 = __ldg(&globalParams_0->params_0->wide_base_0);
        uint _S2501 = 8U * gx_0;
        *(&(globalParams_0->scratch_0)[_S2500 + _S2501 + 6U]) = make_float4 (wsum_2.x, wsum_2.y, wsum_2.z, 0.0f);
        if(_S2497)
        {
            wide_store_0(gx_0, 2U, tu_5, pv_5);
        }
        uint _S2502 = __ldg(&globalParams_0->params_0->wide_base_0);
        *(&(globalParams_0->scratch_0)[_S2502 + _S2501 + 7U]) = make_float4 (float((*&g_seen_0)[0U]), float((*&g_seen_0)[1U]), float((*&g_seen_0)[2U]), 0.0f);
    }
    return;
}

extern "C" __global__ void wide_chunks()
{
    uint _S2503 = __ballot_sync(4294967295U, true);
    wide_chunks_at_0(blockIdx.x, threadIdx.x, _S2503);
    return;
}

extern "C" __global__ void sums_and_impactors()
{
    uint _S2504 = __ballot_sync(4294967295U, true);
    uint _S2505 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_0 = (_S2505 + 255U) / 256U;
    uint _S2506 = blockIdx.x;
    bool _S2507 = _S2506 < sums_groups_0;
    uint _S2508 = __ballot_sync(_S2504, _S2507);
    if(_S2507)
    {
        contact_sum_at_0(_S2506 * 256U + threadIdx.x);
    }
    else
    {
        impactor_integrate_at_0(_S2506 - sums_groups_0, threadIdx.x, _S2504 & (~_S2508));
        uint _S2509 = __ballot_sync(_S2504, true);
    }
    return;
}

extern "C" __global__ void islands_and_wide_chunks()
{
    uint _S2510 = __ballot_sync(4294967295U, true);
    uint _S2511 = blockIdx.x;
    uint _S2512 = __ldg(&globalParams_0->params_0->halt_index_0);
    bool _S2513 = _S2511 < _S2512;
    uint _S2514 = __ballot_sync(_S2510, _S2513);
    if(_S2513)
    {
        island_frame_at_1(_S2511, threadIdx.x, _S2514);
        uint _S2515 = __ballot_sync(_S2510, true);
    }
    else
    {
        uint _S2516 = _S2510 & (~_S2514);
        uint _S2517 = __ldg(&globalParams_0->params_0->halt_index_0);
        wide_chunks_at_0(_S2511 - _S2517, threadIdx.x, _S2516);
        uint _S2518 = __ballot_sync(_S2510, true);
    }
    return;
}

extern "C" __global__ void contact_islands_and_wide_chunks()
{
    uint _S2519 = __ballot_sync(4294967295U, true);
    uint _S2520 = blockIdx.x;
    uint _S2521 = __ldg(&globalParams_0->params_0->halt_index_0);
    bool _S2522 = _S2520 < _S2521;
    uint _S2523 = __ballot_sync(_S2519, _S2522);
    if(_S2522)
    {
        island_frame_at_0(_S2520, threadIdx.x, _S2523);
        uint _S2524 = __ballot_sync(_S2519, true);
    }
    else
    {
        uint _S2525 = _S2519 & (~_S2523);
        uint _S2526 = __ldg(&globalParams_0->params_0->halt_index_0);
        wide_chunks_at_0(_S2520 - _S2526, threadIdx.x, _S2525);
        uint _S2527 = __ballot_sync(_S2519, true);
    }
    return;
}

static __device__ void wide_bonds_at_0(uint gx_1, uint tid_22, uint _S2528)
{
    uint _S2529 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
    bool bond_group_0 = gx_1 < _S2529;
    uint _S2530 = __ballot_sync(_S2528, bond_group_0);
    WideGroup_0 wg_6;
    uint _S2531;
    if(bond_group_0)
    {
        uint _S2532 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
        WideGroup_0 _S2533 = wide_group_0(_S2532, gx_1);
        uint _S2534 = __ballot_sync(_S2528, true);
        wg_6 = _S2533;
        _S2531 = _S2534;
    }
    else
    {
        uint _S2535 = __ldg(&globalParams_0->params_0->wide_chunk_table_0);
        uint _S2536 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        WideGroup_0 _S2537 = wide_group_0(_S2535, gx_1 - _S2536);
        uint _S2538 = __ballot_sync(_S2528, true);
        wg_6 = _S2537;
        _S2531 = _S2538;
    }
    uint _S2539 = 0U;
    WideGroup_0 _S2540 = wg_6;
    Island_0 isl_25 = *(&(globalParams_0->islands_0)[wg_6.island_2]);
    bool _S2541 = wide_enter_1(tid_22, wg_6.island_2);
    bool _S2542 = !_S2541;
    uint _S2543 = __ballot_sync(_S2531, _S2542);
    if(_S2542)
    {
        return;
    }
    else
    {
        uint _S2544 = __ballot_sync(_S2531, true);
        _S2539 = _S2544;
    }
    uint _S2545 = 0U;
    Island_0 _S2546 = isl_25;
    uint _S2547 = wide_step_0(&_S2546);
    uint _S2548 = __ballot_sync(_S2539, bond_group_0);
    if(bond_group_0)
    {
        if(((isl_25.info_1.x) & 16U) != 0U)
        {
            return;
        }
        uint i_30 = wg_6.begin_0 + tid_22;
        bool _S2549;
        if(i_30 < (wg_6.end_0))
        {
            float _S2550 = __ldg(&globalParams_0->params_0->dt_0);
            uint _S2551 = __ldg(&globalParams_0->params_0->fracture_0);
            bool _S2552 = bond_update_0(i_30, _S2550, _S2551 != 0U, isl_25.info_1.w + 1U, true);
            _S2549 = _S2552;
        }
        else
        {
            _S2549 = false;
        }
        if(_S2549)
        {
            *&((&(&(globalParams_0->islands_0)[_S2540.island_2])->info_1)->z) = (isl_25.info_1.z) | 2U;
        }
        return;
    }
    else
    {
        uint _S2553 = __ballot_sync(_S2539, true);
        _S2545 = _S2553;
    }
    uint _S2554 = 0U;
    uint _S2555 = isl_25.info_1.x;
    bool _S2556 = (_S2555 & 1U) != 0U;
    uint _S2557 = __ballot_sync(_S2545, _S2556);
    if(_S2556)
    {
        return;
    }
    else
    {
        uint _S2558 = __ballot_sync(_S2545, true);
        _S2554 = _S2558;
    }
    float3  _S2559 = make_float3 (0.0f);
    float3  f_19 = _S2559;
    float3  t_17 = _S2559;
    uint c_53 = wg_6.begin_0 + tid_22;
    bool _S2560 = c_53 < (wg_6.end_0);
    uint _S2561 = __ballot_sync(_S2554, _S2560);
    if(_S2560)
    {
        Island_0 _S2562 = isl_25;
        Rigid_0 _S2563 = rigid_of_0(&_S2562);
        float _S2564 = __ldg(&globalParams_0->params_0->dt_0);
        bool _S2565 = (_S2555 & 4U) != 0U;
        Island_0 _S2566 = isl_25;
        Rigid_0 _S2567 = _S2563;
        net_load_0(c_53, &_S2566, &_S2567, _S2547, _S2564, _S2565, &f_19, &t_17);
        uint _S2568 = __ballot_sync(_S2554, true);
        _S2531 = _S2568;
    }
    else
    {
        uint _S2569 = __ballot_sync(_S2554, true);
        _S2531 = _S2569;
    }
    group_sum3_0(tid_22, &f_19, &t_17, _S2531);
    bool _S2570 = tid_22 == 0U;
    uint _S2571 = __ballot_sync(_S2531, _S2570);
    if(_S2570)
    {
        uint _S2572 = __ldg(&globalParams_0->params_0->wide_bond_groups_0);
        wide_store_0(gx_1 - _S2572, 0U, f_19, t_17);
    }
    return;
}

extern "C" __global__ void wide_bonds()
{
    uint _S2573 = __ballot_sync(4294967295U, true);
    wide_bonds_at_0(blockIdx.x, threadIdx.x, _S2573);
    return;
}

static __device__ void bond_group_at_0(uint table_1, uint gx_2, uint tid_23)
{
    WideGroup_0 wg_7 = wide_group_0(table_1, gx_2);
    Island_0 isl_26 = *(&(globalParams_0->islands_0)[wg_7.island_2]);
    bool _S2574 = wide_enter_1(tid_23, wg_7.island_2);
    bool _S2575;
    if(!_S2574)
    {
        _S2575 = true;
    }
    else
    {
        _S2575 = ((isl_26.info_1.x) & 16U) != 0U;
    }
    if(_S2575)
    {
        return;
    }
    uint i_31 = wg_7.begin_0 + tid_23;
    if(i_31 < (wg_7.end_0))
    {
        float _S2576 = __ldg(&globalParams_0->params_0->dt_0);
        uint _S2577 = __ldg(&globalParams_0->params_0->fracture_0);
        bool _S2578 = bond_update_0(i_31, _S2576, _S2577 != 0U, isl_26.info_1.w + 1U, true);
        _S2575 = _S2578;
    }
    else
    {
        _S2575 = false;
    }
    if(_S2575)
    {
        *&((&(&(globalParams_0->islands_0)[wg_7.island_2])->info_1)->z) = (isl_26.info_1.z) | 2U;
    }
    return;
}

extern "C" __global__ void sums_impactors_bonds()
{
    uint _S2579 = __ballot_sync(4294967295U, true);
    uint _S2580 = __ldg(&globalParams_0->params_0->seg_count_0);
    uint sums_groups_1 = (_S2580 + 255U) / 256U;
    uint _S2581 = __ldg(&globalParams_0->params_0->impactor_count_0);
    uint _S2582 = (U32_max((_S2581), (1U)));
    uint _S2583 = blockIdx.x;
    bool _S2584 = _S2583 < sums_groups_1;
    uint _S2585 = __ballot_sync(_S2579, _S2584);
    if(_S2584)
    {
        contact_sum_at_0(_S2583 * 256U + threadIdx.x);
    }
    else
    {
        uint _S2586 = _S2579 & (~_S2585);
        bool _S2587 = _S2583 < (sums_groups_1 + _S2582);
        uint _S2588 = __ballot_sync(_S2586, _S2587);
        if(_S2587)
        {
            impactor_integrate_at_0(_S2583 - sums_groups_1, threadIdx.x, _S2588);
            uint _S2589 = __ballot_sync(_S2586, true);
        }
        else
        {
            uint gb_0 = _S2583 - sums_groups_1 - _S2582;
            uint _S2590 = __ldg(&globalParams_0->params_0->contact_bond_groups_0);
            bool narrow_0 = gb_0 < _S2590;
            uint _S2591;
            if(narrow_0)
            {
                uint _S2592 = __ldg(&globalParams_0->params_0->contact_bond_table_0);
                _S2591 = _S2592;
            }
            else
            {
                uint _S2593 = __ldg(&globalParams_0->params_0->wide_bond_table_0);
                _S2591 = _S2593;
            }
            uint _S2594;
            if(narrow_0)
            {
                _S2594 = gb_0;
            }
            else
            {
                uint _S2595 = __ldg(&globalParams_0->params_0->contact_bond_groups_0);
                _S2594 = gb_0 - _S2595;
            }
            bond_group_at_0(_S2591, _S2594, threadIdx.x);
        }
    }
    return;
}

